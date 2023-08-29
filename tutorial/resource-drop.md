## 리소스 삭제 ##

* AMP / AMG 삭제
```
aws grafana delete-workspace \
--workspace-id=$(aws grafana list-workspaces --query workspaces[].id --output text)
aws amp delete-workspace \
--workspace-id=$(aws amp list-workspaces --query workspaces[].workspaceId --output text)
```

* Cloud9 에서 실행
```
eksctl delete nodegroup --cluster ${CLUSTER_NAME} --region ${AWS_REGION} --name ng-2xlarge
eksctl delete cluster $CLUSTER_NAME
```

* 로컬 PC 에서 실행
```
aws cloud9 delete-environment \
--environment-id=$(aws cloud9 list-environments --query environmentIds --output text) 
```

```
cd ~/eks-on-aws/tf

terraform destroy
```

* 기타 - AMP / AMG 및 SSO 는 AWS 콘솔에서 지운다. 
