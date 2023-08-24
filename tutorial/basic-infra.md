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

로컬 PC의 테라폼을 이용하여 VPC, Subnet(퍼블릭 2개, 프라이빗 2개 - EKS 클러스터용, 프라이빗 2개 - RDS 및 ElastiCache용), 인터넷 GW 및 NAT GW 를 생성합니다. 또한 퍼블릭 서브넷에 Cloud9, RDS 를 프라이빗 서브넷에 설치됩니다.  

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


### 3. Cloud9 설정 ###

AWS Cloud9 서비스 콘솔로 로그인하여, cloud9 터미널에서 아래 명령어를 실행합니다. 이 시점 부터는 Cloud9 터미널에서 모든 작업을 수행합니다.

#### 3.1 유틸리티 설치 ####
```
# AWS CLI Upgrade
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
source ~/.bashrc
aws --version

# AWS CLI 자동완성 설치 
which aws_completer
export PATH=/usr/local/bin:$PATH
source ~/.bash_profile
complete -C '/usr/local/bin/aws_completer' aws

aws --version

# kubectl 설치
cd ~
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.22.6/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> ~/.bashrc
kubectl version --short --client

# 유틸리티 설치
sudo yum -y install jq gettext bash-completion moreutils
for command in kubectl jq envsubst aws
  do
    which $command &>/dev/null && echo "$command in path" || echo "$command NOT FOUND"
  done

# k9s
K9S_VERSION=v0.26.7
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz | sudo tar xfz - -C /usr/local/bin 
  
```

#### 3.2 cloud9 용 IAM 역할 생성 ####

AWS IAM 콘솔에서 eksworkshop-admin 역할을 만듭니다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-2.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-3.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-4.png)




#### 3.3 cloud9 IAM 역할 수정 ####

EC2 콘솔에서 cloud9 인스턴스의 IAM 역할을 eksworkshop-admin 으로 수정한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-apply-1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-apply-2.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-apply-3.png)

Cloud9의 기존 자격증명과 임시 자격 증명등을 비활성화 합니다. 우측 상단의 톱니바뀌 모양 아이콘을 클릭한 후 좌측 Preferences 에서 AWS Settings 을 선택한 후 AWS managed temporary credentials 을 비활성화 합니다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloud9-role-apply-4.png)

Cloud9 터미널에서 기존 자격 증명 파일을 제거하고 변경된 Role 을 확인합니다. 
```
rm -vf ${HOME}/.aws/credentials

aws sts get-caller-identity --region ap-northeast-2 --query Arn | grep eksworkshop-admin -q && echo "IAM role valid" \
 || echo "IAM role NOT valid"
aws sts get-caller-identity --region ap-northeast-2
```

#### 3.4 Shell 환경변수 저장 ####

```
# Account , Region 정보를 AWS Cli로 추출합니다.
export ACCOUNT_ID=$(aws sts get-caller-identity --region ap-northeast-2 --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
echo $ACCOUNT_ID
echo $AWS_REGION
# bash_profile에 Account 정보, Region 정보를 저장합니다.
echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure --profile default list
```

#### 3.5 SSH Key 생성 ####

key 이름을 eksworkshop 으로 생성합니다.
Enter file in which to save the key (/home/ec2-user/.ssh/id_rsa): eksworkshop

```
cd ~/environment/
ssh-keygen

mv ./eksworkshop ./eksworkshop.pem
chmod 400 ./eksworkshop.pem

# ap-northeast-2 로 전송합니다.
aws ec2 import-key-pair --key-name "eksworkshop" --public-key-material fileb://./eksworkshop.pub --region ap-northeast-2
```




## 레퍼런스 ##
