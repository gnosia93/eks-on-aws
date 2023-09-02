
```
aws secretsmanager create-secret \
    --name "prod/shop/mysql8.1.3" \
    --description "eks-workshop mysql id/password" \
    --secret-string "{\"user\":\"shop\",\"password\":\"shop\"}"
```

## 레퍼런스 ##

* https://velog.io/@korea3611/Spring-Boot-AWS-Secret-Manager%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-%ED%94%84%EB%A1%9C%ED%8D%BC%ED%8B%B0%EB%A5%BC-%EA%B4%80%EB%A6%AC%ED%95%98%EC%9E%90
