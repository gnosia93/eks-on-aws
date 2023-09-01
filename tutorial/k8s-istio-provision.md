
cloud9 터미널에서 아래 명령어를 실행한다.

```
curl -O https://raw.githubusercontent.com/istio/istio/master/release/downloadIstioCandidate.sh ​

sh downloadIstioCandidate.sh
```

[결과]
```
Downloading istio-1.18.2 from https://github.com/istio/istio/releases/download/1.18.2/istio-1.18.2-linux-amd64.tar.gz ...

Istio 1.18.2 Download Complete!

Istio has been successfully downloaded into the istio-1.18.2 folder on your system.

Next Steps:
See https://istio.io/latest/docs/setup/install/ to add Istio to your Kubernetes cluster.

To configure the istioctl client tool for your workstation,
add the /home/ec2-user/environment/istio-1.18.2/bin directory to your environment path variable with:
         export PATH="$PATH:/home/ec2-user/environment/istio-1.18.2/bin"

Begin the Istio pre-installation check by running:
         istioctl x precheck 

Need more information? Visit https://istio.io/latest/docs/setup/install/ 
```


## 레퍼런스 ##

* https://malwareanalysis.tistory.com/297
