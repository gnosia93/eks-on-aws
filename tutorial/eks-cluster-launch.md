## 1. EKS 클러스터 생성 ##

이전 단계에서 생성된 eks-workshop VPC 의 private 서브넷 2곳에 EKS 클러스터를 설치할 것이다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/aws-vpc.png)

AWS VPC 콘솔에서 VPC_ID 와 프라이빗 서브넷 ID 를 확인한 후 아래 export 스크립트를 수정한다. 
```
export VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?Tags[?Key==`Name`]|[?Value==`eks-workshop`]].VpcId' --output text)
export PRIVATE_SUBNET_1=subnet-09509024e2b2c24a1
export PRIVATE_SUBNET_2=subnet-0b42d58a3c5421ffc

export CLUSTER_NAME=eks-workshop
if ! grep -q CLUSTER_NAME ~/.bash_profile; then echo "export CLUSTER_NAME="$CLUSTER_NAME >>  ~/.bash_profile; fi   
```

cloud9 콘솔에서 $CLUSTER_NAME.yaml 파일을 생성한 후, 
```
cat <<EOF > $CLUSTER_NAME.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: $CLUSTER_NAME
  region: ap-northeast-2

vpc:
  id: "${VPC_ID}"
  subnets:
    private:
      private-sub-1:           # subnet alias for ClusterConfig file, not VPC console subnet alias.
          id: "${PRIVATE_SUBNET_1}"
      private-sub-2:
          id: "${PRIVATE_SUBNET_2}"
  clusterEndpoints:
    publicAccess: true
    privateAccess: true                   # API 엔드포인트 접근을 VPC 내부에서 가능하도록 한다.       

managedNodeGroups:
- name: ng-2xlarge
  desiredCapacity: 3
  instanceType: m6i.2xlarge
  privateNetworking: true
  subnets:
    - private-sub-1
    - private-sub-2
  volumeSize: 80
  ssh: # use existing EC2 key, check from AWS EC2 console's keypair sub menu.
      publicKeyName: aws-kp-2
EOF
```

eksctl 를 이용하여 클러스터를 생성한다. 
```
eksctl create cluster -f $CLUSTER_NAME.yaml
```

[결과]
```
2023-08-24 04:39:34 [ℹ]  eksctl version 0.153.0
2023-08-24 04:39:34 [ℹ]  using region ap-northeast-2
2023-08-24 04:39:34 [✔]  using existing VPC (vpc-00e1fdf5c2c9272d1) and subnets (private:map[private-sub-1:{subnet-0c10211bf63884f93 ap-northeast-2a 10.1.101.0/24 0 } private-sub-2:{subnet-0bd2186738362fe57 ap-northeast-2b 10.1.102.0/24 0 } private-sub-3:{subnet-049345252a9d75d3d ap-northeast-2c 10.1.103.0/24 0 }] public:map[])
2023-08-24 04:39:34 [!]  custom VPC/subnets will be used; if resulting cluster doesn't function as expected, make sure to review the configuration of VPC/subnets
2023-08-24 04:39:34 [ℹ]  nodegroup "eks-ng-1" will use "" [AmazonLinux2/1.25]
2023-08-24 04:39:34 [ℹ]  using EC2 key pair "aws-kp-2"
2023-08-24 04:39:34 [ℹ]  using Kubernetes version 1.25
2023-08-24 04:39:34 [ℹ]  creating EKS cluster "eks-workshop" in "ap-northeast-2" region with managed nodes
2023-08-24 04:39:34 [ℹ]  1 nodegroup (eks-ng-1) was included (based on the include/exclude rules)
2023-08-24 04:39:34 [ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
2023-08-24 04:39:34 [ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
2023-08-24 04:39:34 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-northeast-2 --cluster=eks-workshop'
2023-08-24 04:39:34 [ℹ]  Kubernetes API endpoint access will use provided values {publicAccess=true, privateAccess=true} for cluster "eks-workshop" in "ap-northeast-2"
2023-08-24 04:39:34 [ℹ]  CloudWatch logging will not be enabled for cluster "eks-workshop" in "ap-northeast-2"
2023-08-24 04:39:34 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-northeast-2 --cluster=eks-workshop'
2023-08-24 04:39:34 [ℹ]  
2 sequential tasks: { create cluster control plane "eks-workshop", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create managed nodegroup "eks-ng-1",
    } 
}
2023-08-24 04:39:34 [ℹ]  building cluster stack "eksctl-eks-workshop-cluster"
2023-08-24 04:39:34 [ℹ]  deploying stack "eksctl-eks-workshop-cluster"
2023-08-24 04:40:04 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:40:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:41:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:42:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:43:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:44:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:45:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:46:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:47:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:48:35 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-24 04:49:05 [!]  API server is unreachable
2023-08-24 04:49:06 [ℹ]  building managed nodegroup stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:49:06 [ℹ]  deploying stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:49:06 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:49:36 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:50:10 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:51:09 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:52:04 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-eks-ng-1"
2023-08-24 04:52:04 [ℹ]  waiting for the control plane to become ready
2023-08-24 04:52:04 [✔]  saved kubeconfig as "/home/ec2-user/.kube/config"
2023-08-24 04:52:04 [ℹ]  no tasks
2023-08-24 04:52:04 [✔]  all EKS cluster resources for "eks-workshop" have been created
Error: listing nodes: Get "https://31FEBEAA231F37E94B7CF384D8EC3EDD.gr7.ap-northeast-2.eks.amazonaws.com/api/v1/nodes?labelSelector=alpha.eksctl.io%2Fnodegroup-name%3Deks-ng-1": dial tcp 10.1.103.146:443: i/o timeout
```

all EKS cluster resources for "eks-workshop" have been created 메시지 출력 이후, 오랜시간 동안 아무런 출력없이 머물러 있다가 i/o timeout 에러가 발생하는데, 이는 eksctl 설정파일에 clusterEndpoints 의 privateAcesss 를 true 로 설정했기 때문이다. 
```
clusterEndpoints:
    ...
    privateAccess: true         
```
클러스터 생성 시점에서는 private 채널을 통한 통신이 불가능하며, 이를 해결하기 위해서는 EKS control plane 의 security group 을 변경해 줘야 한다.
(아래 트러블 슈팅 참고) 


#### [참고 - 클러스터 삭제] ####
```
eksctl delete cluster $CLUSTER_NAME
```

## 2. 클러스터 확인하기 ##

#### context 확인 ###
```
cat ~/.kube/config
```
[결과]
```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJS29WUnZyTnUwRkV3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TXpBNE1qQXdORFV4TURGYUZ3MHpNekE0TVRjd05EVXhNREZhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUURZSldJNlZHL1licUNhb1BsZTQxYXd5RW9MVExHbWtkV1gwWWZSamNwS2ZRL05HMnRIaUtlcHROeGcKZ3JHRG1NVm5mWEpoU3JlVUlUQWdtYjBaUGpIcEJtNlRNcTlxNW1vUzVIUjNoWmQ2SDB1T2ZrQVRTanY5VEdQdwpEeU05MDExWkFzNlVkbzhUK2FpVmdWbkNqSVBoa1pEUDdmdnBiSlBrKytmMlJYU0l5eUx2MW9pNHh2dGpQTTNTCmpuTTVkejZBVUVYT2NNSTJHMDREZFNvdFhHOG  ....
    server: https://60E6BA36AA5E9836286C5BC3F735E9C3.gr7.ap-northeast-2.eks.amazonaws.com
  name: eks-cluster-7.ap-northeast-2.eksctl.io
contexts:
- context:
    cluster: eks-cluster-7.ap-northeast-2.eksctl.io
    user: i-0b33b3127e4d57036@eks-cluster-7.ap-northeast-2.eksctl.io
  name: i-0b33b3127e4d57036@eks-cluster-7.ap-northeast-2.eksctl.io

current-context: i-0b33b3127e4d57036@eks-cluster-7.ap-northeast-2.eksctl.io
kind: Config
preferences: {}
users:
- name: i-0b33b3127e4d57036@my-cluster.ap-northeast-2.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      args:
      - eks
      - get-token
      - --output
      - json
      - --cluster-name
      - my-cluster
      - --region
      - ap-northeast-2
      command: aws
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
      interactiveMode: IfAvailable
      provideClusterInfo: false
```

#### 노드 리스트 ####
```
kubectl get nodes
```
[결과]
```
NAME                                              STATUS   ROLES    AGE   VERSION
ip-10-1-101-109.ap-northeast-2.compute.internal   Ready    <none>   18m   v1.25.11-eks-a5565ad
ip-10-1-102-4.ap-northeast-2.compute.internal     Ready    <none>   18m   v1.25.11-eks-a5565ad
ip-10-1-103-239.ap-northeast-2.compute.internal   Ready    <none>   18m   v1.25.11-eks-a5565ad
```

#### aws-auth 확인 ####
```
kubectl describe -n kube-system configmap/aws-auth
```
[결과]
```
Name:         aws-auth
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Data
====
mapRoles:
----
- groups:
  - system:bootstrappers
  - system:nodes
  rolearn: arn:aws:iam::xxxxxxxxxxxx:role/eksctl-eks-cluster-7-nodegroup-no-NodeInstanceRole-1L3CNTPC95JPB
  username: system:node:{{EC2PrivateDNSName}}


BinaryData
====

Events:  <none>
$ 
```

#### kube-system 네임스페이스 오브젝트 ####
```
kubectl get all -n kube-system
```
[결과]
```           
NAME                           READY   STATUS    RESTARTS   AGE
pod/aws-node-9dq6t             1/1     Running   0          115m
pod/aws-node-d5hlv             1/1     Running   0          115m
pod/coredns-76b4dcc5cc-s8c2n   1/1     Running   0          122m
pod/coredns-76b4dcc5cc-z55c7   1/1     Running   0          122m
pod/kube-proxy-v55qw           1/1     Running   0          115m
pod/kube-proxy-wf487           1/1     Running   0          115m

NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)         AGE
service/kube-dns   ClusterIP   10.100.0.10   <none>        53/UDP,53/TCP   122m

NAME                        DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/aws-node     2         2         2       2            2           <none>          122m
daemonset.apps/kube-proxy   2         2         2       2            2           <none>          122m

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/coredns   2/2     2            2           122m

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/coredns-76b4dcc5cc   2         2         2       122m
hopigaga:~/.kube $ 
```

## 트러블 슈팅 ##

### 1. kubectl timeout ###

[How do I troubleshoot issues with the API server endpoint of my Amazon EKS cluster?](https://repost.aws/knowledge-center/eks-api-server-endpoint-failed)
```
$ kubectl get nodes
Unable to connect to the server: dial tcp 172.31.44.26:443: i/o timeout

$ kubectl describe -n kube-system configmap/aws-auth
Unable to connect to the server: dial tcp 172.31.28.35:443: i/o timeout
```
위와 같이 timeout 이 발생하는 경우, EKS 클러스터(컨트롤 플레인) 시큐리티 그룹 엔트리에 cloud9 설정이 없는 것으로,
아래와 같이 cloud9의 시큐리티 그룹에 대한 443 포트를 오픈해 준다.

[EKS 클러스터 시큐리티 그룹 확인]
![](https://github.com/gnosia93/container-on-aws/blob/main/images/kubctl-timeout-1.png)

[Inbound 규칙 추가]
![](https://github.com/gnosia93/container-on-aws/blob/main/images/kubctl-timeout-2.png)


### 2. 콘솔 메시지 (Your current IAM principal doesn't have access to Kubernetes objects on this cluster.) ###

- https://stackoverflow.com/questions/70787520/your-current-user-or-role-does-not-have-access-to-kubernetes-objects-on-this-eks
- https://varlogdiego.com/eks-your-current-user-or-role-does-not-have-access-to-kubernetes

## 레퍼런스 ##

* https://eksctl.io/usage/creating-and-managing-clusters/

* https://kingofbackend.tistory.com/235

