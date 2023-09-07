eks_mysql_exporter EC2 인스턴스에 접속하여 keycloak 을 설치한다.
```
EC2=$(aws ec2 describe-instances --filter Name=tag:Name,Values=eks_mysql_exporter\
  --query "Reservations[].Instances[].PublicDnsName" --out text)

ssh -i aws-kp-2.pem ec2-user@${EC2}
```


```
docker run -d -p 8080:8080 --name keycloak -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin quay.io/keycloak/keycloak\
  kc.sh start
```


## 레퍼런스 ##

* https://league-cat.tistory.com/397

* https://github.com/keycloak/keycloak

* [[aws cli] EC2 - TAG 필터링](https://passwd.tistory.com/entry/aws-cli-EC2-TAG-%ED%95%84%ED%84%B0%EB%A7%81)
