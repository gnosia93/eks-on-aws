## 설치 ##

```
sudo yum install python
sudo yum install python3-pip
pip install locust
locust -V
```

[결과]
```
locust 2.16.1 from /home/ec2-user/.local/lib/python3.9/site-packages/locust (python 3.9.16)
```

## 코드작성 ##
[test.py]
```
import json
from locust import HttpUser,  task , between
class sample(HttpUser):
	wait_time = between(5, 15)
	access_token = ""
	def on_start(self):		
		print("start test")		

	def on_stop(self):		
		print("end test")		

	@task
	def login(self):
		data = {
			"id" : "sample"
			,"password" : "ssss"
		}
		self.client.post("/api/auth/sign-in", json.dumps(data), headers={"Content-Type" : "application/json"})

	@task
	def logout(self):
		self.client.post("/api/auth/sign-out",
						headers={"Content-Type" : "application/json"}
		)
```

```
locust -f ./test.py -P 8080
```



## 레퍼런스 ##

* https://ellune.tistory.com/68
