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

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-3.png)


Code 시리스 Auto 를 선택하고 Confirm 버튼을 클릭한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-4.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-5.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-6.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-7.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/code-pipeline-8.png)



## 레퍼런스 ##

* [CodePineLine 구축](https://potato-yong.tistory.com/130)

* [깃허브 토큰 발급](https://velog.io/@shin6949/Github-Token-%EB%B0%A9%EC%8B%9D%EC%9C%BC%EB%A1%9C-%EB%A1%9C%EA%B7%B8%EC%9D%B8%ED%95%98%EA%B8%B0-ch3ra7vc)
