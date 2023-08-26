
### 1. 환경 수집 ###
```
export CLUSTER_NAME=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.name')
export EKS_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.version')
export VPC_ID=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.resourcesVpcConfig.vpcId')
export PLATFORM_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.platformVersion')
export END_POINT=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.endpoint')

export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
```



### 2. ArgoCD 설치 ###
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl describe svc argocd-server -n argocd
```









## 삭제 ##
```
# ArgoCD 삭제
helm -n argocd uninstall argocd

# Kubernetes 네임스페이스 삭제
kubectl delete namespace argocd
```

## 트러블 슈팅 ##

* https://stackoverflow.com/questions/76863249/argocd-unable-to-create-application-permission-denied

## 레퍼런스 ##
* https://mycup.tistory.com/423
* https://sncap.tistory.com/1124


