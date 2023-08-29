* 주문 -> 혜택(포인트) -> 결제 

  * 주문 - 스프링부트 
  * [혜택(포인트) - node.js](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-nodejs.md)
  * 결제 - flask


## 서비스 배포 ##

### nodejs-point ###
```
cat <<EOF > shop-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-point
  namespace: default
  labels:
    app: nodejs-point
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs-point
  template:
    metadata:
      labels:
        app: nodejs-point
    spec:
      containers:
        - name: nodejs-point
          image: 499514681453.dkr.ecr.ap-northeast-2.amazonaws.com/nodejs-point
          ports:
            - containerPort: 3000
          imagePullPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-point
  namespace: default
  labels:
    app: nodejs-point
spec:
  selector:
    app: nodejs-point
  ports:
    - port: 80
      targetPort: 3000
EOF
```
