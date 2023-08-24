## 카펜터 스케일링 테스트 ##

#### cloud9 ####

cloud9 에서 탭을 열어서 아래 명령어 들을 실행한다.

#### nginx ####
```

```

#### 카펜트 로그 확인 ####
```
kubectl logs -f -n karpenter -c controller -l app.kubernetes.io/name=karpenter
```
#### 노드 갯수 확인 ####
```
kubectl get node
```





#### 스케일링 ####
```
kubectl scale --replicas=30 deployment/nginx-to-scaleout
```


## 레퍼런스 ##
