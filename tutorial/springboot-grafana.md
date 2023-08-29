## SpringBoot with OpenTelemetry ##

이번 챕터에서는 OpenTelemetry 로 springboot 의 메트릭을 수집하여 AMP 로 보내고자 한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/otel-collector-position.png)

OpenTelemetry 컬렉터는 스프링 부트의 prometheus 엔드포인트로 부터 데이터를 수집하고, 수집된 데이터를 처리한 후 백엔드 시스템(AMP) 으로 전송하는 역할을 한다.

### 1. build.gradle ###

io.micrometer:micrometer-registry-prometheus 디펜던시를 추가한다.
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

Intelij 의 shop 프로젝트를 실행하고 http://localhost:8080/actuator/prometheus 접근해서 출력 내용을 확인한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-prometheus.png)


### 4. shop 서비스 재배포 (optional) ###

이미 소스 코드상에 actuator/prometheus 설정이 적용된 관계로 이 섹션을 건너뛰어도 뒤지만, 만약을 위해 아래 과정을 실행해 준다.

#### 4.1 actuator/prometheus 가 적용된 도커 이미지 ECR 등록 ####
CI 파이프 라인 실행

#### 4.2 shop 서비스 재배포 ####
cloud9 터미널에서 아래 명령어를 실행한다. 
```
kubectl delete -f shop_service.yaml
kubectl apply -f shop_service.yaml
```

### 5. open telemetry 컬렉터 설정 ###

[Amazon Managed Service for Prometheus / Grafana with OpenTelemetry](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-amp.md) 포스팅의 [6. Otel collector 설치] 섹션에서 했던 것 처럼 otel-collector-config.yaml 파일에 아래 그림처럼 springboot actuator/prometheus 용 설정파일을 추가하고 collector 를 재시작 한다. (라인넘버 321)  
해당 yaml 파일은 cloud9 터미널에서 확인할 수 있다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/otel-collector-config-springboot.png)

[otel-collector-config.yaml 에 추가할 설정]
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

OpenTelemetry 컬렉터의 설정을 바꾸고, 재실행한다. 
```
kubectl apply -f otel-collector-config.yaml
```

[결과]
* prometheus 네임스페이스의 observability-collector 컬렉터 파드가 동작중인 것을 볼수 있다.
* logs 명령어로 확인해 보면 receiver 가 스프링 부트 메트릭을 수집하고 있다. 
```
$ kubectl get all -n prometheus
NAME                                           READY   STATUS    RESTARTS   AGE
pod/observability-collector-6f564d8489-hpk8w   1/1     Running   0          22m

NAME                                         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/observability-collector-monitoring   ClusterIP   172.20.130.82   <none>        8888/TCP   57m

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/observability-collector   1/1     1            1           57m

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/observability-collector-6b4576d759   0         0         0       43m
replicaset.apps/observability-collector-6bc78d99b7   0         0         0       57m
replicaset.apps/observability-collector-6f564d8489   1         1         1       22m
replicaset.apps/observability-collector-74d88486c5   0         0         0       42m
replicaset.apps/observability-collector-f57d5bcf8    0         0         0       32m

$ kubectl logs pod/observability-collector-6f564d8489-hpk8w -n prometheus

...
2023-08-29T11:15:01.096Z        info    prometheusreceiver@v0.74.0/metrics_receiver.go:243      Scrape job added        {"kind": "receiver", "name": "prometheus", "data_type": "metrics", "jobName": "integrations/springboot"}
2023-08-29T11:15:01.096Z        info    kubernetes/kubernetes.go:326    Using pod service account via in-cluster config {"kind": "receiver", "name": "prometheus", "data_type": "metrics", "discovery": "kubernetes", "config": "kubernetes-nodes-cadvisor"}
2023-08-29T11:15:01.096Z        info    kubernetes/kubernetes.go:326    Using pod service account via in-cluster config {"kind": "receiver", "name": "prometheus", "data_type": "metrics", "discovery": "kubernetes", "config": "kubernetes-service-endpoints-slow"}
2023-08-29T11:15:01.096Z        info    kubernetes/kubernetes.go:326    Using pod service account via in-cluster config {"kind": "receiver", "name": "prometheus", "data_type": "metrics", "discovery": "kubernetes", "config": "kubernetes-pods-slow"}
2023-08-29T11:15:01.096Z        info    kubernetes/kubernetes.go:326    Using pod service account via in-cluster config {"kind": "receiver", "name": "prometheus", "data_type": "metrics", "discovery": "kubernetes", "config": "integrations/springboot"}
2023-08-29T11:15:01.096Z        info    kubernetes/kubernetes.go:326    Using pod service account via in-cluster config {"kind": "receiver", "name": "prometheus", "data_type": "metrics", "discovery": "kubernetes", "config": "prometheus-pushgateway"}
2023-08-29T11:15:01.097Z        info    service/service.go:145  Everything is ready. Begin running and processing data.
2023-08-29T11:15:01.097Z        info    prometheusreceiver@v0.74.0/metrics_receiver.go:289      Starting scrape manager {"kind": "receiver", "name": "prometheus", "data_type": "metrics"}
```

### 6. AMG 대시보드 설정 ###

#### 19004(Spring Boot 3.x Statistics) ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-springboot.png)



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
