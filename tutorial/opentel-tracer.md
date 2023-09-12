### build.gradle ###

```
implementation 'io.micrometer:micrometer-tracing-bridge-otel:1.0.0-M8'
implementation 'io.opentelemetry:opentelemetry-exporter-otlp:1.30.0'
```

### application-dev.yaml ###
```
spring:
  application:
    name: app

tracing:
  url: http://localhost:4318/v1/traces

management:
  tracing:
    sampling:
      probability: 1.0

logging:
  pattern:
    level: '%5p [${spring.application.name:},%X{traceId:-},%X{spanId:-}]'
```

### application-stage.yaml ###
```
spring:
  application:
    name: app

tracing:
  url: http://<eks-mysql-exporter EC2 IP>:4318/v1/traces

management:
  tracing:
    sampling:
      probability: 1.0

logging:
  pattern:
    level: '%5p [${spring.application.name:},%X{traceId:-},%X{spanId:-}]'
```

### Jaeger ###

eks_mysql_exporter EC2 인스턴스에서 도커로 실행한다. 
```
version: '3.9'
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - 4318:4318
      - 16686:16686
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```



## 레퍼런스 ##

* https://refactorfirst.com/distributed-tracing-with-opentelemetry-jaeger-in-spring-boot
* https://refactorfirst.com/distributed-tracing-with-spring-cloud-sleuth.html
* https://www.sumologickorea.com/blog/configure-opentelemetry-collector/
