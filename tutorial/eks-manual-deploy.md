## 어플리케이션 배포 ##

이번 챕터에서는 shop 프로젝트를 서비스로 배포하고 인그레스를 설치하여 웹으로 노출할 예정이다.  
cloud9 에서 아래 명령어 실행해서 어플리케이션을 배포한다. 

#### 배포용 YAML 파일 생성 ####

컨테이너 이미지 주소(image), DB_ENDPOINT, REDIS_ENDPOINT 정보를 받아온다.
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
            - name: PROD_SERVICE_ENDPOINT
              value: ${PROD_SERVICE_ENDPOINT}
            - name: POINT_SERVICE_ENDPOINT
              value: ${POINT_SERVICE_ENDPOINT}
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
* 컨테이너화 된 자바 힙 메모리 설정 방법 - https://recordsoflife.tistory.com/267

#### NodeGroup IAM Role 수정  ####

EKS 노드그룹의 ROLE eksctl-eks-workshop-nodegroup-ng-NodeInstanceRole-xxxxxxxx 에 SecretManagerReadWrite 권한을 추가해 준다.
[스프링 부트 - Secret Manager 데이터베이스 설정 분리 / 암호화](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-secretmanager.md) 의 EKS 노드그룹 권한 설정 부분을 참고하여 권한을 추가한다.
  
(부연설명) gradle dependancy 에 SecretManager 관련 의존성이 추가되어서 SPRING_PROFILES_ACTIVE 값이 stage 임에도 불구하고 SecretManager 에 접근하는 것으로 보인다.   
즉 의존성을 추가하기만 해도 스프링 부트 실행시 뭔가를 체크하는 듯.. 

#### K8S 오브젝트 생성 및 확인 ####
```
kubectl apply -f shop-service.yaml

kubectl get all
```

[결과]
```
NAME                                   READY   STATUS              RESTARTS   AGE
pod/shop-deployment-547d69d74b-k5lhr   1/1     Running             0          5s
pod/shop-deployment-547d69d74b-lrtsk   0/1     ContainerCreating   0          5s
pod/shop-deployment-547d69d74b-rd9bj   0/1     ContainerCreating   0          5s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.100.0.1      <none>        443/TCP        34m
service/shop         NodePort    10.100.96.117   <none>        80:31889/TCP   6s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/shop-deployment   2/3     3            2           6s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/shop-deployment-547d69d74b   3         3         2       6s
hopigaga:~ $ kubectl get all
NAME                                   READY   STATUS    RESTARTS   AGE
pod/shop-deployment-547d69d74b-k5lhr   1/1     Running   0          29s
pod/shop-deployment-547d69d74b-lrtsk   1/1     Running   0          29s
pod/shop-deployment-547d69d74b-rd9bj   1/1     Running   0          29s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   10.100.0.1      <none>        443/TCP        35m
service/shop         NodePort    10.100.96.117   <none>        80:31889/TCP   29s

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/shop-deployment   3/3     3            3           29s

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/shop-deployment-547d69d74b   3         3         3       29s
```

#### 파드 확인 ####
```
kubectl get pod -o wide
```

[결과]
```
NAME                               READY   STATUS    RESTARTS   AGE   IP              NODE                                               NOMINATED NODE   READINESS GATES
shop-deployment-547d69d74b-k5lhr   1/1     Running   0          50s   172.31.43.245   ip-172-31-34-243.ap-northeast-2.compute.internal   <none>           <none>
shop-deployment-547d69d74b-lrtsk   1/1     Running   0          50s   172.31.22.254   ip-172-31-16-120.ap-northeast-2.compute.internal   <none>           <none>
shop-deployment-547d69d74b-rd9bj   1/1     Running   0          50s   172.31.21.219   ip-172-31-26-197.ap-northeast-2.compute.internal   <none>           <none>
```

#### 스프링 부트 로그 확인 ####
```
kubectl logs shop-deployment-547d69d74b-glzbt
```

[결과]
``` 
Setting Active Processor Count to 8
Calculating JVM memory based on 31550620K available memory
For more information on this calculation, see https://paketo.io/docs/reference/java-reference/#memory-calculator
Calculated JVM Memory Configuration: -XX:MaxDirectMemorySize=10M -XX:MaxMetaspaceSize=161305K -XX:ReservedCodeCacheSize=240M -Xss1M (Total Memory: 31550620K, Thread Count: 250, Loaded Class Count: 26065, Headroom: 0%)
Enabling Java Native Memory Tracking
Adding 137 container CA certificates to JVM truststore
Spring Cloud Bindings Enabled
Picked up JAVA_TOOL_OPTIONS: -Xms1024M -Xmx1024M -Djava.security.properties=/layers/paketo-buildpacks_bellsoft-liberica/java-security-properties/java-security.properties -XX:+ExitOnOutOfMemoryError -XX:ActiveProcessorCount=8 -XX:MaxDirectMemorySize=10M -XX:MaxMetaspaceSize=161305K -XX:ReservedCodeCacheSize=240M -Xss1M -XX:+UnlockDiagnosticVMOptions -XX:NativeMemoryTracking=summary -XX:+PrintNMTStatistics -Dorg.springframework.cloud.bindings.boot.enable=true

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.1.2)

2023-09-06T22:28:44.633Z  INFO 1 --- [           main] b.c.PropertySourceBootstrapConfiguration : Located property source: [BootstrapPropertySource {name='bootstrapProperties-/secret/springboot-shop-stage_stage'}, BootstrapPropertySource {name='bootstrapProperties-/secret/springboot-shop-stage'}, BootstrapPropertySource {name='bootstrapProperties-/secret/application_stage'}, BootstrapPropertySource {name='bootstrapProperties-/secret/application'}]
2023-09-06T22:28:44.644Z  INFO 1 --- [           main] com.example.shop.ShopApplication         : The following 1 profile is active: "stage"
2023-09-06T22:28:45.156Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Multiple Spring Data modules found, entering strict repository configuration mode
2023-09-06T22:28:45.157Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data JPA repositories in DEFAULT mode.
2023-09-06T22:28:45.321Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 158 ms. Found 1 JPA repository interfaces.
2023-09-06T22:28:45.330Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Multiple Spring Data modules found, entering strict repository configuration mode
2023-09-06T22:28:45.331Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data Redis repositories in DEFAULT mode.
2023-09-06T22:28:45.340Z  INFO 1 --- [           main] .RepositoryConfigurationExtensionSupport : Spring Data Redis - Could not safely identify store assignment for repository candidate interface com.example.shop.repository.MemberRepository; If you want this repository to be a Redis repository, consider annotating your entities with one of these annotations: org.springframework.data.redis.core.RedisHash (preferred), or consider extending one of the following types with your repository: org.springframework.data.keyvalue.repository.KeyValueRepository
2023-09-06T22:28:45.340Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 3 ms. Found 0 Redis repository interfaces.
2023-09-06T22:28:45.671Z  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2023-09-06T22:28:45.679Z  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2023-09-06T22:28:45.679Z  INFO 1 --- [           main] o.apache.catalina.core.StandardEngine    : Starting Servlet engine: [Apache Tomcat/10.1.11]
2023-09-06T22:28:45.727Z  INFO 1 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2023-09-06T22:28:45.728Z  INFO 1 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 1074 ms
2023-09-06T22:28:45.919Z  INFO 1 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2023-09-06T22:28:46.048Z  INFO 1 --- [           main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Added connection com.mysql.cj.jdbc.ConnectionImpl@6da9541c
2023-09-06T22:28:46.050Z  INFO 1 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2023-09-06T22:28:46.080Z  INFO 1 --- [           main] o.hibernate.jpa.internal.util.LogHelper  : HHH000204: Processing PersistenceUnitInfo [name: default]
2023-09-06T22:28:46.114Z  INFO 1 --- [           main] org.hibernate.Version                    : HHH000412: Hibernate ORM core version 6.2.6.Final
2023-09-06T22:28:46.115Z  INFO 1 --- [           main] org.hibernate.cfg.Environment            : HHH000406: Using bytecode reflection optimizer
2023-09-06T22:28:46.207Z  INFO 1 --- [           main] o.h.b.i.BytecodeProviderInitiator        : HHH000021: Bytecode provider name : bytebuddy
2023-09-06T22:28:46.295Z  INFO 1 --- [           main] o.s.o.j.p.SpringPersistenceUnitInfo      : No LoadTimeWeaver setup: ignoring JPA class transformer
2023-09-06T22:28:46.459Z  INFO 1 --- [           main] o.h.b.i.BytecodeProviderInitiator        : HHH000021: Bytecode provider name : bytebuddy
2023-09-06T22:28:46.850Z  INFO 1 --- [           main] o.h.e.t.j.p.i.JtaPlatformInitiator       : HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.NoJtaPlatform]
2023-09-06T22:28:46.853Z  INFO 1 --- [           main] j.LocalContainerEntityManagerFactoryBean : Initialized JPA EntityManagerFactory for persistence unit 'default'
2023-09-06T22:28:47.115Z  INFO 1 --- [           main] org.redisson.Version                     : Redisson 3.23.4
2023-09-06T22:28:47.305Z  INFO 1 --- [isson-netty-2-6] o.r.c.pool.MasterPubSubConnectionPool    : 1 connections initialized for eks-redis.bchkjx.0001.apn2.cache.amazonaws.com/10.1.202.176:6379
2023-09-06T22:28:47.418Z  INFO 1 --- [sson-netty-2-20] o.r.c.pool.MasterConnectionPool          : 24 connections initialized for eks-redis.bchkjx.0001.apn2.cache.amazonaws.com/10.1.202.176:6379
2023-09-06T22:28:47.475Z  WARN 1 --- [           main] JpaBaseConfiguration$JpaWebConfiguration : spring.jpa.open-in-view is enabled by default. Therefore, database queries may be performed during view rendering. Explicitly configure spring.jpa.open-in-view to disable this warning
2023-09-06T22:28:47.902Z  INFO 1 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 3 endpoint(s) beneath base path '/actuator'
2023-09-06T22:28:47.950Z  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2023-09-06T22:28:47.962Z  INFO 1 --- [           main] com.example.shop.ShopApplication         : Started ShopApplication in 4.591 seconds (process running for 4.906)
```

## Ingress 생성 ##

외부로 서비스를 노출하기 위해서 Ingress 를 생성한다. [Ingress 설치하기](https://three-beans.tistory.com/entry/AWSEKS-%EC%BD%98%EC%86%94%EB%A1%9C-%EC%83%9D%EC%84%B1%ED%95%98%EB%8A%94-EKS-%E2%91%A3-ingress-AWS-LoadBalancer-Controller-%EA%B5%AC%EC%84%B1)

- https://archive.eksworkshop.com/beginner/130_exposing-service/ingress_controller_alb/

### 1. IAM OICD 프로바이더 생성 ###
쿠버네티스 서비스 어카운트가 AWS IAM 리소스에 억세스하고 다룰 수 있도록 OIDC 값으로 IAM Identity 프러바이더를 생성해 줘야 한다.

```
eksctl utils associate-iam-oidc-provider \
    --region ap-northeast-2 \
    --cluster $CLUSTER_NAME \
    --approve
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/iam-oicd-provider.png)

### 2. AWSLoadBalancerControllerIAMPolicy 정책 생성 ###
```
echo 'export LBC_VERSION="v2.6.0"' >>  ~/.bash_profile
. ~/.bash_profile

curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${LBC_VERSION}/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
```

[결과]
```
{
    "Policy": {
        "PolicyName": "AWSLoadBalancerControllerIAMPolicy", 
        "PermissionsBoundaryUsageCount": 0, 
        "CreateDate": "2023-08-22T11:12:05Z", 
        "AttachmentCount": 0, 
        "IsAttachable": true, 
        "PolicyId": "ANPAXITLFFBWUJLM6A2BI", 
        "DefaultVersionId": "v1", 
        "Path": "/", 
        "Arn": "arn:aws:iam::499514681453:policy/AWSLoadBalancerControllerIAMPolicy", 
        "UpdateDate": "2023-08-22T11:12:05Z"
    }
}
```

### 3. aws-load-balancer-controller 서비스 어카운트 생성 ###
```
eksctl create iamserviceaccount \
  --cluster $CLUSTER_NAME \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

### 4. TargetGroupBinding CRDs ###

```
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
```

```
kubectl get crd
```

### 5. Load Balancer 컨트롤러 생성 ###

* https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases 
* [https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/)
```
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
```

```
helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="${LBC_VERSION}" 
#    --version="${LBC_CHART_VERSION}"
```

```
kubectl -n kube-system rollout status deployment aws-load-balancer-controller
```

### 6. Ingress 생성 ###
https://kubernetes.io/ko/docs/concepts/services-networking/ingress/

******
ALB 가 생성되는 VPC의 퍼블릭 서브넷에 대해 Key가 kubernetes.io/role/elb Value가 1인 태그를 설정한다. (AWS 콘솔에서 설정)  
aws ec2 create-tags --resources $subnet-id --tags "Key=kubernetes.io/role/elb,Value=1"
******

```
cat <<EOF > shop-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: shop-ingress
  namespace: default
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/target-type: instance
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/load-balancer-name: shop-alb
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
              name: shop
              port:
                number: 80
EOF
```
```
kubectl apply -f shop-ingress.yaml
```

```
kubectl describe ingress shop-ingress
```
[결과]  
Successfully reconciled 라는 메시지가 출력되어야 한다.
```
Name:             shop-ingress
Labels:           <none>
Namespace:        default
Address:          shop-alb-1405949135.ap-northeast-2.elb.amazonaws.com
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /   shop:80 (172.31.21.245:8080,172.31.33.139:8080,172.31.34.38:8080)
Annotations:  alb.ingress.kubernetes.io/load-balancer-name: shop-alb
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: instance
              kubernetes.io/ingress.class: alb
Events:
  Type    Reason                  Age   From     Message
  ----    ------                  ----  ----     -------
  Normal  SuccessfullyReconciled  7s    ingress  Successfully reconciled
```

### 7. Ingress 응답 확인 ###

스프링 부트 어플리케이션에 설치된 actuator 의 health 체크 페이지를 호출한다.
아래와 같은 메시지가 나오는 경우 정상적으로 인그레스가 동작하는 것이다. 

```
$ curl shop-alb-1152585058.ap-northeast-2.elb.amazonaws.com/actuator/health
{"status":"UP","groups":["liveness","readiness"]}
```


## 트러블 슈팅 ##

*  Failed build model due to couldn't auto-discover subnets: unable to resolve at least one subnet (0 match VPC and tags)

```
$ kubectl describe ingress shop-ingress
Name:             shop-ingress
Namespace:        default
Address:          
Default backend:  default-http-backend:80 (<error: endpoints "default-http-backend" not found>)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           
              /   shop:80 (10.1.101.42:8080,10.1.102.12:8080,10.1.102.5:8080)
Annotations:  alb.ingress.kubernetes.io/healthcheck-interval-seconds: 5
              alb.ingress.kubernetes.io/healthcheck-path: /actuator/health
              alb.ingress.kubernetes.io/healthcheck-timeout-seconds: 3
              alb.ingress.kubernetes.io/healthy-threshold-count: 2
              alb.ingress.kubernetes.io/load-balancer-name: shop-alb
              alb.ingress.kubernetes.io/scheme: internet-facing
              alb.ingress.kubernetes.io/target-type: instance
              alb.ingress.kubernetes.io/unhealthy-threshold-count: 2
              kubernetes.io/ingress.class: alb
Events:
  Type     Reason            Age                 From     Message
  ----     ------            ----                ----     -------
  Warning  FailedBuildModel  14s (x13 over 36s)  ingress  Failed build model due to couldn't auto-discover subnets: unable to resolve at least one subnet (0 match VPC and tags)
```

[해결방법]   
ALB 가 생성되는 VPC의 퍼블릭 서브넷에 대해 Key가 kubernetes.io/role/elb Value가 1인 태그를 설정한다.  


* User: arn:aws:sts::499514681453:assumed-role/eksctl-eks-workshop-nodegroup-ng-NodeInstanceRole-19V44PLCLT4DL/i-0f5e06f997358fa77 is not authorized to perform: secretsmanager:GetSecretValue on resource: /secret/springboot-shop-stage_stage because no identity-based policy allows the secretsmanager:GetSecretValue action (Service: AWSSecretsManager; Status Code: 400; Error Code: AccessDeniedException; Request ID: f96450fb-7f8d-4ed8-a3a5-ffa50dcf334a; Proxy: null)

[해결방법]   
eksctl-eks-workshop-nodegroup-ng-NodeInstanceRole-19V44PLCLT4DL 롤에 SecretManagerReadWrite 권한을 추가해 준다...
```
kubectl rollout restart deployment shop                                                                                                             
deployment.apps/shop restarted

kubectl get all
```  

## 레퍼런스 ##
* [AWS EKS에서 ALB Ingress Controller 활용기](https://medium.com/coinone/aws-eks%EC%97%90%EC%84%9C-alb-ingress-controller-%ED%99%9C%EC%9A%A9%EA%B8%B0-6a29aa2a1144)
* [eks에서 exec plugin is configured to use API version 이슈](https://shblue21.github.io/aws/eks%EC%97%90%EC%84%9C-exec-plugin-is-configured-to-use-API-version-%EC%9D%B4%EC%8A%88/)
* https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_api-versions/

* https://stackoverflow.com/questions/72126048/circleci-message-error-exec-plugin-invalid-apiversion-client-authentication
  
* https://github.com/hashicorp/terraform-provider-helm/issues/893

* [Ingress 로 서비스 외부로 노출 시키기](https://three-beans.tistory.com/entry/AWSEKS-%EC%BD%98%EC%86%94%EB%A1%9C-%EC%83%9D%EC%84%B1%ED%95%98%EB%8A%94-EKS-%E2%91%A3-ingress-AWS-LoadBalancer-Controller-%EA%B5%AC%EC%84%B1)
  
* https://learnk8s.io/spring-boot-kubernetes-guide

* https://medium.com/edrolo-engineering/writing-filters-for-the-aws-ec2-cli-a985c29b9267
