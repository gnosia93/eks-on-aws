## SSO 을 위한 Keycloak 서버 구축 ##

### 1. 설치하기 ###
#### keycloak 설치 ####
eks_mysql_exporter EC2 에 설치한다. 
```
EC2=$(aws ec2 describe-instances --filter Name=tag:Name,Values=eks_mysql_exporter\
  --query "Reservations[].Instances[].PublicDnsName" --out text)

echo 'ssh to '${EC2}...
ssh -i aws-kp-2.pem ec2-user@${EC2}
```

```
docker rm $(docker ps -a -f name=keycloak | awk '{ if (NR != 1) {print $1}}')
```

#### keycloak 실행하기 ####
```
nohup docker run -p 8080:8080 --name keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin\
  quay.io/keycloak/keycloak "start-dev" &

tail -f nohup.out
```
[결과]
```
2023-09-08 00:11:20,691 INFO  [io.quarkus] (main) Installed features: [agroal, cdi, hibernate-orm, jdbc-h2, jdbc-mariadb, jdbc-mssql, jdbc-mysql, jdbc-oracle, jdbc-postgresql, keycloak, logging-gelf, micrometer, narayana-jta, reactive-routes, resteasy, resteasy-jackson, smallrye-context-propagation, smallrye-health, vertx]
2023-09-08 00:11:20,839 INFO  [org.keycloak.services] (main) KC-SERVICES0009: Added user 'admin' to realm 'master'
2023-09-08 00:11:20,841 WARN  [org.keycloak.quarkus.runtime.KeycloakMain] (main) Running the server in development mode. DO NOT use this configuration in production.
2023-09-08 00:13:45,600 WARN  [org.keycloak.events] (executor-thread-6) type=LOGIN_ERROR, realmId=bb7741bc-8e89-4f0d-b688-cbde88bfddca, clientId=null, userId=null, ipAddress=218.48.121.117, error=ssl_required
2023-09-08 00:13:52,585 WARN  [org.keycloak.events] (executor-thread-11) type=LOGIN_ERROR, realmId=bb7741bc-8e89-4f0d-b688-cbde88bfddca, clientId=null, userId=null, ipAddress=218.48.121.117, error=ssl_required
2023-09-08 00:13:59,719 WARN  [org.keycloak.events] (executor-thread-10) type=LOGIN_ERROR, realmId=bb7741bc-8e89-4f0d-b688-cbde88bfddca, clientId=null, userId=null, ipAddress=218.48.121.117, error=ssl_required
2023-09-08 00:17:05,831 WARN  [org.keycloak.events] (executor-thread-13) type=LOGIN_ERROR, realmId=bb7741bc-8e89-4f0d-b688-cbde88bfddca, clientId=null, userId=null, ipAddress=218.48.121.117, error=ssl_required
2023-09-08 00:17:09,523 WARN  [org.keycloak.events] (executor-thread-12) type=LOGIN_ERROR, realmId=bb7741bc-8e89-4f0d-b688-cbde88bfddca, clientId=null, userId=null, ipAddress=218.48.121.117, error=ssl_required
2023-09-08 00:17:17,022 WARN  [org.keycloak.events] (executor-thread-13) type=LOGIN_ERROR, realmId=bb7741bc-8e89-4f0d-b688-cbde88bfddca, clientId=null, userId=null, ipAddress=218.48.121.117, error=ssl_required
2023-09-08 02:36:22,063 INFO  [io.quarkus] (Shutdown thread) Keycloak stopped in 0.031s
nohup: ignoring input and appending output to 'nohup.out'
Updating the configuration and installing your custom providers, if any. Please wait.
2023-09-12 01:09:13,295 INFO  [io.quarkus.deployment.QuarkusAugmentor] (main) Quarkus augmentation completed in 6162ms
2023-09-12 01:09:15,129 INFO  [org.keycloak.quarkus.runtime.hostname.DefaultHostnameProvider] (main) Hostname settings: Base URL: <unset>, Hostname: <request>, Strict HTTPS: false, Path: <request>, Strict BackChannel: false, Admin URL: <unset>, Admin: <request>, Port: -1, Proxied: false
2023-09-12 01:09:17,064 WARN  [io.quarkus.agroal.runtime.DataSources] (main) Datasource <default> enables XA but transaction recovery is not enabled. Please enable transaction recovery by setting quarkus.transaction-manager.enable-recovery=true, otherwise data may be lost if the application is terminated abruptly
2023-09-12 01:09:17,753 WARN  [org.infinispan.PERSISTENCE] (keycloak-cache-init) ISPN000554: jboss-marshalling is deprecated and planned for removal
2023-09-12 01:09:18,036 INFO  [org.infinispan.CONTAINER] (keycloak-cache-init) ISPN000556: Starting user marshaller 'org.infinispan.jboss.marshalling.core.JBossUserMarshaller'
2023-09-12 01:09:19,502 INFO  [org.keycloak.quarkus.runtime.storage.legacy.liquibase.QuarkusJpaUpdaterProvider] (main) Initializing database schema. Using changelog META-INF/jpa-changelog-master.xml
2023-09-12 01:09:21,374 INFO  [org.keycloak.connections.infinispan.DefaultInfinispanConnectionProviderFactory] (main) Node name: node_874627, Site name: null
2023-09-12 01:09:21,473 INFO  [org.keycloak.broker.provider.AbstractIdentityProviderMapper] (main) Registering class org.keycloak.broker.provider.mappersync.ConfigSyncEventListener
2023-09-12 01:09:21,521 INFO  [org.keycloak.services] (main) KC-SERVICES0050: Initializing master realm
2023-09-12 01:09:23,106 INFO  [io.quarkus] (main) Keycloak 22.0.1 on JVM (powered by Quarkus 3.2.0.Final) started in 9.711s. Listening on: http://0.0.0.0:8080
2023-09-12 01:09:23,107 INFO  [io.quarkus] (main) Profile dev activated.
2023-09-12 01:09:23,107 INFO  [io.quarkus] (main) Installed features: [agroal, cdi, hibernate-orm, jdbc-h2, jdbc-mariadb, jdbc-mssql, jdbc-mysql, jdbc-oracle, jdbc-postgresql, keycloak, logging-gelf, micrometer, narayana-jta, reactive-routes, resteasy, resteasy-jackson, smallrye-context-propagation, smallrye-health, vertx]
2023-09-12 01:09:23,305 INFO  [org.keycloak.services] (main) KC-SERVICES0009: Added user 'admin' to realm 'master'
2023-09-12 01:09:23,307 WARN  [org.keycloak.quarkus.runtime.KeycloakMain] (main) Running the server in development mode. DO NOT use this configuration in production.
```

#### SSL disable #### 
* https://velog.io/@jungsangu/Keycloak-HTTPS-required-%EC%97%90%EB%9F%AC
```
# 도커 컨테이너 bash 진입
docker exec -it <컨테이너이름> bash

# keycloak bin 폴더로 이동
cd /opt/keycloak/bin

# 비밀번호는 admin
./kcadm.sh config credentials --server http://localhost:8080 --realm master --user admin

# master realm에서 sslRequired를 NONE으로 바꾸기
./kcadm.sh update realms/master -s sslRequired=NONE
```

#### 어드민페이지 접속 ####

Administration Console 을 클릭한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-1.png)

로그인 Username/Password 는 admin/admin 이다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-2.png)


### 2. SAML 연동하기 ###



## 레퍼런스 ##
* https://mr-zero.tistory.com/568
  
* https://league-cat.tistory.com/397

* https://github.com/keycloak/keycloak

* [[aws cli] EC2 - TAG 필터링](https://passwd.tistory.com/entry/aws-cli-EC2-TAG-%ED%95%84%ED%84%B0%EB%A7%81)
