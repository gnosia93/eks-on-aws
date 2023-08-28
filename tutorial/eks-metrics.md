### 1. 메트릭 서버 설치 ###

Amazon EKS에서는 Metrics Server가 기본적으로 설치되지 않는다. 아래의 명령어를 이용하여 설치한다. 

```
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```


## 트러블 슈팅 ##

```
$ kubectl top node
error: Metrics API not available
```




## 레퍼런스 ##

* [k8s metrics](https://ikcoo.tistory.com/104)
