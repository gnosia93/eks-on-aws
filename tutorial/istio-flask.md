## 개발환경 구성 ##
#### flask 설치 ####
```
pip install flask
pip install flask-migrate
```

## flask 개발 ##
#### [app.py] ####
```
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/prod/<int:prod>', methods=['GET'])
def index(prod):
    return jsonify({ prod: 'ok' })

if __name__ == "__main__":
    app.run(host="localhost", port=3001, debug=False)
```

## flask 실행 ##
```
python app.py
```

## 도커라이징 ##

#### Dockerfile ####
```
FROM python:3.9
ENV FLASK_APP=app
COPY . /usr/src/main/
WORKDIR /usr/src/main
RUN pip3 install -r requirements.txt

EXPOSE 3001
CMD ["flask", "run", "--host=0.0.0.0", "--port=3001"]
```

#### requirements.txt ####
```
flask
flask-migrate
```

#### 이미지 빌드 ####
```
docker build . -t flask-prod
```

```
docker image ls flask-prod
```

## ECR 이미지 푸시 ##

#### ECR 생성 ####
```
ACCOUNT_ID=`aws sts get-caller-identity|jq -r ".Account"`;AWS_REGION=ap-northeast-2
IMAGE_REPO=eks-on-aws-flask-prod

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

aws ecr create-repository \
    --repository-name ${IMAGE_REPO} \
    --image-scanning-configuration scanOnPush=true \
    --region ${AWS_REGION}
```

#### 이미지 푸시 ####
```
docker tag nodejs-point ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:latest

docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}
```


## 레퍼런스 ##

* https://doitgrow.com/37#google_vignette

* [점프 투 플라스크](https://wikidocs.net/book/4542)
