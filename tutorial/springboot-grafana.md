## SpringBoot with OpenTelemetry ##

이번 챕터에서는 OpenTelemetry 로 springboot 의 메트릭을 수집하여 AMP 로 보내고자 한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/otel-collector-position.png)

OpenTelemetry 컬렉터는 스프링 부트의 prometheus 엔드포인트로 부터 데이터를 수집하고, 해당 데이터를 처리한 후 백엔드 시스템(AMP) 으로 전송하는 역할을 한다.

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

[Amazon Managed Service for Prometheus / Grafana with OpenTelemetry](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-amp.md)

/6. Otel collector 설치/ 에서 했던 것 처럼 otel-collector-config.yaml 파일에 아래 그림처럼 springboot actuator/prometheus 용 설정파일을 추가하고 collector 의 설정을 바꾼다. 


![](https://github.com/gnosia93/eks-on-aws/blob/main/images/otel-collector-config-springboot.png)

[otel-collector-config.yaml]
```
- job_name: integrations/springboot
  metrics_path: '/actuator/prometheus'
  kubernetes_sd_configs:
    - role: pod
      namespaces:
        names:
          - default
  relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
    - source_labels: [__address__]
      action: replace
      regex: ([^:]+)(?::\d+)?
      replacement: $1:8080
      target_label: __address__
```


```
kubectl apply -f otel-collector-config.yaml
```

### 5. AMG 대시보드 설정 ###






## 레퍼런스 ##

* https://stackoverflow.com/questions/51731112/unable-to-scrape-metrics-from-pods
  
* https://github.com/prometheus/prometheus/blob/release-2.46/config/testdata/conf.good.yml

* https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config

* [How to capture Spring Boot metrics with the OpenTelemetry Java Instrumentation Agent](https://grafana.com/blog/2022/05/04/how-to-capture-spring-boot-metrics-with-the-opentelemetry-java-instrumentation-agent/)
  
* [Spring Boot + Actuator + Micrometer로 Prometheus 연동하기](https://velog.io/@windsekirun/Spring-Boot-Actuator-Micrometer%EB%A1%9C-Prometheus-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0)

* [OpenTelemetry Spring Boot Tutorial - complete implementation guide](https://signoz.io/blog/opentelemetry-spring-boot/)
  
* [OpenTelemetry Setup in Spring Boot Application](https://www.baeldung.com/spring-boot-opentelemetry-setup)
  
* [Automatic Instrumentation of Spring Boot 3.x Applications with Grafana OpenTelemetry Starter](https://grafana.com/docs/opentelemetry/instrumentation/java/spring-starter/)
  
* [SpringBoot Actuator + Prometheus + Grafana](https://jydlove.tistory.com/70)

* https://grafana.com/blog/2022/03/21/how-relabeling-in-prometheus-works/

* https://blog.devops.dev/monitoring-a-spring-boot-application-in-kubernetes-with-prometheus-a2d4ec7f9922
