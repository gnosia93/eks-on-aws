## 어플리케이션 배포 ##

cloud9 에서 아래 명령어 실행해서 어플리케이션을 배포한다. 

```
$ cat <<EOF > springboot-shop.yaml
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
          imagePullPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: knote
spec:
  selector:
    app: shop
  ports:
    - port: 80
      targetPort: 8080
EOF

$ kubectl apply -f springboot-shop.yaml
```

## 레퍼런스 ##

* https://learnk8s.io/spring-boot-kubernetes-guide
