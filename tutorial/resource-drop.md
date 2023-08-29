## 리소스 삭제 ##

Cloud9 에서 실행

#### 1. AMP / AMG 삭제 ####

```
aws grafana delete-workspace \
--workspace-id=$(aws grafana list-workspaces --query workspaces[].id --output text)
aws amp delete-workspace \
--workspace-id=$(aws amp list-workspaces --query workspaces[].workspaceId --output text)
```

#### 2. EKS 삭제 #### 

```
eksctl delete nodegroup --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --name ng-2xlarge

eksctl delete cluster ${CLUSTER_NAME}
```

로컬 PC 에서 실행

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

#### 5. SSO 를 지운다 ####
