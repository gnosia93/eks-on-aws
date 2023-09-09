
### 지표서버 설치 ###

HPA 가 동작하기 위해서는 지표 서버가 클러스터에 설치되어 있어야 한다. [Kubernetes 지표 서버 설치](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-metrics.md) 를 참고해서 서버를 설치한다. 


### 서비스 배포(shop-ha) ###
cloud9 터미널에서 아래 명령어를 실행한다.
```
STAGE_DB=$(aws rds describe-db-instances | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g' | grep 'eks-mysql-stage')
PROD_DB=$(aws rds describe-db-instances | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g' | grep 'eks-mysql-prod')
IMAGE_REPO_ADDR=$(aws ecr describe-repositories | jq '.repositories[].repositoryUri' | sed 's/"//g' | grep 'springboot')
DB_ENDPOINT=${STAGE_DB}
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --show-cache-node-info \
--query 'CacheClusters[?starts_with(CacheClusterId, `eks-redis`)].CacheNodes[].Endpoint[].Address' --out text)

echo "${DB_ENDPOINT}"
echo "${REDIS_ENDPOINT}"
echo "${IMAGE_REPO_ADDR}"
```
Redis 캐시 서버와 연결가능한지 확인한다. Connected 라는 메시지가 나오면 정상적으로 연결된 것이다. 

```
curl -v telnet://${REDIS_ENDPOINT}:6379
```
[결과]
```
Trying 172.31.1.242:6379...
Connected to test.1234id.clustercfg.euw1.cache.amazonaws.com (172.31.1.242) port 6379 (#0)
```

Ctrl + C 를 눌러 빠져나온 다음, 아래의 서비스 배포용 YAML 파일을 생성하고 서비스를 생성한다. 
```
cat <<EOF > shop-service-hpa.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop-hpa
  namespace: default
  labels:
    app: shop-hpa
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shop-hpa
  template:
    metadata:
      labels:
        app: shop-hpa
      annotations:
        builder: 'SoonBeom Kwon'
        prometheus.io/scrape: 'true'
        prometheus.io/path: '/actuator/prometheus'
        prometheus.io/port: '8080'
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
              value: ${DB_ENDPOINT}
            - name: DB_USERNAME
              value: shop
            - name: DB_PASSWORD
              value: shop
            - name: REDIS_ENDPOINT
              value: ${REDIS_ENDPOINT}
            - name: JAVA_TOOL_OPTIONS
              value: "-Xms1024M -Xmx1024M"
          imagePullPolicy: Always
          resources:
            requests:
              cpu: "125m"
              memory: "2048Mi"
            limits:
              cpu: "250m"
              memory: "2048Mi"
---
apiVersion: v1
kind: Service
metadata:
  name: shop-hpa
  namespace: default
  labels:
    app: shop-hpa
spec:
  selector:
    app: shop-ha
  ports:
    - port: 80
      targetPort: 8080
EOF
```

```
kubectl apply -f shop-service-hpa.yaml
kubectl get all
```

### Ingress 생성 ###
인그레이스를 IP 타입으로 생성한다.
```
cat <<EOF > shop-hpa-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-hpa-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/load-balancer-name: shop-hpa-alb
    alb.ingress.kubernetes.io/healthcheck-path: /actuator/health
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '5'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '3'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
spec:
  rules:
   - http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: shop-hpa
              port:
                number: 80
EOF
```
```
kubectl apply -f shop-hpa-ingress.yaml
kubectl describe ingress shop-hpa-ingress
```
#### shop-hpa-ingress 조회결과 ####
```
Name:             shop-hpa-ingress
Namespace:        default
Address:          shop-hpa-alb-124751562.ap-northeast-2.elb.amazonaws.com
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /   shop-hpa:80 (10.1.101.239:8080,10.1.101.68:8080,10.1.101.89:8080 + 2 more...)
Annotations:  alb.ingress.kubernetes.io/healthcheck-interval-seconds: 5
              alb.ingress.kubernetes.io/healthcheck-path: /actuator/health
              alb.ingress.kubernetes.io/healthcheck-timeout-seconds: 3
              alb.ingress.kubernetes.io/healthy-threshold-count: 2
              alb.ingress.kubernetes.io/load-balancer-name: shop-hpa-alb
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: ip
              alb.ingress.kubernetes.io/unhealthy-threshold-count: 2
              kubernetes.io/ingress.class: alb
Events:       <none>
```

### HorizontalPodAutoscaler 생성 ###
shop-hpa 디플로이먼트에 대해서 HPA 를 생성한다. 
```
kubectl autoscale deployment shop-hpa --cpu-percent=30 --min=1 --max=10
```
[결과]
```
horizontalpodautoscaler.autoscaling/shop-hpa autoscaled
```

생성된 HPA 리스트를 조회한다. 
```
kubectl get hpa
```
[결과]
```
NAME       REFERENCE             TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
shop-hpa   Deployment/shop-hpa   <unknown>/30%   1         10        0          8s
```

### HorizontalPodAutoscaler 테스트 ###
eks-locust EC2 인스턴스로 로그인 한 후, https://github.com/gnosia93/eks-on-aws-locust 를 클론하여 아래 명령어를 실행한다.

```
git clone https://github.com/gnosia93/eks-on-aws-locust
cd eks-on-aws-locust
locust -f ./scenario.py -u 300 -P 8080 -H http://shop-hpa-alb-124751562.ap-northeast-2.elb.amazonaws.com
```
* -H 의 http 주소는 Ingress 의 주소 여러분들의 주소로 수정해야 한다. 

[결과]
```
ip-10-1-1-67.ap-northeast-2.compute.internal/INFO/locust.main: Starting web interface at http://0.0.0.0:8080 (accepting connections from all network interfaces)
ip-10-1-1-67.ap-northeast-2.compute.internal/INFO/locust.main: Starting Locust 2.16.1
```
웹브라우저로 eks-locust EC2 인스턴스의 8080 포트로 접속해서 Start swarming 버튼을 누른다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/eks-hpa-1.png)

#### k9s 실행화면 ####

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/eks-hpa.png)

## 레퍼런스 ##

* https://kubernetes.io/ko/docs/tasks/run-application/horizontal-pod-autoscale/
* https://aws-diary.tistory.com/138
