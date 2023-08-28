## Kubernetes 지표 서버 설치 ##

### 1. 메트릭 서버 설치 ###

Amazon EKS에서는 Metrics Server가 기본적으로 설치되지 않는다. cloud9 터미널에서 아래의 명령어를 이용하여 설치한다. 

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

[결과]
```
$ kubectl get pod -n kube-system
NAME                                            READY   STATUS    RESTARTS   AGE
aws-load-balancer-controller-7556b645df-2v995   1/1     Running   0          33m
aws-load-balancer-controller-7556b645df-l7f2n   1/1     Running   0          33m
aws-node-74nbk                                  1/1     Running   0          24h
aws-node-hrcsm                                  1/1     Running   0          24h
aws-node-w466v                                  1/1     Running   0          24h
coredns-76b4dcc5cc-mmw4v                        1/1     Running   0          24h
coredns-76b4dcc5cc-rbwxl                        1/1     Running   0          24h
kube-proxy-7js2l                                1/1     Running   0          24h
kube-proxy-f2rxj                                1/1     Running   0          24h
kube-proxy-fdxxh                                1/1     Running   0          24h
metrics-server-5b4fc487-v26lr                   1/1     Running   0          52s
```
metrics-server-5b4fc487-v26lr 서버가 설치된 것을 확인할 수 있다.

### kubectl top ###
```
$ kubectl top pod
NAME                    CPU(cores)   MEMORY(bytes)   
shop-8649fb4698-5ztkq   2m           412Mi           
shop-8649fb4698-fhwdd   2m           412Mi           
shop-8649fb4698-skckg   2m           406Mi           

$ kubectl top node
NAME                                              CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%   
ip-10-1-101-166.ap-northeast-2.compute.internal   30m          0%     988Mi           3%        
ip-10-1-102-148.ap-northeast-2.compute.internal   27m          0%     946Mi           3%        
ip-10-1-102-227.ap-northeast-2.compute.internal   39m          0%     1254Mi          4%

$ kubectl top pod -n prometheus
NAME                                       CPU(cores)   MEMORY(bytes)   
observability-collector-69f488d4c7-qm85g   7m           339Mi    
```
메트릭 서버가 설치되어서 kubectl top 명령어가 동작한다.

## 트러블 슈팅 ##

* kubectl top node - error: Metrics API not available

  아래 명령어로 메트릭 서버를 설치한다. 
  ```
  kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
  ```

## 레퍼런스 ##

* [Kubernetes 지표 서버 설치](https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/metrics-server.html)

* [k8s metrics](https://ikcoo.tistory.com/104)


---

```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
"prometheus-community" already exists with the same configuration, skipping
hopigaga:~/environment $ helm repo update
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "eks" chart repository
...Successfully got an update from the "prometheus-community" chart repository
Update Complete. ⎈Happy Helming!⎈
hopigaga:~/environment $ helm install ksm prometheus-community/kube-state-metrics --set image.tag="v2.8.2" -n "default"
NAME: ksm
LAST DEPLOYED: Mon Aug 28 13:54:06 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
kube-state-metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.
The exposed metrics can be found here:
https://github.com/kubernetes/kube-state-metrics/blob/master/docs/README.md#exposed-metrics

The metrics are exported on the HTTP endpoint /metrics on the listening port.
In your case, ksm-kube-state-metrics.default.svc.cluster.local:8080/metrics

They are served either as plaintext or protobuf depending on the Accept header.
They are designed to be consumed either by Prometheus itself or by a scraper that is compatible with scraping a Prometheus client endpoint.
hopigaga:~/environment $ 
hopigaga:~/environment $ 
hopigaga:~/environment $ 
hopigaga:~/environment $ kubectl get all
NAME                                          READY   STATUS    RESTARTS   AGE
pod/ksm-kube-state-metrics-58dcbb6dc9-t2kqf   1/1     Running   0          60s
pod/shop-8649fb4698-5ztkq                     1/1     Running   0          166m
pod/shop-8649fb4698-fhwdd                     1/1     Running   0          166m
pod/shop-8649fb4698-skckg                     1/1     Running   0          166m

NAME                             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/ksm-kube-state-metrics   ClusterIP   172.20.102.83    <none>        8080/TCP       60s
service/kubernetes               ClusterIP   172.20.0.1       <none>        443/TCP        26h
service/shop                     NodePort    172.20.210.136   <none>        80:30751/TCP   166m

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ksm-kube-state-metrics   1/1     1            1           60s
deployment.apps/shop                     3/3     3            3           166m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/ksm-kube-state-metrics-58dcbb6dc9   1         1         1       61s
replicaset.apps/shop-8649fb4698                     3         3         3       166m
hopigaga:~/environment $ 
```
