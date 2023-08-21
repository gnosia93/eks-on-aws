## CI 구성하기 ##

깃 허브에 새로운 코드가 commit 이 되면 AWS CodeBuild 가 소스코드를 다운로드 받아서 컴파일하고,
Docker 이미지를 빌드한 다음 ECR 레지스트리에 푸시한다. 

### 1. GitHub 억세스 토큰 생성 ###

깃허브의 Settings / Developer Settings 페이지로 이동하여 Fine-grained tokens 메뉴에서 [Generate new token] 버튼을 누른다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-2.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/github-token-3.png)


## 레퍼런스 ##

* [CodePineLine 구축](https://potato-yong.tistory.com/130)
