## 카펜터 스케일링 ##

카펜터 스케일링 테스트는 아래 순서대로 실행하고, 실행 속도를 관찰한다. 

### 1. 카펜트 로그 모니터링 ###

cloud9 터미널 탭을 하나 열어서 카펜터의 로그를 모니터링 한다. 
```
kubectl logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter
```

### 2. 오토스케일링 그룹 설정 ###

cloud9 에서 새로운 탭을 하나 열어 eks-workshop 클러스터의 노드 최대 사이즈를 3개에서 9개로 증가시킨다. 
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

### 3. nginx 디플로이먼트 생성 ###

cloud9 의 터미널에서 nginx-to-scaleout 오브젝트를 생성한다.  
```
cat <<EOF > nginx.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-to-scaleout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        service: nginx
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx-to-scaleout
        resources:
          limits:
            cpu: 1000m
            memory: 2048Mi
          requests:
            cpu: 1000m
            memory: 2048Mi
EOF

kubectl apply -f nginx.yaml
kubectl get deployment/nginx-to-scaleout
```

### 4. nginx 스케일링 / 노드 갯수 확인 ###

* 터미널에서 k9s 을 실행해서 파드 상태를 실시간으로 관찰한다.
```
k9s
```

* 리플리카 갯수를 30개로 증가시키고 노드수를 관찰하고, EC2 의 Instance 정보도 동시에 모니터링 한다.  
```
# 스케일아웃
kubectl scale --replicas=30 deployment/nginx-to-scaleout

# 노드수 조회
kubectl get node
```

### 5. nginx 삭제 ###

```
kubectl delete deployment/nginx-to-scaleout
```




