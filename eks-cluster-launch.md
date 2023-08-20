### 1. VPC 생성 ###

2개의 AZ 에 걸쳐서 public 및 private 서브넷을 각각 2개씩 생성한다.


### 2. Cloud9 생성 ###

public 서브넷 한곳에 cloud9 을 생성한다.


### 3. EKS 클러스터 설치 ###

위에서 생성된 VPC 의 private 서브넷에 EKS 클러스터를 설치할 것이다.
eksctl 로 아래의 cluster config 파일을 실행한다. 

* cluster-config.yaml   
  https://eksctl.io/usage/vpc-configuration/
```
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: eks-cluster-1
  region: ap-northeast-2

vpc:
  id: "vpc-0f154186c927b11bf"
  subnets:
    private:
      ap-northeast-2b-private1:           # subnet alias
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
```





## 레퍼런스 ##

* https://eksctl.io/usage/creating-and-managing-clusters/

* https://kingofbackend.tistory.com/235

* eks workshop - https://www.eksworkshop.com/010_introduction/

* Containers from the Couch  
  https://www.youtube.com/@ContainersfromtheCouch/videos

* https://awskocaptain.gitbook.io/aws-builders-eks/4.-eksctl 

