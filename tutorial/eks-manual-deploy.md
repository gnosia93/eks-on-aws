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
외부로 서비스를 노출하기 위해서 Ingress 를 생성한다.


## 레퍼런스 ##

* [Ingress 로 서비스 외부로 노출 시키기](https://three-beans.tistory.com/entry/AWSEKS-%EC%BD%98%EC%86%94%EB%A1%9C-%EC%83%9D%EC%84%B1%ED%95%98%EB%8A%94-EKS-%E2%91%A3-ingress-AWS-LoadBalancer-Controller-%EA%B5%AC%EC%84%B1)
  
* https://learnk8s.io/spring-boot-kubernetes-guide
