### 1. VPC 생성 ###

2개의 AZ 에 걸쳐서 public 및 private 서브넷을 각각 2개씩 생성한다.


### 2. Cloud9 생성 ###

public 서브넷 한곳에 cloud9 을 생성한다.


### 3. EKS 클러스터 설치 ###

위에서 생성된 VPC 의 private 서브넷에 EKS 클러스터를 설치할 것이다.
eks-cluster-1.yaml 을 콘솔에서 생성한 후, eksctl 를 이용하여 클러스터를 생성한다. 

* eks-cluster-1.yaml   
```
$ cat << EOF > eks-cluster-1.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-cluster-1
  region: ap-northeast-2

vpc:
  id: "vpc-0f154186c927b11bf"
  subnets:
    private:
      ap-northeast-2b-private1:           # subnet alias for ClusterConfig file, not VPC console subnet alias.
          id: "subnet-0e00aad3d9ebdf2b2"
      ap-northeast-2c-private2:
          id: "subnet-03941214c7e716f91"

managedNodeGroups:
- name: nodegroup-1
  desiredCapacity: 3
  instanceType: t3.small
  privateNetworking: true
  subnets:
    - ap-northeast-2b-private1
    - ap-northeast-2c-private2
  volumeSize: 80
  ssh: # use existing EC2 key, check from AWS EC2 console's keypair sub menu.
      publicKeyName: aws-kp-2
EOF
```

```
$ eksctl create cluster -f eks-cluster-1.yaml
2023-08-20 02:46:09 [ℹ]  eksctl version 0.153.0
2023-08-20 02:46:09 [ℹ]  using region ap-northeast-2
2023-08-20 02:46:09 [✔]  using existing VPC (vpc-0f154186c927b11bf) and subnets (private:map[ap-northeast-2b-private1:{subnet-0e00aad3d9ebdf2b2 ap-northeast-2b 172.31.16.0/20 0 } ap-northeast-2c-private2:{subnet-03941214c7e716f91 ap-northeast-2c 172.31.32.0/20 0 }] public:map[])
2023-08-20 02:46:09 [!]  custom VPC/subnets will be used; if resulting cluster doesn't function as expected, make sure to review the configuration of VPC/subnets
2023-08-20 02:46:09 [ℹ]  nodegroup "nodegroup-1" will use "" [AmazonLinux2/1.25]
2023-08-20 02:46:09 [ℹ]  using EC2 key pair "aws-kp-2"
2023-08-20 02:46:09 [ℹ]  using Kubernetes version 1.25
2023-08-20 02:46:09 [ℹ]  creating EKS cluster "eks-cluster-1" in "ap-northeast-2" region with managed nodes
2023-08-20 02:46:09 [ℹ]  1 nodegroup (nodegroup-1) was included (based on the include/exclude rules)
2023-08-20 02:46:09 [ℹ]  will create a CloudFormation stack for cluster itself and 0 nodegroup stack(s)
2023-08-20 02:46:09 [ℹ]  will create a CloudFormation stack for cluster itself and 1 managed nodegroup stack(s)
2023-08-20 02:46:09 [ℹ]  if you encounter any issues, check CloudFormation console or try 'eksctl utils describe-stacks --region=ap-northeast-2 --cluster=eks-cluster-1'
2023-08-20 02:46:09 [ℹ]  Kubernetes API endpoint access will use default of {publicAccess=true, privateAccess=false} for cluster "eks-cluster-1" in "ap-northeast-2"
2023-08-20 02:46:09 [ℹ]  CloudWatch logging will not be enabled for cluster "eks-cluster-1" in "ap-northeast-2"
2023-08-20 02:46:09 [ℹ]  you can enable it with 'eksctl utils update-cluster-logging --enable-types={SPECIFY-YOUR-LOG-TYPES-HERE (e.g. all)} --region=ap-northeast-2 --cluster=eks-cluster-1'
2023-08-20 02:46:09 [ℹ]  
2 sequential tasks: { create cluster control plane "eks-cluster-1", 
    2 sequential sub-tasks: { 
        wait for control plane to become ready,
        create managed nodegroup "nodegroup-1",
    } 
}
2023-08-20 02:46:09 [ℹ]  building cluster stack "eksctl-eks-cluster-1-cluster"
2023-08-20 02:46:10 [ℹ]  deploying stack "eksctl-eks-cluster-1-cluster"
2023-08-20 02:46:40 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-1-cluster"
2023-08-20 02:47:10 [ℹ]  waiting for CloudFormation stack "eksctl-eks-cluster-1-cluster"
```





## 레퍼런스 ##

* https://eksctl.io/usage/creating-and-managing-clusters/

* https://kingofbackend.tistory.com/235

* eks workshop - https://www.eksworkshop.com/010_introduction/

* Containers from the Couch  
  https://www.youtube.com/@ContainersfromtheCouch/videos

* https://awskocaptain.gitbook.io/aws-builders-eks/4.-eksctl 

* https://eksctl.io/usage/vpc-configuration/
