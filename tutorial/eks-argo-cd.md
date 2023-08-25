
### 1. ArgoCD 배포 ###
```
kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

### 2. CLI 설치 ###
```
export VERSION=v2.8.2

curl -LO https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64

chmod u+x argocd-linux-amd64

sudo mv argocd-linux-amd64 /usr/local/bin/argocd
```

### 3. 인그레스 생성 ###

```
cat <<EOF > argocd-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/target-type: instance
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/load-balancer-name: argocd-alb
#    alb.ingress.kubernetes.io/healthcheck-path: /actuator/health
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '5'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '3'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'
spec:
  rules:
   - http:
      paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: argocd-server 
              port:
                number: 80
EOF
```

```
kubectl apply -f argocd-ingress.yaml

kubectl describe ingress argocd-ingress -n argocd
```




## 레퍼런스 ##

* https://nyyang.tistory.com/114
  
