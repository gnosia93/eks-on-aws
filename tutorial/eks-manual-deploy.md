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
hopigaga:~ $ 
```
외부로 서비스를 노출하기 위해서 Ingress 를 생성한다.


## 레퍼런스 ##

* https://learnk8s.io/spring-boot-kubernetes-guide
