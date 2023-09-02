
### secret 생성 ###
```
aws secretsmanager create-secret \
    --name "prod/shop/mysql-8.x" \
    --description "eks-workshop mysql id/password" \
    --secret-string "{\"user\":\"shop\",\"password\":\"shop\"}"
```

[결과]
```
{
    "ARN": "arn:aws:secretsmanager:ap-northeast-2:000000000:secret:prod/shop/mysql-8.x-GWdTBZ",
    "Name": "prod/shop/mysql-8.x",
    "VersionId": "296c05bf-ebdb-4806-9a17-946cb10f6b69"
}
```

### 패스워드 rotation 설정 ###

AWS 콘솔의 secret manager 로 이동해서 아래 람다 함수를 등록한다. 
rotation configuration 에서 [edit rotation] 버튼 클릭.

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/secretmanager-rotation.png)

* https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/blob/master/SecretsManagerRDSMySQLRotationSingleUser/lambda_function.py

### springboot 수정 ###

#### application-prod.yml ####
```
server:
  port: 8080
spring:
  application:
    name: springboot-shop-prod
  datasource:
    url: jdbc-secretsmanager:postgresql://${DB_ENDPOINT}:3306/shop
    username: prod/shop/mysql-8.x
    driver-class-name: com.amazonaws.secretsmanager.sql.AWSSecretsManagerMySQLDriver

logging.level.root : info

msa.service.endpoint.prod : ${PROD_SERVICE_ENDPOINT}
msa.service.endpoint.point: ${POINT_SERVICE_ENDPOINT}
```

#### build.gradle ####
```
dependencies {
	implementation 'org.springframework.cloud:spring-cloud-starter-bootstrap:3.1.3'
	implementation 'org.springframework.cloud:spring-cloud-starter-aws-secrets-manager-config:2.2.6.RELEASE'
	implementation 'com.amazonaws.secretsmanager:aws-secretsmanager-jdbc:1.0.8'
    ...
```

### EKS 노드그룹 권한 설정 ###

EKS 콘솔에서 ng-2xlarge 노드그룹의 Role을 확인한 후, 
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/secretmanager-role-0.png)

해당 Role 에 대해서 아래와 같이
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/secretmanager-role-1.png)

SecretsManagerReadWrite 권한을 추가한다.
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/secretmanager-role-2.png)


## 트러블 슈팅 ##

*  s.AwsSecretsManagerPropertySourceLocator : Fail fast is set and there was an error reading configuration from AWS Secrets Manager:
User: arn:aws:sts::0000000000000:assumed-role/eksctl-eks-workshop-nodegroup-ng-NodeInstanceRole-1VUIDMEQADL6L/i-050601b9544ac5653 is not authorized to perform: secretsmanager:GetSecretValue on resource: /secret/springboot-shop-stage_stage because no identity-based policy allows the secretsmanager:GetSecretValue action (Service: AWSSecretsManager; Status Code: 400; Error Code: AccessDeniedException; Request ID: 425815ec-5503-4d14-93ec-9b210b384c76; Proxy: null)





## 레퍼런스 ##

* https://velog.io/@korea3611/Spring-Boot-AWS-Secret-Manager%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-%ED%94%84%EB%A1%9C%ED%8D%BC%ED%8B%B0%EB%A5%BC-%EA%B4%80%EB%A6%AC%ED%95%98%EC%9E%90
