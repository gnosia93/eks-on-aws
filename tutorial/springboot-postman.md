### Swagger 설치 ###

...


### 어플리케이션 URL 테스트 ###

[Postman](https://www.postman.com/) 을 설치해서 어플리케이션(CRUD)를 테스트한다. Intelij 로 shop 프로젝트를 오픈한 다음 좌측 패널에서 ShopApplication 을 선택하고 우측 상단의 Run 버튼(녹색 삼각형) 클릭하여 어플리케이션을 실행한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/shop-run.png)

#### 회원 등록 ####
Postman 으로 http://localhost:8080/member/add 을 테스트 한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/postman-post.png)

```
{
    "password": "111",
    "name": "member-111",
    "phoneNumber": "1111-111-11",
    "emailAddress": "member-111@example.com"
}
```

#### 회원 조회 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/postman-get.png)


#### 회원 리스트 조회 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/postman-get-list.png)

#### 회원 수정 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/postman-put.png)

```
{
    "name": "member-111-modified",
    "emailAddress": "member-111-modified@example.com"
}
```

## 레퍼런스 ##

* [Swagger 3.0.0 적용](https://chanos.tistory.com/entry/Spring-API-%EB%AC%B8%EC%84%9C-%EC%9E%90%EB%8F%99%ED%99%94%EB%A5%BC-%EC%9C%84%ED%95%9C-Swagger-300-%EC%A0%81%EC%9A%A9)


