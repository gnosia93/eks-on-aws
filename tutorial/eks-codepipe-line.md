## CI 구성하기 ##

깃 허브에 새로운 코드가 commit 이 되면 AWS CodeBuild 가 소스코드를 다운로드 받아서 컴파일하고,
Docker 이미지를 빌드한 다음 ECR 레지스트리에 푸시한다. 

### 1. GitHub 억세스 토큰 생성 ###

* 깃허브의 Settings / Developer Settings 페이지로 이동하여 Fine-grained tokens 메뉴에서 [Generate new token] 버튼을 누른다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-1.png)

* 토큰 이름을 token-[repo name] 으로 설정하고, Only select repositories 에서 연결하고자 하는 레포지토리를 설정한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-2.png)

* Overview 에 나오는 것처럼 Commit, Metadata, Webhooks 권한(Read-only)을 선택한 후 [Generate token] 버튼을 눌려서 토큰을 생성한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-3.png)

* 생성된 토큰
  ```
  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
  ```

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
깃허브 레포지토리의 root 디렉토리 또는 Intelij 의 shop 프로젝트 root 디렉토리에 buildspec.yaml 파일을 생성한다. codebuild 생성시 정의했던 파일로 codebuild가 빌드할 때 이 파일을 참조하게 된다. 


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

* [깃허브 토큰 발급](https://velog.io/@shin6949/Github-Token-%EB%B0%A9%EC%8B%9D%EC%9C%BC%EB%A1%9C-%EB%A1%9C%EA%B7%B8%EC%9D%B8%ED%95%98%EA%B8%B0-ch3ra7vc)

* [Gradle 기본사용법](https://velog.io/@franc/Gradle-%EA%B8%B0%EB%B3%B8%EC%82%AC%EC%9A%A9%EB%B2%95)

* [Gradle 설치](https://kotlinworld.com/312)

* [Amazon Linux 2 서버에 스프링 부트 + gradle 프로젝트 jar 배포하기](https://tlatmsrud.tistory.com/66)

* [spring boot 프로젝트 도커 이미지로 빌드](https://velog.io/@dhk22/Docker-spring-boot-%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B8-%EB%8F%84%EC%BB%A4-%EC%9D%B4%EB%AF%B8%EC%A7%80%EB%A1%9C-%EB%B9%8C%EB%93%9C)

* https://stackoverflow.com/questions/38587325/aws-ecr-getauthorizationtoken
  
* https://docs.aws.amazon.com/ko_kr/AmazonECR/latest/userguide/getting-started-cli.html

* https://docs.aws.amazon.com/ko_kr/codebuild/latest/userguide/sample-runtime-versions.html 

