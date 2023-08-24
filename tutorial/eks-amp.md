cloud9 터미널에서 아래 단계를 실행한다. 

### 1. 환경변수 설정 ###
```
export EKS_CLUSTER_NAME=`eksctl get cluster|awk '{print $1}'|tail -1`
export AWS_REGION=`eksctl get cluster|awk '{print $2}'|tail -1`
export ACCOUNT_ID=`aws sts get-caller-identity|grep "Arn"|cut -d':' -f6`
```

### 2. AMP 워크스페이스 생성 ### 

```
aws amp create-workspace --alias adot-eks-workshop --tags env=eks-workshop
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace.png)


### 3. IRSA 생성 ###
```
eksctl create iamserviceaccount \
--name amp-irsa-role \
--namespace prometheus \
--cluster $EKS_CLUSTER_NAME \
--attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
--approve \
--override-existing-serviceaccounts
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/prometheus-entity.png)

### 4. cert manager 설치 ###

ADOT Operator에서 해당 작업(예: pods에 사이드카를 삽입하기 위해 webhook 호출 등)에 사용되며 제대로 작동하는 데 필요합니다.

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.2/cert-manager.yaml
```

```
kubectl apply -f https://amazon-eks.s3.amazonaws.com/docs/addons-otel-permissions.yaml

aws eks create-addon \
--addon-name adot \
--addon-version v0.74.0-eksbuild.1 \
--cluster-name $EKS_CLUSTER_NAME

aws eks describe-addon --addon-name adot --cluster-name $EKS_CLUSTER_NAME | jq .addon.status
```
상태값이 ACTIVE 가 될때 까지 대기한다.


### 5. OTel Collector CR(사용자 지정 리소스) 설치 ###
```
WORKSPACE_ID=$(aws amp list-workspaces --alias adot-eks | jq '.workspaces[0].workspaceId' -r)

AMP_ENDPOINT_URL=$(aws amp describe-workspace --workspace-id $WORKSPACE_ID | jq '.workspace.prometheusEndpoint' -r)

AMP_REMOTE_WRITE_URL=${AMP_ENDPOINT_URL}api/v1/remote_write

curl -O https://raw.githubusercontent.com/aws-containers/eks-app-mesh-polyglot-demo/master/workshop/otel-collector-config.yaml 

sed -i -e s/AWS_REGION/$AWS_REGION/g otel-collector-config.yaml

sed -i -e s^AMP_WORKSPACE_URL^$AMP_REMOTE_WRITE_URL^g otel-collector-config.yaml

kubectl apply -f ./otel-collector-config.yaml
```

```
kubectl get all -n prometheus
```

[결과]
```
NAME                                           READY   STATUS    RESTARTS   AGE
pod/observability-collector-6cf8bb5996-gzx8f   1/1     Running   0          109s

NAME                                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/observability-collector-monitoring   ClusterIP   172.20.159.141   <none>        8888/TCP   109s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/observability-collector   1/1     1            1           109s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/observability-collector-6cf8bb5996   1         1         1       109s 
```


## 레퍼런스 ##
* https://kschoi728.tistory.com/97
* https://malwareanalysis.tistory.com/602
