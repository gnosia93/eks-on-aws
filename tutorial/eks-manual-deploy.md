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
  name: shop
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

$ kubectl apply -f springboot-shop.yaml

$ kubectl get all
NAME                                   READY   STATUS    RESTARTS   AGE
pod/shop-deployment-547d69d74b-glzbt   1/1     Running   0          11m
pod/shop-deployment-547d69d74b-nn8pm   1/1     Running   0          11m
pod/shop-deployment-547d69d74b-xc445   1/1     Running   0          11m

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.100.0.1      <none>        443/TCP   2d3h
service/shop         ClusterIP   10.100.26.238   <none>        80/TCP    11m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/shop-deployment   3/3     3            3           11m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/shop-deployment-547d69d74b   3         3         3       11m

$ kubectl logs shop-deployment-547d69d74b-glzbt 
Setting Active Processor Count to 4
Calculating JVM memory based on 15478272K available memory
For more information on this calculation, see https://paketo.io/docs/reference/java-reference/#memory-calculator
Calculated JVM Memory Configuration: -XX:MaxDirectMemorySize=10M -Xmx14851315K -XX:MaxMetaspaceSize=114956K -XX:ReservedCodeCacheSize=240M -Xss1M (Total Memory: 15478272K, Thread Count: 250, Loaded Class Count: 17882, Headroom: 0%)
Enabling Java Native Memory Tracking
Adding 137 container CA certificates to JVM truststore
Spring Cloud Bindings Enabled
Picked up JAVA_TOOL_OPTIONS: -Djava.security.properties=/layers/paketo-buildpacks_bellsoft-liberica/java-security-properties/java-security.properties -XX:+ExitOnOutOfMemoryError -XX:ActiveProcessorCount=4 -XX:MaxDirectMemorySize=10M -Xmx14851315K -XX:MaxMetaspaceSize=114956K -XX:ReservedCodeCacheSize=240M -Xss1M -XX:+UnlockDiagnosticVMOptions -XX:NativeMemoryTracking=summary -XX:+PrintNMTStatistics -Dorg.springframework.cloud.bindings.boot.enable=true

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::                (v3.1.2)

2023-08-22T08:32:55.978Z  INFO 1 --- [           main] com.example.shop.ShopApplication         : Starting ShopApplication v0.0.1-SNAPSHOT using Java 17.0.7 with PID 1 (/workspace/BOOT-INF/classes started by cnb in /workspace)
2023-08-22T08:32:55.981Z  INFO 1 --- [           main] com.example.shop.ShopApplication         : The following 1 profile is active: "stage"
2023-08-22T08:32:56.532Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Bootstrapping Spring Data JPA repositories in DEFAULT mode.
2023-08-22T08:32:56.580Z  INFO 1 --- [           main] .s.d.r.c.RepositoryConfigurationDelegate : Finished Spring Data repository scanning in 42 ms. Found 1 JPA repository interfaces.
2023-08-22T08:32:57.099Z  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat initialized with port(s): 8080 (http)
2023-08-22T08:32:57.110Z  INFO 1 --- [           main] o.apache.catalina.core.StandardService   : Starting service [Tomcat]
2023-08-22T08:32:57.110Z  INFO 1 --- [           main] o.apache.catalina.core.StandardEngine    : Starting Servlet engine: [Apache Tomcat/10.1.11]
2023-08-22T08:32:57.195Z  INFO 1 --- [           main] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2023-08-22T08:32:57.197Z  INFO 1 --- [           main] w.s.c.ServletWebServerApplicationContext : Root WebApplicationContext: initialization completed in 1168 ms
2023-08-22T08:32:57.328Z  INFO 1 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Starting...
2023-08-22T08:32:57.612Z  INFO 1 --- [           main] com.zaxxer.hikari.pool.HikariPool        : HikariPool-1 - Added connection com.mysql.cj.jdbc.ConnectionImpl@52f6900a
2023-08-22T08:32:57.614Z  INFO 1 --- [           main] com.zaxxer.hikari.HikariDataSource       : HikariPool-1 - Start completed.
2023-08-22T08:32:57.659Z  INFO 1 --- [           main] o.hibernate.jpa.internal.util.LogHelper  : HHH000204: Processing PersistenceUnitInfo [name: default]
2023-08-22T08:32:57.739Z  INFO 1 --- [           main] org.hibernate.Version                    : HHH000412: Hibernate ORM core version 6.2.6.Final
2023-08-22T08:32:57.741Z  INFO 1 --- [           main] org.hibernate.cfg.Environment            : HHH000406: Using bytecode reflection optimizer
2023-08-22T08:32:57.890Z  INFO 1 --- [           main] o.h.b.i.BytecodeProviderInitiator        : HHH000021: Bytecode provider name : bytebuddy
2023-08-22T08:32:58.023Z  INFO 1 --- [           main] o.s.o.j.p.SpringPersistenceUnitInfo      : No LoadTimeWeaver setup: ignoring JPA class transformer
2023-08-22T08:32:58.261Z  INFO 1 --- [           main] o.h.b.i.BytecodeProviderInitiator        : HHH000021: Bytecode provider name : bytebuddy
2023-08-22T08:32:58.794Z  INFO 1 --- [           main] o.h.e.t.j.p.i.JtaPlatformInitiator       : HHH000490: Using JtaPlatform implementation: [org.hibernate.engine.transaction.jta.platform.internal.NoJtaPlatform]
2023-08-22T08:32:58.797Z  INFO 1 --- [           main] j.LocalContainerEntityManagerFactoryBean : Initialized JPA EntityManagerFactory for persistence unit 'default'
2023-08-22T08:32:59.076Z  WARN 1 --- [           main] JpaBaseConfiguration$JpaWebConfiguration : spring.jpa.open-in-view is enabled by default. Therefore, database queries may be performed during view rendering. Explicitly configure spring.jpa.open-in-view to disable this warning
2023-08-22T08:32:59.334Z  INFO 1 --- [           main] o.s.b.w.embedded.tomcat.TomcatWebServer  : Tomcat started on port(s): 8080 (http) with context path ''
2023-08-22T08:32:59.350Z  INFO 1 --- [           main] com.example.shop.ShopApplication         : Started ShopApplication in 3.761 seconds (process running for 4.083)
```

## Ingress 생성 ##

외부로 서비스를 노출하기 위해서 Ingress 를 생성한다. [Ingress 설치하기](https://three-beans.tistory.com/entry/AWSEKS-%EC%BD%98%EC%86%94%EB%A1%9C-%EC%83%9D%EC%84%B1%ED%95%98%EB%8A%94-EKS-%E2%91%A3-ingress-AWS-LoadBalancer-Controller-%EA%B5%AC%EC%84%B1)

- https://archive.eksworkshop.com/beginner/130_exposing-service/ingress_controller_alb/

### 1. IAM OICD 프로바이더 생성 ###
쿠버네티스 서비스 어카운트가 AWS IAM 리소스에 억세스하고 다룰 수 있도록 OIDC 값으로 IAM Identity 프러바이더를 생성해 줘야 한다.

```
$ eksctl utils associate-iam-oidc-provider \
    --region ap-northeast-2 \
    --cluster eks-cluster-1 \
    --approve
2023-08-22 11:00:52 [ℹ]  will create IAM Open ID Connect provider for cluster "eks-cluster-1" in "ap-northeast-2"
2023-08-22 11:00:52 [✔]  created IAM Open ID Connect provider for cluster "eks-cluster-1" in "ap-northeast-2"
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/iam-oicd-provider.png)

### 2. AWSLoadBalancerControllerIAMPolicy 정책 생성 ###
```
$ echo 'export LBC_VERSION="v2.4.1"' >>  ~/.bash_profile
$ echo 'export LBC_CHART_VERSION="1.4.1"' >>  ~/.bash_profile
$ . ~/.bash_profile

$ curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/${LBC_VERSION}/docs/install/iam_policy.json

$ aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json
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
$ eksctl create iamserviceaccount \
  --cluster eks-cluster-1 \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::${ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
2023-08-22 11:14:47 [ℹ]  1 iamserviceaccount (kube-system/aws-load-balancer-controller) was included (based on the include/exclude rules)
2023-08-22 11:14:47 [!]  metadata of serviceaccounts that exist in Kubernetes will be updated, as --override-existing-serviceaccounts was set
2023-08-22 11:14:47 [ℹ]  1 task: { 
    2 sequential sub-tasks: { 
        create IAM role for serviceaccount "kube-system/aws-load-balancer-controller",
        create serviceaccount "kube-system/aws-load-balancer-controller",
    } }2023-08-22 11:14:47 [ℹ]  building iamserviceaccount stack "eksctl-eks-cluster-1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2023-08-22 11:14:47 [ℹ]  deploying stack "eksctl-eks-cluster-1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
2023-08-22 11:14:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-1-addon-iamserviceaccount-kube-system-aws-load-balancer-controller"
```

### 4. TargetGroupBinding CRDs ###

```
$ kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
customresourcedefinition.apiextensions.k8s.io/ingressclassparams.elbv2.k8s.aws created
customresourcedefinition.apiextensions.k8s.io/targetgroupbindings.elbv2.k8s.aws created

$ kubectl get crd
NAME                                         CREATED AT
cninodes.vpcresources.k8s.aws                2023-08-20T04:51:53Z
eniconfigs.crd.k8s.amazonaws.com             2023-08-20T04:51:50Z
ingressclassparams.elbv2.k8s.aws             2023-08-22T11:18:03Z
policyendpoints.networking.k8s.aws           2023-08-20T04:51:54Z
securitygrouppolicies.vpcresources.k8s.aws   2023-08-20T04:51:53Z
targetgroupbindings.elbv2.k8s.aws            2023-08-22T11:18:03Z
```

### 5. helm 차트 배포 ###
```
$ curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

$ helm version --short

$ helm repo add eks https://aws.github.io/eks-charts

$ helm upgrade -i aws-load-balancer-controller \
    eks/aws-load-balancer-controller \
    -n kube-system \
    --set clusterName=eks-cluster-7 \
    --set serviceAccount.create=false \
    --set serviceAccount.name=aws-load-balancer-controller \
    --set image.tag="${LBC_VERSION}" \
    --version="${LBC_CHART_VERSION}"
Release "aws-load-balancer-controller" does not exist. Installing it now.
NAME: aws-load-balancer-controller
LAST DEPLOYED: Tue Aug 22 12:00:25 2023
NAMESPACE: kube-system
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
AWS Load Balancer controller installed!

$ kubectl -n kube-system rollout status deployment aws-load-balancer-controller
deployment "aws-load-balancer-controller" successfully rolled out

$ kubectl -n kube-system get all
NAME                                               READY   STATUS    RESTARTS   AGE
pod/aws-load-balancer-controller-9b5577c7f-k9jsq   1/1     Running   0          4m59s
pod/aws-load-balancer-controller-9b5577c7f-xsnrp   1/1     Running   0          4m59s
pod/aws-node-9dq6t                                 1/1     Running   0          2d7h
pod/aws-node-d5hlv                                 1/1     Running   0          2d7h
pod/coredns-76b4dcc5cc-s8c2n                       1/1     Running   0          2d7h
pod/coredns-76b4dcc5cc-z55c7                       1/1     Running   0          2d7h
pod/kube-proxy-v55qw                               1/1     Running   0          2d7h
pod/kube-proxy-wf487                               1/1     Running   0          2d7h

NAME                                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)         AGE
service/aws-load-balancer-webhook-service   ClusterIP   10.100.254.171   <none>        443/TCP         5m
service/kube-dns                            ClusterIP   10.100.0.10      <none>        53/UDP,53/TCP   2d7h

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/aws-node     2         2         2       2            2           <none>          2d7h
daemonset.apps/kube-proxy   2         2         2       2            2           <none>          2d7h

NAME                                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/aws-load-balancer-controller   2/2     2            2           5m
deployment.apps/coredns                        2/2     2            2           2d7h

NAME                                                     DESIRED   CURRENT   READY   AGE
replicaset.apps/aws-load-balancer-controller-9b5577c7f   2         2         2       5m
replicaset.apps/coredns-76b4dcc5cc                       2         2         2       2d7h
```


## 레퍼런스 ##

* [eks에서 exec plugin is configured to use API version 이슈](https://shblue21.github.io/aws/eks%EC%97%90%EC%84%9C-exec-plugin-is-configured-to-use-API-version-%EC%9D%B4%EC%8A%88/)
* https://jamesdefabia.github.io/docs/user-guide/kubectl/kubectl_api-versions/

* https://stackoverflow.com/questions/72126048/circleci-message-error-exec-plugin-invalid-apiversion-client-authentication
  
* https://github.com/hashicorp/terraform-provider-helm/issues/893

* [Ingress 로 서비스 외부로 노출 시키기](https://three-beans.tistory.com/entry/AWSEKS-%EC%BD%98%EC%86%94%EB%A1%9C-%EC%83%9D%EC%84%B1%ED%95%98%EB%8A%94-EKS-%E2%91%A3-ingress-AWS-LoadBalancer-Controller-%EA%B5%AC%EC%84%B1)
  
* https://learnk8s.io/spring-boot-kubernetes-guide
