
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
helm repo add argo https://argoproj.github.io/argo-helm

kubectl create namespace argocd

helm -n argocd template argocd argo/argo-cd

helm -n argocd install argocd argo/argo-cd
```

---> 소스 코드 받아서 수정해야 할듯 하다. / 로컬 PC 는 port-forward 이 되는데, cloud9 이라서 ㅜㅜㅜ 







## 삭제 ##
```
# ArgoCD 삭제
helm -n argocd uninstall argocd

# Kubernetes 네임스페이스 삭제
kubectl delete namespace argocd
```

## 트러블 슈팅 ##

* https://stackoverflow.com/questions/71052421/argocd-app-create-in-ci-pipeline-github-actions-tekton-throws-permissio
  

## 레퍼런스 ##
* https://mycup.tistory.com/423
* https://sncap.tistory.com/1124


