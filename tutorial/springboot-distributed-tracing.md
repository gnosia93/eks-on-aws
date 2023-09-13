### grafana loki 설치 ###
```
wget https://raw.githubusercontent.com/grafana/loki/v2.9.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:2.9.0 -config.file=/mnt/config/loki-config.yaml

wget https://raw.githubusercontent.com/grafana/loki/v2.9.0/clients/cmd/promtail/promtail-docker-config.yaml -O promtail-config.yaml
docker run --name promtail -d -v $(pwd):/mnt/config -v /var/log:/var/log --link loki grafana/promtail:2.9.0 -config.file=/mnt/config/promtail-config.yaml

```

### build.gradle ###
```
implementation 'org.springframework.boot:spring-boot-starter-web'
implementation 'org.springframework.boot:spring-boot-starter-actuator'

implementation 'org.springframework.boot:spring-boot-starter-aop'
implementation 'io.micrometer:micrometer-tracing-bridge-brave'
implementation 'io.zipkin.reporter2:zipkin-reporter-brave'
implementation 'com.github.loki4j:loki-logback-appender'
```


## 레퍼런스 ##

* https://spring.io/blog/2022/10/12/observability-with-spring-boot-3

