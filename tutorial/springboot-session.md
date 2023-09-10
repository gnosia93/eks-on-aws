
### admin 유저 생성 ###
cloud9 터미널에서 아래 명령어를 수행한다. 
```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
echo ${DB_ADDR}

mysql -u shop -p -h ${DB_ADDR}
```

```
mysql> use shop;
mysql> insert into member(password, name, phone_no, email_addr) values('admin', 'admin', '000-000-0000', 'admin@shop.com');
mysql> commit;
mysql> select member_id, password, email_addr from member where email_addr = 'admin@shop.com';
```

### redis cli 설치 ###
로컬 PC 에 redis cli 를 설치한다.
```
brew install redis
```

### build.gradle ###

```
implementation 'org.springframework.boot:spring-boot-starter-data-redis'
implementation 'org.springframework.session:spring-session-data-redis'
```

### application.yaml ###
```
  redis:
      host: localhost
      port: 6379
  session:
      store-type:redis
```

### RedissonCongiruation ###
@EnableRedisRepositories 어노테이션 추가 
```
package com.example.shop.configuration;

import lombok.Getter;
import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.data.redis.repository.configuration.EnableRedisRepositories;

@Getter
@Configuration
@EnableRedisRepositories
@Profile({"!test"})
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


## 레퍼런스 ##

* https://chb2005.tistory.com/173
* https://stir.tistory.com/256
* https://moonsiri.tistory.com/27
* [레디스 명령어](https://devhj.tistory.com/26)
