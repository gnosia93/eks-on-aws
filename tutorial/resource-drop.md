## 리소스 삭제 ##

eks 클러스터를 먼저 지운 후에 terraform 을 실행한다.

* cloud9 터미널에서 실행
```
eksctl delete cluster $CLUSTER_NAME
```

* 로컬 PC 에서 실행
```
cd ~/eks-on-aws/tf

terraform destroy
```

* 기타 - AMP / AMG 및 SSO 는 AWS 콘솔에서 지운다. 
