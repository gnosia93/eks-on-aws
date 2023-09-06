## 리소스 삭제 ##

### 1. EKS 삭제 ### 

cloud9 터미널에서 실행한다.
  
#### Ingress 및 LoadBalancer 타입의 K8S 오브젝트를 지운다. ####
```
kubectl delete service nginx
kubectl delete ingress shop-ingress
```
#### cloudformation 지우기 ####

```
aws cloudformation delete-stack --stack-name eksctl-eks-workshop-addon-iamserviceaccount-kube-system-aws-load-balancer-controller
aws cloudformation delete-stack --stack-name eksctl-eks-workshop-addon-iamserviceaccount-prometheus-amp-irsa-role
```
```
aws cloudformation delete-stack --stack-name eksctl-eks-workshop-nodegroup-ng-2xlarge
-- 노드 인스턴스 그룹 롤을 먼저지워야함 secret manager. read/write.
```
#### eksctl ###
```
eksctl delete cluster eks-workshop
aws cloudformation delete-stack --stack-name eksctl-eks-workshop-cluster
```

#### EKS 시큐리티 그룹 삭제 ####
```
aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `eks-workshop`)].GroupId' --out text

sg-00e8ead96f504e4bc    sg-0e26fb54474ff7985    sg-04690df9206057f4c    sg-0df8fb4f4f045549e

aws ec2 delete-security-group --group-id sg-00e8ead96f504e4bc
```

* k8s ELB
```
SGS=$(aws ec2 describe-security-groups --query 'SecurityGroups[?contains(GroupName, `k8s`)].GroupId' --out text)
for 

```


### 2. 기본 인프라 삭제 ###
로컬 PC 에서 실행한다.
```
cd ~/eks-on-aws/tf

terraform destroy -auto-approve
```
* 테라폼으로 지우다가 에러가 발생하는 경우 AWS 콘솔로 이동하여 수동으로 지워준다.


### 3. AMP / AMG / SSO 삭제 ###

```
aws grafana delete-workspace \
--workspace-id=$(aws grafana list-workspaces --query workspaces[].id --output text)
aws amp delete-workspace \
--workspace-id=$(aws amp list-workspaces --query workspaces[].workspaceId --output text)
```
* AWS Identity Centor 콘솔에서 지운다.


## 레퍼런스 ##

* https://bobbyhadz.com/blog/aws-cli-query-contains

* [linux - 문자 분리(split, awk, cut, awk)](https://linuxism.ustd.ip.or.kr/1260)
