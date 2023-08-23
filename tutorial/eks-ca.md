
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

eksctl create iamserviceaccount \
    --name cluster-autoscaler \
    --namespace kube-system \
    --cluster ${CLUSTER_NAME} \
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/k8s-asg-policy" \
    --approve \
    --override-existing-serviceaccounts

kubectl -n kube-system describe sa cluster-autoscaler
```
[결과]
```
Name:                cluster-autoscaler
Namespace:           kube-system
Labels:              app.kubernetes.io/managed-by=eksctl
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::499514681453:role/eksctl-eks-workshop-addon-iamserviceaccount-Role1-MXUNUFQKEXRB
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```

### 4. CA 설치 ###

* 클러스터 버전 확인
```
$ kubectl version --short=true
Client Version: v1.23.6
Server Version: v1.25.12-eks-2d98532
WARNING: version difference between client (1.23) and server (1.25) exceeds the supported minor version skew of +/-1
```

* https://github.com/kubernetes/autoscaler/releases 에서 EKS 서버 버전에 맞는 autoscaler 최신 버전 확인
```
Cluster Autoscaler 1.25.3
```
  

* cluster-autoscaler-autodiscover.yaml 수정
```
curl -o cluster-autoscaler-autodiscover.yaml \
https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
```

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/autodiscover.png)

```
1. <YOUR CLUSTER NAME> 을 ${CLUSTER_NAME} 으로 수정
2. 컨테이너 이미지 cluster-autoscaler:v1.26.2 를 cluster-autoscaler:v1.25.3 으로 수정
```

* 오브젝트 생성
```
kubectl apply -f cluster-autoscaler-autodiscover.yaml
```

[결과]
```
Warning: resource serviceaccounts/cluster-autoscaler is missing the kubectl.kubernetes.io/last-applied-configuration annotation which is required by kubectl apply. kubectl apply should only be used on resources created declaratively by either kubectl create --save-config or kubectl apply. The missing annotation will be patched automatically.
serviceaccount/cluster-autoscaler configured
clusterrole.rbac.authorization.k8s.io/cluster-autoscaler created
role.rbac.authorization.k8s.io/cluster-autoscaler created
clusterrolebinding.rbac.authorization.k8s.io/cluster-autoscaler created
rolebinding.rbac.authorization.k8s.io/cluster-autoscaler created
deployment.apps/cluster-autoscaler created
```


## 레퍼런스 ##

* [EKS Cluster Autoscaler(CA scales)](https://blog.luxrobo.com/eks-cluster-autoscaler-ca-scales-2bbf2a3147ae)

* https://archive.eksworkshop.com/beginner/080_scaling/deploy_ca/
