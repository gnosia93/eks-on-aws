istio는 각 파드에 envoy proxy를 설치하여 서비스 메시를 관리한다.

원하는 pod만 envory proxy를 설치하고 싶은 겁니다. 객체지향 DI(Dependency Injection)처럼 Istio도 Sidecar Injection을 지원합니다. 공식문서(https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)에서도 따로 문서로 정리될만큼 중요한 개념입니다.

 

Istio Injection은 두가지 방법이 존재하는데요!. ①명령어로 수동으로 하는 방법과 ②라벨로 설정하는 방법이 있습니다. 이 글에서는 라벨로 설정하는 방법을 다룹니다. 명령어는 istio공식문서를 참고하시길 바랍니다.

## 레퍼런스 ##

* https://malwareanalysis.tistory.com/299
