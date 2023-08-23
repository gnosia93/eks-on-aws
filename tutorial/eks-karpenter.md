

### 1. 환경변수 설정 ###

```
export CLUSTER_NAME=eks-workshop
export KARPENTER_VERSION=v0.29.2
export CLUSTER_ENDPOINT="$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text)"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

kubectl config current-context
eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} --approve
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

### 3. karpenter 서비스 어카운트 생성 ###
```
echo '{
    "Statement": [
        {
            "Action": [
                "ssm:GetParameter",
                "iam:PassRole",
                "ec2:DescribeImages",
                "ec2:RunInstances",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeLaunchTemplates",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceTypes",
                "ec2:DescribeInstanceTypeOfferings",
                "ec2:DescribeAvailabilityZones",
                "ec2:DeleteLaunchTemplate",
                "ec2:CreateTags",
                "ec2:CreateLaunchTemplate",
                "ec2:CreateFleet",
                "ec2:DescribeSpotPriceHistory",
                "pricing:GetProducts"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "Karpenter"
        },
        {
            "Action": "ec2:TerminateInstances",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/Name": "*karpenter*"
                }
            },
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ConditionalEC2Termination"
        }
    ],
    "Version": "2012-10-17"
}' > controller-policy.json

aws iam create-policy --policy-name KarpenterControllerPolicy-${CLUSTER_NAME} --policy-document file://controller-policy.json

eksctl create iamserviceaccount \
  --cluster "${CLUSTER_NAME}" --name karpenter --namespace karpenter \
  --role-name "$KarpenterControllerRole-${CLUSTER_NAME}" \
  --attach-policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/KarpenterControllerPolicy-${CLUSTER_NAME}" \
  --override-existing-serviceaccounts \
  --approve
```


## 레퍼런스 ##

* https://github.com/aws/karpenter/releases

* https://tech.scatterlab.co.kr/spot-karpenter/

* https://karpenter.sh/

* https://repost.aws/knowledge-center/eks-install-karpenter
