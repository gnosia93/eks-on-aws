CA 의 경우 노드 증설 이벤트 발생시 ASG 가 laucnch 템플릿을 이용하여 노드를 증설하는 반면, 카펜터의 경우 ASG 의 min/max/desired 숫자만 참고하고
노드 증설은 직접한다. CA 가 노드 증설 이벤트를 폴링 방식(확인 주기 maybe 15초) 으로 확인 하는 반면, 카펜터의 경우 이벤트 발생시 즉각적으로 동작한다.
CA 의 경우 K8S 의 컨트롤러 오브젝트이고, ASG 는 AWS 의 오브젝트이기 때문에 둘 간의 메타 정보 불일치가 발생할 가능성이 있다.
이러한 이유로 CA 는 카펜터에 비해 노드 증설, 축소 속도가 느린편이다. 

## CA 스케일링 ##

.. 테스트 생략 ..

## 카펜터 스케일링 ##

카펜터 스케일링 테스트는 아래 순서대로 실행하고, 실행 속도를 관찰한다. 대략적인 스케일링 속도(노드추가 + 파드스케줄링)는 30초 ~ 1분 사이인것으로 보인다.

### 1. 카펜트 로그 모니터링 ###

cloud9 터미널 탭을 하나 열어서 카펜터의 로그를 모니터링 한다. 
```
kubectl logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-scale-log.png)


### 2. 오토스케일링 그룹 설정 ###

cloud9 에서 새로운 탭을 하나 열어 eks-workshop 클러스터의 노드 최대 사이즈를 3개에서 9개로 증가시킨다. 
```
export ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && \
 Value=='${CLUSTER_NAME}']].AutoScalingGroupName" --output text)
```

```
aws autoscaling \
    update-auto-scaling-group \
    --auto-scaling-group-name ${ASG_NAME} \
    --min-size 3 \
    --desired-capacity 3 \
    --max-size 9
```

```
aws autoscaling \
    describe-auto-scaling-groups \
    --query "AutoScalingGroups[? Tags[? (Key=='eks:cluster-name') && Value=='${CLUSTER_NAME}']].[AutoScalingGroupName, MinSize, MaxSize,DesiredCapacity]" \
    --output table
```

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-scale-aws.png)


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

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-scale-deployment.png)



### 4. nginx 스케일링 / 노드 갯수 확인 ###

* 터미널에서 k9s 을 실행해서 파드 상태를 실시간으로 관찰한다.
```
k9s
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-scale-k9s-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-scale-k9s-2.png)


* 리플리카 갯수를 30개로 증가시키고 노드수를 관찰하고, EC2 의 Instance 정보도 동시에 모니터링 한다.  
```
# 스케일아웃
kubectl scale --replicas=30 deployment/nginx-to-scaleout

# 노드수 조회
kubectl get node
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-scale-scaleout.png)

* EC2 인스턴스
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/karpenter-ec2-instance.png)
동일 타입의 인스턴스를 증설하는 CA 와 달리 카펜터의 경우 서로 다른 타입의 인스턴스가 증설되는 것을 확인할 수 있다. 자세한 내용은 아래 블로그 확인.
[Amazon EKS 클러스터를 비용 효율적으로 오토스케일링하기](https://aws.amazon.com/ko/blogs/tech/amazon-eks-cluster-auto-scaling-karpenter-bp/)

### 5. nginx 삭제 ###

```
kubectl delete deployment/nginx-to-scaleout
```





