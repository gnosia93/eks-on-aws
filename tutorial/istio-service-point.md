node.js 를 이용하여 point 서비스를 구현 한다.

## 개발환경 구성 ##

#### 1. node 설치 ####
```
brew install node
```

#### 2. 프로젝트 생성 ####
```
$ npm init
This utility will walk you through creating a package.json file.
It only covers the most common items, and tries to guess sensible defaults.

See `npm help init` for definitive documentation on these fields
and exactly what they do.

Use `npm install <pkg>` afterwards to install a package and
save it as a dependency in the package.json file.

Press ^C at any time to quit.
package name: (soonbeom) point
```
```
npm install --save express
```

## Express 개발 ##
#### package.json ####
```
{
  "name": "point",
  "version": "1.0.0",
  "description": "",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC",
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

#### app.js ####
```
const express = require('express');
const app = express();

app.get("/point/:memberNo", (req, res) => {
    let memberNo = req.params.memberNo 
    res.json(
        {
            memberNo: memberNo,
            point: 'ok' 
        }
    );
});

app.listen(3000, () => {
    console.log("Server running at http://localhost:3000"); 
});
```

## Express 실행 ##
```
node app.js
```

## 도커라이징 ##

#### Dockerfile ####
```
FROM node:latest

# 앱 디렉터리 생성
WORKDIR /usr/src/app

# 앱 의존성 설치
# 가능한 경우(npm@5+) package.json과 package-lock.json을 모두 복사하기 위해
# 와일드카드를 사용
COPY package*.json ./

RUN npm install
# 프로덕션을 위한 코드를 빌드하는 경우
# RUN npm ci --only=production

# 앱 소스 추가
COPY . .

EXPOSE 3000
CMD [ "node", "app.js" ]
```

#### .dockerignore ####
```
node_modules
npm-debug.log
```

#### 이미지 빌드 ####
```
docker build . -t nodejs-point
```
```
$ docker image ls nodejs-point
REPOSITORY     TAG       IMAGE ID       CREATED         SIZE
nodejs-point   latest    f2e9776cb622   3 minutes ago   1.1GB
```

#### 도커 어플리케이션 테스트 ####
```
docker run -it --name nodejs-point -p 3000:3000 nodejs-point
```

```
curl http://localhost:3000
```


## ECR 이미지 푸시 ##

#### ECR 생성 ####
```
ACCOUNT_ID=`aws sts get-caller-identity|jq -r ".Account"`;AWS_REGION=ap-northeast-2
IMAGE_REPO=eks-on-aws-nodejs-point

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

aws ecr create-repository \
    --repository-name ${IMAGE_REPO} \
    --image-scanning-configuration scanOnPush=true \
    --region ${AWS_REGION}
```

#### 이미지 푸시 ####
```
#docker tag nodejs-point ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}:latest
#docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO}

docker buildx create --use

docker buildx build --push \
     --platform linux/amd64,linux/arm64 \
     -t ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_REPO} .
```


## 레퍼런스 ##

* [도커이미지 사이즈 줄이기](https://jeffminsungkim.medium.com/docker-%EC%9D%B4%EB%AF%B8%EC%A7%80-%ED%81%AC%EA%B8%B0-%EC%A4%84%EC%9D%B4%EA%B8%B0-2f90fa5c96)

* [node 도커라이징](https://cocoon1787.tistory.com/749)

* [node express](https://blog.codefactory.ai/nodejs/creating-server-with-express/express-intro/)
  
* [node.js Controller, Service, Repository](https://jin-coder.tistory.com/entry/nodejs-Controller-Service-Repository)

* [VSCode node 개발환경 구성](https://devmoony.tistory.com/151)
  
* [Homebrew 를 통해 node, npm, yarn 설치](https://butter-ring.tistory.com/17)
