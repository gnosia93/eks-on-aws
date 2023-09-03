## Istio 설치 및 테스트 ##

 * [Istio 설치하기](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-provision.md)

 * [Istio 인젝션 설정](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-injection.md)

 * [Istio 어플리케이션 배포 - bookinfo](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-istio-bookinfo.md)


## SHOP 어플리케이션 EKS 배포하기 ##

istio 를 적용할 SHOP 어플리케이션의 호출 구조는 다음과 같다. (주문시 상품과 혜택(포인트) 서비스를 호출)   
각 서비스의 서브 링크로 방문해서 어플리케이션 빌드후 ECR 및 EKS 에서 배포한다. 

```
주문 -> 상품(재고조회) 
    -> 혜택(포인트)
```
  
  * [주문 - springboot](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-service-order.md)
  * [상품 - python flask](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-flask-prod.md
)
  * [혜택(포인트) - node.js](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/istio-nodejs-point.md)
  * [배송 - scala]


#### 주문 동작 확인 ####
```
kubectl logs -f -l app=shop --all-containers=true
```

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-order-eks.png)


## SHOP 어플리케이션 Istio 적용 ##

later..


## 레퍼런스 ##

* [ISTIO ALB 적용하기](https://devocean.sk.com/experts/techBoardDetail.do?ID=163656&boardType=experts&page=&searchData=&subIndex=&idList=)

* https://bcho.tistory.com/1266

* https://www.lihaoyi.com/post/SimpleWebandApiServerswithScala.html

