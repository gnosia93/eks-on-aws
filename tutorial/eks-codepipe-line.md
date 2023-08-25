## CI 구성하기 ##

스프링부트 shop 프로젝트로 CI 파이프라인을 테스트 하기 위해서는 

* 깃허브에 계정을 만들고,
* 깃허브 웹에서 https://github.com/gnosia93/eks-on-aws-springboot 레포지토리를 fork 해야한다.
* Github 엑세스 토큰을 생성하고
* AWS Codepipeline 을 구성

한다.

깃 허브에 새로운 코드가 commit 이 되면 AWS CodeBuild 가 소스코드를 다운로드 받아서 컴파일하고,
Docker 이미지를 빌드한 다음 ECR 레지스트리에 푸시한다. 

### 1. GitHub 억세스 토큰 생성 ###

* [깃허브 토큰 발급](https://velog.io/@shin6949/Github-Token-%EB%B0%A9%EC%8B%9D%EC%9C%BC%EB%A1%9C-%EB%A1%9C%EA%B7%B8%EC%9D%B8%ED%95%98%EA%B8%B0-ch3ra7vc)

을 참고하여 PAT 토큰을 만든다. 이 토큰은 CodeBuild 에서 github 레포지토리에 접근할 때 사용된다.  

### 2. CodeBuild 설정 ###

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-2.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-3.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-4.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-5.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-6.png)


### 3. Code Pipeline 설정 ###

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-2.png)

[Connect to Github] 버튼을 클릭한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-3.png)

팝업창에서 Code 시리즈 O-Auth 를 선택하고 Confirm 버튼을 클릭한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-4.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-5.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-6.png)

[Skip Deploy Stage] 버튼을 클릭한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-7.png)

[Create Pipeline] 버튼을 클릭한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-8.png)


### 4. buildspec.yaml 파일 생성 ###
Intelij 의 shop 프로젝트 root 디렉토리에 buildspec.yaml 파일을 생성한다. codebuild 생성시 정의했던 파일로 이 파일의 내용을 참조하여 빌드작업이 수행된다.   
codebiuld 에서 도커 이미지를 빌드하는 방법은 아래와 같이 두가지 방식이 있는데, 방안-2 를 사용하도록 한다. 

#### 방안-1 ####
이 방식을 사용하는 경우 도커 이미지를 빌들하기 위해서 Dockerfile 이 필요하다. 아래는 도커 파일의 예시이다.
gradlew bootjar 를 실행하면 단독으로 실행가능한 fat jar 파일에 만들어 지게 된다.
```
# base image
FROM amazoncorretto:17

# 변수설정 (빌드파일의 경로)
ARG BOOT_JAR=build/libs/*.jar
# 빌드파일을 컨테이너로 복사
COPY ${BOOT_JAR} boot.jar
# jar 파일 실행
ENTRYPOINT ["java", "-jar", "/boot.jar"]
```

[buildspec.yaml]
```
version: 0.2
phases:
  install:
    runtime-versions:
      java: corretto17
    commands:
       - java -version
       - docker -v

  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/
  build:
    commands:
      - ./gradlew bootjar
      - BOOT_JAR=`ls build/libs/*.jar`
      - echo $BOOT_JAR
      - echo Building the Docker image
      - docker build -t $IMAGE_REPO_NAME:$IMAGE_TAG .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
      - docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG

  post_build:
    commands:
      - DATE='date'
      - echo Build completed on $DATE
```


#### 방안-2 ####

gradlew bootBuildImage 이용하여 layerd docker image 를 생성한다. layered 도커 이미지를 생성하는 경우 타켓 이미지 사이즈를 줄일 수 있고, 별도의 Dockerfile 파일 또한 없어도 된다.
[Gradle, Layered Jar 그리고 Dockerbuild 최적화](https://velog.io/@ssol_916/Gradle-Layered-Jar-%EA%B7%B8%EB%A6%AC%EA%B3%A0-Dockerbuild-%EC%B5%9C%EC%A0%81%ED%99%94)

단 build.gradle 파일의 dependencies 섹션에 gradle-plugin 을 추가해야 한다.
```
dependencies {
	implementation 'org.springframework.boot:spring-boot-gradle-plugin:3.1.2'
	...

```

[buildspec.yml]
```
version: 0.2
phases:
  install:
    runtime-versions:
      java: corretto17
    commands:
       - java -version
       - docker -v

  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/
  build:
    commands:
      - echo Building the Layered Docker Image with Gradlew
      - ./gradlew clean bootBuildImage
      - docker tag docker.io/library/shop:0.0.1-SNAPSHOT $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG
      - docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:$IMAGE_TAG

  post_build:
    commands:
      - DATE='date'
      - echo Build completed on $DATE
```

아래 그림과 같이 codebuild 의 environment 를 수정해 준다. IMAGE_REPO_NAME, IMAGE_TAG 등은 buildspec.yaml 에서 사용되는 환경 변수이다.  
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-env.png)



### 5. ECR Private 레포지토리 생성 ###

cloud9 에서 아래 명령어를 실행하여 도커 이미지 레포지토리를 생성한다. 
```
$ ACCOUNT_ID=`aws sts get-caller-identity|jq -r ".Account"`; REGION=ap-northeast-2

$ aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
WARNING! Your password will be stored unencrypted in /home/ec2-user/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

$ aws ecr create-repository \
    --repository-name eks-on-aws-springboot \
    --image-scanning-configuration scanOnPush=true \
    --region $REGION
{
    "repository": {
        "repositoryUri": "000000000000.dkr.ecr.ap-northeast-2.amazonaws.com/eks-on-aws-springboot", 
        "imageScanningConfiguration": {
            "scanOnPush": true
        }, 
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }, 
        "registryId": "000000000000", 
        "imageTagMutability": "MUTABLE", 
        "repositoryArn": "arn:aws:ecr:ap-northeast-2:000000000000:repository/eks-on-aws-springboot", 
        "repositoryName": "eks-on-aws-springboot", 
        "createdAt": 1692627316.0
    }
}
```

buildspec.yaml 파일에서 codebuild 가 ECR에 로그인 하기위해서 아래의 정책을 codebuild 서비스 롤인 codebuild-service-role에 바인딩한다. 
```
$ aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess --role-name codebuild-service-role
```


## 레퍼런스 ##

* [CodePineLine 구축](https://potato-yong.tistory.com/130)

* [Gradle 기본사용법](https://velog.io/@franc/Gradle-%EA%B8%B0%EB%B3%B8%EC%82%AC%EC%9A%A9%EB%B2%95)

* [Gradle 설치](https://kotlinworld.com/312)

* [Amazon Linux 2 서버에 스프링 부트 + gradle 프로젝트 jar 배포하기](https://tlatmsrud.tistory.com/66)

* [spring boot 프로젝트 도커 이미지로 빌드](https://velog.io/@dhk22/Docker-spring-boot-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EB%8F%84%EC%BB%A4-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A1%9C-%EB%B9%8C%EB%93%9C)

* https://stackoverflow.com/questions/38587325/aws-ecr-getauthorizationtoken
  
* https://docs.aws.amazon.com/ko_kr/AmazonECR/latest/userguide/getting-started-cli.html

* https://docs.aws.amazon.com/ko_kr/codebuild/latest/userguide/sample-runtime-versions.html 

----

## 스프링 부트 도커 이미지 빌드하기 ##

* https://binux.tistory.com/62
* https://binux.tistory.com/121
* [Spring Boot로 효율적인 Docker Image 만들기](https://jaime-note.tistory.com/44)
* [Springboot Profile 설정방법 및 가져오기](https://oingdaddy.tistory.com/393)
