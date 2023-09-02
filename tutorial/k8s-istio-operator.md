
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
