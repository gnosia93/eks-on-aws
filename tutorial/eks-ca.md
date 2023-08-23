

```
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && \
    Value=='${CLUSTER_NAME}']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```

```
-------------------------------------------------------------------------
|                       DescribeAutoScalingGroups                       |
+--------------------------------------------------------+----+----+----+
|  eks-nodegroup-1-4ec51041-924b-6017-2037-43d446c0c4ff  |  3 |  3 |  3 |
+--------------------------------------------------------+----+----+----+
```


## 레퍼런스 ##

* [EKS Cluster Autoscaler(CA scales)](https://blog.luxrobo.com/eks-cluster-autoscaler-ca-scales-2bbf2a3147ae)

* https://archive.eksworkshop.com/beginner/080_scaling/deploy_ca/
