
### 1. 오토 스케일링 그룹 설정 확인 ###
```
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && \
    Value=='${CLUSTER_NAME}']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```
[결과]
```
-------------------------------------------------------------------------
|                       DescribeAutoScalingGroups                       |
+--------------------------------------------------------+----+----+----+
|  eks-nodegroup-1-4ec51041-924b-6017-2037-43d446c0c4ff  |  3 |  3 |  3 |
+--------------------------------------------------------+----+----+----+
```

### 2. 노드 MaxSize 변경 ###
```
# we need the ASG name
export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && \
 Value=='${CLUSTER_NAME}']].AutoScalingGroupName" --output text)

# increase max capacity up to 6
aws autoscaling \
    update-auto-scaling-group \
    --auto-scaling-group-name ${ASG_NAME} \
    --min-size 3 \
    --desired-capacity 3 \
    --max-size 6

# Check new values
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='${CLUSTER_NAME}']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```

[결과]
```
-------------------------------------------------------------------------
|                       DescribeAutoScalingGroups                       |
+--------------------------------------------------------+----+----+----+
|  eks-nodegroup-1-4ec51041-924b-6017-2037-43d446c0c4ff  |  3 |  6 |  3 |
+--------------------------------------------------------+----+----+----+
```

### 3. 서비스 어카운트 생성 ###
```
cat <<EOF > k8s-asg-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "ec2:DescribeLaunchTemplateVersions"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF

aws iam create-policy   \
  --policy-name k8s-asg-policy \
  --policy-document file://k8s-asg-policy.json
```



## 레퍼런스 ##

* [EKS Cluster Autoscaler(CA scales)](https://blog.luxrobo.com/eks-cluster-autoscaler-ca-scales-2bbf2a3147ae)

* https://archive.eksworkshop.com/beginner/080_scaling/deploy_ca/
