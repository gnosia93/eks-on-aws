istio는 각 파드에 envoy proxy를 sidecar 패턴으로 설치하여 서비스 메시를 관리한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-mesh.png)

전체 pod 에도 설치할 수 있지만, 원하는 pod 에만 envory proxy를 설치할 수도 있다. 이때 사용되는 기술이 바로 객체지향의 DI(Dependency Injection)와 같은 기술로, Istio는 Sidecar Injection을 지원한다.(https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

 

Istio Injection은 두가지 방법이 존재하는데요!. ①명령어로 수동으로 하는 방법과 ②라벨로 설정하는 방법이 있습니다. 이 글에서는 라벨로 설정하는 방법을 다룹니다. 명령어는 istio공식문서를 참고하시길 바랍니다.

## 레퍼런스 ##

* https://malwareanalysis.tistory.com/299
