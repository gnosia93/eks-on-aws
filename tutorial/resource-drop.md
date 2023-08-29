## 리소스 삭제 ##

#### 1. AMP / AMG 삭제 ####
Cloud9 에서 실행
```
aws grafana delete-workspace \
--workspace-id=$(aws grafana list-workspaces --query workspaces[].id --output text)
aws amp delete-workspace \
--workspace-id=$(aws amp list-workspaces --query workspaces[].workspaceId --output text)
```

#### 2. EKS 삭제 #### 
Cloud9 에서 실행
```
eksctl delete nodegroup --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --name ng-2xlarge

eksctl delete cluster ${CLUSTER_NAME}
```


#### 3. cloud9 삭제 ####
로컬 PC 에서 실행
```
aws cloud9 delete-environment \
--environment-id=$(aws cloud9 list-environments --query environmentIds --output text) 
```

#### 4. 기본 인프라 삭제 ####
로컬 PC 에서 실행
```
cd ~/eks-on-aws/tf

terraform destroy
```

* SSO 를 지운다.
