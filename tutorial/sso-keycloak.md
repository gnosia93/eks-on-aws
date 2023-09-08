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
