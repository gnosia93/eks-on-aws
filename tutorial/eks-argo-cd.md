
### 1. ArgoCD 배포 ###
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
loadbalancer 타입으로 변경해서 접속한다. 기본설정이 SSL 경우라서 ...



### 2. CLI 설치 ###
```
export VERSION=v2.8.2

curl -LO https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

chmod u+x argocd-linux-amd64

sudo mv argocd-linux-amd64 /usr/local/bin/argocd
```


## 레퍼런스 ##

* https://velog.io/@bbkyoo/ArgoCD-%EA%B8%B0%EB%B3%B8-%EC%A0%95%EB%A6%AC

* https://nyyang.tistory.com/114
  
