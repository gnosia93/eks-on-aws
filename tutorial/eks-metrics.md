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


