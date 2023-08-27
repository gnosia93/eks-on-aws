AMG 를 이용해서 AMP 의 대시보드를 만들기 위해서는 SSO 를 설정해야 한다. 

## 프로메테우스(AMP) 설치 ##

AMP 워크스페이스를 생성하기 위해, AMP 콘솔로 이동한다.  

### 1. 워크스페이스 생성 ###

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace-1.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-workspace-2.png)

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
