eks_mysql_exporter EC2 인스턴스에 접속하여 keycloak 을 설치한다.
```
EC2=$(aws ec2 describe-instances --filter Name=tag:Name,Values=eks_mysql_exporter\
  --query "Reservations[].Instances[].PublicDnsName" --out text)

ssh -i aws-kp-2.pem ec2-user@${EC2}
```

```
docker rm $(docker ps -a -f name=keycloak | awk '{ if (NR != 1) {print $1}}')
```

keycloak 실행하기
```
nohup docker run -p 8080:8080 --name keycloak -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin\
  quay.io/keycloak/keycloak "start-dev" &
```


## 레퍼런스 ##

* https://league-cat.tistory.com/397

* https://github.com/keycloak/keycloak

* [[aws cli] EC2 - TAG 필터링](https://passwd.tistory.com/entry/aws-cli-EC2-TAG-%ED%95%84%ED%84%B0%EB%A7%81)
