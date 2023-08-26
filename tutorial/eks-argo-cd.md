### 1. ArgoCD 설치 ###
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl describe svc argocd-server -n argocd
```

[결과]
```
Name:                     argocd-server
Namespace:                argocd
Labels:                   app.kubernetes.io/component=server
                          app.kubernetes.io/name=argocd-server
                          app.kubernetes.io/part-of=argocd
Annotations:              <none>
Selector:                 app.kubernetes.io/name=argocd-server
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.111.250
IPs:                      172.20.111.250
LoadBalancer Ingress:     aeba3b6bf5bba4851bc73abb9fcb26b0-83759394.ap-northeast-2.elb.amazonaws.com
Port:                     http  80/TCP
TargetPort:               8080/TCP
NodePort:                 http  32140/TCP
Endpoints:                10.1.103.42:8080
Port:                     https  443/TCP
TargetPort:               8080/TCP
NodePort:                 https  32385/TCP
Endpoints:                10.1.103.42:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

### 2. 초기 비밀번호 확인 ###
아래의 명령어로 초기 비밀번호를 알아낸 다음 argo-cd 웹 콘솔에서 비밀번호를 변경한다. 
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
EAekaj9K

### 3. argo cd 로그인 ###
유저명 admin / 패스워드 EAekaj9K 로 로그인 한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-login.png)

User Info 메뉴에서 패스워드를 변경한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-update-pass.png)


### 4. 어플리케이션 생성(배포) ###

Applications 메뉴에서 + NEW APP 버튼을 클릭하고, 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app2.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app3.png)



## 레퍼런스 ##

* https://mycup.tistory.com/423


