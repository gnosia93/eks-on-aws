


### 1. EKS 노드그룹의 Role 에 CloudWatchAgentServerPolicy 추가 ###

eks 노드그룹의 role 을 확인한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nodegroup-node-iam.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nodegroup-node-iam-role.png)

이제 eks 노드가 cloudwatch 에 접근할 수 있게 되었다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nodegroup-node-iam-role-cloudwatch.png)


### 2. 설치 ###

cloud9 터미널에서 아래 명령어를 실행한다. 
```
kubectl create ns amazon-cloudwatch
```

```
ClusterName=${CLUSTER_NAME}
RegionName=ap-northeast-2
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'

[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'

kubectl create configmap fluent-bit-cluster-info \
--from-literal=cluster.name=${ClusterName} \
--from-literal=http.server=${FluentBitHttpServer} \
--from-literal=http.port=${FluentBitHttpPort} \
--from-literal=read.head=${FluentBitReadFromHead} \
--from-literal=read.tail=${FluentBitReadFromTail} \
--from-literal=logs.region=${RegionName} -n amazon-cloudwatch
```

```
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights\
/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring\
/fluent-bit/fluent-bit.yaml
```



## 레퍼런스 ##

* [Fluent Bit를 사용하여 Cloudwatch log group 으로 로그 전송하기](https://wlsdn3004.tistory.com/40)
  
* https://three-beans.tistory.com/entry/AWSEKS-AWS%EB%A1%9C-EKS-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-%EB%A1%9C%EA%B7%B8-%EC%88%98%EC%A7%91-%ED%95%98%EA%B8%B0-w-Container-Insights-fluentbit

  
