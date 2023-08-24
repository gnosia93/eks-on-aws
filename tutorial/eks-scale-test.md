## 카펜터 스케일링 ##


### 1. 카펜트 로그 모니터링 ###

cloud9 터미널 탭을 하나 열어서 카펜터의 로그를 모니터링 한다. 
```
kubectl logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter
```

### 2. 오토스케일링 그룹 설정 확인 ###

eks-workshop 클러스터의 노드 최대 사이즈를 3개에서 9개로 설정한다. 
```
export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && \
 Value=='${CLUSTER_NAME}']].AutoScalingGroupName" --output text)
```
```
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='${CLUSTER_NAME}']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```
```
aws autoscaling \
    update-auto-scaling-group \
    --auto-scaling-group-name ${ASG_NAME} \
    --min-size 3 \
    --desired-capacity 3 \
    --max-size 9
```

### 2. nginx ###
```

```


#### 노드 갯수 확인 ####
```
kubectl get node
```





#### 스케일링 ####
```
kubectl scale --replicas=30 deployment/nginx-to-scaleout
```


## 레퍼런스 ##
