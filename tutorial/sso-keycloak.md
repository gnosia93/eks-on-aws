eks_mysql_exporter EC2 인스턴스에 접속하여 keycloak 을 설치한다.
```
aws ec2 describe-instances --filter Name=tag:Name,Values=eks_mysql_exporter\
  --query "Reservations[].Instances[].PublicDnsName" --out text
```


```
docker run -p 8080:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin quay.io/keycloak/keycloak:10.0.2
```


## 레퍼런스 ##

* https://league-cat.tistory.com/397

* https://github.com/keycloak/keycloak
