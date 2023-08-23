

### 1. 환경변수 설정 ###

```
kubectl config current-context
export CLUSTER_NAME=eks-workshop
export KARPENTER_VERSION=v0.29.2
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text)"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
```

### 2. KarpenterInstanceNodeRole Role 생성 ###
```
cat <<EOF > role-trust.json 
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
  --role-name KarpenterInstanceNodeRole \
  --assume-role-policy-document file://role-trust.json

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
  --role-name KarpenterInstanceNodeRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name KarpenterInstanceNodeRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
  --role-name KarpenterInstanceNodeRole

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore \
  --role-name KarpenterInstanceNodeRole
```


## 레퍼런스 ##

* https://github.com/aws/karpenter/releases

* https://tech.scatterlab.co.kr/spot-karpenter/

* https://karpenter.sh/

* https://repost.aws/knowledge-center/eks-install-karpenter
