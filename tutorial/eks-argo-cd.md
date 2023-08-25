
### 1. eks 클러스터 확인 ###
```
export CLUSTER_NAME=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.name')
export EKS_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.version')
export VPC_ID=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.resourcesVpcConfig.vpcId')
export PLATFORM_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.platformVersion')
export END_POINT=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.endpoint')

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
export ARN=$(aws sts get-caller-identity --query 'Arn' --output text)
```



### 2. ArgoCD 설치 ###
```
helm repo add argo https://argoproj.github.io/argo-helm

kubectl create namespace argocd

helm -n argocd template argocd argo/argo-cd

helm -n argocd install argocd argo/argo-cd
```



### 3. 접속 ###
```
kubectl -n argocd port-forward service/argocd-server 8080:443

```



![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-login.png)



## 삭제 ##
```
# ArgoCD 삭제
helm -n argocd uninstall argocd

# Kubernetes 네임스페이스 삭제
kubectl delete namespace argocd
```


## 레퍼런스 ##

* https://sncap.tistory.com/1124


