

https://github.com/aws-samples/amazon-cloudwatch-container-insights/blob/main/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-configmap.yaml

https://github.com/aws-samples/amazon-cloudwatch-container-insights/blob/main/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml

https://github.com/aws-samples/amazon-cloudwatch-container-insights/blob/main/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-serviceaccount.yaml




```
$ ClusterName=spark-on-eks
RegionName=ap-northeast-2
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
```

```
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights\
/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring\
/quickstart/cwagent-fluent-bit-quickstart.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f - 
```


```
$ % kubectl get namespace amazon-cloudwatch
NAME                STATUS   AGE
amazon-cloudwatch   Active   6h52m

$ kubectl get pods -n amazon-cloudwatch

NAME                     READY   STATUS    RESTARTS   AGE
cloudwatch-agent-85fcl   1/1     Running   0          6h46m
cloudwatch-agent-dsqn6   1/1     Running   0          6h46m
cloudwatch-agent-gdsgc   1/1     Running   0          6h46m
cloudwatch-agent-kbnl8   1/1     Running   0          6h46m
cloudwatch-agent-mmbxd   1/1     Running   0          6h46m
cloudwatch-agent-z4tnc   1/1     Running   0          6h46m
fluent-bit-46pfl         1/1     Running   0          6h46m
fluent-bit-6tcnp         1/1     Running   0          6h45m
fluent-bit-hfbfs         1/1     Running   0          6h46m
fluent-bit-qvshq         1/1     Running   0          6h45m
fluent-bit-v67m2         1/1     Running   0          6h45m
fluent-bit-vg2x5         1/1     Running   0          6h46m

$ kubectl describe pod fluent-bit-46pfl -n amazon-cloudwatch

$ kubectl describe configmaps fluent-bit-cluster-info -n amazon-cloudwatch

```
