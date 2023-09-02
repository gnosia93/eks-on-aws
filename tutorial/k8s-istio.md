## Istio 적용하기 ##

 * [Istio 설치하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-provision.md)

 * [Istio 인젝션 설정](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-injection.md)

 * [Istio 어플리케이션 배포 - bookinfo](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-bookinfo.md)


## Shop 어플리케이션 Istio 적용 ##

### 서비스 개발 ###
istio 를 적용할 마이크로 서비스의 구조는 다음과 같은데 주문 발생시 상품과 혜택(포인트)를 호출한다. 각 서비스의 서브 링크로 방문해서 어플리케이션을 빌드후 ECR 에 푸시한다.

```
주문 -> 상품(재고조회) 
    -> 혜택(포인트)
```
  
  * [주문 - springboot](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-service-order.md)
  * [상품 - python flask](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-flask-prod.md
)
  * [혜택(포인트) - node.js](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-nodejs-point.md)


### 서비스 배포 ###

EKS 클러스터에 서비스를 배포한다. 

#### 1. flask-prod ####

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
            - containerPort: 3001
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

#### 2. nodejs-point ####

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

#### 3. springboot-order ####

```
$ kubectl get endpoints
NAME           ENDPOINTS                                              AGE
flask-prod     10.1.101.133:3001,10.1.101.190:3001,10.1.102.10:3001   20m
kubernetes     10.1.101.212:443,10.1.102.215:443                      4h29m
nodejs-point   10.1.101.87:3000,10.1.102.46:3000,10.1.102.64:3000     19m
shop           10.1.101.15:8080,10.1.101.99:8080,10.1.102.78:8080     3h16m
```

```
STAGE_DB=$(aws rds describe-db-instances | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g' | grep 'eks-mysql-stage')
IMAGE_REPO_ADDR=$(aws ecr describe-repositories | jq '.repositories[].repositoryUri' | sed 's/"//g' | grep 'springboot')
```

```
cat <<EOF > shop-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  namespace: default
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
          image: ${IMAGE_REPO_ADDR}
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
            - name: DB_ENDPOINT
              value: ${STAGE_DB}
            - name: DB_USERNAME
              value: shop
            - name: DB_PASSWORD
              value: shop
            - name: JAVA_TOOL_OPTIONS
              value: "-Xms1024M -Xmx1024M"
            - name: PROD_SERVICE_ENDPOINT
              value: "http://flask-prod.default.svc.cluster.local/prod"
            - name: POINT_SERVICE_ENDPOINT
              value: "http://nodejs-point.default.svc.cluster.local/point"
          imagePullPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: shop
  namespace: default
  labels:
    app: shop
spec:
  type: NodePort
  selector:
    app: shop
  ports:
    - port: 80
      targetPort: 8080
EOF
```

```
kubectl apply -f shop-service.yaml
```


#### 4. 서비스 실행 ####
```
kubectl logs -f -l app=shop --all-containers=true
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-order-eks.png)



## 레퍼런스 ##

* https://bcho.tistory.com/1266

* https://www.lihaoyi.com/post/SimpleWebandApiServerswithScala.html

