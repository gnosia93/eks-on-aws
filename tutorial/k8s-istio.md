## Istio 설치 및 테스트 ##

 * [Istio 설치하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-provision.md)

 * [Istio 인젝션 설정](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-injection.md)

 * [Istio 어플리케이션 배포 - bookinfo](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-bookinfo.md)


## SHOP 서비스 EKS 배포하기 ##

istio 를 적용할 마이크로 서비스의 구조는 다음과 같은데 주문 발생시 상품과 혜택(포인트)를 호출한다. 각 서비스의 서브 링크로 방문해서 어플리케이션을 빌드후 ECR 에 푸시한다.

```
주문 -> 상품(재고조회) 
    -> 혜택(포인트)
```
  
  * [주문 - springboot](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-service-order.md)
  * [상품 - python flask](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-flask-prod.md
)
  * [혜택(포인트) - node.js](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-nodejs-point.md)


#### 주문 동작 확인 ####
```
kubectl logs -f -l app=shop --all-containers=true
```

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-order-eks.png)


## SHOP 서비스 Istio 적용 ##


## 레퍼런스 ##

* https://bcho.tistory.com/1266

* https://www.lihaoyi.com/post/SimpleWebandApiServerswithScala.html

