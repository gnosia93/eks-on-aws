
```
kubectl config current-context
export CLUSTER_NAME = eks-workshop
export KARPENTER_VERSION = v0.29.2
export CLUSTER_ENDPOINT = "$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.endpoint" --output text)"
export AWS_ACCOUNT_ID = $(aws sts get-caller-identity --query 'Account' --output text)
```


## 레퍼런스 ##

* https://github.com/aws/karpenter/releases

* https://tech.scatterlab.co.kr/spot-karpenter/

* https://karpenter.sh/

* https://repost.aws/knowledge-center/eks-install-karpenter
