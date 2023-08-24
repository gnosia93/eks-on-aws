

### 1. 테라폼 설치 ###

로컬 PC(mac) 에 테라폼을 설치합니다. 
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
terraform -version
```
[결과]
```
Terraform v1.5.6
on darwin_arm64
```

### 2. 기본 인프라 구성 ###



## 레퍼런스 ##
