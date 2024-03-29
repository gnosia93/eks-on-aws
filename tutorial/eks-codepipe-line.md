## AWS CodePipeline CI 구성하기 ##

스프링부트 shop 프로젝트로 CI 파이프라인을 구성하기 위해서는 

* Github 계정을 만들어 로그인 
* Github 웹에서 https://github.com/gnosia93/eks-on-aws-springboot 레포지토리 fork
* Github 엑세스 토큰 생성
* AWS Codepipeline 구성

과정을 거쳐야 한다.

코드 파이프라인의 동작 순서는 Github에 새로운 코드가 commit 이 되면 AWS CodeBuild 가 소스코드를 다운로드 받아서 컴파일하고,
Docker 이미지를 생성한 다음 프라이빗 ECR 레지스트리에 푸시하는 과정으로 구성되어 있다. 

#### 레포지토리 fork 예시 ####

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/repo-fork1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/repo-fork2.png)


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



### 4. ECR Private 레포지토리 생성 ###

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

### 5. buildspec.yaml 파일의 이해 ###

buildspec.yaml 파일은 codebuild 생성시 정의했던 파일로, 빌드 작업시 이 파일에 나와 있는 명령어들이 순차적으로 실행된다.     
shop 프로젝트 원본 레포지토리인 https://github.com/gnosia93/eks-on-aws-springboot 에 보면 root 디렉토리에 
buildspec.yaml 파일이 존재하는 것을 확인할 수 있다. (fork 한 프로젝트 역시 동일한 구조이다) 

codebiuld 에서 도커 이미지를 빌드하는 방법은 아래와 같이 두가지 방식이 있는데, 방안-2 를 사용하는 것이 훨씬 좋다.  
이미 빌드에 필요한 명령어 들이 정의되어 있기 때문에 별도로 추가하거나 수정할 내용은 없다.

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
      - docker build -t $IMAGE_REPO_NAME:latest .
      - docker tag $IMAGE_REPO_NAME:$IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:latest
      - docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:latest

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
#      - ./gradlew bootjar
#      - BOOT_JAR=`ls build/libs/*.jar`
#      - echo $BOOT_JAR
      - echo Building the Layered Docker Image with Gradlew
      - ./gradlew clean bootBuildImage | tee ./tmp
      - DOCKER_IMAGE_NAME=$(grep 'Building image' ./tmp | awk '{print $3}' | tr -d "'")
      - DOCKER_IMAGE_TAG=$(echo $DOCKER_IMAGE_NAME | awk -F ':' '{print $2}')
      - echo .....$DOCKER_IMAGE_NAME
      - echo .....$DOCKER_IMAGE_TAG
# Building image 'docker.io/library/shop:0.0.1-SNAPSHOT'
      - docker tag $DOCKER_IMAGE_NAME $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:$DOCKER_IMAGE_TAG
      - docker tag $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:$DOCKER_IMAGE_TAG $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME:latest
      - docker push --all-tags $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$IMAGE_REPO_NAME

  post_build:
    commands:
      - DATE='date'
      - echo Build completed on $DATE
```

아래 그림과 같이 codebuild 의 environment 를 수정해 준다. IMAGE_REPO_NAME, IMAGE_TAG 등은 buildspec.yaml 에서 사용되는 환경 변수이다.  
아래 그림에서 환경변수 중 IMAGE_TAG 는 설정하지 않아도 된다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codebuild-env.png)


### 6. 빌드 파이프 라인 트리거 하기 ###

여러분의 깃허브 계정으로 fork 한 shop 프로젝트 코드에 대한 변경이 발생하는 경우 AWS CodePipeline 이 동작하게 되는데, 본 워크삽에서는 아래 그림에서 보이는 것처럼 CodePipeline 콘솔화면에서 [Release Change] 버튼을 눌러 수동으로 빌드 작업을 트리거 한다. 물론 fork 한 shop 프로젝트 레포지토리의 특정 파일을 변경해도 빌드 파이프 라인이 이를 인지하고 빌드 작업을 수행한다. 또는 InteliJ 와 같은 통합개발 환경이 여러분들의 깃허브와 연동된 경우, InteliJ 에서 소스 코드를 변경한 다음 git 명령어로 푸시하면 AWS CodePipeline 이 이를 인지하여 빌드 작업을 수행한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/codepipeline-release-change.png)


### 7. ECR 도커 이미지 ###

CI 파이프 라인이 제대로 동작한다면 아래 레포지토리에서 볼수 있는 것처럼 빌드 작업시 마다 새로운 도커 이미지가 생성되게 된다. 
최신 버전은 latest 로 태깅되며, 새로운 빌드가 발생하면 latest 정보 또한 업데이트 된다.  

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/ecr-image.png)



## 레퍼런스 ##

* [spring boot 프로젝트 도커 이미지로 빌드](https://velog.io/@dhk22/Docker-spring-boot-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EB%8F%84%EC%BB%A4-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A1%9C-%EB%B9%8C%EB%93%9C)

* https://docs.aws.amazon.com/ko_kr/codebuild/latest/userguide/sample-runtime-versions.html 

* https://blog.shikisoft.com/define-environment-vars-aws-codebuild-buildspec/

* [Spring Boot로 효율적인 Docker Image 만들기](https://jaime-note.tistory.com/44)
  
* [Springboot Profile 설정방법 및 가져오기](https://oingdaddy.tistory.com/393)
