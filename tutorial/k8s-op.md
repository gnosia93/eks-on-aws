## k8s 운영 ##

* [k8s command 모음](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/k8s-op-cmd.md)

* [helm](https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/study-helm.md)

* [Drain & Cardon](https://velog.io/@koo8624/Kubernetes-Drain-Cordon-and-Uncordon)

* [Graceful Shutdown](https://waspro.tistory.com/682)
  
* [resource request / limit](https://kubernetes.io/ko/docs/concepts/configuration/manage-resources-containers/) 

* Volume

* deployment - https://arisu1000.tistory.com/27833
  
* [Cluster upgrade](https://jerryljh.tistory.com/86)  

* [어플리케이션 배포 전략](https://velog.io/@_zero_/%EC%BF%A0%EB%B2%84%EB%84%A4%ED%8B%B0%EC%8A%A4-%EB%B0%B0%ED%8F%AC-%EC%A0%84%EB%9E%B5RollingUpdate-BlueGreen-Canary-%EB%B0%8F-%EB%A1%A4%EB%B0%B1Rollback-%EA%B0%9C%EB%85%90%EA%B3%BC-%EC%84%A4%EC%A0%95)

  - https://blog.yevgnenll.me/k8s/deployment-declaration-update-application

* [PDB](https://halfmoon95.tistory.com/entry/PodDisruptionBudget%EC%9D%84-%EC%9D%B4%EC%9A%A9%ED%95%9C-Pod-%EC%9E%AC%EB%B0%B0%EC%B9%98)

* 트러블 슈팅
  - [Kubernetes CrashLoopBackOff — How to Troubleshoot](https://foxutech.medium.com/kubernetes-crashloopbackoff-how-to-troubleshoot-940dbb16bc84)

## 개발 ##
    
* [Spring Security / JWT - 로그인 구현](https://webfirewood.tistory.com/115)
  * https://github.com/gnosia93/eks-on-aws/blob/main/tutorial/springboot-redis-session.md   

* [Redis - 대기열 시스템 구현](https://dev-jj.tistory.com/entry/%ED%94%84%EB%A1%9C%EB%AA%A8%EC%85%98%EC%9D%84-%EB%8C%80%EB%B9%84%ED%95%9C-%EB%8C%80%EA%B8%B0%EC%97%B4-%EC%8B%9C%EC%8A%A4%ED%85%9C-%EA%B5%AC%EC%84%B1%ED%95%98%EA%B8%B0-Redis-WebSocket-Spring)  
  * https://kdg-is.tistory.com/entry/Spring-Boot-Redis-Sorted-Set%EC%9D%84-%EC%82%AC%EC%9A%A9%ED%95%98%EC%97%AC-%EB%8C%80%EA%B8%B0%EC%97%B4-%EA%B5%AC%ED%98%84
  * https://duddal.tistory.com/64


## PVRE ##

#### 1. EKS NodeGroup Role 에 아래 정책을 추가한다. ####
```
AmazonSSMManagedInstanceCore
AmazonSSMPatchAssociation
```

#### 2. SSM Agent 를 K8S 데몬셋으로 설정한다. ####
* https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/install-ssm-agent-on-amazon-eks-worker-nodes-by-using-kubernetes-daemonset.html    
cloud9 터미널에서 아래 명령어를 실행한다.
```
cat << EOF > ssm_daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    k8s-app: ssm-installer
  name: ssm-installer
  namespace: kube-system
spec:
  selector:
    matchLabels:
      k8s-app: ssm-installer
  template:
    metadata:
      labels:
        k8s-app: ssm-installer
    spec:
      containers:
      - name: sleeper
        image: busybox
        command: ['sh', '-c', 'echo I keep things running! && sleep 3600']
      initContainers:
      - image: amazonlinux
        imagePullPolicy: Always
        name: ssm
        command: ["/bin/bash"]
        args: ["-c","echo '* * * * * root yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm & rm -rf /etc/cron.d/ssmstart' > /etc/cron.d/ssmstart"]
        securityContext:
          allowPrivilegeEscalation: true
        volumeMounts:
        - mountPath: /etc/cron.d
          name: cronfile
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      volumes:
      - name: cronfile
        hostPath:
          path: /etc/cron.d
          type: Directory
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      terminationGracePeriodSeconds: 30
EOF
```
데몬셋을 생성한다. 
```
kubectl apply -f ssm_daemonset.yaml
```

데몬셋 실행로그를 확인한다. 
```
kubectl logs ssm-installer-2r7qj -n kube-system
```
I keep things running!

#### 3. Patch Manager 에서 Patch Policy 를 생성한다. ####
AWS System Manager 콘솔에서 Patch Manager 서브 메뉴로 이동하여 Patch Policy 를 생성한다.  
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/patchmanager-1.png)
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/patchmanager-2.png)
