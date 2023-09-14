## springboot 프로젝트 생성 ##

이번 챕터에서는 spring.io 와 InteliJ 통합 자바 개발환경을 이용해서 스프링 부트 프로젝트를 생성하는 방법에 대해서 설명한다.  
eks-on-aws 워크샵에서 사용되는 shop 프로젝트 코드는 https://github.com/gnosia93/eks-on-aws-springboot 에서 확인 가능하다.  
shop 프로젝트 역시 여기에서 기술하는 방식으로 생성하였다.   
스프링 부트 3.x 는 자바 17부터, 스프링 부트 2.x는 자바 11을 사용해야 한다.

### 1. [spring.io](https://start.spring.io/) 사이트에서 아래 그림과 같은 설정으로 프로젝트 하나를 생성한다. ###
  
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-create.png)

### 2. shop.zip 파일을 로컬PC 로 다운로드 받은 후, 압축을 해제한다. ###
```
$ shop % ls -la
total 64
drwxr-xr-x@ 10 soonbeom  staff   320  8 20 18:54 .
drwxr-x---+ 93 soonbeom  staff  2976  8 20 19:03 ..
-rw-r--r--@  1 soonbeom  staff   444  8 20 18:54 .gitignore
-rw-r--r--@  1 soonbeom  staff  1327  8 20 18:54 HELP.md
-rw-r--r--@  1 soonbeom  staff   745  8 20 18:54 build.gradle
drwxr-xr-x@  3 soonbeom  staff    96  8 20 18:54 gradle
-rwxr-xr-x@  1 soonbeom  staff  8527  8 20 18:54 gradlew
-rw-r--r--@  1 soonbeom  staff  2868  8 20 18:54 gradlew.bat
-rw-r--r--@  1 soonbeom  staff    26  8 20 18:54 settings.gradle
drwxr-xr-x@  4 soonbeom  staff   128  8 20 18:54 src
```

### 3. InteliJ 로 shop 프로젝트를 오픈한다. ###
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-shop.png)


### 4. springboot DB 연결 설정 ###

전체 설정 파일 및 코드는 https://github.com/gnosia93/eks-on-aws-springboot 에서 확인할 수 있다.

[build.gradle]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-build.gradle-mysql.png)

[application.yml]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-application-yaml.png)

[application-dev.yml]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-application-yaml-dev.png)

[application-stage.yml]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-application-yaml-stage.png)

## 트러블 슈팅 ##

* [Could not resolve org.springframework.boot:spring-boot-gradle-plugin:3.1.2 해결 방법](https://effortguy.tistory.com/286)

  InteliJ의 Gradle JVM 버전을 17 버전을 설정한다. 맥의 경우 상단 InteliJ IDEA 메뉴 하단의 Preferences 를 클릭하면 아래와 같은 팝업창이 뜬다.
    
  ![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-gradle-jvm17.png)
  
* [Failed to configure a DataSource: 'url' attribute is not specified and no embedded datasource could be configured](https://yanacoding.tistory.com/entry/Spring-Boot-%EC%8A%A4%ED%94%84%EB%A7%81%EB%B6%80%ED%8A%B8-%EC%97%90%EB%9F%AC-Failed-to-configure-a-DataSource-url-attribute-is-not-specified-and-no-embedded-datasource-could-be-configured-DB%EC%97%B0%EA%B2%B0-%ED%95%98%EC%A7%80-%EC%95%8A%EC%9D%84-%EB%95%8C)
  - https://7942yongdae.tistory.com/128


## 참고자료 ##

* [IntelliJ Springboot 프로젝트 생성 및 실행](https://velog.io/@deannn/Spring-IntelliJ-Springboot-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EC%83%9D%EC%84%B1-%EB%B0%8F-%EC%8B%A4%ED%96%89)

* [InteliJ Auto Import](https://tychejin.tistory.com/340)

* [MySQL application.yml 설정](https://velog.io/@minbo2002/JPA-application.yml-%EC%84%A4%EC%A0%95)

* https://kdg-is.tistory.com/entry/Spring-Boot-Redis-Sorted-Set%EC%9D%84-%EC%82%AC%EC%9A%A9%ED%95%98%EC%97%AC-%EB%8C%80%EA%B8%B0%EC%97%B4-%EA%B5%AC%ED%98%84

