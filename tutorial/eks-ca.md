

```
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && \
    Value=='${CLUSTER_NAME}']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```


## 레퍼런스 ##

* [EKS Cluster Autoscaler(CA scales)](https://blog.luxrobo.com/eks-cluster-autoscaler-ca-scales-2bbf2a3147ae)

* https://archive.eksworkshop.com/beginner/080_scaling/deploy_ca/
