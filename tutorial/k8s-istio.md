****
currently in development ..
****

## 서비스 개발 ##
isto 를 적용할 마이크로 서비스의 코드는 다음과 같다. 아래 서브 링크로 방문해서 각 서비스를 ECR 에 푸시한다.

* 주문 -> 상품재고 -> 혜택(포인트) -> 결재완료  
  * [주문 - 스프링부트](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-springboot.md)
  * [상품 - python flask](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-flask.md)
  * [혜택(포인트) - node.js](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-nodejs.md)

## 서비스 배포 ##

### 1. nodejs-point ###
```
cat <<EOF > nodejs-point.yaml
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
```
kubectl apply -f nodejs-point.yaml
```

### 2. flask-inventory ###

## istio 설치 ##

 * https://github.com/gnosia93/eks-on-aws/edit/main/tutorial/k8s-istio-install.md
