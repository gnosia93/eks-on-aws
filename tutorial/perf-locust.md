******
[TO-DO] python faker (https://www.daleseo.com/python-faker/) 를 이용한 테스트 코드 작성.
******

## 성능 테스트 ##

### 1. locust ec2 로그인 ###

콘솔에서 Name 이 eks_locust 인 인스턴스를 찾아 로그인 한다. 
```
$ ssh -i aws-kp-2.pem ec2-user@<server ip> 
```

### 2. 테스트 코드작성 ###
```
pip install --upgrade pip
pip install locust
pip install urllib3==1.26.6
pip install greenlet==1.1.3 gevent==21.8.0
```

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
  
### 3. 테스트 ###

* -f 테스트 코드 파일
* -P locust 웹페이지 포트
* -H 테스트 대상 서버 URL 

```
locust -f ./test.py -P 8080 -H http://shop-alb-1152585058.ap-northeast-2.elb.amazonaws.com
```
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/%20locust.png)



## 레퍼런스 ##

* https://ellune.tistory.com/68
