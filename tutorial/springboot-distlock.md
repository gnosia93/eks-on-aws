분산락이란 race condition 상태에서 공유자원에 접근할 때, 데이터 무결성을 지키기 위해 어떠한 오퍼레이션의 원자성(atomic)을 보장하는 기법이다.   
ElastiCache For Redis 를 활용해서 제한이 설정된 판매 및 재고수량 관리시 분산락 기법을 활용할 수 있다.   
데이터베이스로도 관리할 수 있으나 트랜잭션 관리에 초점을 두고 있는 RDMS 시스템들은 Redis 와 같은 캐쉬 시스템에 비해서 처리 속도가 상당히 느린편이고, DeadLock이 발생할 가능성이 있다. (select ~ for update)

### 로컬 PC 에 Redis 설치 ###

```
docker pull redis

docker images

docker run --name my-redis -p 6379:6379 -d redis
```
Redis 동작여부를 확인한다.
```
% docker ps -a | grep my-redis
2465999b7f47   redis                           "docker-entrypoint.s…"   8 seconds ago   Up 8 seconds                0.0.0.0:6379->6379/tcp   my-redis

% docker exec -it my-redis /bin/bash
root@2465999b7f47:/data# redis-cli
127.0.0.1:6379> ping
PONG
127.0.0.1:6379>
```

### build.gradle ###

redisson 패키지 의존성을 추가한다.
```
dependencies {
	implementation 'org.redisson:redisson-spring-boot-starter:3.23.4'
	...
```

### application-dev.yaml ###
아래와 같이 redis 설정을 넣어준다.
```
server:
  port: 8080
spring:
  application:
    name: springboot-shop-dev
  jpa:
#    database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
#    hibernate:
#      ddl-auto: update
#      naming:
#        physical-strategy: org.hibernate.boot.model.naming.PhysicalNamingStrategyStandardImpl
#    generate-ddl: false
    show-sql: true
    properties:
      hibernate:
        format_sql: true

  datasource:
    url: jdbc:mysql://localhost:3306/shop
    username: shop
    password: shop
    driver-class-name: com.mysql.cj.jdbc.Driver

  redis:
      host: localhost
      port: 6379
      
logging.level.root : info

msa.service.endpoint.prod : "http://localhost:3001/prod"
msa.service.endpoint.point: "http://localhost:3000/point"
```

### RedissonConfiguration ###
```
package com.example.shop.configuration;

import lombok.Getter;
import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Getter
@Configuration
public class RedissonConfiguration {

    @Value( "${spring.redis.host}" )
    private String host;

    @Value( "${spring.redis.port}" )
    private int port;

    @Bean
    public RedissonClient redissonClient(){
        Config config = new Config();
        config.useSingleServer()
                .setAddress("redis://"+ this.host+":"+ this.port);

        return Redisson.create(config);
    }
}
```

### ProductController.java ###
```
package com.example.shop.controller;

import com.example.shop.service.ProductService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;

@Slf4j
@RequiredArgsConstructor
@RequestMapping(value="/product")
@RestController
public class ProductController {

    private final ProductService productService;

    @ResponseBody
    @RequestMapping(value="/sellCount/productId={productId}&count={count}", method=RequestMethod.PUT)
    public ResponseEntity<?> updateSellCount(@PathVariable int productId,
                                  @PathVariable int count) {
        productService.increaseSellCount(productId, count);
        int productSellCount = productService.getProductSellCount(productId);

        HashMap<String, Object> productResponse = new HashMap<String, Object>();
        productResponse.put("sellCount", productSellCount);

        return ResponseEntity.status(HttpStatus.OK).body(productResponse);
    }
}
```

### ProductService.java ###
```
package com.example.shop.service;


import com.example.shop.configuration.RedissonConfiguration;
import com.example.shop.exception.ProductSoldOutException;
import com.example.shop.exception.ProductTryLockFail;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.redisson.api.RLock;
import org.redisson.api.RedissonClient;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProductService {

    private final RedissonClient redissonClient;
    private final RedissonConfiguration redissonConfiguration;
    private static final int MAX_SELLABLE_COUNT = 30;		// 최대 판매수량을 상품별로 30개로 설정


    public String getLockName(int productId){
        final String prefix = "%s-lock";
        return String.format(prefix, productId);
    }

    public String getKey(int productId) {
        return String.valueOf(productId);
    }

    // 판매수량을 증가시키는 함수 
    public void increaseSellCount(final int productId, final int count){
        final String key = getKey(productId);
        final String lockName = getLockName(productId);
        final RLock lock = redissonClient.getLock(lockName);
        final String worker = Thread.currentThread().getName();

        int currentSellCount;
        try {
            if(!lock.tryLock(1, 3, TimeUnit.SECONDS))        			// 1초동안 분산락을 여러번 획득시도 / 실패하는 경우 예외 처리
                throw new ProductTryLockFail();
                //return;

            currentSellCount = getCurrentSellCount(key);     			// 현재 판매수량 조회
            if(currentSellCount + count > MAX_SELLABLE_COUNT) {			// 판매 가능여부 체크
                log.info("[{}] 모두 팔렸음!!! ({}개)", worker, currentSellCount + count);
                throw new ProductSoldOutException();
                //return;
            }

            setSellCount(key, currentSellCount + count);			// 판매수량 업데이트
            log.info("현재 진행중인 사람 : {} & 현재 팔린 갯수 : {}개", worker, currentSellCount + count);

        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            if(lock != null && lock.isLocked() && lock.isHeldByCurrentThread()) {
                lock.unlock();							// 분산락 해제
            }
        }
    }

    public void setSellCount(String key, int amount){

        redissonClient.getBucket(key).set(amount);
    }

    public int getCurrentSellCount(String key) {
        if(redissonClient.getBucket(key).get() == null)
            return 0;

        return (int) redissonClient.getBucket(key).get();
    }

    public int getProductSellCount(int productId) {
        return getCurrentSellCount(getKey(productId));
    }
}
```

## 레퍼런스 ##

* https://incheol-jung.gitbook.io/docs/q-and-a/spring/redisson-trylock
* https://github.com/hgs-study/distributed-lock-practice/tree/master
* https://wildeveloperetrain.tistory.com/280
* https://kkambi.tistory.com/196
* [재고시스템으로 알아보는 동시성이슈 해결방법](https://thalals.tistory.com/370)
* https://lktprogrammer.tistory.com/42
