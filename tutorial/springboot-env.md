
springboot properties 파일의 데이터베이스 연결정보 ${DB_HOST}, ${DB_USERNAME}, ${DB_PASSWORD} 값을 환경변수로 부터 받아 올수 있도록 설정하였다. 

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
env 부분에서 환경변수로 값들을 컨테이너 어플리케이션에 전달하고 있다.


## 레퍼런스 ##

* https://waspro.tistory.com/681

* https://aws-diary.tistory.com/131
