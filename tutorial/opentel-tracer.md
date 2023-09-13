## OpenTelemetry 스프링 부트 분산 트레이싱 ##
****
spring cloud 라이브러리와 충돌하는듯.. 나중에 해결.. 
****
* https://awstip.com/grafana-loki-and-promtail-for-visualization-on-aws-ec2-instance-2799f9fc6450
* https://devocean.sk.com/blog/techBoardDetail.do?ID=163964
* https://spring.io/blog/2022/10/12/observability-with-spring-boot-3
* https://docs.aws.amazon.com/grafana/latest/userguide/v9-explore-tracing.html
* https://grafana.com/docs/grafana/latest/panels-visualizations/visualizations/traces/
* https://blog.cloudtechner.com/log-management-and-distributed-tracing-using-grafana-loki-and-tempo-b9c56392bae7
    
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-distributed-tracing.png)


### 1. Jaeger 설치 ###

로컬 PC 및 eks_mysql_exporter EC2 인스턴스에 아래 명령어를 이용해서 jaeger 를 설치한다. 
```
docker pull jaegertracing/all-in-one:latest
nohup docker run --name my-jaeger -p 4318:4318 -p 16686:16686 -e COLLECTOR_OTLP_ENABLED=true -d jaegertracing/all-in-one &
```

### 2. build.gradle ###
```
implementation 'io.micrometer:micrometer-tracing-bridge-otel:1.1.5'
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
  url: http://${EKS_MYSQL_EXPORTER}:4318/v1/traces
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
cloud9 터미널에서 benefit 서비스를 배포한다. 

```
STAGE_DB=$(aws rds describe-db-instances | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g' | grep 'eks-mysql-stage')
PROD_DB=$(aws rds describe-db-instances | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g' | grep 'eks-mysql-prod')
IMAGE_REPO_ADDR=$(aws ecr describe-repositories | jq '.repositories[].repositoryUri' | sed 's/"//g' | grep 'springboot')
DB_ENDPOINT=${STAGE_DB}
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --show-cache-node-info \
--query 'CacheClusters[?starts_with(CacheClusterId, `eks-redis`)].CacheNodes[].Endpoint[].Address' --out text)
EKS_MYSQL_EXPORTER=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=eks_mysql_exporter" --query 'Reservations[].Instances[].PublicDnsName' --out text)

echo "${DB_ENDPOINT}"
echo "${REDIS_ENDPOINT}"
echo "${IMAGE_REPO_ADDR}"
echo "${EKS_MYSQL_EXPORTER}"
spring_application_name=benefit
```

```
cat <<EOF > benefit-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: benefit
  namespace: default
  labels:
    app: benefit
spec:
  replicas: 3
  selector:
    matchLabels:
      app: benefit
  template:
    metadata:
      labels:
        app: benefit
      annotations:
        builder: 'SoonBeom Kwon'
        prometheus.io/scrape: 'true'
        prometheus.io/path: '/actuator/prometheus'
        prometheus.io/port: '8080'
    spec:
      containers:
        - name: benefit
          image: ${IMAGE_REPO_ADDR}
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
            - name: DB_ENDPOINT
              value: ${DB_ENDPOINT}
            - name: DB_USERNAME
              value: shop
            - name: DB_PASSWORD
              value: shop
            - name: REDIS_ENDPOINT
              value: ${REDIS_ENDPOINT}
            - name: JAVA_TOOL_OPTIONS
              value: "-Xms1024M -Xmx1024M"
            - name: EKS_MYSQL_EXPORTER
              value: ${EKS_MYSQL_EXPORTER}
            - name: spring.application.name
              value: ${spring_application_name}
          imagePullPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: benefit
  namespace: default
  labels:
    app: benefit
spec:
  selector:
    app: benefit
  ports:
    - port: 80
      targetPort: 8080
EOF
```
benefit k8s 서비스의 FQDN 명은 benefit.default.svc.cluster.local 이다. 


### 6. benefit 서비스 호출 ###

### 7. Jaeger 조회 ###


## 레퍼런스 ##

* https://refactorfirst.com/distributed-tracing-with-opentelemetry-jaeger-in-spring-boot
* https://refactorfirst.com/distributed-tracing-with-spring-cloud-sleuth.html
* https://www.sumologickorea.com/blog/configure-opentelemetry-collector/
