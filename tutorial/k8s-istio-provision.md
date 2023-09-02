
cloud9 터미널에서 아래 명령어를 실행한다.

```
curl -O https://raw.githubusercontent.com/istio/istio/master/release/downloadIstioCandidate.sh ​

sh downloadIstioCandidate.sh
```

.bash_profile 의 PATH 변수에 istioctl 의 경로를 추가하고, precheck 로 클러스터에 이슈가 있는지 체크한다.  
iostoctl 은 ./istio-1.18.2/bin 에 있다. (예시) /home/ec2-user/environment/istio-1.18.2/bin
```
istioctl x precheck
```
[결과]
```
✔ No issues found when checking the cluster. Istio is safe to install or upgrade!
  To get started, check out https://istio.io/latest/docs/setup/getting-started/
```

install 명령어로 EKS 클러스터에 istio 를 설치한다. 
```
istioctl profile dump

istioctl install
```

[결과]
```
This will install the Istio 1.18.2 default profile with ["Istio core" "Istiod" "Ingress gateways"] components into the cluster. Proceed? (y/N) y
✔ Istio core installed                                                                                         
✔ Istiod installed                                                                                             
✔ Ingress gateways installed                                                                                   
✔ Installation complete                                                                                        Making this installation the default for injection and validation.
```

설치 내용을 확인한다. 
```
kubectl get all -n istio-system
```

[결과]
```
NAME                                        READY   STATUS    RESTARTS   AGE
pod/istio-ingressgateway-767b5dd74c-662sd   1/1     Running   0          26s
pod/istiod-758754dcd5-ff6kh                 1/1     Running   0          36s

NAME                           TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)                                      AGE
service/istio-ingressgateway   LoadBalancer   172.20.241.252   a5a6a5f298b8441658371be38ae36d67-1397138782.ap-northeast-2.elb.amazonaws.com   15021:32328/TCP,80:30904/TCP,443:31882/TCP   26s
service/istiod                 ClusterIP      172.20.27.106    <none>                                                                         15010/TCP,15012/TCP,443/TCP,15014/TCP        36s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-ingressgateway   1/1     1            1           26s
deployment.apps/istiod                 1/1     1            1           36s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-ingressgateway-767b5dd74c   1         1         1       26s
replicaset.apps/istiod-758754dcd5                 1         1         1       36s

NAME                                                       REFERENCE                         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   <unknown>/80%   1         5         1          26s
horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 <unknown>/80%   1         5         1          36s
```



## 레퍼런스 ##

* https://istio.io/latest/docs/setup/getting-started/
  
* [Tagging VPC Subnet](https://repost.aws/knowledge-center/eks-vpc-subnet-discovery)
  
* https://istio.io/latest/docs/setup/install/istioctl/
  
* https://malwareanalysis.tistory.com/297

* https://malwareanalysis.tistory.com/298

* https://istio.io/v1.15/blog/2020/show-source-ip/

* https://nyyang.tistory.com/158

* https://www.clud.me/11354dd3-48f3-454d-917f-eca8d975e034
