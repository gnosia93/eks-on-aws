AMG 를 이용해서 AMP 의 대시보드를 만들기 위해서는 SSO 를 설정해야 한다. 

## 프로메테우스(AMP) 설치 ##

cloud9 터미널에서 아래 단계를 실행한다. 

### 1. 환경변수 설정 ###
```
export EKS_CLUSTER_NAME=`eksctl get cluster|awk '{print $1}'|tail -1`
export AWS_REGION=`eksctl get cluster|awk '{print $2}'|tail -1`
export ACCOUNT_ID=`aws sts get-caller-identity|grep "Arn"|cut -d':' -f6`
```

### 2. AMP 워크스페이스 생성 ### 

```
aws amp create-workspace --alias adot-eks --tags env=eks-workshop
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

### 6. awscurl 설치 ###
awscurl을 이용해서 수집된 메트릭이 AMP 에 저장되었는지 확인한다. 
```
sudo pip install --upgrade pip

sudo ln -s -f /usr/local/bin/pip /usr/bin/pip

pip install awscurl==0.26
```

```
awscurl --service=aps --region=$AWS_REGION "${AMP_ENDPOINT_URL}api/v1/query?query=scrape_samples_scraped"
```

[결과]
```
/home/ec2-user/.local/lib/python3.6/site-packages/OpenSSL/_util.py:6: CryptographyDeprecationWarning: Python 3.6 is no longer supported by the Python core team. Therefore, support for it is deprecated in cryptography. The next release of cryptography will remove support for Python 3.6.
  from cryptography.hazmat.bindings.openssl.binding import Binding
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"scrape_samples_scraped","app_kubernetes_io_instance":"aws-load-balancer-controller","app_kubernetes_io_name":"aws-load-balancer-controller","instance":"10.1.102.228:8080","job":"kubernetes-pods","kubernetes_namespace":"kube-system","kubernetes_pod_name":"aws-load-balancer-controller-7556b645df-k49gw","pod_template_hash":"7556b645df"},"value":[1692887220.496,"790"]},{"metric":{"__name__":"scrape_samples_scraped","app":"cert-manager","app_kubernetes_io_component":"controller","app_kubernetes_io_instance":"cert-manager","app_kubernetes_io_name":"cert-
...
```

## IAM Identify Center (SSO) ##

그라파나(AMG) 설치하기 전에 IAM Identify Center 로 방문해서 Single Sign On 용 유저를 먼저 생성해야 한다.

#### [Add user] 버튼을 클릭한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-1.png)

#### 필수 정보를 입력하고 유저를 생성한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-2.png)

#### 리스트에서 생성한 유저명을 클릭하고 상세 화면으로 이동한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-3.png)

#### [Send email verification link] 를 클릭해서 초대 메일을 발송한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-4.png)

#### 인증 메일을 발송을 확인하다 #### 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-5.png)

#### 메일함에서 인증 요청에 응답한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-6.png)

#### SSO 로그인 화면에서 신규 패스워드를 입력한다 #### 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-7.png)

#### 메일함에서 SSO용 메일 주소 자체에 대해 인증한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/sso-login-8.png)



## 그라파나(AMG) 워크스페이스 생성 ##


#### 대시보드 설정 ####
https://malwareanalysis.tistory.com/602 의 AMG 연동 부분 참고.


## 레퍼런스 ##
* https://velog.io/@joshua_s/Prometheus-Grafana%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-EC2-%EC%8B%9C%EA%B0%81%ED%99%94
* https://st-ycloud.tistory.com/89
* https://kschoi728.tistory.com/97
* https://malwareanalysis.tistory.com/602
