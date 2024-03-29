## ArgoCD 로 GitOps 구현하기 ##

ArgoCD 는 git 허브와 같은 소스 레포지토리에 있는 K8S 리소스(YAML) 파일을 모니터링 하고 있다가, 파일에 변경이 발생하면 K8S 클러스터의 현재 배포상태와 비교하여 변경된 부분을 적용하는 방식으로 동작한다. 적용 방식은 자동 및 수동 모두 가능한데, 이 챕터에서는 수동 방식으로 작동하도록 구성하였다.
https://github.com/gnosia93/eks-on-aws/blob/main/apps/shop-template.yaml 경로에 있는 YAML 파일을 다운 로드 받아서 여러분들이 만든 git repository 의 
apps 디렉토리에 복사한다. 이때 다음의 변수 값들은 여러분들의 환경이 맞게 알맞은 값으로 수정해야 하고, 파일이름을 shop.yaml 으로 변경한다.
```
${DOCKER_IMAGE_URL}
${DB_ENDPOINT}
${REDIS_ENDPOINT}
${LOKI_URL}
```
여기서 LOCK_URL 의 경우 http://<eks_mysql_exporter EC2 Public IP>:3100/loki/api/v1/push 로 수정한다.

기존에 수동으로 EKS 클러스터에 배포했던 shop 어플리케이션은 아래 명령어로 삭제한다 (단 shop-ingress 는 유지함)
```
kubectl delete service/shop
kubectl delete deployment.apps/shop
kubectl get all
```
[결과]
```
NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   172.20.0.1   <none>        443/TCP   45h
```

### 1. ArgoCD 설치 ###
cloud9 터미널에서 eks-workshop 클러스터에 ArgoCD를 설치한다. 
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
Appliation Name 은 shop, Project Name 은 default 로 입력한다. (다른값을 입력하는 경우 오류가 발생함, 프로젝트명은 별도로 생성해야 하는 듯 ^^) 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app2.png)
Repository URL 은 여러분들의 git repository 주소를 입력하고 (예-https://github.com/gnosia93/eks-on-aws.git) Path 는 apps 이다.

Create 버튼을 클릭하여 어플리케이션을 생성한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app3.png)
Sync 버튼을 눌러서 어플리케이션을 배포한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app4.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/argo-cd-app5.png)

#### kubectl 로 확인 ####
```
$ kubectl get all
NAME                        READY   STATUS    RESTARTS   AGE
pod/shop-787954cc9b-h9x6r   1/1     Running   0          13s
pod/shop-787954cc9b-lgl9s   1/1     Running   0          13s
pod/shop-787954cc9b-tcf6f   1/1     Running   0          13s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes   ClusterIP   172.20.0.1      <none>        443/TCP        44h
service/shop         NodePort    172.20.93.200   <none>        80:30914/TCP   13s

NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/shop   3/3     3            3           13s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/shop-787954cc9b   3         3         3       14s
```


## 레퍼런스 ##

* https://mycup.tistory.com/423
* https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-cli/


