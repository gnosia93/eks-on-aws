python flask 를 이용하여 prod 서비스를 구현 한다.

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

#### requirements.txt ####
```
flask
flask-migrate
```

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
#docker tag nodejs-point ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:latest
#docker buildx push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}

docker buildx create --use

docker buildx build --push \
     --platform linux/amd64,linux/arm64 \
     -t ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO} .
```


## 레퍼런스 ##

* https://doitgrow.com/37#google_vignette

* [점프 투 플라스크](https://wikidocs.net/book/4542)

* [docker 멀티아키텍처 이미지 생성하기](https://velog.io/@baeyuna97/exec-user-process-caused-exec-format-error-%EC%97%90%EB%9F%AC%ED%95%B4%EA%B2%B0)
