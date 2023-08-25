
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

### 2. CLI 설치 ###
```
VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\\1/')

echo $VERSION

curl -LO https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

chmod u+x argocd-linux-amd64

sudo mv argocd-linux-amd64 /usr/local/bin/argocd
```



## 레퍼런스 ##

* https://nyyang.tistory.com/114
  
