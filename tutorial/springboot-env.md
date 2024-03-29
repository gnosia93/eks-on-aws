
springboot properties 의 설정값은 런타임의 환경변수로 부터 받아올 수 있다. 이 예제에서는 ${DB_HOST}, ${DB_USERNAME}, ${DB_PASSWORD} 가 바로 properties 들이다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/springboot-env-db.png)

쿠버네티스의 경우 env 섹션에 아래와 같이 선언하면 환경변수 값들이 컨테이너 어플리케이션에게 전달되어 스프링 부트의 properties 로 자동 셋팅된다.   
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
          image: 00000000000.dkr.ecr.ap-northeast-2.amazonaws.com/eks-on-aws-springboot
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

## ConfigMap ##
Key / Value 쌍을 저장하는 컨피그맵을 이용해서 어플리케이션 데이터(스트링 or 바이너리)를 저장할 수 있다.  
어플리케이션 코드와 데이터가 분리되기 때문에, 데이터 변경으로 인한 어플리케이션 재배포는 하지 않아도 된다 (단, 재시작은 필요)  
아래 예제에서는 DB_ENDPOINT, DB_USER, DB_PASSWORD 를 ConfigMap 에 저장하고 있다.     
(주의) 데이터베이스 user/password 는 보안상 이슈가 생길 수 있으니, AWS SecretManager 와 같은 서비스를 사용하는 것이 좋다.
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: shop-config
data:
  DB_ENDPOINT: eks-mysql-stage.czed7onsq5sy.ap-northeast-2.rds.amazonaws.com
  DB_USER : shop
  DB_PASSWORD : shop
EOF
---
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
          image: 00000000000.dkr.ecr.ap-northeast-2.amazonaws.com/eks-on-aws-springboot
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
            - name: DB_ENDPOINT
              valueFrom:
                configMapKeyRef:
                  name: shop-config
                  key: DB_ENDPOINT
            - name: DB_USER
              valueFrom:
                configMapKeyRef:
                  name: shop-config
                  key: DB_USER
            - name: DB_PASSWORD
               valueFrom:
                configMapKeyRef:
                  name: shop-config
                  key: DB_PASSWORD
          imagePullPolicy: Always
```

## Secret ##
평문으로 데이터를 Key / Value 형태로 저장하는 컨피그맵에 반해 Secret 는 Base64 로 인코딩해서 데이터를 저장하게 한다.
Secret 에 저장하기 전에 데이터를 base64 형태로 변환한 후 저장해야 하고, 읽어 올때는 자동 디코딩되어 진다.

```
apiVersion: v1
kind: Secret
metadata:
  name: shop-secret
type: Opaque
data:
  DB_ENDPOINT: ZWtzLW15c3FsLXN0YWdlLmN6ZWQ3b25zcTVzeS5hcC1ub3J0aGVhc3QtMi5yZHMuYW1hem9uYXdzLmNvbQo=
  DB_USER: c2hvcAo=
  DB_PASSWORD: c2hvcAo=
---
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
          image: 00000000000.dkr.ecr.ap-northeast-2.amazonaws.com/eks-on-aws-springboot
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
            - name: DB_ENDPOINT
              valueFrom:
                secretKeyRef:
                  name: shop-secret
                  key: DB_ENDPOINT
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: shop-secret
                  key: DB_USER
            - name: DB_PASSWORD
               valueFrom:
                secretKeyRef:
                  name: shop-secret
                  key: DB_PASSWORD
          imagePullPolicy: Always
```

## 레퍼런스 ##

* https://waspro.tistory.com/681

* https://aws-diary.tistory.com/131

* [[Spring Boot] AWS Secret Manager를 이용하여 프로퍼티를 관리하자](https://velog.io/@korea3611/Spring-Boot-AWS-Secret-Manager%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-%ED%94%84%EB%A1%9C%ED%8D%BC%ED%8B%B0%EB%A5%BC-%EA%B4%80%EB%A6%AC%ED%95%98%EC%9E%90)

* https://docs.aws.amazon.com/ko_kr/secretsmanager/latest/userguide/rotate-secrets_turn-on-for-db.html
