****
currently in development ..
****

## 서비스 개발 ##
isto 를 적용할 마이크로 서비스의 호출 구조는 다음과 같다. 주문 서비스가 상품과 혜택을 각각 호출하는 구조이나 여기서는 편의상 순서대로 chaining 으로 호출하는 것으로 테스트 한다. 아래 서브 링크로 방문해서 각 서비스를 ECR 에 푸시한다.

* 주문 -> 상품(재고조회) -> 혜택(포인트)
  
  * [주문 - 스프링부트](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-service-order.md)
  * [상품 - python flask](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-service-prod.md)
  * [혜택(포인트) - node.js](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-service-point.md)


## 서비스 배포 ##

EKS 클러스터에 서비스를 배포한다. 

### 1. flask-prod ###
3001 포트로 노출한다.
```
PROD_IMAGE_REPO_ADDR=$(aws ecr describe-repositories | jq '.repositories[].repositoryUri' | sed 's/"//g' | grep 'flask-prod')
POINT_IMAGE_REPO_ADDR=$(aws ecr describe-repositories | jq '.repositories[].repositoryUri' | sed 's/"//g' | grep 'nodejs-point')
```

```
cat <<EOF > flask-prod.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-prod
  namespace: default
  labels:
    app: flask-prod
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-prod
  template:
    metadata:
      labels:
        app: flask-prod
    spec:
      containers:
        - name: flask-prod
          image: ${PROD_IMAGE_REPO_ADDR}
          ports:
            - containerPort: 3000
          imagePullPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: flask-prod
  namespace: default
  labels:
    app: flask-prod
spec:
  selector:
    app: flask-prod
  ports:
    - port: 80
      targetPort: 3001
EOF
```
```
kubectl apply -f flask-prod.yaml
```

### 2. nodejs-point ###
3000 포트로 노출한다. 
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
          image: ${POINT_IMAGE_REPO_ADDR}
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

## istio 구성하기 ##

 * [Istio 설치](https://github.com/gnosia93/eks-on-aws/edit/main/tutorial/k8s-istio-install.md)
