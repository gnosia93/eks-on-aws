이렇게 기존의 세션-쿠키 기반의 로그인이 아니라 JWT같은 토큰 기반의 로그인을 하게 되면 세션이 유지되지 않는 다중 서버 환경에서도 로그인을 유지할 수 있게 되고 한 번의 로그인으로 유저정보를 공유하는 여러 도메인에서 사용할 수 있다는 장점이 있습니다.
이 때 회원을 구분할 수 있는 정보가 담기는 곳이 바로 JWT의 payload 부분이고 이곳에 담기는 정보의 한 '조각'을 Claim 이라고 합니다. Claim은 name / value 한 쌍으로 이루어져 있으며 당연히 여러개의 Claim들을 넣을 수 있습니다.

그러나 우리가 만들고자 하는것은 세션-쿠키 기반의 전통적인 로그인 방법이 아니라 JWT 를 이용한 방법입니다. JWT 형식의 토큰을 발행하고 검증하는 모듈이 필요합니다. 다음과 같은 dependency를 추가해 주도록 하겠습니다.



..

## 레퍼런스 ##

* [SPRING SECURITY + JWT 회원가입, 로그인 기능 구현](https://webfirewood.tistory.com/115)

* [JWT 를 사용한 로그인 구현](https://llshl.tistory.com/28)

* https://stir.tistory.com/256

* https://oingdaddy.tistory.com/310

* https://oingdaddy.tistory.com/311
