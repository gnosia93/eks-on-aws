## SSO 을 위한 Keycloak 서버 구축 ##
* https://www.keycloak.org/
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

### 2. realm 및 유저 생성하기 ###

#### 2.1 eks-on-aws realm 생성 ###

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-realm-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-realm-2.png)
Require SSL 을 None 으로 선택한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-realm-3.png)

#### 2.2 grafana 유저 생성 ####
eks-on-aws realm 에 grafana 유저를 생성한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-adduser-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-adduser-2.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-adduser-3.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-adduser-4.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-adduser-5.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-adduser-6.png)


#### 2.3 grafana 유저로 로그인 ####
http://<User EC2>:8080/realms/eks-on-aws/account/#/ 로 이동하여 grafana 유저로 로그인한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-grafana-login-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-grafana-login-2.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-grafana-login-3.png)


### 3. AWS SAML 연동하기 ###

#### 3.1 AMG SAML 설정 ####

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-grafana-saml.png)
* Asssertion attribute role 에는 "role" 을 입력한다.
* Admin role values 텍스트 박스에 "admin, editor, viewer" 를 입력한다. 그라파나는 이와 같이 3가지 형태의 Role을 제공하고 있는데, SAML 연동시 IDP 인 Keycloak 에서 이 값을 그라파나에게 넘겨줘야 로그인이 가능하다. (주의 - Role 이 제대로 설정되지 않으면, Keycloak 과 AMG 간의 세션은 생성되나 로그인 화면에서 failed to save the SAML received information 오류가 발생하게 되고 그라파나 화면은 나오지 않는다.) 
* Metadata URL은 Keyloack realm 의 SAML Metadata 주소로 아래 그림과 같이 Realm 메뉴에서 확인할 수 있다.

#### 3.2 KeyCloak Realm 설정 ####
AMG 와 연동하기 위해 Keycloak 어드민 계정으로 로그인하여 아래와 같이 Realm 설정을 확인한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-realm-saml-meta-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-realm-saml-meta-2.png)

* Required SSL 의 값은 None 이다. (http 사용)

#### 3.3 KeyCloak Client 설정 ####
아래 그림과 같이 client 를 생성하고 설정을 확인한다. KeyCloak 입장에서 Client 는 AMG 이다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-01.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-02.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-03.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-04.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-05.png)
[Add mapper] 버튼을 눌려 email, role list, name 매퍼를 생성해야 한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-06.png)
아래 그림에서 세가지 매퍼에 대한 세부 설정값을 확인 할 수 있다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-07.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-08.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-09.png)


#### 3.4 KeyCloak Role 설정 ###
Realm roles 메뉴에서 admin, editor, viwer 역할을 생성한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-role-01.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-role-02.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-role-03.png)


#### 3.5 KeyCloak 유저 설정 ####
아래와 같이 유저의 설정값을 확인한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-user-01.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-user-02.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-user-03.png)
grafana 유저의 역할을 editor 로 설정하고 있다. (가능한 값은 admin, editor, viewer 이렇게 세가지 이다)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-user-04.png)


#### 참고 - Client 설정 확인 ####
client 메뉴에서 grafana workspace 클라이언트에 대한 설정을 아래와 같이 확인할 수 있다. 우측 상단의 팝업 메뉴에서 Export 를 누른 다음, 로컬PC 로 설정을 다운로드 받아서 확인한다. 아래 #### 필수설정 #### 과 비교해서 틀린 부분이 있는 경우 수정하도록 한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-config-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-client-config-2.png)

#### 필수설정 ####
```
  "clients": [
          {
            "clientId": "https://${WORKSPACE_ENDPOINT}/saml/metadata",
            "name": "amazon-managed-grafana",
            "enabled": true,
            "protocol": "saml",
            "adminUrl": "https://${WORKSPACE_ENDPOINT}/login/saml",
            "redirectUris": [
              "https://${WORKSPACE_ENDPOINT}/saml/acs"
            ],
            "attributes": {
              "saml.authnstatement": "true",
              "saml.server.signature": "true",
              "saml_name_id_format": "email",
              "saml_force_name_id_format": "true",
              "saml.assertion.signature": "true",
              "saml.client.signature": "false"
            },
            "defaultClientScopes": [],
            "protocolMappers": [
              {
                "name": "name",
                "protocol": "saml",
                "protocolMapper": "saml-user-property-mapper",
                "consentRequired": false,
                "config": {
                  "attribute.nameformat": "Unspecified",
                  "user.attribute": "firstName",
                  "attribute.name": "displayName"
                }
              },
              {
                "name": "email",
                "protocol": "saml",
                "protocolMapper": "saml-user-property-mapper",
                "consentRequired": false,
                "config": {
                  "attribute.nameformat": "Unspecified",
                  "user.attribute": "email",
                  "attribute.name": "mail"
                }
              },
              {
                "name": "role list",
                "protocol": "saml",
                "protocolMapper": "saml-role-list-mapper",
                "config": {
                  "single": "true",
                  "attribute.nameformat": "Unspecified",
                  "attribute.name": "role"
                }
              }
            ]
```

### 4. AMG(그라파나) 로그인하기 ###
[Sign in with SAML] 버튼을 눌러서 Keycloak 을 통해 로그인 한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-login-01.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-login-02.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/keycloak-login-03.png)


  
## 레퍼런스 ##


* https://aws.amazon.com/blogs/mt/amazon-managed-grafana-supports-direct-saml-integration-with-identity-providers/

* https://stackoverflow.com/questions/69304162/using-googles-sso-with-aws-managed-grafana-and-getting-failed-to-save-the-saml
  
* https://docs.aws.amazon.com/grafana/latest/userguide/authentication-in-AMG-SAML.html

* https://aws.amazon.com/blogs/opensource/authenticating-with-amazon-managed-grafana-using-open-source-keycloak-on-amazon-eks/
 
* [[aws cli] EC2 - TAG 필터링](https://passwd.tistory.com/entry/aws-cli-EC2-TAG-%ED%95%84%ED%84%B0%EB%A7%81)
