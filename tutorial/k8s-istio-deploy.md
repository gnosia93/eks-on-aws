
#### gateway 설정 ####
```
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
 { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.2" | kubectl apply -f -; }
```

[결과]
```
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
```

#### bookinfo 배포 ####
```
cd ~/istio-1.18.2

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```
[결과]
```
service/details created
serviceaccount/bookinfo-details created
deployment.apps/details-v1 created
service/ratings created
serviceaccount/bookinfo-ratings created
deployment.apps/ratings-v1 created
service/reviews created
serviceaccount/bookinfo-reviews created
deployment.apps/reviews-v1 created
deployment.apps/reviews-v2 created
deployment.apps/reviews-v3 created
service/productpage created
serviceaccount/bookinfo-productpage created
deployment.apps/productpage-v1 created
```


## 레퍼런스 ##

* https://cwal.tistory.com/42

* https://istio.io/latest/docs/setup/getting-started/
  
* https://malwareanalysis.tistory.com/307

* https://istio.io/latest/docs/examples/bookinfo/
