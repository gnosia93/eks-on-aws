
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
pod/istio-ingressgateway-6f488f8f45-fnp6v   1/1     Running   0          70s
pod/istiod-6dbd6db74f-9qppx                 1/1     Running   0          79s

NAME                           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                                      AGE
service/istio-ingressgateway   LoadBalancer   172.20.6.75     <pending>     15021:30227/TCP,80:32420/TCP,443:31372/TCP   70s
service/istiod                 ClusterIP      172.20.108.52   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        79s

NAME                                   READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-ingressgateway   1/1     1            1           71s
deployment.apps/istiod                 1/1     1            1           79s

NAME                                              DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-ingressgateway-6f488f8f45   1         1         1       70s
replicaset.apps/istiod-6dbd6db74f                 1         1         1       79s

NAME                                                       REFERENCE                         TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/istio-ingressgateway   Deployment/istio-ingressgateway   <unknown>/80%   1         5         1          70s
horizontalpodautoscaler.autoscaling/istiod                 Deployment/istiod                 <unknown>/80%   1         5         1          79s
```

## 트러블 슈팅 ##
* Failed build model due to unable to resolve at least one subnet (0 match VPC and tags)
```
$ kubectl describe service istio-ingressgateway -n istio-system
Name:                     istio-ingressgateway
Namespace:                istio-system
Labels:                   app=istio-ingressgateway
                          install.operator.istio.io/owning-resource=unknown
                          install.operator.istio.io/owning-resource-namespace=istio-system
                          istio=ingressgateway
                          istio.io/rev=default
                          operator.istio.io/component=IngressGateways
                          operator.istio.io/managed=Reconcile
                          operator.istio.io/version=1.18.2
                          release=istio
Annotations:              <none>
Selector:                 app=istio-ingressgateway,istio=ingressgateway
Type:                     LoadBalancer
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       172.20.6.75
IPs:                      172.20.6.75
Port:                     status-port  15021/TCP
TargetPort:               15021/TCP
NodePort:                 status-port  30227/TCP
Endpoints:                10.1.102.16:15021
Port:                     http2  80/TCP
TargetPort:               8080/TCP
NodePort:                 http2  32420/TCP
Endpoints:                10.1.102.16:8080
Port:                     https  443/TCP
TargetPort:               8443/TCP
NodePort:                 https  31372/TCP
Endpoints:                10.1.102.16:8443
Session Affinity:         None
External Traffic Policy:  Cluster
Events:
  Type     Reason            Age                  From     Message
  ----     ------            ----                 ----     -------
  Warning  FailedBuildModel  12m (x28 over 3h4m)  service  Failed build model due to unable to resolve at least one subnet (0 match VPC and tags)
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
