## OpenTelemetry 스프링 부트 분산 트레이싱 ##

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-distributed-tracing.png)


### 1. Jaeger 설치 ###

로컬 PC 및 eks_mysql_exporter EC2 인스턴스에 아래 명령어를 이용해서 jaeger 를 설치한다. 
```
docker pull jaegertracing/all-in-one:latest
docker run --name my-jaeger -p 4318:4318 -p 16686:16686 -e COLLECTOR_OTLP_ENABLED=true -d jaegertracing/all-in-one
```

#### eks_mysql_exporter EC2 ####
```

```

### 2. build.gradle ###
```
implementation 'io.micrometer:micrometer-tracing-bridge-otel:1.0.0-M8'
implementation 'io.opentelemetry:opentelemetry-exporter-otlp:1.30.0'
```

### 3. application properties ###
#### application.yaml ####
management 와 logging 설정을 추가한다.
```
management:
  tracing:
    sampling:
      probability: 1.0

logging:
  pattern:
    level: '%5p [${spring.application.name:},%X{traceId:-},%X{spanId:-}]'
```


#### application-dev.yaml ####
```
tracing:
  url: http://localhost:4318/v1/traces
```

#### application-stage.yaml ####
production yaml 도 stage 와 동일하게 아래 내용을 추가한다. 
```
tracing:
  url: http://${EKS-MYSQL_EXPORTER_EC2}>:4318/v1/traces
```

### 4. 스프링 부트 Controller ###

#### MemberController 수정 ####
getMemberBenefit 메소드를 최하단에 추가한다.
```
    ...

    @ResponseBody
    @RequestMapping(value="/benefit/{memberId}", method=RequestMethod.GET)
    public ResponseEntity<?> getMemberBenefit(@PathVariable Integer memberId) {

        String benefitUrl = msaServiceConfiguration.getBenefit() + "/" + memberId;
        String benefitResponse = restTemplate.getForObject(benefitUrl, String.class);

        Map<String, Object> responseMap = new HashMap<>();
        responseMap.put("memberId", memberId);
        responseMap.put("benefit", benefitResponse);

        return ResponseEntity.status(HttpStatus.OK).body(responseMap);
    }

}
```

#### BenefitController 생성 ####
```
package com.example.shop.controller;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RequiredArgsConstructor
@RequestMapping(value="/benefit")
@RestController
public class BenefitController {

    private final RestTemplate restTemplate;

    @ResponseBody
    @RequestMapping(value="/{memberId}", method= RequestMethod.GET)
    public ResponseEntity<?> getPoint(@PathVariable Integer memberId) {

        Map<String, Integer> responseMap = new HashMap<>();
        responseMap.put("point", getRandomPoint(1, 1000));
        responseMap.put("accumulate", getRandomPoint(1, 30000));

        return ResponseEntity.status(HttpStatus.OK).body(responseMap);
    }

    private int getRandomPoint(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }
}
```


### 5. Benefit 서비스 배포 ###



### 6. Jaeger 조회 ###


## 레퍼런스 ##

* https://refactorfirst.com/distributed-tracing-with-opentelemetry-jaeger-in-spring-boot
* https://refactorfirst.com/distributed-tracing-with-spring-cloud-sleuth.html
* https://www.sumologickorea.com/blog/configure-opentelemetry-collector/
