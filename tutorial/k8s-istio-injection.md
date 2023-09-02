istio는 각 파드에 envoy proxy를 sidecar 패턴으로 설치하여 서비스 메시를 관리한다.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-mesh.png)

전체 pod 에도 설치할 수 있지만, 원하는 pod 에만 envory proxy를 설치할 수도 있다. 이때 사용되는 기술이 바로 객체지향 언어의 DI(Dependency Injection)와 같은 기술로, Istio는 Sidecar Injection을 지원한다.(https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

Injection은 두가지 방식으로 가능한데, ①명령어로 수동으로 하는 방법과 ②라벨로 설정하는 방법이 있다. 여기서는  라벨로 설정하는 방법에 대해서 다룰 예정이다.

## Istio 인젝션 설정 ##

```
$ kubectl label namespace default istio-injection=enabled --overwrite
namespace/default labeled

$ kubectl describe ns default
Name:         default
Labels:       istio-injection=enabled
              kubernetes.io/metadata.name=default
Annotations:  <none>
Status:       Active

$ kubectl get namespace -L istio-injection
NAME              STATUS   AGE   ISTIO-INJECTION
default           Active   37h   enabled
istio-operator    Active   75m   
istio-system      Active   97m   
kube-node-lease   Active   37h   
kube-public       Active   37h   
kube-system       Active   37h

```



### 샘플 어플리케이션 배포 ###

```
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/sleep/sleep.yaml
serviceaccount/sleep created
service/sleep created
deployment.apps/sleep created

$ kubectl get pod 
NAME                     READY   STATUS    RESTARTS   AGE
nginx-748c667d99-pxbn5   1/1     Running   0          33m
sleep-645b966fc4-dg5kt   2/2     Running   0          58s
```
nginx 는 pod 가 1/1 인데 비해, sleep pod 의 경우 2/2 인것을 확인할 수 있다.

```
$ kubectl describe pod sleep
Name:         sleep-645b966fc4-dg5kt
Namespace:    default
Priority:     0
Node:         ip-10-1-101-119.ap-northeast-2.compute.internal/10.1.101.119
Start Time:   Sat, 02 Sep 2023 09:14:09 +0000
Labels:       app=sleep
              pod-template-hash=645b966fc4
              security.istio.io/tlsMode=istio
              service.istio.io/canonical-name=sleep
              service.istio.io/canonical-revision=latest
Annotations:  istio.io/rev: default
              kubectl.kubernetes.io/default-container: sleep
              kubectl.kubernetes.io/default-logs-container: sleep
              prometheus.io/path: /stats/prometheus
              prometheus.io/port: 15020
              prometheus.io/scrape: true
              sidecar.istio.io/status:
                {"initContainers":["istio-init"],"containers":["istio-proxy"],"volumes":["workload-socket","credential-socket","workload-certs","istio-env...
Status:       Running
IP:           10.1.101.166
IPs:
  IP:           10.1.101.166
Controlled By:  ReplicaSet/sleep-645b966fc4
Init Containers:
  istio-init:
    Container ID:  containerd://3503b2d2ff8949eac2dbabfdc90de06cff0168afb9ab4d4e06b3b2a780f6fe62
    Image:         docker.io/istio/proxyv2:1.18.2
    Image ID:      docker.io/istio/proxyv2@sha256:b71f2657e038a0d6092dfd954050a2783c7887ff8e72f77ce64840c0c39b076e
    Port:          <none>
    Host Port:     <none>
    Args:
      istio-iptables
      -p
      15001
      -z
      15006
      -u
      1337
      -m
      REDIRECT
      -i
      *
      -x
      
      -b
      *
      -d
      15090,15021,15020
      --log_output_level=default:info
    State:          Terminated
      Reason:       Completed
      Exit Code:    0
      Started:      Sat, 02 Sep 2023 09:14:09 +0000
      Finished:     Sat, 02 Sep 2023 09:14:09 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     2
      memory:  1Gi
    Requests:
      cpu:        100m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-f25kr (ro)
Containers:
  sleep:
    Container ID:  containerd://5baf760e262ee20a708fe6e81685a8d8c4afc2ad143fd0411ee519442d4a5973
    Image:         curlimages/curl
    Image ID:      docker.io/curlimages/curl@sha256:bb0843a1307b1aa73f65f24379d11dde881c16db62ba50810de0c64d48e740ed
    Port:          <none>
    Host Port:     <none>
    Command:
      /bin/sleep
      3650d
    State:          Running
      Started:      Sat, 02 Sep 2023 09:14:14 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/sleep/tls from secret-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-f25kr (ro)
  istio-proxy:
    Container ID:  containerd://93c824089f0de2bc91ee41505a7c453468d3aecf020628771a813782ab8258da
    Image:         docker.io/istio/proxyv2:1.18.2
    Image ID:      docker.io/istio/proxyv2@sha256:b71f2657e038a0d6092dfd954050a2783c7887ff8e72f77ce64840c0c39b076e
    Port:          15090/TCP
    Host Port:     0/TCP
    Args:
      proxy
      sidecar
      --domain
      $(POD_NAMESPACE).svc.cluster.local
      --proxyLogLevel=warning
      --proxyComponentLogLevel=misc:error
      --log_output_level=default:info
    State:          Running
      Started:      Sat, 02 Sep 2023 09:14:14 +0000
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     2
      memory:  1Gi
    Requests:
      cpu:      100m
      memory:   128Mi
    Readiness:  http-get http://:15021/healthz/ready delay=1s timeout=3s period=2s #success=1 #failure=30
    Environment:
      JWT_POLICY:                    third-party-jwt
      PILOT_CERT_PROVIDER:           istiod
      CA_ADDR:                       istiod.istio-system.svc:15012
      POD_NAME:                      sleep-645b966fc4-dg5kt (v1:metadata.name)
      POD_NAMESPACE:                 default (v1:metadata.namespace)
      INSTANCE_IP:                    (v1:status.podIP)
      SERVICE_ACCOUNT:                (v1:spec.serviceAccountName)
      HOST_IP:                        (v1:status.hostIP)
      ISTIO_CPU_LIMIT:               2 (limits.cpu)
      PROXY_CONFIG:                  {}
                                     
      ISTIO_META_POD_PORTS:          [
                                     ]
      ISTIO_META_APP_CONTAINERS:     sleep
      ISTIO_META_CLUSTER_ID:         Kubernetes
      ISTIO_META_NODE_NAME:           (v1:spec.nodeName)
      ISTIO_META_INTERCEPTION_MODE:  REDIRECT
      ISTIO_META_WORKLOAD_NAME:      sleep
      ISTIO_META_OWNER:              kubernetes://apis/apps/v1/namespaces/default/deployments/sleep
      ISTIO_META_MESH_ID:            cluster.local
      TRUST_DOMAIN:                  cluster.local
    Mounts:
      /etc/istio/pod from istio-podinfo (rw)
      /etc/istio/proxy from istio-envoy (rw)
      /var/lib/istio/data from istio-data (rw)
      /var/run/secrets/credential-uds from credential-socket (rw)
      /var/run/secrets/istio from istiod-ca-cert (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-f25kr (ro)
      /var/run/secrets/tokens from istio-token (rw)
      /var/run/secrets/workload-spiffe-credentials from workload-certs (rw)
      /var/run/secrets/workload-spiffe-uds from workload-socket (rw)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  workload-socket:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  credential-socket:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  workload-certs:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  istio-envoy:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     Memory
    SizeLimit:  <unset>
  istio-data:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime)
    Medium:     
    SizeLimit:  <unset>
  istio-podinfo:
    Type:  DownwardAPI (a volume populated by information about the pod)
    Items:
      metadata.labels -> labels
      metadata.annotations -> annotations
  istio-token:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  43200
  istiod-ca-cert:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      istio-ca-root-cert
    Optional:  false
  secret-volume:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  sleep-secret
    Optional:    true
  kube-api-access-f25kr:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Burstable
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  88s   default-scheduler  Successfully assigned default/sleep-645b966fc4-dg5kt to ip-10-1-101-119.ap-northeast-2.compute.internal
  Normal  Pulled     88s   kubelet            Container image "docker.io/istio/proxyv2:1.18.2" already present on machine
  Normal  Created    88s   kubelet            Created container istio-init
  Normal  Started    88s   kubelet            Started container istio-init
  Normal  Pulling    88s   kubelet            Pulling image "curlimages/curl"
  Normal  Pulled     83s   kubelet            Successfully pulled image "curlimages/curl" in 4.57695278s (4.576965693s including waiting)
  Normal  Created    83s   kubelet            Created container sleep
  Normal  Started    83s   kubelet            Started container sleep
  Normal  Pulled     83s   kubelet            Container image "docker.io/istio/proxyv2:1.18.2" already present on machine
  Normal  Created    83s   kubelet            Created container istio-proxy
  Normal  Started    83s   kubelet            Started container istio-proxy
```


## 레퍼런스 ##
* https://devocean.sk.com/experts/techBoardDetail.do?ID=163656&boardType=experts&page=&searchData=&subIndex=&idList=
* https://devocean.sk.com/blog/techBoardDetail.do?ID=163655
* https://malwareanalysis.tistory.com/299
* https://malwareanalysis.tistory.com/305
* https://malwareanalysis.tistory.com/306
* https://malwareanalysis.tistory.com/307
