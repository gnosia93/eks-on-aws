## springboot 프로젝트 생성 ##

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

### 3. InteliJ 로 springboot-shop 프로젝트를 오픈한다. ###
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-shop.png)

### 4. springboot DB 연결 설정 ###
[build.gradle]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-build.gradle-mysql.png)

[application.yml]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-application-yml.png)

## 트러블 슈팅 ##

* [Could not resolve org.springframework.boot:spring-boot-gradle-plugin:3.1.2 해결 방법](https://effortguy.tistory.com/286)

  InteliJ의 Gradle JVM 버전을 17 버전을 설정한다. 맥의 경우 상단 InteliJ IDEA 메뉴 하단의 Preferences 를 클릭하면 아래와 같은 팝업창이 뜬다.
    
  ![](https://github.com/gnosia93/eks-on-aws/blob/main/images/project-gradle-jvm17.png)
  
* [Failed to configure a DataSource: 'url' attribute is not specified and no embedded datasource could be configured](https://yanacoding.tistory.com/entry/Spring-Boot-%EC%8A%A4%ED%94%84%EB%A7%81%EB%B6%80%ED%8A%B8-%EC%97%90%EB%9F%AC-Failed-to-configure-a-DataSource-url-attribute-is-not-specified-and-no-embedded-datasource-could-be-configured-DB%EC%97%B0%EA%B2%B0-%ED%95%98%EC%A7%80-%EC%95%8A%EC%9D%84-%EB%95%8C)
  - https://7942yongdae.tistory.com/128


## 참고자료 ##

* [IntelliJ Springboot 프로젝트 생성 및 실행](https://velog.io/@deannn/Spring-IntelliJ-Springboot-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EC%83%9D%EC%84%B1-%EB%B0%8F-%EC%8B%A4%ED%96%89)

* [Mac에 MySQL 설치하기](https://losskatsu.github.io/it-infra/mysql-install-mac/#%EC%B0%B8%EA%B3%A0-%EB%A7%81%ED%81%AC)

* [MySQL 유저 생성](https://nickjoit.tistory.com/144)

* [MySQL application.yml 설정](https://velog.io/@minbo2002/JPA-application.yml-%EC%84%A4%EC%A0%95)

