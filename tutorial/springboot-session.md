
### 테스트용 유저 생성 ###
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
mysql> insert into member(password, name, phone_no, email_addr) values('admin1', 'admin1', '111-000-0000', 'admin1@shop.com');
mysql> insert into member(password, name, phone_no, email_addr) values('admin2', 'admin2', '222-000-0000', 'admin2@shop.com');
mysql> insert into member(password, name, phone_no, email_addr) values('admin3', 'admin3', '333-000-0000', 'admin3@shop.com');
mysql> commit;
mysql> select member_id, password, email_addr from member where email_addr = 'admin@shop.com';
```
[결과]
```
+-----------+----------+----------------+
| member_id | password | email_addr     |
+-----------+----------+----------------+
|    485413 | admin    | admin@shop.com |
+-----------+----------+----------------+
1 row in set (0.10 sec)
```

### redis cli 설치 ###
로컬 PC 에 redis cli 를 설치한다.
```
brew install redis
```
```
127.0.0.1:6379> keys *
1) "spring:session:sessions:f34bc2bb-d3f9-4bcb-bbc8-3da51955885a"

127.0.0.1:6379> hgetall "spring:session:sessions:f34bc2bb-d3f9-4bcb-bbc8-3da51955885a"
1) "creationTime"
2) "\xac\xed\x00\x05sr\x00\x0ejava.lang.Long;\x8b\xe4\x90\xcc\x8f#\xdf\x02\x00\x01J\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\x01\x8a\x7f\x01\xd3\x9f"
3) "lastAccessedTime"
4) "\xac\xed\x00\x05sr\x00\x0ejava.lang.Long;\x8b\xe4\x90\xcc\x8f#\xdf\x02\x00\x01J\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\x01\x8a\x7f\x01\xe8\x9b"
5) "maxInactiveInterval"
6) "\xac\xed\x00\x05sr\x00\x11java.lang.Integer\x12\xe2\xa0\xa4\xf7\x81\x878\x02\x00\x01I\x00\x05valuexr\x00\x10java.lang.Number\x86\xac\x95\x1d\x0b\x94\xe0\x8b\x02\x00\x00xp\x00\x00\a\b"
7) "sessionAttr:emailAddress"
8) "\xac\xed\x00\x05t\x00\x0eadmin@shop.com"
```

#### [참고] ####
Redis support 5 types of data types. You need to know what type of value that key maps to, as for each data type, the command to retrieve it is different.

```
Here are the commands to retrieve key value:

if value is of type string -> GET <key>
if value is of type hash -> HGETALL <key>
if value is of type lists -> lrange <key> <start> <end>
if value is of type sets -> smembers <key>
if value is of type sorted sets -> ZRANGEBYSCORE <key> <min> <max>
command to check the type of value a key mapping to:

type <key>
```

### build.gradle ###
* https://github.com/redisson/redisson/wiki/14.-Integration-with-frameworks/
```
implementation 'org.springframework.session:spring-session-data-redis'
implementation 'org.springframework.boot:spring-boot-starter-data-redis'
implementation 'org.springframework.session:spring-session-core:3.0.1'
implementation 'org.redisson:redisson-spring-data-30:3.21.0'
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
@EnableRedisRepositories 어노테이션 추가하고, AbstractHttpSessionApplicationInitializer 을 상속받는다.  
redissonConnectionFactory 빈을 추가한다. 
```
package com.example.shop.configuration;

import lombok.Getter;
import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;
import org.redisson.spring.data.connection.RedissonConnectionFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.session.data.redis.config.annotation.web.http.EnableRedisHttpSession;
import org.springframework.session.web.context.AbstractHttpSessionApplicationInitializer;

@Getter
@Configuration
@EnableRedisHttpSession
@Profile({"!test"})
public class RedissonConfiguration extends AbstractHttpSessionApplicationInitializer {

    @Value( "${spring.redis.host}" )
    private String host;

    @Value( "${spring.redis.port}" )
    private int port;

    @Bean
    public RedissonConnectionFactory redissonConnectionFactory(RedissonClient redisson) {
        return new RedissonConnectionFactory(redisson);
    }

    @Bean
    public RedissonClient redissonClient(){
        Config config = new Config();
        config.useSingleServer()
                .setAddress("redis://"+ this.host+":"+ this.port);

        return Redisson.create(config);
    }
}
```

#### LoginController ####
```
package com.example.shop.controller;

import com.example.shop.dto.LoginRequest;
import com.example.shop.dto.LoginResponse;
import com.example.shop.dto.MemberDto;
import com.example.shop.service.MemberService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.joda.time.LocalDateTime;
import org.redisson.api.RedissonClient;
import org.redisson.client.codec.StringCodec;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

@Slf4j
@RestController
@RequiredArgsConstructor
@RequestMapping(value="/session")
public class LoginController {

    private final MemberService memberService;

    private final RedissonClient redissonClient;

    private final String cacheName = "spring:session:sessions:";

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest,
                               HttpServletRequest httpServletRequest) {
        log.info("userId: " + loginRequest.getUserId());
        log.info("password: " + loginRequest.getPassword());

        // userId, password 로 로그인 한다.
        // 성공하는 경우 Redis K/V 설정
        // LoginResponse 객체 반환(userId, email, 로그인 성공여부, 로그인일시)
        MemberDto memberDto = memberService.findMember(loginRequest.getUserId());
        LoginResponse.LoginResponseBuilder loginResponse = LoginResponse.builder();
        loginResponse.isLogined(false);

        if(memberDto.getPassword() != null
                && memberDto.getPassword().equals(loginRequest.getPassword())) {

            HttpSession prevSession = httpServletRequest.getSession();
            prevSession.invalidate();
            log.info("prev session id: " + prevSession.getId());

            HttpSession session = httpServletRequest.getSession(true);
            session.setAttribute("emailAddress", memberDto.getEmailAddress());
            session.setAttribute("phoneNumber", memberDto.getPhoneNumber());
            session.setMaxInactiveInterval(1800); // Session이 30분동안 유지
            log.info("session id: " + session.getId());

            SimpleDateFormat dtf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
            LocalDateTime now = LocalDateTime.now();
            loginResponse.sessionId(session.getId())
                    .loginDate(dtf.format(now.toDate()))
                    .emailAddress(memberDto.getEmailAddress())
                    .isLogined(true);
        }

        return ResponseEntity.status(HttpStatus.OK).body(loginResponse.build());
    }

    @GetMapping("/logout")
    public ResponseEntity<?> logout(HttpServletRequest httpServletRequest) {
        HttpSession session = httpServletRequest.getSession(false);  // Session이 없으면 null return
        if(session != null) {
            session.invalidate();
        }

        return ResponseEntity.status(HttpStatus.OK).body(
                LoginResponse.builder()
                    .isLogined(false)
                    .build());
    }

    @GetMapping("/info")
    public ResponseEntity<?> info(HttpServletRequest httpServletRequest) {
        HttpSession session = httpServletRequest.getSession(false);
        if(session == null)
            return ResponseEntity.status(HttpStatus.OK).body("Session is null...");

        Map<Object, Object> returnMap = new HashMap<>();
        returnMap.put("sessionId", session.getId());

        Set<Map.Entry<Object, Object>> entrySet = redissonClient
                .getMap(cacheName + session.getId(), StringCodec.INSTANCE)
                .readAllEntrySet();
        Iterator<Map.Entry<Object, Object>> iterator = entrySet.iterator();

        while(iterator.hasNext()) {
            Map.Entry<Object, Object> entry = iterator.next();
            if(((String)entry.getKey()).startsWith("sessionAttr"))
                returnMap.put(((String) entry.getKey()).split(":")[1], entry.getValue());
        }

        return ResponseEntity.status(HttpStatus.OK).body(returnMap);
    }
}
```

#### 로그인 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-session-1.png)

#### 로그인 정보 조회 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-session-2.png)

#### 로그 아웃 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-session-3.png)

## 레퍼런스 ##
* https://stackoverflow.com/questions/70129192/java-redisson-client-error-bad-argument-2-to-unpack-data-string-too-short
* https://stackoverflow.com/questions/68544253/retrieve-existing-key-value-pair-present-in-redis-using-redisson
* https://www.baeldung.com/redis-redisson
* https://chb2005.tistory.com/173
* https://stir.tistory.com/256
* https://moonsiri.tistory.com/27
* [레디스 명령어](https://devhj.tistory.com/26)
