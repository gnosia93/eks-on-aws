## SpringBoot with OpenTelemetry ##

OpenTelemetry 로 springboot 의 메트릭을 수집하여 AMG 로 출력하고자 한다. 

### 1. build.gradle ###
dependencies 에 io.micrometer:micrometer-registry-prometheus 를 추가한다.
```
dependencies {
...
	implementation 'org.springframework.boot:spring-boot-starter-actuator'
	implementation 'io.micrometer:micrometer-registry-prometheus'   
...
```

### 2. application.yaml ###
exposure.include 에 prometheus 추가한다.
```
spring:
  profiles:
    active: dev

# http://localhost:8080/actuator/health
management:
  endpoints:
    web:
      exposure:
        include: health, info, prometheus
```

### 3. prometheus 메트릭 확인 ###

http://localhost:8080/actuator/prometheus 접근해서 출력 내용을 확인한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-prometheus.png)

### 4. open telemetry 컬렉터 설정 ###
OpenTelemetry 컬렉터는 메트릭 데이터를 수신, 처리 및 내보내는 구성 요소로, 모니터링할 애플리케이션과 모니터링 백엔드(AMP) 의 중간에 위치한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/otel-collector-position.png)

스프링 부트의 prometheus 엔드포인트로 부터 데이터를 모우고, 수신한 데이터를 처리한 후 백엔드 시스템(AMP) 으로 전송하는 역할을 한다.

### 5. AMG 대시보드 설정 ###






## 레퍼런스 ##

* [How to capture Spring Boot metrics with the OpenTelemetry Java Instrumentation Agent](https://grafana.com/blog/2022/05/04/how-to-capture-spring-boot-metrics-with-the-opentelemetry-java-instrumentation-agent/)
  
* [Spring Boot + Actuator + Micrometer로 Prometheus 연동하기](https://velog.io/@windsekirun/Spring-Boot-Actuator-Micrometer%EB%A1%9C-Prometheus-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0)

* [OpenTelemetry Spring Boot Tutorial - complete implementation guide](https://signoz.io/blog/opentelemetry-spring-boot/)
  
* [OpenTelemetry Setup in Spring Boot Application](https://www.baeldung.com/spring-boot-opentelemetry-setup)
  
* [Automatic Instrumentation of Spring Boot 3.x Applications with Grafana OpenTelemetry Starter](https://grafana.com/docs/opentelemetry/instrumentation/java/spring-starter/)
  
* [SpringBoot Actuator + Prometheus + Grafana](https://jydlove.tistory.com/70)
