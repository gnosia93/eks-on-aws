
cloud9 터미널에서 아래 명령어를 실행한다. 
```
kubectl create deployment nginx --image=nginx --replicas 1
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```
