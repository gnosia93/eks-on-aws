## Istio 어플리케이션 배포 - bookinfo ##

#### default 네임스페이스 인젝션 설정 ####
```
kubectl label namespace default istio-injection=enabled
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

#### POD 동작 확인 ####
```
kubectl get pod -l app=ratings -o yaml > rating.yaml

kubectl exec "$(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}')" \
 -c ratings -- curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
```

#### 외부 노출 설정 ####
```
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway
```
[결과]
```
gateway.networking.istio.io/bookinfo-gateway created
virtualservice.networking.istio.io/bookinfo created

NAME               AGE
bookinfo-gateway   3s
```

#### ingressgateway 파드 확인 #### 
```
$ kubectl get pod -n istio-system -l istio=ingressgateway
NAME                                    READY   STATUS    RESTARTS   AGE
istio-ingressgateway-767b5dd74c-662sd   1/1     Running   0          149m
```

#### 설정오류 확인 ####
```
istioctl analyze 
```

#### istio-ingressgateway 서비스 확인 ####
``` 
kubectl get service -n istio-system
```
[결과]
```
NAME                   TYPE           CLUSTER-IP       EXTERNAL-IP                                                                    PORT(S)                                      AGE
istio-ingressgateway   LoadBalancer   172.20.27.104    a2000b639c9a147f8840ba80dd7be449-1085459483.ap-northeast-2.elb.amazonaws.com   15021:30047/TCP,80:32292/TCP,443:32358/TCP   9m57s
istiod                 ClusterIP      172.20.231.243   <none>                                                                         15010/TCP,15012/TCP,443/TCP,15014/TCP        10m
```

http2 포트를 확인해서 80:32292/TCP 로 바인딩되어 있음 확인한다.
```
kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}'
```
[결과]
```
32292
```

## 크롬 브라우저에서 확인 ## 

http://a2000b639c9a147f8840ba80dd7be449-1085459483.ap-northeast-2.elb.amazonaws.com/productpage 접속


## 트러블 슈팅 ##
* kubectl get gateway 출력결과 없음.
-> istioctl analyze 로 확인
```
$ istioctl analyze 
Error [IST0101] (VirtualService default/demo-virtualservice) Referenced host not found: "demo-version"
Error [IST0145] (Gateway default/bookinfo-gateway) Conflict with gateways default/demo-gateway (workload selector istio=ingressgateway, port 80, hosts *).
Error [IST0145] (Gateway default/demo-gateway) Conflict with gateways default/bookinfo-gateway (workload selector istio=ingressgateway, port 80, hosts helloworld.com).
Warning [IST0103] (Pod default/nginx-748c667d99-pxbn5) The pod default/nginx-748c667d99-pxbn5 is missing the Istio proxy. This can often be resolved by restarting or redeploying the workload.
Info [IST0118] (Service default/nginx) Port name  (port: 80, targetPort: 80) doesn't follow the naming convention of Istio port.
Error: Analyzers found issues when analyzing namespace: default.
See https://istio.io/v1.18/docs/reference/config/analysis for more information about causes and resolutions.
```
* https://stackoverflow.com/questions/76330171/why-i-cant-find-istio-gateway-under-namespace-of-istio-system-or-any-other-names

## 레퍼런스 ##

* [Istio #3 - 설치와 bookinfo 예제 실습](https://musclebear.tistory.com/157)
 
* https://istio.io/latest/docs/reference/config/networking/gateway/

* https://cwal.tistory.com/42

* https://istio.io/latest/docs/setup/getting-started/
  
* https://malwareanalysis.tistory.com/307

* https://istio.io/latest/docs/examples/bookinfo/
