### application.yaml ###
```
...

# http://localhost:8080/actuator/health
management:
  endpoints:
    web:
      exposure:
        include: health, info
```

### build.gradle ###
```
dependencies {
	...
	implementation 'org.springframework.boot:spring-boot-starter-actuator'
	...
```

## 레퍼런스 ##

* [Spring actuator 사용하기 - health check, healthIndicator custom](https://truehong.tistory.com/124)
