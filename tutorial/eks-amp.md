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
```


## 레퍼런스 ##
* https://kschoi728.tistory.com/97
* https://malwareanalysis.tistory.com/602
