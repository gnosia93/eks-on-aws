### 1. VPC 생성 ###

2개의 AZ 에 걸쳐서 public 및 private 서브넷을 각각 2개씩 생성한다.
NAT GW 를 public 서브넷에 설치한다. EKS 클러스터 설치시 private subnet 에 노드그룹을 위치 시키는 경우, 노드그룹의 EC2 인스턴스가 생성된 후,
public 을 통해서 K8S apiend point 와의 통신이 필요하기 떄문이다 (필수) 


### 2. Cloud9 생성 ###

public 서브넷 한곳에 cloud9 을 생성한다.


### 3. EKS 클러스터 설치 ###

위에서 생성된 VPC 의 private 서브넷에 EKS 클러스터를 설치할 것이다.
cloud9 콘솔에서 eks-cluster-1.yaml 파일을 생성한 후, eksctl 를 이용하여 클러스터를 생성한다. 

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
  clusterEndpoints:
    publicAccess: true
    privateAccess: true                   # private subnet 에 설치되는 노드 그룹의 ec2 인스턴스들이 클러스터에 접근하기 위해서 설정
                                          # NATGW 에 있는 경우에는 false 로 설정가능.
                                          # NATGW 가 없고 privateAcess 가 false 인 상태에서 private subnet 에 워커노드를 생성하는 경우 클러스터에 조인 불가함.

managedNodeGroups:
- name: nodegroup-1
  desiredCapacity: 3
  instanceType: m6i.xlarge
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


## 트러블 슈팅 ##

* [How do I troubleshoot issues with the API server endpoint of my Amazon EKS cluster?](https://repost.aws/knowledge-center/eks-api-server-endpoint-failed)




## 레퍼런스 ##

* https://eksctl.io/usage/creating-and-managing-clusters/

* https://kingofbackend.tistory.com/235

* eks workshop - https://www.eksworkshop.com/010_introduction/

* Containers from the Couch  
  https://www.youtube.com/@ContainersfromtheCouch/videos

* https://awskocaptain.gitbook.io/aws-builders-eks/4.-eksctl 

* https://eksctl.io/usage/vpc-configuration/
