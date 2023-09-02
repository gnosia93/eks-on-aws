istio는 각 파드에 envoy proxy를 sidecar 패턴으로 설치하여 서비스 메시를 관리한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-mesh.png)

전체 pod 에도 설치할 수 있지만, 원하는 pod 에만 envory proxy를 설치할 수도 있다. 이때 사용되는 기술이 바로 객체지향 언어의 DI(Dependency Injection)와 같은 기술로, Istio는 Sidecar Injection을 지원한다.(https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

Injection은 두가지 방식으로 가능한데, ①명령어로 수동으로 하는 방법과 ②라벨로 설정하는 방법이 있다. 여기서는  라벨로 설정하는 방법에 대해서 다룰 예정이다.

## 레퍼런스 ##

* https://malwareanalysis.tistory.com/299
