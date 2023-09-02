istio 설정을 파일로 관리하는 기능을 제공하는 것이 바로 istio operator 이다. 이를 이용하면 쿠버네티스 CRD로 istio 를 설정할 수 있다.   
아래 화면에서는 istio operator 를 설치하고 있다. 

```
$ istioctl operator init
Installing operator controller in namespace: istio-operator using image: docker.io/istio/operator:1.18.2
Operator controller will watch namespaces: istio-system
✔ Istio operator installed                                                                                                                                      
✔ Installation complete
```

```
$ kubectl -n istio-operator get all
NAME                                  READY   STATUS    RESTARTS   AGE
pod/istio-operator-7d8f6b889f-nwwx2   1/1     Running   0          48m

NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/istio-operator   ClusterIP   172.20.141.203   <none>        8383/TCP   48m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/istio-operator   1/1     1            1           48m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/istio-operator-7d8f6b889f   1         1         1       48m
```

## 레퍼런스 ##

* https://malwareanalysis.tistory.com/298
