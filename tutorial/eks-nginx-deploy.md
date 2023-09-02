
cloud9 터미널에서 아래 명령어를 실행한다. 
```
kubectl create deployment nginx --image=nginx --replicas 1

kubectl expose deployment nginx --port=80 --type=LoadBalancer

kubectl get all
```

[결과]
```
NAME                        READY   STATUS    RESTARTS   AGE
pod/nginx-76d6c9b8c-gp2ts   1/1     Running   0          22s

NAME                 TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)        AGE
service/kubernetes   ClusterIP      172.20.0.1       <none>                                                                         443/TCP        41m
service/nginx        LoadBalancer   172.20.228.144   aa0c4c9de5bb2491aaeb7754a1cbaee7-1757716375.ap-northeast-2.elb.amazonaws.com   80:31397/TCP   5s

NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx   1/1     1            1           23s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-76d6c9b8c   1         1         1       23s
```

#### ELB 정보 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nginx-1.png)

#### ELB 인스턴스 #### 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nginx-2.png)

EKS 클러스터에 할당된 프라이빗 서브넷의 AZ 가 a, b 이므로, 그림에서 보는 것처럼 퍼브릭 서브넷 역시 a, b 에 존재해야 한다.
단 CrossRegion 로드밸런싱에 대해서는 체크가 필요함. 

#### 웹 화면 #### 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nginx-3.png)


## 레퍼런스 ##

* https://stackoverflow.com/questions/66039501/eks-alb-is-not-to-able-to-auto-discover-subnets

