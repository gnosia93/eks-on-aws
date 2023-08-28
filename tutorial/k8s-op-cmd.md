
#### 네임스페이스의 모든 오브젝트 삭제 ####
```
$ kubectl delete all --all -n prometheus                                                                                                               
pod "prometheus-for-amp-kube-state-metrics-8d596446c-pcxfw" deleted
pod "prometheus-for-amp-prometheus-node-exporter-mzcdr" deleted
pod "prometheus-for-amp-prometheus-node-exporter-s9p28" deleted
pod "prometheus-for-amp-prometheus-node-exporter-zbrms" deleted
pod "prometheus-for-amp-prometheus-pushgateway-6675558fcb-5rfhx" deleted
pod "prometheus-for-amp-server-0" deleted
service "prometheus-for-amp-kube-state-metrics" deleted
service "prometheus-for-amp-prometheus-node-exporter" deleted
service "prometheus-for-amp-prometheus-pushgateway" deleted
service "prometheus-for-amp-server" deleted
service "prometheus-for-amp-server-headless" deleted
daemonset.apps "prometheus-for-amp-prometheus-node-exporter" deleted
deployment.apps "prometheus-for-amp-kube-state-metrics" deleted
deployment.apps "prometheus-for-amp-prometheus-pushgateway" deleted
statefulset.apps "prometheus-for-amp-server" deleted

$ kubectl get all -n prometheus
No resources found in prometheus namespace.
```

#### 서비스 어카운트 전체 출력 ####
```
$ kubectl get sa --all-namespaces
NAMESPACE         NAME                                 SECRETS   AGE
cert-manager      cert-manager                         0         2m31s
cert-manager      cert-manager-cainjector              0         2m32s
cert-manager      cert-manager-webhook                 0         2m31s
cert-manager      default                              0         2m32s
default           default                              0         15h
kube-node-lease   default                              0         15h
kube-public       default                              0         15h
kube-system       attachdetach-controller              0         15h
kube-system       aws-cloud-provider                   0         15h
kube-system       aws-node                             0         15h
kube-system       certificate-controller               0         15h
kube-system       clusterrole-aggregation-controller   0         15h
kube-system       coredns                              0         15h
kube-system       cronjob-controller                   0         15h
kube-system       daemon-set-controller                0         15
```
