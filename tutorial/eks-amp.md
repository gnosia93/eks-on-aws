ADOT(AWS Distro for [Open Telemetry](https://opentelemetry.io/)) collector 로 k8s 메트릭을 수집해서 AMP 로 내보내고, AMG 로 시각화하는 방법을 알아볼 예정이
다.
프로메테우스 helm 차트를 이용해서 수집기를 구성할 수는 있으나, 프로메테우스 서버가 메트릭을 저장하기 위해서는 K8S 볼륨을 필요하다. 즉 메트릭을 볼륨에 먼저 저장한 후, AMP 로 전송하는 하는 구조로 되어 있다.  
이 워크샵에서는 EKS 클러스터 에 Volume 을 만들지 않는 관계로, ADOT 를 활용해서 메트릭을 AMP 로 보낸다. 

```
export CLUSTER_NAME=`eksctl get cluster|awk '{print $1}'|tail -1`
export AWS_REGION=`eksctl get cluster|awk '{print $2}'|tail -1`
export ACCOUNT_ID=`aws sts get-caller-identity|grep "Arn"|cut -d':' -f6`
```

OpenTelemetry 를 활용한 K8S 메트릭 수집에 대한 보다 자세한 내용은 아래 링크에서 참조.
* [Send Kubernetes metrics and logs using the OpenTelemetry Collector](https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/configure-infrastructure-manually/otel-collector/)


## AMP (매니지드 프로메테우스) ##

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
#### 권한부여 ####
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

#### 추가기능 설치 ####
```
aws eks create-addon \
--addon-name adot \
--addon-version v0.74.0-eksbuild.1 \
--cluster-name ${CLUSTER_NAME}
```
[결과]
```
{
    "addon": {
        "addonName": "adot",
        "clusterName": "eks-workshop",
        "status": "CREATING",
        "addonVersion": "v0.74.0-eksbuild.1",
        "health": {
            "issues": []
        },
        "addonArn": "arn:aws:eks:ap-northeast-2:499514681453:addon/eks-workshop/adot/f4c51d12-7c82-b56d-7474-f4e467b24717",
        "createdAt": "2023-08-28T03:16:56.364000+00:00",
        "modifiedAt": "2023-08-28T03:16:56.380000+00:00",
        "tags": {}
    }
}
```
#### 동작확인 ####
```
aws eks describe-addon --addon-name adot --cluster-name ${CLUSTER_NAME} | jq .addon.status
```
"ACTIVE"



### 5. kube-state-metrics & node_exporter 설치 ###
* [Send Kubernetes metrics and logs using the OpenTelemetry Collector](https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/configure-infrastructure-manually/otel-collector/)
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install ksm prometheus-community/kube-state-metrics --set image.tag="v2.8.2" -n "default"
helm install nodeexporter prometheus-community/prometheus-node-exporter -n "default"
```

[결과]
kube-state-metrics 와 nodeexporter 파드가 설치된 것을 확인할 수 있다.
```
$ kubectl get all
NAME                                              READY   STATUS    RESTARTS   AGE
pod/ksm-kube-state-metrics-58dcbb6dc9-t2kqf       1/1     Running   0          3m42s
pod/nodeexporter-prometheus-node-exporter-cm5fm   1/1     Running   0          15s
pod/nodeexporter-prometheus-node-exporter-kk94w   1/1     Running   0          15s
pod/nodeexporter-prometheus-node-exporter-m4qj9   1/1     Running   0          15s
pod/shop-8649fb4698-5ztkq                         1/1     Running   0          169m
pod/shop-8649fb4698-fhwdd                         1/1     Running   0          169m
pod/shop-8649fb4698-skckg                         1/1     Running   0          169m

NAME                                            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
service/ksm-kube-state-metrics                  ClusterIP   172.20.102.83    <none>        8080/TCP       3m42s
service/kubernetes                              ClusterIP   172.20.0.1       <none>        443/TCP        26h
service/nodeexporter-prometheus-node-exporter   ClusterIP   172.20.248.153   <none>        9100/TCP       16s
service/shop                                    NodePort    172.20.210.136   <none>        80:30751/TCP   169m

NAME                                                   DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
daemonset.apps/nodeexporter-prometheus-node-exporter   3         3         3       3            3           kubernetes.io/os=linux   15s

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/ksm-kube-state-metrics   1/1     1            1           3m42s
deployment.apps/shop                     3/3     3            3           169m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/ksm-kube-state-metrics-58dcbb6dc9   1         1         1       3m42s
replicaset.apps/shop-8649fb4698                     3         3         3       169m
```

### 6. Otel collector 설치 ###
```
WORKSPACE_ID=$(aws amp list-workspaces --alias eks-workshop | jq '.workspaces[0].workspaceId' -r)
AMP_ENDPOINT_URL=$(aws amp describe-workspace --workspace-id $WORKSPACE_ID | jq '.workspace.prometheusEndpoint' -r)
AMP_REMOTE_WRITE_URL=${AMP_ENDPOINT_URL}api/v1/remote_write

curl -O https://raw.githubusercontent.com/aws-containers/eks-app-mesh-polyglot-demo/master/workshop/otel-collector-config.yaml 
sed -i -e s/AWS_REGION/$AWS_REGION/g otel-collector-config.yaml
sed -i -e s^AMP_WORKSPACE_URL^$AMP_REMOTE_WRITE_URL^g otel-collector-config.yaml
```

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/otel-collector-config-append-1.png)

위의 그림처럼 otel-collector-config.yaml 파일에 아래 내용을 추가하고 (라인번호 292),
```
- job_name: integrations/kubernetes/kube-state-metrics
  kubernetes_sd_configs:
    - role: pod
  relabel_configs:
    - action: keep
      regex: kube-state-metrics
      source_labels:
        - __meta_kubernetes_pod_label_app_kubernetes_io_name

- job_name: integrations/node_exporter
  kubernetes_sd_configs:
    - namespaces:
        names:
          - default
      role: pod
  relabel_configs:
    - action: keep
      regex: prometheus-node-exporter.*
      source_labels:
        - __meta_kubernetes_pod_label_app_kubernetes_io_name
    - action: replace
      source_labels:
        - __meta_kubernetes_pod_node_name
      target_label: instance
    - action: replace
      source_labels:
        - __meta_kubernetes_namespace
      target_label: namespace
```

otel collector 를 실행한다.
```
kubectl apply -f ./otel-collector-config.yaml
```

[결과]
```
opentelemetrycollector.opentelemetry.io/observability created
clusterrole.rbac.authorization.k8s.io/otel-prometheus-role created
clusterrolebinding.rbac.authorization.k8s.io/otel-prometheus-role-binding created
```

### 7. collector 정상동작 여부 확인 ###

#### collector 확인 ####
```
kubectl get all -n prometheus
```

[결과]
```
NAME                                           READY   STATUS    RESTARTS   AGE
pod/observability-collector-69f488d4c7-qm85g   1/1     Running   0          86s

NAME                                         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/observability-collector-monitoring   ClusterIP   172.20.55.1   <none>        8888/TCP   86s

NAME                                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/observability-collector   1/1     1            1           87s

NAME                                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/observability-collector-69f488d4c7   1         1         1       87s
```

#### AMP 수집 데이터 확인 ####
```
sudo pip install --upgrade pip
sudo ln -s /usr/local/bin/pip /usr/bin/pip
pip install awscurl==0.26
```

```
awscurl --service "aps" --region=${AWS_REGION} \
    "${AMP_ENDPOINT_URL}api/v1/query?query=scrape_samples_scraped"
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-opentel-working.png)



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



## AMG(매니지드 그라파나) ##

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

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-5.png)

워크스페이스가 생성되었다. AMG 에 접근하기 위해서 Autehntification 메뉴에서 [Assign new new or group] 버튼을 클릭한 후

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-6.png)

SSO 에서 생성한 유저를 등록하도록 한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-7.png)

[Action] 버튼을 클릭한 후 Viewer 권한을 Admin 으로 변경한다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-8.png)

eks-workshop 워크스페이스 상세페이지로 이동하여 그라파나 워크스페이스 URL 을 클릭한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-9.png)

Sign in with AWS Identity Center 버튼을 클릭한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-10.png)

AMG 대시보드에 로그인 하였다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-ws-11.png)


### 2. 데이터 소스 설정 ###

2023.5월 기준으로 서울리전은 AWS data source방법으로 AMP연결기능이 지원되지 않아서 SigV4서명방법으로 AMP를 연결해야 한다.

** -> 현재 IAM 롤 설정으로 AMP 에 연결할 수 있다.....아래 내용 수정필요.

Administration > Data sources 메뉴로 이동해서 [Add data source] 버튼을 클릭한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-datasource-1.png)

리스트 화면에서 Prometheus 를 선택한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-datasource-2.png)

```
HTTP - URL : AMP(프로메테우스) query URL 
Auth - Sigv4 auth 를 선택
Autentification Provider : Acess & secret key
Access Key : ..
Secret Access Key : ..
Default Region : ap-northeast-2
```
#### AMP query URL (/api/v1/query 는 제외해야 함) ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amp-query-url.png)

위의 조건대로 각 항목을 입력하고 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-datasource-3.png)

[Save & test] 버튼을 눌러서 "Data source is working" 이라는 메시지를 확인한다. 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-datasource-4.png)


### 3. eks 대시보드 생성 ###

Home > Dashboards 메뉴로 이동한다. 

#### New 버튼 하단의 Import 서브 메뉴를 클릭한다 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-dashboard-1.png)

#### Import via grafna.com 항목에 13548 입력하고 Load 버튼 클릭 #### 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-dashboard-2.png)

#### Import 버튼 클릭 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-dashboard-3.png)

#### 대시보드 샘플 ####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-dashboard-5.png)

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/amg-dashboard-6.png)

위와 같이 설치가 완료되었다.

## 레퍼런스 ##

* [ADOT, AMP 및 AMG를 사용한 모니터링](https://kschoi728.tistory.com/97)
* [AMG - SigV4 서명으로 AMP에 연결하기](https://malwareanalysis.tistory.com/602)
* [AWS SSO와 Directory Service 연동하기](https://blog.leedoing.com/176)
* https://archive.eksworkshop.com/intermediate/246_monitoring_amp_amg/
* [AWS EKS에 볼륨 마운트 해보기](https://blog.wonizz.tk/2019/11/28/kubernetes-aws-eks-volume/)
