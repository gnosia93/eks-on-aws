ElastiCache For Redis 를 활용한 판매 및 재고수량 관리 방법에 대해서 설명한다. 데이터베이스로도 관리할 수 있으나 트랜잭션 관리에 초점을 두고 있는 RDMS 시스템들은 Redis 와 같은 캐쉬 시스템에 비해서 처리 속도가 상당히 느린편이다.

### 로컬 PC 에 Redis 설치 ###

```
docker pull redis

docker images

docker run --name my-redis -p 6379:6379 -d redis
```
```
% docker ps -a | grep my-redis
2465999b7f47   redis                           "docker-entrypoint.s…"   8 seconds ago   Up 8 seconds                0.0.0.0:6379->6379/tcp   my-redis

% docker exec -it my-redis /bin/bash
root@2465999b7f47:/data# redis-cli
127.0.0.1:6379> ping
PONG
127.0.0.1:6379>
```

### build.gradle ###

redisson 패키지 의존성을 추가한다.
```
dependencies {
	implementation 'org.redisson:redisson-spring-boot-starter:3.23.4'
	...
```


## 레퍼런스 ##

* [재고시스템으로 알아보는 동시성이슈 해결방법](https://thalals.tistory.com/370)
