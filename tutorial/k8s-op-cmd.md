* How to Delete All Pods in All Kubernetes Namespaces

  https://www.baeldung.com/linux/kubernetes-delete-all-pods

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
