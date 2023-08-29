

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
exposure.include 에 prometheus 추가
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

## 레퍼런스 ##

* [How to capture Spring Boot metrics with the OpenTelemetry Java Instrumentation Agent](https://grafana.com/blog/2022/05/04/how-to-capture-spring-boot-metrics-with-the-opentelemetry-java-instrumentation-agent/)
  
* [Spring Boot + Actuator + Micrometer로 Prometheus 연동하기](https://velog.io/@windsekirun/Spring-Boot-Actuator-Micrometer%EB%A1%9C-Prometheus-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0)

* [OpenTelemetry Spring Boot Tutorial - complete implementation guide](https://signoz.io/blog/opentelemetry-spring-boot/)
  
* [OpenTelemetry Setup in Spring Boot Application](https://www.baeldung.com/spring-boot-opentelemetry-setup)
  
* [Automatic Instrumentation of Spring Boot 3.x Applications with Grafana OpenTelemetry Starter](https://grafana.com/docs/opentelemetry/instrumentation/java/spring-starter/)
  
* [SpringBoot Actuator + Prometheus + Grafana](https://jydlove.tistory.com/70)
