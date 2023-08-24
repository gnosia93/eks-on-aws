
### 1. 환경변수 설정 ###
```
export EKS_CLUSTER_NAME=`eksctl get cluster|awk '{print $1}'|tail -1`
export AWS_REGION=`eksctl get cluster|awk '{print $2}'|tail -1`
export ACCOUNT_ID=`aws sts get-caller-identity|grep "Arn"|cut -d':' -f6`
```

```

```

## 레퍼런스 ##
* https://kschoi728.tistory.com/97
* https://malwareanalysis.tistory.com/602
