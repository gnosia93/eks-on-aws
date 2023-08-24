## 1. EKS 클러스터 생성 ##

이전 단계에서 생성된 eks-workshop VPC 의 private 서브넷 3곳에 EKS 클러스터를 설치할 것이다.

```
export PRIVATE_SUBNET_1=subnet-0c10211bf63884f93
export PRIVATE_SUBNET_2=subnet-0bd2186738362fe57
export PRIVATE_SUBNET_3=subnet-049345252a9d75d3d

$ export CLUSTER_NAME=eks-workshop
$ if ! grep -q CLUSTER_NAME ~/.bash_profile; then echo "export CLUSTER_NAME="$CLUSTER_NAME >>  ~/.bash_profile; fi   
```

cloud9 콘솔에서 eks-cluster-1.yaml 파일을 생성한 후, eksctl 를 이용하여 클러스터를 생성한다. 
```
$ cat << EOF > $CLUSTER_NAME.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: $CLUSTER_NAME
  region: ap-northeast-2

vpc:
  id: "vpc-0f154186c927b11bf"
  subnets:
    private:
      private-sub-1:           # subnet alias for ClusterConfig file, not VPC console subnet alias.
          id: "${PRIVATE_SUBNET_1}"
      private-sub-2:
          id: "${PRIVATE_SUBNET_2}"
      private-sub-3:
          id: "${PRIVATE_SUBNET_3}"
  clusterEndpoints:
    publicAccess: true
    privateAccess: true                   # API 엔드포인트 접근을 VPC 내부에서 가능하도록 한다.       

managedNodeGroups:
- name: ng-1
  desiredCapacity: 3
  instanceType: m6i.xlarge
  privateNetworking: true
  subnets:
    - private-sub-1
    - private-sub-2
    - private-sub-3
  volumeSize: 80
  ssh: # use existing EC2 key, check from AWS EC2 console's keypair sub menu.
      publicKeyName: aws-kp-2
EOF
```

```
$ eksctl create cluster -f $CLUSTER_NAME.yaml
2023-08-23 03:39:47 [ℹ]  eksctl version 0.153.0
2023-08-23 03:39:47 [ℹ]  using region ap-northeast-2
2023-08-23 03:39:47 [✔]  using existing VPC (vpc-0f154186c927b11bf) and subnets (private:map[private-sub-1:{subnet-0e00aad3d9ebdf2b2 ap-northeast-2b 172.31.16.0/20 0 } private-sub-2:{subnet-03941214c7e716f91 ap-northeast-2c 172.31.32.0/20 0 }] public:map[])
2023-08-23 03:39:47 [!]  custom VPC/subnets will be used; if resulting cluster doesn't function as expected, make sure to review the configuration of VPC/subnets
2023-08-23 03:39:47 [ℹ]  nodegroup "nodegroup-1" will use "" [AmazonLinux2/1.25]
2023-08-23 03:39:47 [ℹ]  using EC2 key pair "aws-kp-2"
2023-08-23 03:39:47 [ℹ]  using Kubernetes version 1.25
2023-08-23 03:39:47 [ℹ]  creating EKS cluster "eks-workshop" in "ap-northeast-2" region with managed nodes
2023-08-23 03:39:47 [ℹ]  1 nodegroup (nodegroup-1) was included (based on the include/exclude rules)
2023-08-23 03:39:47 [ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
2023-08-23 03:39:47 [ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
2023-08-23 03:39:47 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-northeast-2 --cluster=eks-workshop'
2023-08-23 03:39:47 [ℹ]  Kubernetes API endpoint access will use provided values {publicAccess=true, privateAccess=true} for cluster "eks-workshop" in "ap-northeast-2"
2023-08-23 03:39:47 [ℹ]  CloudWatch logging will not be enabled for cluster "eks-workshop" in "ap-northeast-2"
2023-08-23 03:39:47 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-northeast-2 --cluster=eks-workshop'
2023-08-23 03:39:47 [ℹ]  
2 sequential tasks: { create cluster control plane "eks-workshop", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create managed nodegroup "nodegroup-1",
    } 
}
2023-08-23 03:39:47 [ℹ]  building cluster stack "eksctl-eks-workshop-cluster"
2023-08-23 03:39:47 [ℹ]  deploying stack "eksctl-eks-workshop-cluster"
2023-08-23 03:40:17 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:40:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:41:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:42:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:43:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:44:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:45:47 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:46:48 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:47:48 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:48:48 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-cluster"
2023-08-23 03:49:18 [!]  API server is unreachable
2023-08-23 03:49:18 [ℹ]  building managed nodegroup stack "eksctl-eks-workshop-nodegroup-nodegroup-1"
2023-08-23 03:49:18 [ℹ]  deploying stack "eksctl-eks-workshop-nodegroup-nodegroup-1"
2023-08-23 03:49:18 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-nodegroup-1"
2023-08-23 03:49:48 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-nodegroup-1"
2023-08-23 03:50:26 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-nodegroup-1"
2023-08-23 03:52:05 [ℹ]  waiting for CloudFormation stack "eksctl-eks-workshop-nodegroup-nodegroup-1"
2023-08-23 03:52:05 [ℹ]  waiting for the control plane to become ready
2023-08-23 03:52:05 [✔]  saved kubeconfig as "/home/ec2-user/.kube/config"
2023-08-23 03:52:05 [ℹ]  no tasks
2023-08-23 03:52:05 [✔]  all EKS cluster resources for "eks-workshop" have been created
```

* [참고 - 클러스터 삭제]
```
eksctl delete cluster $CLUSTER_NAME
```

## 2. 클러스터 확인하기 ##

```
$ cat ~/.kube/config
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

* 노드 리스트 및 aws-auth 확인 
```
$ kubectl get nodes
NAME                                               STATUS   ROLES    AGE   VERSION
ip-172-31-25-232.ap-northeast-2.compute.internal   Ready    <none>   99m   v1.25.11-eks-a5565ad
ip-172-31-36-93.ap-northeast-2.compute.internal    Ready    <none>   99m   v1.25.11-eks-a5565ad

$ kubectl describe -n kube-system configmap/aws-auth
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
* 전체 네임스페이스 및 kube-system 네임스페이스 리소스 조회
```
$ kubectl get namespace
NAME              STATUS   AGE
default           Active   120m
kube-node-lease   Active   120m
kube-public       Active   120m
kube-system       Active   120m

$ kubectl get all -n kube-system                                                                                                                 
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

* eks workshop - https://www.eksworkshop.com/010_introduction/

* Containers from the Couch  
  https://www.youtube.com/@ContainersfromtheCouch/videos

* https://awskocaptain.gitbook.io/aws-builders-eks/4.-eksctl 

* https://eksctl.io/usage/vpc-configuration/


---
### 참고 .. VPC 생성 ###

2개의 AZ 에 걸쳐서 public 및 private 서브넷을 각각 2개씩 생성하고, NAT GW 를 public 서브넷에 설치한다.  
(주의) 예를들어 EKS 클러스터의 노드그룹이 a, c AZ 의 프라이빗 서브넷에 생성되는 경우하게 되는 경우, a, c AZ 에는 퍼브릿 서브넷이 꼭 존재해야 한다.
그렇지 않으면 ELB 가 생성되더라도 파드로 라우팅이 되지 않는다.  
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/elb-subnet-mapping.png)
또는 ELB 생성후 Cross Zone Load Balancing 기능을 enable 한다. K8S 서비스 또는 Ingress 설치시 Cross Zone Load Balancing 은 기본값이 diable 이다. 

프라이빗 서브넷용 라우팅 테이블을 생성하고, 0.0.0.0/0 라우팅에 대해서는 NAT GW 를 가리키도록 설정한다. 
EKS 클러스터 설치시 프라이빗 서브넷에에 노드그룹을 생성하는 경우, 워커노드가 생성되면 EKS 클러스터에 조인하게 되는데,
이때 public 을 통해서 K8S api 엔드포인트와 통신하게 된다.(즉 NAT GW를 통해서 public 으로 나가게 된다)  

아래와 같이 eksctl 설정파일에 privateAcesss 를 true 로 설정하더라도 
```
clusterEndpoints:
    publicAccess: true
    privateAccess: true         
```
클러스터 생성 시점에서는 통신이 불가능하며 클러스터 생성 완료 후 control plane 의 security group 을 변경해 줘야 한다. 



* DB 스키마 생성
cloud9 콘솔에서 아래 명령어를 샐행한다. 
```
$ mysql -u root -p -h springboot-stage.czed7onsq5sy.ap-northeast-2.rds.amazonaws.com
```
