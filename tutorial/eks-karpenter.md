

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
  --role-only \
  --approve
```


### 4. 서브넷 태깅 ###
```
for NODEGROUP in $(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} \
    --query 'nodegroups' --output text); do aws ec2 create-tags \
        --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
        --resources $(aws eks describe-nodegroup --cluster-name ${CLUSTER_NAME} \
        --nodegroup-name $NODEGROUP --query 'nodegroup.subnets' --output text )
done
```

### 5. 시큐리티 그룹 태깅 ###
```
NODEGROUP=$(aws eks list-nodegroups --cluster-name ${CLUSTER_NAME} \
    --query 'nodegroups[0]' --output text)
 
LAUNCH_TEMPLATE=$(aws eks describe-nodegroup --cluster-name ${CLUSTER_NAME} \
    --nodegroup-name ${NODEGROUP} --query 'nodegroup.launchTemplate.{id:id,version:version}' \
    --output text | tr -s "\t" ",")
 
# If your EKS setup is configured to use only Cluster security group, then please execute -
 
SECURITY_GROUPS=$(aws eks describe-cluster \
    --name ${CLUSTER_NAME} --query cluster.resourcesVpcConfig.clusterSecurityGroupId | tr -d '"')

aws ec2 create-tags \
    --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
    --resources ${SECURITY_GROUPS}
 
# If your setup uses the security groups in the Launch template of a managed node group, then :
 
SECURITY_GROUPS=$(aws ec2 describe-launch-template-versions \
    --launch-template-id ${LAUNCH_TEMPLATE%,*} --versions ${LAUNCH_TEMPLATE#*,} \
    --query 'LaunchTemplateVersions[0].LaunchTemplateData.[NetworkInterfaces[0].Groups||SecurityGroupIds]' \
    --output text)
 
aws ec2 create-tags \
    --tags "Key=karpenter.sh/discovery,Value=${CLUSTER_NAME}" \
    --resources ${SECURITY_GROUPS}
```

### 6. Update aws-auth ConfigMap ###

KarpenterInstanceNodeRole 로 클러스터 리소스에 접근할 수 있도록 한다. 

```
kubectl edit configmap aws-auth -n kube-system
```

아래 mapRoles 추가한다. 이때 ${AWS_ACCOUNT_ID} 부분은 어카운트ID 로 바꾸고, {{EC2PrivateDNSName}} 는 그대로 유지한다.  
```
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterInstanceNodeRole
  username: system:node:{{EC2PrivateDNSName}}
```

### 7. KARPENTER 설치 ### 

#### 7.1 helm 차트 설치 ####
```
echo $KARPENTER_VERSION

# make sure that the Helm client version is v3.11.0 or later.
helm version --short

helm template karpenter oci://public.ecr.aws/karpenter/karpenter --version ${KARPENTER_VERSION} --namespace karpenter \
    --set settings.aws.defaultInstanceProfile=KarpenterInstanceProfile \
    --set settings.aws.clusterEndpoint="${CLUSTER_ENDPOINT}" \
    --set settings.aws.clusterName=${CLUSTER_NAME} \
    --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::${AWS_ACCOUNT_ID}:role/KarpenterControllerRole-${CLUSTER_NAME}" \
> karpenter.yaml
```

#### 7.2 karpenter.yaml 수정 - nodegroup 부분 추가 ####
```
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: karpenter.sh/provisioner-name
          operator: DoesNotExist
      - matchExpressions:
        - key: eks.amazonaws.com/nodegroup
          operator: In
          values:
          - ${NODEGROUP}
```

[수정전]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-node-affinity-1.png)

[수정후]
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-node-affinity-2.png)


#### 7.3 리소스 설치 ####

```
kubectl create namespace karpenter
kubectl create -f https://raw.githubusercontent.com/aws/karpenter/${KARPENTER_VERSION}/pkg/apis/crds/karpenter.sh_provisioners.yaml
kubectl create -f https://raw.githubusercontent.com/aws/karpenter/${KARPENTER_VERSION}/pkg/apis/crds/karpenter.k8s.aws_awsnodetemplates.yaml
kubectl apply -f karpenter.yaml
```

#### 7.4 디폴트 프로비저너 생성 ####
```
cat <<EOF | kubectl apply -f -
apiVersion: karpenter.sh/v1alpha5
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: karpenter.k8s.aws/instance-category
      operator: In
      values: [c, m, r]
    - key: karpenter.k8s.aws/instance-generation
      operator: Gt
      values: ["2"]
  providerRef:
    name: default
  ttlSecondsAfterEmpty: 30
---
apiVersion: karpenter.k8s.aws/v1alpha1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: "${CLUSTER_NAME}"
  securityGroupSelector:
    karpenter.sh/discovery: "${CLUSTER_NAME}"
EOF
```

### 8. 스케일링 테스트 ###

```
aws eks update-nodegroup-config --cluster-name ${CLUSTER_NAME} \
    --nodegroup-name ${NODEGROUP} \
    --scaling-config "minSize=2,maxSize=2,desiredSize=2"
```

```
kubectl logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter
```
Note: If you notice any webhook.DefaultingWebhook Reconcile error in the controller logs, restart your Karpenter pods to fix it.

```
kubectl get nodes
```


## 트러블 슈팅 ##
```
Error from server (InternalError): error when creating "STDIN": Internal error occurred: failed calling webhook "defaulting.webhook.karpenter.k8s.aws": failed to call webhook: Post "https://karpenter.karpenter.svc:8443/?timeout=10s": no endpoints available for service "karpenter"
Error from server (InternalError): error when creating "STDIN": Internal error occurred: failed calling webhook "defaulting.webhook.karpenter.k8s.aws": failed to call webhook: Post "https://karpenter.karpenter.svc:8443/?timeout=10s": no endpoints available for service "karpenter"
hopigaga:~/environment $ kubectl -n karpenter get po -w
NAME                         READY   STATUS             RESTARTS      AGE
karpenter-585bdd986b-mlm8n   0/1     CrashLoopBackOff   6 (57s ago)   7m3s
karpenter-585bdd986b-z9wkq   0/1     CrashLoopBackOff   6 (46s ago)   7m2s
```



## 레퍼런스 ##

* https://github.com/aws/karpenter/releases

* https://tech.scatterlab.co.kr/spot-karpenter/

* https://karpenter.sh/

* https://repost.aws/knowledge-center/eks-install-karpenter
