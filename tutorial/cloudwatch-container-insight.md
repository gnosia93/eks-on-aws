
### 1. 네임스페이스 생성 ###
```
kubectl create ns amazon-cloudwatch
```

### 2. 서비스 어카운트 생성 ###
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml
```
[결과]
```
serviceaccount/cloudwatch-agent created
clusterrole.rbac.authorization.k8s.io/cloudwatch-agent-role created
clusterrolebinding.rbac.authorization.k8s.io/cloudwatch-agent-role-binding created
```

### 3. 컨피그 맵 생성 ###
```
export ClusterName=${CLUSTER_NAME}
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml \
| sed "s/{{cluster_name}}/${ClusterName}/" | kubectl apply -f - 
```

```
kubectl describe configmap cwagentconfig -n amazon-cloudwatch
```

### 4. CloudWatch 에이전트 설치 ###
```
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml
```

### 5. 설치 확인 ###
```
kubectl get all -n amazon-cloudwatch
```
[결과]
```
NAME                         READY   STATUS    RESTARTS   AGE
pod/cloudwatch-agent-7w9kx   1/1     Running   0          68s
pod/cloudwatch-agent-c2blw   0/1     Pending   0          68s
pod/cloudwatch-agent-grcwj   0/1     Pending   0          69s
pod/cloudwatch-agent-gszvh   1/1     Running   0          68s
pod/fluent-bit-4cvm8         1/1     Running   0          3h17m
pod/fluent-bit-6jcdx         1/1     Running   0          19h
pod/fluent-bit-8psrj         1/1     Running   0          19h
pod/fluent-bit-t2flc         1/1     Running   0          19h

NAME                              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/cloudwatch-agent   4         4         2       4            2           kubernetes.io/os=linux   69s
daemonset.apps/fluent-bit         4         4         4       4            4           <none>                   19h
```

## 설치 삭제 ##
```
$ kubectl delete daemonset cloudwatch-agent -n amazon-cloudwatch                                                                                        
daemonset.apps "cloudwatch-agent" deleted
```

## 트러블 슈팅 ##

### 1. Pod Status Pending ###

```
kubectl describe pod cloudwatch-agent-lx8rz -n amazon-cloudwatch
```
[결과]
```
ode-Selectors:              kubernetes.io/os=linux
Tolerations:                 node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m54s  default-scheduler  0/4 nodes are available: 1 Insufficient cpu. preemption: 0/4 nodes are available: 4 No preemption victims found for incoming pod.
```
노드 CPU 용량 부족으로 cloudwatch 에이전트가 스케줄 되지 않음 !!!! 노드의 CPU 용량이 작은거면 이런 경우도 있구나....헐~~~

## 레퍼런스 ##

* https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-metrics.html
* https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-troubleshooting.html

