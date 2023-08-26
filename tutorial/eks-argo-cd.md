### 1. ArgoCD 설치 ###
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl describe svc argocd-server -n argocd
```

### 2. 비밀번호 변경 ###
아래의 명령어로 초기 비밀번호를 알아낸 다음 argo-cd 웹 콘솔에서 비밀번호를 변경한다. 
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```



## 레퍼런스 ##

* https://mycup.tistory.com/423


