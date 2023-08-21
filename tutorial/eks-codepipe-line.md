## CI 구성하기 ##

깃 허브에 새로운 코드가 commit 이 되면 AWS CodeBuild 가 소스코드를 다운로드 받아서 컴파일하고,
Docker 이미지를 빌드한 다음 ECR 레지스트리에 푸시한다. 

### 1. GitHub 억세스 토큰 생성 ###

깃허브의 Settings / Developer Settings 페이지로 이동하여 Fine-grained tokens 메뉴에서 [Generate new token] 버튼을 누른다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-1.png)

토큰 이름을 token-<repo name> 으로 설정하고, Only select repositories 에서 연결하고자 하는 레포지토리를 설정한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-2.png)

Overview 에 나오는 것처럼 Commit, Metadata, Webhooks 권한(Read-only)을 선택한 후 [Generate token] 버튼을 눌려서 토큰을 생성한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-3.png)


## 레퍼런스 ##

* [CodePineLine 구축](https://potato-yong.tistory.com/130)
