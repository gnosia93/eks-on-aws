springboot (micrometer/zipkin library) ---> logback ---> loki <-------- grafana.


## Grafana Loki ##

### Architecture ###
https://grafana.com/docs/loki/latest/get-started/overview/
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/loki-architecture-2.png)

### Loki 설치 ###

* 로컬 PC
```
wget https://raw.githubusercontent.com/grafana/loki/v2.9.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:2.9.0 -config.file=/mnt/config/loki-config.yaml
```

* EC2
eks_mysql_exporter EC2 인스턴스에 grafana loki를 설치한다.(https://grafana.com/docs/loki/latest/setup/install/local/)
```
dnf update
dnf install loki
```

## SpringBoot ##

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
* https://0soo.tistory.com/245
* https://stackoverflow.com/questions/35651241/configure-logback-using-several-profiles
* https://supawer0728.github.io/2018/04/07/spring-boot-logging/
* https://grafana.com/docs/loki/latest/
* https://spring.io/blog/2022/10/12/observability-with-spring-boot-3
* https://tanzu.vmware.com/developer/guides/observability-reactive-spring-boot-3/
