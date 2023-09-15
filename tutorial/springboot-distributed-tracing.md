*** logback 이 제대로 동작하지 않음(spring property 먹지 않음) ****

springboot (micrometer/zipkin library) ---> logback ---> loki <-------- grafana.


## Grafana Loki ##

### Architecture ###
https://grafana.com/docs/loki/latest/get-started/overview/
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/loki-architecture-2.png)

### Loki 설치 (https://grafana.com/docs/loki/latest/setup/install/) ###

아래 명령어로 로컬 PC 및 eks_mysql_exporter EC2 인스턴스에 grafana loki를 설치한다
```
wget https://raw.githubusercontent.com/grafana/loki/v2.9.0/cmd/loki/loki-local-config.yaml -O loki-config.yaml
mkdir -p $(pwd)/mnt/config; cp loki-config.yaml $(pwd)/mnt/config
docker run --name loki -d -v $(pwd):/mnt/config -p 3100:3100 grafana/loki:2.9.0 -config.file=/mnt/config/loki-config.yaml
```
*  docker -v mount path 수정필요.


## 테스트 ##




## 레퍼런스 ##
* https://inma.tistory.com/164
* https://velog.io/@gillog/Spring-Boot-application.properties-%EC%BB%A4%EC%8A%A4%ED%85%80-property-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0ConfigurationProperties
* https://velog.io/@shawnhansh/SpringBoot-logback-%EB%8D%94-%EC%89%BD%EA%B2%8C-%EC%84%A4%EC%A0%95%ED%95%98%EA%B8%B0application.properties%EC%99%80-logback-spring.xml
* https://0soo.tistory.com/245
* https://stackoverflow.com/questions/35651241/configure-logback-using-several-profiles
* https://supawer0728.github.io/2018/04/07/spring-boot-logging/
* https://grafana.com/docs/loki/latest/
* https://spring.io/blog/2022/10/12/observability-with-spring-boot-3
* https://tanzu.vmware.com/developer/guides/observability-reactive-spring-boot-3/
