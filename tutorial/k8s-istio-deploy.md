```
kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
 { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.6.2" | kubectl apply -f -; }
```
```
customresourcedefinition.apiextensions.k8s.io/gatewayclasses.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/gateways.gateway.networking.k8s.io created
customresourcedefinition.apiextensions.k8s.io/httproutes.gateway.networking.k8s.io created
```

```
cd ~/istio-1.18.2

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
```

## 레퍼런스 ##

* https://cwal.tistory.com/42

* https://istio.io/latest/docs/setup/getting-started/
  
* https://malwareanalysis.tistory.com/307

* https://istio.io/latest/docs/examples/bookinfo/
