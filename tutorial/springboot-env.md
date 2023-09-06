
springboot properties 의 설정값은 런타임의 환경변수로 부터 받아올 수 있다. ${DB_HOST}, ${DB_USERNAME}, ${DB_PASSWORD} 가 설정값이다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-env-db.png)

쿠버네티스의 환경인 경우 아래의 설정을 참고한다. 
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-deployment
  labels:
    app: shop
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shop
  template:
    metadata:
      labels:
        app: shop
    spec:
      containers:
        - name: shop
          image: 499514681453.dkr.ecr.ap-northeast-2.amazonaws.com/eks-on-aws-springboot
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
            - name: DB_ENDPOINT
              value: eks-mysql-stage.czed7onsq5sy.ap-northeast-2.rds.amazonaws.com
            - name: DB_USER
              value: shop
            - name: DB_PASSWORD
              value: shop
          imagePullPolicy: Always
```
env 부분에서 환경변수로 값들을 설정해서 컨테이너 어플리케이션에 전달하고 있다.


## ConfigMap ##

...

## Secret ##

...



## 레퍼런스 ##

* https://waspro.tistory.com/681

* https://aws-diary.tistory.com/131

* [[Spring Boot] AWS Secret Manager를 이용하여 프로퍼티를 관리하자](https://velog.io/@korea3611/Spring-Boot-AWS-Secret-Manager%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-%ED%94%84%EB%A1%9C%ED%8D%BC%ED%8B%B0%EB%A5%BC-%EA%B4%80%EB%A6%AC%ED%95%98%EC%9E%90)

* https://docs.aws.amazon.com/ko_kr/secretsmanager/latest/userguide/rotate-secrets_turn-on-for-db.html
