***** ***
아직 동작 하지 않는다. 디버깅 필요.. 나중에  ~~~~
OpenTelemetry 로 설치해야 하는 듯.

****

ADOT(AWS Distro for [Open Telemetry](https://opentelemetry.io/)) 수집기로 서비스 메트릭 수집해서 AMP 로 내보내고, AMG 로 시각화하는 방법을 알아볼 예정이다.
프로메테우스 helm 차트를 이용해서 수집기를 구성할 수는 있으나, 프로메테우스 서버가 메트릭을 저장하기 위해서는 K8S 볼륨을 필요하다. 즉 메트릭을 볼륨에 먼저 저장한 후, AMP 로 전송하는 하는 구조로 되어 있다.  
이 워크샵에서는 EKS 클러스터 에 Volume 을 만들지 않는 관계로, ADOT 를 활용해서 메트릭을 AMP 로 보낸다. 

```
export CLUSTER_NAME=`eksctl get cluster|awk '{print $1}'|tail -1`
export REGION=`eksctl get cluster|awk '{print $2}'|tail -1`
export ACCOUNT_ID=`aws sts get-caller-identity|grep "Arn"|cut -d':' -f6`
```

## AMP ##

### 1. 워크스페이스 생성 ###
```
aws amp create-workspace --alias eks-workshop --tags env=eks-workshop
```

### 2. IRSA 설정 ###
```
eksctl create iamserviceaccount \
--name amp-irsa-role \
--namespace prometheus \
--cluster ${CLUSTER_NAME} \
--attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
--approve \
--override-existing-serviceaccounts
```
cloudformation 이 동작하여 EKS 클러스터에 prometheus 네임스페이스를 생성하고 amp-irsa-role 이라는 서비스 계정을 생성한다. AmazonPrometheusRemoteWriteAccess 정책이 바인딩되고 IAM OpenID Connect 공급자(OIDC)와 EKS 서비스 어카운트 간에 신뢰 정책이 생성된다.  

[결과]
```
$ kubectl get sa -n prometheus
NAME            SECRETS   AGE
amp-irsa-role   0         27s
default         0         27s

$ kubectl describe sa amp-irsa-role -n prometheus
Name:                amp-irsa-role
Namespace:           prometheus
Labels:              app.kubernetes.io/managed-by=eksctl
Annotations:         eks.amazonaws.com/role-arn: arn:aws:iam::499514681453:role/eksctl-eks-workshop-addon-iamserviceaccount-Role1-C8K9CXJIJXXW
Image pull secrets:  <none>
Mountable secrets:   <none>
Tokens:              <none>
Events:              <none>
```

### 3. cert manager 설치 ###

ADOT 오퍼레이터에서 Pod 에 사이드카 삽입시 webhook 호출을 하는데 이때 인증을 위해 사용된다.
```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.2/cert-manager.yaml
```

[결과]
```
namespace/cert-manager created
customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io created
customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io created
serviceaccount/cert-manager-cainjector created
serviceaccount/cert-manager created
serviceaccount/cert-manager-webhook created
configmap/cert-manager-webhook created
clusterrole.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrole.rbac.authorization.k8s.io/cert-manager-view created
clusterrole.rbac.authorization.k8s.io/cert-manager-edit created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-approve:cert-manager-io created
clusterrole.rbac.authorization.k8s.io/cert-manager-controller-certificatesigningrequests created
clusterrole.rbac.authorization.k8s.io/cert-manager-webhook:subjectaccessreviews created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-cainjector created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-issuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-clusterissuers created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificates created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-orders created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-challenges created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-ingress-shim created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-approve:cert-manager-io created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-controller-certificatesigningrequests created
clusterrolebinding.rbac.authorization.k8s.io/cert-manager-webhook:subjectaccessreviews created
role.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
role.rbac.authorization.k8s.io/cert-manager:leaderelection created
role.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
rolebinding.rbac.authorization.k8s.io/cert-manager-cainjector:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager:leaderelection created
rolebinding.rbac.authorization.k8s.io/cert-manager-webhook:dynamic-serving created
service/cert-manager created
service/cert-manager-webhook created
deployment.apps/cert-manager-cainjector created
deployment.apps/cert-manager created
deployment.apps/cert-manager-webhook created
mutatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
validatingwebhookconfiguration.admissionregistration.k8s.io/cert-manager-webhook created
```

### 4. ADOT 추가 기능 설치 ###
```
kubectl apply -f https://amazon-eks.s3.amazonaws.com/docs/addons-otel-permissions.yaml
```

[결과]
```
namespace/opentelemetry-operator-system created
clusterrole.rbac.authorization.k8s.io/eks:addon-manager-otel created
clusterrolebinding.rbac.authorization.k8s.io/eks:addon-manager-otel created
role.rbac.authorization.k8s.io/eks:addon-manager created
rolebinding.rbac.authorization.k8s.io/eks:addon-manager created
```

```
aws eks create-addon \
--addon-name adot \
--addon-version v0.74.0-eksbuild.1 \
--cluster-name ${CLUSTER_NAME}
```

---------------
## 프로메테우스(AMP) 설치 ##

AMP 워크스페이스를 생성하기 위해, AMP 콘솔로 이동한다. AMP 는 EKS 및 EC2 에 사용자가 직접 생성한 클러스터로 부터의 데이터 수집이 가능하다.  

### 1. 워크스페이스 생성 ###

#### [Create workspace] 버튼을 클릭한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace-1.png)

#### Workspace alias 를 입력하고 [Create workspace] 버튼을 클릭한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace-2.png)

### 2. Ingestion 설정 ###

cloud9 터미널을 이동하여 아래 스크립트를 실행한다. 
* https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-new-Prometheus.html

#### helm 차트 레포지토리 등록 ####
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
helm repo update
```

#### EKS namespace 생성 ####
```
kubectl create namespace prometheus
```

#### 서비스 어카운트용 Role 설정 ####
* https://docs.aws.amazon.com/prometheus/latest/userguide/set-up-irsa.html#set-up-irsa-ingest
```
export CLUSTER_NAME=${CLUSTER_NAME}
export SERVICE_ACCOUNT_NAMESPACE=springboot

echo ${CLUSTER_NAME}...
echo ${SERVICE_ACCOUNT_NAMESPACE}... 
```
```
#!/bin/bash -e
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
OIDC_PROVIDER=$(aws eks describe-cluster --name $CLUSTER_NAME --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
SERVICE_ACCOUNT_AMP_INGEST_NAME=amp-iamproxy-ingest-service-account
SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE=amp-iamproxy-ingest-role
SERVICE_ACCOUNT_IAM_AMP_INGEST_POLICY=AMPIngestPolicy
#
# Set up a trust policy designed for a specific combination of K8s service account and namespace to sign in from a Kubernetes cluster which hosts the OIDC Idp.
#
cat <<EOF > TrustPolicy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/${OIDC_PROVIDER}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_PROVIDER}:sub": "system:serviceaccount:${SERVICE_ACCOUNT_NAMESPACE}:${SERVICE_ACCOUNT_AMP_INGEST_NAME}"
        }
      }
    }
  ]
}
EOF
#
# Set up the permission policy that grants ingest (remote write) permissions for all AMP workspaces
#
cat <<EOF > PermissionPolicyIngest.json
{
  "Version": "2012-10-17",
   "Statement": [
       {"Effect": "Allow",
        "Action": [
           "aps:RemoteWrite", 
           "aps:GetSeries", 
           "aps:GetLabels",
           "aps:GetMetricMetadata"
        ], 
        "Resource": "*"
      }
   ]
}
EOF

function getRoleArn() {
  OUTPUT=$(aws iam get-role --role-name $1 --query 'Role.Arn' --output text 2>&1)

  # Check for an expected exception
  if [[ $? -eq 0 ]]; then
    echo $OUTPUT
  elif [[ -n $(grep "NoSuchEntity" <<< $OUTPUT) ]]; then
    echo ""
  else
    >&2 echo $OUTPUT
    return 1
  fi
}

#
# Create the IAM Role for ingest with the above trust policy
#
SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE_ARN=$(getRoleArn $SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE)
if [ "$SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE_ARN" = "" ]; 
then
  #
  # Create the IAM role for service account
  #
  SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE_ARN=$(aws iam create-role \
  --role-name $SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE \
  --assume-role-policy-document file://TrustPolicy.json \
  --query "Role.Arn" --output text)
  #
  # Create an IAM permission policy
  #
  SERVICE_ACCOUNT_IAM_AMP_INGEST_ARN=$(aws iam create-policy --policy-name $SERVICE_ACCOUNT_IAM_AMP_INGEST_POLICY \
  --policy-document file://PermissionPolicyIngest.json \
  --query 'Policy.Arn' --output text)
  #
  # Attach the required IAM policies to the IAM role created above
  #
  aws iam attach-role-policy \
  --role-name $SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE \
  --policy-arn $SERVICE_ACCOUNT_IAM_AMP_INGEST_ARN  
else
    echo "$SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE_ARN IAM role for ingest already exists"
fi
echo $SERVICE_ACCOUNT_IAM_AMP_INGEST_ROLE_ARN
#
# EKS cluster hosts an OIDC provider with a public discovery endpoint.
# Associate this IdP with AWS IAM so that the latter can validate and accept the OIDC tokens issued by Kubernetes to service accounts.
# Doing this with eksctl is the easier and best approach.
#
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve
```

```
sh irsa-amp-ingest.sh
```

#### 프로메테우스 서버 설치 ####

[values.yaml]
```
## The following is a set of default values for prometheus server helm chart which enable remoteWrite to AMP
## For the rest of prometheus helm chart values see: https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml
##
serviceAccounts:
  server:
    name: amp-iamproxy-ingest-service-account
    annotations: 
      eks.amazonaws.com/role-arn: ${IAM_PROXY_PROMETHEUS_ROLE_ARN}
server:
  remoteWrite:
    - url: https://aps-workspaces.${REGION}.amazonaws.com/workspaces/${WORKSPACE_ID}/api/v1/remote_write
      sigv4:
        region: ${REGION}
      queue_config:
        max_samples_per_send: 1000
        max_shards: 200
        capacity: 2500
```
* IAM_PROXY_PROMETHEUS_ROLE_ARN 값을 "arn:aws:iam::499514681453:role/amp-iamproxy-ingest-role"
* REGION 값을 ap-northeast-2
* WORKSPACE_ID 값을 ws-65af76f8-c2bb-415a-9500-5b2eef043b30

[values-rep.yaml]
```
serviceAccounts:
  server:
    name: amp-iamproxy-ingest-service-account
    annotations: 
    eks.amazonaws.com/role-arn: "arn:aws:iam::499514681453:role/amp-iamproxy-ingest-role"
server:
  remoteWrite:
    - url: https://aps-workspaces.ap-northeast-2.amazonaws.com/workspaces/ws-65af76f8-c2bb-415a-9500-5b2eef043b30/api/v1/remote_write
      sigv4:
        region: ap-northeast-2
      queue_config:
        max_samples_per_send: 1000
        max_shards: 200
        capacity: 2500
```

```
helm install prometheus prometheus-community/prometheus -n prometheus \
-f values-rep.yaml
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

AWS 그라파나(AMG) 콘솔으로 이동하여 AMG 워크스페이스 생성한다.
AMG 워크스페이스 생성하기 전에 AMP 워크스페이스가 생성되어 있어야 한다.

### 1. 워크스페이스 생성 ###
#### [Create workspace] 버튼을 누른다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-1.png)

#### Workspace name 을 입력한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-2.png)

#### AWS IAM Identity Center 을 선택한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-3.png)

#### Amazon Managed Service for Prometheus 를 선택한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-4.png)

위의 설정으로 워크스페이스를 생성한다. 

### 2. 대시보드 설정 ###
https://malwareanalysis.tistory.com/602 의 AMG 연동 부분 참고.


## 레퍼런스 ##

* [EKS Observability - ADOT, AMP 및 AMG를 사용한 모니터링](https://kschoi728.tistory.com/97)
* https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-OpenTelemetry.html
* https://archive.eksworkshop.com/intermediate/246_monitoring_amp_amg/
* https://malwareanalysis.tistory.com/602
* [AWS EKS에 볼륨 마운트 해보기](https://blog.wonizz.tk/2019/11/28/kubernetes-aws-eks-volume/)
