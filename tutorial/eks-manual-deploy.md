
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: knote
spec:
  replicas: 3
  selector:
    matchLabels:
      app: knote
  template:
    metadata:
      labels:
        app: knote
    spec:
      containers:
        - name: shop
          image: 499514681453.dkr.ecr.ap-northeast-2.amazonaws.com/eks-on-aws-springboot
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
          imagePullPolicy: Always
```

## 레퍼런스 ##

* https://learnk8s.io/spring-boot-kubernetes-guide
