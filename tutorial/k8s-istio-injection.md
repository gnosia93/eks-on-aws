istio는 각 파드에 envoy proxy를 sidecar 패턴으로 설치하여 서비스 메시를 관리한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-mesh.png)

전체 pod 에도 설치할 수 있지만, 원하는 pod 에만 envory proxy를 설치할 수도 있다. 이때 사용되는 기술이 바로 객체지향 언어의 DI(Dependency Injection)와 같은 기술로, Istio는 Sidecar Injection을 지원한다.(https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

Injection은 두가지 방식으로 가능한데, ①명령어로 수동으로 하는 방법과 ②라벨로 설정하는 방법이 있다. 여기서는  라벨로 설정하는 방법에 대해서 다룰 예정이다.

## Istio 인젝션 설정 ##

### 1. 샘플 어플리케이션 배포 ###

```
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/sleep/sleep.yaml
serviceaccount/sleep created
service/sleep created
deployment.apps/sleep created

$ kubectl get pod | grep sleep
sleep-84549b8696-zpfb7          1/1     Running   0          17s

$ kubectl label namespace default istio-injection=enabled --overwrite
namespace/default labeled

$ kubectl describe ns default
Name:         default
Labels:       istio-injection=enabled
              kubernetes.io/metadata.name=default
Annotations:  <none>
Status:       Active

$ kubectl get namespace -L istio-injection
NAME              STATUS   AGE   ISTIO-INJECTION
default           Active   37h   enabled
istio-operator    Active   75m   
istio-system      Active   97m   
kube-node-lease   Active   37h   
kube-public       Active   37h   
kube-system       Active   37h

$ kubectl delete pod -l app=sleep
pod "sleep-84549b8696-zpfb7" deleted

$ kubectl get pod | grep sleep
sleep-84549b8696-ws4r5          2/2     Running   0          10s
```


## 레퍼런스 ##
* https://devocean.sk.com/blog/techBoardDetail.do?ID=163655
* https://malwareanalysis.tistory.com/299
* https://malwareanalysis.tistory.com/305
* https://malwareanalysis.tistory.com/306
* https://malwareanalysis.tistory.com/307
