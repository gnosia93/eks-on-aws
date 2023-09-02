
cloud9 터미널에서 아래 명령어를 실행한다.

```
curl -O https://raw.githubusercontent.com/istio/istio/master/release/downloadIstioCandidate.sh ​

sh downloadIstioCandidate.sh
```

[결과]
```
Downloading istio-1.18.2 from https://github.com/istio/istio/releases/download/1.18.2/istio-1.18.2-linux-amd64.tar.gz ...

Istio 1.18.2 Download Complete!

Istio has been successfully downloaded into the istio-1.18.2 folder on your system.

Next Steps:
See https://istio.io/latest/docs/setup/install/ to add Istio to your Kubernetes cluster.

To configure the istioctl client tool for your workstation,
add the /home/ec2-user/environment/istio-1.18.2/bin directory to your environment path variable with:
         export PATH="$PATH:/home/ec2-user/environment/istio-1.18.2/bin"

Begin the Istio pre-installation check by running:
         istioctl x precheck 

Need more information? Visit https://istio.io/latest/docs/setup/install/ 
```

.bash_profile 의 PATH 환경변수에 istioctl 의 경로를 추가하고, precheck 로  클러스터에 이슈가 있는지 체크한다.  
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



## 레퍼런스 ##

* https://istio.io/latest/docs/setup/install/istioctl/
  
* https://malwareanalysis.tistory.com/297

* https://malwareanalysis.tistory.com/298 
