AMG 를 이용해서 AMP 의 대시보드를 만들기 위해서는 SSO 를 설정해야 한다. 

## 프로메테우스(AMP) 설치 ##

AMP 워크스페이스를 생성하기 위해, AMP 콘솔로 이동한다.  

### 1. 워크스페이스 생성 ###

#### [Create workspace] 버튼을 클릭한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace-1.png)

#### Workspace alias 를 입력하고 [Create workspace] 버튼을 클릭한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace-2.png)

### 2. IRSA 설정 ###

AMP 는 EKS 및 EC2 에 사용자가 직접 생성한 클러스터로 부터의 데이터 수집이 가능하다. 

#### IAM 롤 생성 ####

cloud9 터미널을 이동하여 아래 스크립트를 실행한다. 

* https://docs.aws.amazon.com/prometheus/latest/userguide/set-up-irsa.html#set-up-irsa-ingest

```
CLUSTER_NAME=${CLUSTER_NAME}
SERVICE_ACCOUNT_NAMESPACE=springboot

echo ${CLUSTER_NAME}...
echo ${SERVICE_ACCOUNT_NAMESPACE}... 
```

```
#!/bin/bash -e
CLUSTER_NAME=<my_amazon_eks_clustername>
SERVICE_ACCOUNT_NAMESPACE=<my_prometheus_namespace>
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

#### 프로메테우스 서버 설치 ####

프로메테스의 메트릭 gathering 서버가 설치된다고 생각하면 된다. 이 서버는 EKS 의 메트릭을 수집한 후 AMP workspace 로 데이터를 ingest 시킨다.  

```
helm ls --all-namespaces
```

```
helm upgrade prometheus-chart-name prometheus-community/prometheus -n prometheus_namespace -f my_prometheus_values_yaml --version current_helm_chart_version
```


#### 프로메테우스 서버 설정 ####


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
* https://velog.io/@joshua_s/Prometheus-Grafana%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%9C-EC2-%EC%8B%9C%EA%B0%81%ED%99%94
* https://st-ycloud.tistory.com/89
* https://kschoi728.tistory.com/97
* https://malwareanalysis.tistory.com/602
