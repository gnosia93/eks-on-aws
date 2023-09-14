springboot (micrometer/zipkin library) ---> logback ---> loki <-------- grafana.


## Grafana Loki ##

### Architecture ###
https://grafana.com/docs/loki/latest/get-started/overview/
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/loki-architecture-2.png)

### Loki 설치 (https://grafana.com/docs/loki/latest/setup/install/) ###

아래 명령어로 로컬 PC 및 eks_mysql_exporter EC2 인스턴스에 grafana loki를 설치한다
```
wget https://raw.githubusercontent.com/grafana/loki/v2.9.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:2.9.0\
 -config.file=./loki-config.yaml

nohup docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:2.9.0\
 -config.file=/mnt/config/loki-config.yaml &

```

## SpringBoot ##

### build.gradle ###
```
implementation 'com.github.loki4j:loki-logback-appender:1.4.1'
```

** 아래 내용은 나중에 확인.
```
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-actuator'

implementation 'org.springframework.boot:spring-boot-starter-aop'
implementation 'io.micrometer:micrometer-tracing-bridge-brave'
implementation 'io.zipkin.reporter2:zipkin-reporter-brave'
```

### properties 파일 (application-dev.xml) ###
```
log.endpoint.lokiUrl: "http://localhost:3100/loki/api/v1/push"
```

### logback 설정 파일 (logback-dev.xml) ###
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration scan="true" scanPeriod="30 seconds">
    <include resource="org/springframework/boot/logging/logback/base.xml" />
    <springProperty scope="context" name="appName" source="spring.application.name"/>
    <springProperty scope="context" name="LOKI_URL" source="log.endpoint.lokiUrl" />

    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>
                %d{HH:mm:ss.SSS} %-5level %logger{36} %X{X-Request-ID} - %msg%n
            </pattern>
        </encoder>
    </appender>
    <appender name="LOKI" class="com.github.loki4j.logback.Loki4jAppender">
        <http>
            <url>${LOKI_URL}</url>
        </http>
        <format>
            <label>
                <pattern>app=${appName},host=${HOSTNAME},traceID=%X{traceId:-NONE},level=%level</pattern>
            </label>
            <message>
                <pattern>${FILE_LOG_PATTERN}</pattern>
            </message>
            <sortByTime>true</sortByTime>
        </format>
    </appender>
    <root level="INFO">
        <appender-ref ref="CONSOLE" />
        <appender-ref ref="LOKI"/>
    </root>
</configuration>
```

### ObervationConfiguration ###
```
package com.example.shop.configuration;

import io.micrometer.observation.ObservationRegistry;
import io.micrometer.observation.aop.ObservedAspect;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
public class ObservationConfiguration {

    // To have the @Observed support we need to register this aspect
    @Bean
    ObservedAspect observedAspect(ObservationRegistry observationRegistry) {
        return new ObservedAspect(observationRegistry);
    }
}
```

### ObservationHandlerImpl ###
```
package com.example.shop.configuration;

import io.micrometer.common.KeyValue;
import io.micrometer.observation.Observation;
import io.micrometer.observation.ObservationHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.stream.StreamSupport;

public class ObservationHandlerImpl implements ObservationHandler<Observation .Context> {
    private static final Logger log = LoggerFactory.getLogger(ObservationHandlerImpl.class);

    @Override
    public void onStart(Observation.Context context) {
        log.info("Before running the observation for context [{}], userType [{}]", context.getName(), getUserTypeFromContext(context));
    }

    @Override
    public void onStop(Observation.Context context) {
        log.info("After running the observation for context [{}], userType [{}]", context.getName(), getUserTypeFromContext(context));
    }

    @Override
    public boolean supportsContext(Observation.Context context) {
        return true;
    }

    private String getUserTypeFromContext(Observation.Context context) {
        return StreamSupport.stream(context.getLowCardinalityKeyValues().spliterator(), false)
                .filter(keyValue -> "userType".equals(keyValue.getKey()))
                .map(KeyValue::getValue)
                .findFirst()
                .orElse("UNKNOWN");
    }
}
```

### BenefitService ###
```
package com.example.shop.service;

import io.micrometer.observation.annotation.Observed;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import java.util.Random;

@Slf4j
@Service
public class BenefitService {

    @Observed(name = "user.name",
            contextualName = "getTotalPoint",
            lowCardinalityKeyValues = {"userType", "userType2"})
    public int getTotalPoint(int userId) {
        log.info("Getting user name for user with id <{}>", userId);

        final Random random = new Random();
        try {
            Thread.sleep(random.nextLong(200L));
        }
        catch(InterruptedException e) {
            throw new RuntimeException(e);
        }

        return getRandomPoint(100, 10000);
    }

    public int getRandomPoint(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }
}
```

### BenefitController ###
```
package com.example.shop.controller;

import com.example.shop.service.BenefitService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@RequestMapping(value="/benefit")
@RestController
public class BenefitController {

    private final BenefitService benefitService;

    @ResponseBody
    @RequestMapping(value="/{memberId}", method= RequestMethod.GET)
    public ResponseEntity<?> getPoint(@PathVariable Integer memberId) {

        Map<String, Object> responseMap = new HashMap<>();
        responseMap.put("memberId", memberId);
        responseMap.put("accumulate", benefitService.getTotalPoint(memberId));

        return ResponseEntity.status(HttpStatus.OK).body(responseMap);
    }
}
```

## 레퍼런스 ##
* https://velog.io/@gillog/Spring-Boot-application.properties-%EC%BB%A4%EC%8A%A4%ED%85%80-property-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0ConfigurationProperties
* https://velog.io/@shawnhansh/SpringBoot-logback-%EB%8D%94-%EC%89%BD%EA%B2%8C-%EC%84%A4%EC%A0%95%ED%95%98%EA%B8%B0application.properties%EC%99%80-logback-spring.xml
* https://0soo.tistory.com/245
* https://stackoverflow.com/questions/35651241/configure-logback-using-several-profiles
* https://supawer0728.github.io/2018/04/07/spring-boot-logging/
* https://grafana.com/docs/loki/latest/
* https://spring.io/blog/2022/10/12/observability-with-spring-boot-3
* https://tanzu.vmware.com/developer/guides/observability-reactive-spring-boot-3/
