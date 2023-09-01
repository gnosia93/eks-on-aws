주문 서비스의 경우 https://github.com/gnosia93/eks-on-aws-springboot 에 통합되어 있어서, 아래 코드만 참고한다. 

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

## 서비스 응답 ##
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/istio-service-order.png)

## 레퍼런스 ##

* [application.properties 커스텀 property 추가하기(@ConfigurationProperties)](https://velog.io/@gillog/Spring-Boot-application.properties-%EC%BB%A4%EC%8A%A4%ED%85%80-property-%EC%B6%94%EA%B0%80%ED%95%98%EA%B8%B0ConfigurationProperties)

* https://jie0025.tistory.com/531
