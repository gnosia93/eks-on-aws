## 성능 테스트 ##

### 1. ec2 생성 ###
AWS 콘솔에서 아마존 리눅스를 사용하는 c6i.2xlarge 인스턴스를 하나 만들고, 22, 8080 포트를 0.0.0.0/0 으로 오픈한다.
```
$ ssh -i aws-kp-2.pem ec2-user@<server ip> 
```

### 2. python 설치 ###
```
sudo yum install python
sudo yum install python3-pip
```

### 3. locust 설치 ###
```
pip install locust
locust -V
```

[결과]
```
locust 2.16.1 from /home/ec2-user/.local/lib/python3.9/site-packages/locust (python 3.9.16)
```

### 4. 테스트 코드작성 ###
[test.py]
```
import json
from locust import HttpUser,  task , between
class sample(HttpUser):
	wait_time = between(1, 3)
	access_token = ""
	def on_start(self):		
		print("start test")		

	def on_stop(self):		
		print("end test")		

	@task
	def add(self):
		data = {	
		    	"password": "7771",
			"name": "111",
    			"phoneNumber": "9-111-11",
    			"emailAddress": "9999@example.com"
		}
		self.client.post("/member/add", json.dumps(data), headers={"Content-Type" : "application/json"})

	@task
	def get(self):
		self.client.get("/member/1", headers={"Content-Type" : "application/json"})
```
- https://docs.locust.io/en/stable/
  
### 5. 테스트 ###
```
locust -f ./test.py -P 8080 -H http://shop-alb-1152585058.ap-northeast-2.elb.amazonaws.com
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/%20locust.png)



## 레퍼런스 ##

* https://ellune.tistory.com/68
