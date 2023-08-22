
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
    app: knote
  ports:
    - port: 80
      targetPort: 8080
EOF

$ kubectl apply -f springboot-shop.yaml
```

## 레퍼런스 ##

* https://learnk8s.io/spring-boot-kubernetes-guide
