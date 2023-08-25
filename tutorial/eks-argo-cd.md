
### 1. eks 클러스터 확인 ###
```
export CLUSTER_NAME=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.name')
export EKS_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.version')
export VPC_ID=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.resourcesVpcConfig.vpcId')
export PLATFORM_VERSION=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.platformVersion')
export END_POINT=$(aws eks describe-cluster --name eks-workshop | jq '.cluster.endpoint')
```



### 2. ArgoCD 설치 ###
```
helm repo add argo https://argoproj.github.io/argo-helm

kubectl create namespace argocd

helm -n argocd template argocd argo/argo-cd

helm -n argocd install argocd argo/argo-cd
```

[결과]
```
NAME: argocd
LAST DEPLOYED: Fri Aug 25 08:56:50 2023
NAMESPACE: argocd
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
In order to access the server UI you have the following options:

1. kubectl port-forward service/argocd-server -n argocd 8080:443

    and then open the browser on http://localhost:8080 and accept the certificate

2. enable ingress in the values file `server.ingress.enabled` and either
      - Add the annotation for ssl passthrough: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-1-ssl-passthrough
      - Set the `configs.params."server.insecure"` in the values file and terminate SSL at your ingress: https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#option-2-multiple-ingress-objects-and-hosts


After reaching the UI the first time you can login with username: admin and the random password generated during the installation. You can find the password by running:

kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

(You should delete the initial secret afterwards as suggested by the Getting Started Guide: https://argo-cd.readthedocs.io/en/stable/getting_started/#4-login-using-the-cli)
```


#### ...####

```
eksctl create iamidentitymapping \
  --username system:node:{{EC2PrivateDNSName}} \
  --cluster "${CLUSTER_NAME}" \
  --arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterInstanceNodeRole" \
  --group system:bootstrappers \
  --group system:nodes
```



### 3. 접속 ###
```
kubectl -n argocd port-forward service/argocd-server 8080:443

```



![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-login.png)




-----
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```
[결과]
```
3YmHOEYvMl7yE7XQ
```

admin / 3YmHOEYvMl7yE7XQ (초기 패스워드) 로 로그인 하여, 패스워드를 admin22admin 으로 변경한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-password.png)


## 삭제 ##
```
# ArgoCD 삭제
helm -n argocd uninstall argocd

# Kubernetes 네임스페이스 삭제
kubectl delete namespace argocd
```


## 레퍼런스 ##

* https://happygram.tistory.com/entry/ArgoCD-helm-%EC%9C%BC%EB%A1%9C-%EC%84%A4%EC%B9%98%ED%95%98%EA%B8%B0

* https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/ 

* https://velog.io/@bbkyoo/ArgoCD-%EA%B8%B0%EB%B3%B8-%EC%A0%95%EB%A6%AC

* https://nyyang.tistory.com/114
  
