아래 단계를 실행하기 위해서는 로컬 PC 에 AWS EC2 keypair 파일(aws-kp-2.pem)이 생성되어 있어야 하며, AWS CLI 또한 최신 버전이 설치되어 있어야 합니다.

### 1. 테라폼 설치 ###

로컬 PC(mac) 에 테라폼을 설치합니다. 
* https://registry.terraform.io/providers/hashicorp/aws/3.75.0/docs 
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

VPC, Subnet(퍼블릭 2개, 프라이빗 2개 - EKS 클러스터용, 프라이빗 2개 - RDS 및 ElastiCache용), 인터넷 GW 및 NAT GW 를 설치합니다.
퍼블릭 서브넷에 Cloud9을 설치하고, RDS 를 프라이빗 서브넷에 설치합니다. 

[인프라 생성]
```
cd

git clone https://github.com/gnosia93/eks-on-aws.git

cd eks-on-aws/tf

terraform init

terraform apply --auto-approve
```

[인프라 삭제]
```
terraform destroy
```


## 레퍼런스 ##
