
* cluster-config.yaml

https://eksctl.io/usage/vpc-configuration/
```
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: my-test
  region: us-west-2

vpc:
  id: "vpc-11111"
  subnets:
    public:
      us-west-2d:
          id: "subnet-0153e560b3129a696"
      us-west-2c:
          id: "subnet-0cc9c5aebe75083fd"
      us-west-2a:
          id: "subnet-009fa0199ec203c37"
      us-west-2b:
          id: "subnet-018fa0176ba320e45"
```




## 레퍼런스 ##

* https://eksctl.io/usage/creating-and-managing-clusters/

* https://kingofbackend.tistory.com/235

* eks workshop - https://www.eksworkshop.com/010_introduction/

* Containers from the Couch  
  https://www.youtube.com/@ContainersfromtheCouch/videos

* https://awskocaptain.gitbook.io/aws-builders-eks/4.-eksctl 

