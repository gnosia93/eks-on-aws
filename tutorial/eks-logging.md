


### 1. EKS 노드그룹의 Role 에 CloudWatchAgentServerPolicy 추가 ###

eks 노드그룹의 role 을 확인한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nodegroup-node-iam.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nodegroup-node-iam-role.png)

이제 eks 노드가 cloudwatch 에 접근할 수 있게 되었다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/nodegroup-node-iam-role-cloudwatch.png)


### 2. fluent bit 배포하기 ###

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
kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights\
/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring\
/fluent-bit/fluent-bit.yaml
```

cloudwatch 에서 로그 그룹을 확인한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloudwatch-eks-log.png)


### 3. fluent bit 설정확인 ###
```
$ kubectl describe configmap/fluent-bit-config -n amazon-cloudwatch
Name:         fluent-bit-config
Namespace:    amazon-cloudwatch
Labels:       k8s-app=fluent-bit
Annotations:  <none>

Data
====
application-log.conf:
----
[INPUT]
    Name                tail
    Tag                 application.*
    Exclude_Path        /var/log/containers/cloudwatch-agent*, /var/log/containers/fluent-bit*, /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
    Path                /var/log/containers/*.log
    multiline.parser    docker, cri
    DB                  /var/fluent-bit/state/flb_container.db
    Mem_Buf_Limit       50MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Rotate_Wait         30
    storage.type        filesystem
    Read_from_Head      ${READ_FROM_HEAD}

[INPUT]
    Name                tail
    Tag                 application.*
    Path                /var/log/containers/fluent-bit*
    multiline.parser    docker, cri
    DB                  /var/fluent-bit/state/flb_log.db
    Mem_Buf_Limit       5MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Read_from_Head      ${READ_FROM_HEAD}

[INPUT]
    Name                tail
    Tag                 application.*
    Path                /var/log/containers/cloudwatch-agent*
    multiline.parser    docker, cri
    DB                  /var/fluent-bit/state/flb_cwagent.db
    Mem_Buf_Limit       5MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Read_from_Head      ${READ_FROM_HEAD}

[FILTER]
    Name                kubernetes
    Match               application.*
    Kube_URL            https://kubernetes.default.svc:443
    Kube_Tag_Prefix     application.var.log.containers.
    Merge_Log           On
    Merge_Log_Key       log_processed
    K8S-Logging.Parser  On
    K8S-Logging.Exclude Off
    Labels              Off
    Annotations         Off
    Use_Kubelet         On
    Kubelet_Port        10250
    Buffer_Size         0

[OUTPUT]
    Name                cloudwatch_logs
    Match               application.*
    region              ${AWS_REGION}
    log_group_name      /aws/containerinsights/${CLUSTER_NAME}/application
    log_stream_prefix   ${HOST_NAME}-
    auto_create_group   true
    extra_user_agent    container-insights

dataplane-log.conf:
----
[INPUT]
    Name                systemd
    Tag                 dataplane.systemd.*
    Systemd_Filter      _SYSTEMD_UNIT=docker.service
    Systemd_Filter      _SYSTEMD_UNIT=containerd.service
    Systemd_Filter      _SYSTEMD_UNIT=kubelet.service
    DB                  /var/fluent-bit/state/systemd.db
    Path                /var/log/journal
    Read_From_Tail      ${READ_FROM_TAIL}

[INPUT]
    Name                tail
    Tag                 dataplane.tail.*
    Path                /var/log/containers/aws-node*, /var/log/containers/kube-proxy*
    multiline.parser    docker, cri
    DB                  /var/fluent-bit/state/flb_dataplane_tail.db
    Mem_Buf_Limit       50MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Rotate_Wait         30
    storage.type        filesystem
    Read_from_Head      ${READ_FROM_HEAD}

[FILTER]
    Name                modify
    Match               dataplane.systemd.*
    Rename              _HOSTNAME                   hostname
    Rename              _SYSTEMD_UNIT               systemd_unit
    Rename              MESSAGE                     message
    Remove_regex        ^((?!hostname|systemd_unit|message).)*$

[FILTER]
    Name                aws
    Match               dataplane.*
    imds_version        v1

[OUTPUT]
    Name                cloudwatch_logs
    Match               dataplane.*
    region              ${AWS_REGION}
    log_group_name      /aws/containerinsights/${CLUSTER_NAME}/dataplane
    log_stream_prefix   ${HOST_NAME}-
    auto_create_group   true
    extra_user_agent    container-insights

fluent-bit.conf:
----
[SERVICE]
    Flush                     5
    Grace                     30
    Log_Level                 info
    Daemon                    off
    Parsers_File              parsers.conf
    HTTP_Server               ${HTTP_SERVER}
    HTTP_Listen               0.0.0.0
    HTTP_Port                 ${HTTP_PORT}
    storage.path              /var/fluent-bit/state/flb-storage/
    storage.sync              normal
    storage.checksum          off
    storage.backlog.mem_limit 5M
    
@INCLUDE application-log.conf
@INCLUDE dataplane-log.conf
@INCLUDE host-log.conf

host-log.conf:
----
[INPUT]
    Name                tail
    Tag                 host.dmesg
    Path                /var/log/dmesg
    Key                 message
    DB                  /var/fluent-bit/state/flb_dmesg.db
    Mem_Buf_Limit       5MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Read_from_Head      ${READ_FROM_HEAD}

[INPUT]
    Name                tail
    Tag                 host.messages
    Path                /var/log/messages
    Parser              syslog
    DB                  /var/fluent-bit/state/flb_messages.db
    Mem_Buf_Limit       5MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Read_from_Head      ${READ_FROM_HEAD}

[INPUT]
    Name                tail
    Tag                 host.secure
    Path                /var/log/secure
    Parser              syslog
    DB                  /var/fluent-bit/state/flb_secure.db
    Mem_Buf_Limit       5MB
    Skip_Long_Lines     On
    Refresh_Interval    10
    Read_from_Head      ${READ_FROM_HEAD}

[FILTER]
    Name                aws
    Match               host.*
    imds_version        v1

[OUTPUT]
    Name                cloudwatch_logs
    Match               host.*
    region              ${AWS_REGION}
    log_group_name      /aws/containerinsights/${CLUSTER_NAME}/host
    log_stream_prefix   ${HOST_NAME}.
    auto_create_group   true
    extra_user_agent    container-insights

parsers.conf:
----
[PARSER]
    Name                syslog
    Format              regex
    Regex               ^(?<time>[^ ]* {1,2}[^ ]* [^ ]*) (?<host>[^ ]*) (?<ident>[a-zA-Z0-9_\/\.\-]*)(?:\[(?<pid>[0-9]+)\])?(?:[^\:]*\:)? *(?<message>.*)$
    Time_Key            time
    Time_Format         %b %d %H:%M:%S

[PARSER]
    Name                container_firstline
    Format              regex
    Regex               (?<log>(?<="log":")\S(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
    Time_Key            time
    Time_Format         %Y-%m-%dT%H:%M:%S.%LZ

[PARSER]
    Name                cwagent_firstline
    Format              regex
    Regex               (?<log>(?<="log":")\d{4}[\/-]\d{1,2}[\/-]\d{1,2}[ T]\d{2}:\d{2}:\d{2}(?!\.).*?)(?<!\\)".*(?<stream>(?<="stream":").*?)".*(?<time>\d{4}-\d{1,2}-\d{1,2}T\d{2}:\d{2}:\d{2}\.\w*).*(?=})
    Time_Key            time
    Time_Format         %Y-%m-%dT%H:%M:%S.%LZ


BinaryData
====

Events:  <none>
```

### 4. cloudwatch 로그 확인 ###

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloudwatch-fluentbit-log1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/cloudwatch-fluentbit-log2.png)




## 레퍼런스 ##

* [Fluent Bit를 사용하여 Cloudwatch log group 으로 로그 전송하기](https://wlsdn3004.tistory.com/40)
  
* https://three-beans.tistory.com/entry/AWSEKS-AWS%EB%A1%9C-EKS-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-%EB%A1%9C%EA%B7%B8-%EC%88%98%EC%A7%91-%ED%95%98%EA%B8%B0-w-Container-Insights-fluentbit

  
