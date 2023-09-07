
### 지표서버 설치 ###

HPA 가 동작하기 위해서는 지표 서버가 클러스터에 설치되어 있어야 한다. [Kubernetes 지표 서버 설치](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/eks-metrics.md) 를 참고해서 서버를 설치한다. 


### 서비스 배포(shop-ha) ###

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
$ curl -v telnet://${REDIS_ENDPOINT}:6379
Trying 172.31.1.242:6379...
Connected to test.1234id.clustercfg.euw1.cache.amazonaws.com (172.31.1.242) port 6379 (#0)
```

서비스 배포용 YAML 파일을 생성한다. 
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
---
apiVersion: v1
kind: Service
metadata:
  name: shop-hpa
  namespace: default
  labels:
    app: shop-hpa
spec:
  type: LoadBalancer
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


### HorizontalPodAutoscaler 생성 ###
아래 내용으로 shop-hpa.yaml 을 생성한다.
```
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: shop-hpa
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Deployment
    name: shop-hpa
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  behavior:
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Pods
        value: 1
        periodSeconds: 60
    scaleUp:
      stabilizationWindowSeconds: 0
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
```

```
kubectl apply -f shop-hpa.yaml
```

### HorizontalPodAutoscaler 테스트 ###

뭘로 부하를 줄까? 


## 레퍼런스 ##

* https://kubernetes.io/ko/docs/tasks/run-application/horizontal-pod-autoscale/
* https://aws-diary.tistory.com/138
