
```
export CLUSTER_NAME=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.name')
export EKS_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.version')
export VPC_ID=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.resourcesVpcConfig.vpcId')
export PLATFORM_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.platformVersion')
export END_POINT=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.endpoint')
```

### 1. ArgoCD 배포 ###
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
loadbalancer 타입으로 변경해서 접속한다. (참고-ALB 인그레스로 설치하는 경우 TLS 오류가 발생한다)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-login.png)



### 2. CLI 설치 ###
```
export VERSION=v2.8.2

curl -LO https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

chmod u+x argocd-linux-amd64

sudo mv argocd-linux-amd64 /usr/local/bin/argocd
```

### 3. 어드민 패스워드 변경 ###
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
[결과]
```
3YmHOEYvMl7yE7XQ
```

admin / 3YmHOEYvMl7yE7XQ (초기 패스워드) 로 로그인 하여, 패스워드를 admin22admin 으로 변경한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-password.png)





## 레퍼런스 ##

* https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/ 

* https://velog.io/@bbkyoo/ArgoCD-%EA%B8%B0%EB%B3%B8-%EC%A0%95%EB%A6%AC

* https://nyyang.tistory.com/114
  
