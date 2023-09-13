이번 챕터를 실행하기 위해서는 로컬 PC 에 AWS EC2 keypair 파일(aws-kp-2.pem)이 있어야 하며, AWS CLI 또한 최신 버전이 설치되어야 한다. 
이미 존재하는 다른 이름의 EC2 keypair 를 사용하고자 한다면, 테라폼 tf/var.tf 파일에서 key_pair 변수값을 해당 keypair 명칭으로 수정한다. 
```
variable "key_pair" {
    type = string
    default = "aws-kp-2"                ## AWS 콘솔에서 생성한 키페어 명칭으로 변경.
}
```


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

로컬 PC의 테라폼을 이용하여 VPC, Subnet, 인터넷 GW 및 NAT GW 를 생성합니다. 또한 퍼블릭 서브넷에 Cloud9, RDS 를 프라이빗 서브넷에 설치됩니다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/eks-on-aws-archi-base-1.png)

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

AWS Cloud9 서비스 콘솔로 로그인하여, cloud9 터미널을 하나 열고 워크샵에 필요한 유틸리티들을 설치한다.

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

# eksctl 설치
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | \
tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

# k9s
K9S_VERSION=v0.26.7
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_x86_64.tar.gz | sudo tar xfz - -C /usr/local/bin

# helm
curl -sSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short

# telnet
sudo yum install telnet -y
```

#### 3.2 cloud9 용 IAM 역할 생성 ####

로컬 PC 에서 아래 명령어로 eksworkshop-admin 역할을 만듭니다.(AWS 어드민 권한 필요)
```
cat <<EOF > assumeRole.json
{
     "Version": "2012-10-17",
     "Statement": [
         {
         "Effect": "Allow",
         "Principal": {
             "Service": "ec2.amazonaws.com"
         },
         "Action": "sts:AssumeRole"
         }
     ]
}
EOF

aws iam create-role \
    --role-name eksworkshop-admin \
    --assume-role-policy-document file://assumeRole.json

aws iam attach-role-policy \
    --role-name eksworkshop-admin \
    --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

cloud9 ec2 인스턴스 프로파일을 만들고 attach 한다. 
```
INSTANCE_ID=$(aws ec2 describe-instances --filter "Name=tag:app,Values=cloud9" --query 'Reservations[].Instances[].InstanceId' --out text)

aws iam create-instance-profile --instance-profile-name eksworkshop-admin-Instance-Profile

aws iam add-role-to-instance-profile --role-name eksworkshop-admin \
     --instance-profile-name eksworkshop-admin-Instance-Profile

aws ec2 associate-iam-instance-profile \
     --iam-instance-profile Name=eksworkshop-admin-Instance-Profile \
     --instance-id ${INSTANCE_ID}
```

#### 3.3 cloud9 자격증명 교체 ####

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
export ACCOUNT_ID=$(aws sts get-caller-identity --region ap-northeast-2 --output text --query Account)
export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

echo "export ACCOUNT_ID=${ACCOUNT_ID}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile
aws configure set default.region ${AWS_REGION}
aws configure --profile default list
```
[결과]
```
      Name                    Value             Type    Location
      ----                    -----             ----    --------
   profile                  default           manual    --profile
access_key     ****************ZD5H         iam-role    
secret_key     ****************IxVN         iam-role    
    region           ap-northeast-2              env    ['AWS_REGION', 'AWS_DEFAULT_REGION']
hopigaga:~ $ 
```
