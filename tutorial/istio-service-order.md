주문 서비스의 경우 https://github.com/gnosia93/eks-on-aws-springboot 에 통합되어 있다. 

## 서비스 개발 ##

### application-dev.yaml ###
msa.service.endpoint.prod 와 msa.service.endpoint.prod 를 추가한다. 
```
logging.level.root : info

msa.service.endpoint.prod : "http://localhost:3001/prod"
msa.service.endpoint.point: "http://localhost:3000/point"
```

### Customer Config 작성 ###
com.example.shop.configuration 패키지 MsaServiceConfiguration.java 추가한다.
```
package com.example.shop.configuration;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix="msa.service.endpoint")
public class MsaServiceConfiguration {
        private String prod;
        private String point;
}
```

### OrderController 추가 ###
com.example.shop.controller 패키지에 OrderController.java 를 추가한다.
```
package com.example.shop.controller;

import com.example.shop.configuration.MsaServiceConfiguration;
import com.fasterxml.jackson.databind.util.JSONPObject;
import com.google.gson.JsonObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import java.util.HashMap;

@RequestMapping(value="/order")
@RestController
public class OrderController {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Autowired
    private MsaServiceConfiguration msaServiceConfiguration;

    private final RestTemplate restTemplate = new RestTemplate();

    @ResponseBody
    @RequestMapping(value="/memberId={memberId}&productId={productId}", method= RequestMethod.GET)
    public ResponseEntity<?> order(@PathVariable Integer memberId,
                                   @PathVariable Integer productId) {

        String prodServiceUrl = msaServiceConfiguration.getProd() + "/" + productId;
        String pointServiceUrl = msaServiceConfiguration.getPoint() + "/" + memberId;

         // prod 서비스 호출
        ResponseEntity<String> prodServiceResponse = restTemplate.getForEntity(
                prodServiceUrl, String.class);

        // point 서비스 호출
        ResponseEntity<String> pointServiceResponse = restTemplate.getForEntity(
                pointServiceUrl, String.class);

        logger.info(prodServiceResponse.getBody());
        logger.info(pointServiceResponse.getBody());

        HashMap<String, Object> orderResponse = new HashMap<String, Object>();
        orderResponse.put("prod", prodServiceResponse.getBody());
        orderResponse.put("point", pointServiceResponse.getBody());

        return ResponseEntity.status(HttpStatus.OK).body(orderResponse);
    }
}
```

## 서비스 배포 ##

EKS 클러스터에 서비스를 배포한다. 

```
STAGE_DB=$(aws rds describe-db-instances | jq '.DBInstances[].Endpoint.Address' | sed 's/"//g' | grep 'eks-mysql-stage')
IMAGE_REPO_ADDR=$(aws ecr describe-repositories | jq '.repositories[].repositoryUri' | sed 's/"//g' | grep 'springboot')
```

```
cat <<EOF > shop-service.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shop
  namespace: default
  labels:
    app: shop
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shop
  template:
    metadata:
      labels:
        app: shop
    spec:
      containers:
        - name: shop
          image: ${IMAGE_REPO_ADDR}
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: stage
            - name: DB_ENDPOINT
              value: ${STAGE_DB}
            - name: DB_USERNAME
              value: shop
            - name: DB_PASSWORD
              value: shop
            - name: JAVA_TOOL_OPTIONS
              value: "-Xms1024M -Xmx1024M"
            - name: PROD_SERVICE_ENDPOINT
              value: "http://flask-prod.default.svc.cluster.local/prod"
            - name: POINT_SERVICE_ENDPOINT
              value: "http://nodejs-point.default.svc.cluster.local/point"
          imagePullPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: shop
  namespace: default
  labels:
    app: shop
spec:
  type: NodePort
  selector:
    app: shop
  ports:
    - port: 80
      targetPort: 8080
EOF
```

```
kubectl apply -f shop-service.yaml
```


## 레퍼런스 ##

* [application.properties 커스텀 property 추가하기(@ConfigurationProperties)](https://velog.io/@gillog/Spring-Boot-application.properties-%EC%BB%A4%EC%8A%A4%ED%85%80-property-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0ConfigurationProperties)

* https://jie0025.tistory.com/531
