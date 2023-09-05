******
 (주의) 현재의 설정에서는 cloudwatch 컨테이너 인사이트에서 정보가 보이지 않는다. 디버깅 필요함, plz stay in tuned.
******


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
echo "CLUSTER_NAME is ${CLUSTER_NAME}..."

curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml \
| sed "s/{{cluster_name}}/${CLUSTER_NAME}/" | kubectl apply -f - 
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
kubectl get all -n amazon-cloudwatch
NAME                         READY   STATUS    RESTARTS   AGE
pod/cloudwatch-agent-hp7rv   1/1     Running   0          24s
pod/cloudwatch-agent-mdvg4   1/1     Running   0          24s

NAME                              DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/cloudwatch-agent   2         2         2       2            2           kubernetes.io/os=linux   25s
```

### 6. pod 로그 확인 ###
```
 kubectl describe pod/cloudwatch-agent-t9xdj  -n amazon-cloudwatch
Name:         cloudwatch-agent-t9xdj
Namespace:    amazon-cloudwatch
Priority:     0
Node:         ip-10-1-103-239.ap-northeast-2.compute.internal/10.1.103.239
Start Time:   Sat, 26 Aug 2023 13:01:21 +0000
Labels:       controller-revision-hash=5c9b87d6ff
              name=cloudwatch-agent
              pod-template-generation=1
Annotations:  <none>
Status:       Running
IP:           10.1.103.35
IPs:
  IP:           10.1.103.35
Controlled By:  DaemonSet/cloudwatch-agent
Containers:
  cloudwatch-agent:
    Container ID:   containerd://04e4020400800932b4fa08597229dc2a92ae5ef5d41ab3e1788a563f36d369a5
    Image:          public.ecr.aws/cloudwatch-agent/cloudwatch-agent:1.247360.0b252689
    Image ID:       public.ecr.aws/cloudwatch-agent/cloudwatch-agent@sha256:888fed6f7fb12948ec015ee4bdbbb759f044a569f5d2d49fb4dd0e49e747df31
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Sat, 26 Aug 2023 13:01:22 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     200m
      memory:  200Mi
    Requests:
      cpu:     200m
      memory:  200Mi
    Environment:
      HOST_IP:         (v1:status.hostIP)
      HOST_NAME:       (v1:spec.nodeName)
      K8S_NAMESPACE:  amazon-cloudwatch (v1:metadata.namespace)
      CI_VERSION:     k8s/1.3.16
    Mounts:
      /dev/disk from devdisk (ro)
      /etc/cwagentconfig from cwagentconfig (rw)
      /rootfs from rootfs (ro)
      /run/containerd/containerd.sock from containerdsock (ro)
      /sys from sys (ro)
      /var/lib/docker from varlibdocker (ro)
      /var/run/docker.sock from dockersock (ro)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-4kd6h (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  cwagentconfig:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      cwagentconfig
    Optional:  false
  rootfs:
    Type:          HostPath (bare host directory volume)
    Path:          /
    HostPathType:  
  dockersock:
    Type:          HostPath (bare host directory volume)
    Path:          /var/run/docker.sock
    HostPathType:  
  varlibdocker:
    Type:          HostPath (bare host directory volume)
    Path:          /var/lib/docker
    HostPathType:  
  containerdsock:
    Type:          HostPath (bare host directory volume)
    Path:          /run/containerd/containerd.sock
    HostPathType:  
  sys:
    Type:          HostPath (bare host directory volume)
    Path:          /sys
    HostPathType:  
  devdisk:
    Type:          HostPath (bare host directory volume)
    Path:          /dev/disk/
    HostPathType:  
  kube-api-access-4kd6h:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              kubernetes.io/os=linux
Tolerations:                 node.kubernetes.io/disk-pressure:NoSchedule op=Exists
                             node.kubernetes.io/memory-pressure:NoSchedule op=Exists
                             node.kubernetes.io/not-ready:NoExecute op=Exists
                             node.kubernetes.io/pid-pressure:NoSchedule op=Exists
                             node.kubernetes.io/unreachable:NoExecute op=Exists
                             node.kubernetes.io/unschedulable:NoSchedule op=Exists
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  3m37s  default-scheduler  Successfully assigned amazon-cloudwatch/cloudwatch-agent-t9xdj to ip-10-1-103-239.ap-northeast-2.compute.internal
  Normal  Pulled     3m36s  kubelet            Container image "public.ecr.aws/cloudwatch-agent/cloudwatch-agent:1.247360.0b252689" already present on machine
  Normal  Created    3m36s  kubelet            Created container cloudwatch-agent
  Normal  Started    3m36s  kubelet            Started container cloudwatch-agent
```

### [참고] 설치삭제 ###
```
kubectl delete -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml                                            ```                                    ```
```


## 레퍼런스 ##

* https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-metrics.html
* https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/ContainerInsights-troubleshooting.html


