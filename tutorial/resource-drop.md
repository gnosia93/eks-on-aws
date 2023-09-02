## 리소스 삭제 ##

1, 2 단계는 Cloud9 에서 실행한다.

#### 1. AMP / AMG 삭제 ####

```
aws grafana delete-workspace \
--workspace-id=$(aws grafana list-workspaces --query workspaces[].id --output text)
aws amp delete-workspace \
--workspace-id=$(aws amp list-workspaces --query workspaces[].workspaceId --output text)
```

#### 2. EKS 삭제 #### 

노드 그룹을 먼저 지우고, 클러스터를 지운다. cardon 에러가 발생하는 경우 AWS EKS 콘솔에서 지운다.
```
eksctl delete nodegroup --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --name ng-2xlarge

eksctl delete cluster ${CLUSTER_NAME}
```

3, 4 단계는 로컬 PC 에서 실행한다.

#### 3. cloud9 삭제 ####

```
aws cloud9 delete-environment \
--environment-id=$(aws cloud9 list-environments --query environmentIds --output text) 
```

#### 4. 기본 인프라 삭제 ####

```
cd ~/eks-on-aws/tf

terraform destroy
```
* 테라폼으로 지우다가 에러가 발생하는 경우 AWS 콘솔로 이동하여 수동으로 지워준다.

#### 5. SSO 를 지운다 ####
