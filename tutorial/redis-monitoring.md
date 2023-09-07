
로컬 PC 에서 아래 명령어를 실행해서 MySQLPrometheusRole Role에 Redis 접근 권한을 추가한다.
```
aws iam attach-role-policy \
    --role-name MySQLPrometheusRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess
```

Redis 주소를 받아오고 
```
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --show-cache-node-info \
--query 'CacheClusters[?starts_with(CacheClusterId, `eks-redis`)].CacheNodes[].Endpoint[].Address' --out text)
echo "${REDIS_ENDPOINT}"
```

Redis exporter 를 설치한다. 
```
export EXPORTER_VERSION=v1.54.0
wget https://github.com/oliver006/redis_exporter/releases/download/${EXPORTER_VERSION}/redis_exporter-v1.54.0.linux-amd64.tar.gz

tar -zxvf redis_exporter-${EXPORTER_VERSION}.linux-arm.tar.gz
```

exporter 를 시작한다. 
```
cd redis_exporter-v1.54.0.linux-amd64/

./redis_exporter -redis.addr=${REDIS_ENDPOINT} &
curl http://localhost:9121
```

[결과]
```
<html>
<head><title>Redis Exporter v1.54.0</title></head>
<body>
<h1>Redis Exporter v1.54.0</h1>
<p><a href='/metrics'>Metrics</a></p>
</body>
</html>
```


## 트러블 슈팅 ##

* An error occurred (AccessDenied) when calling the DescribeCacheClusters operation: User: arn:aws:sts::499514681453:assumed-role/MySQLPrometheusRole/i-07e94667904714f72 is not authorized to perform: elasticache:DescribeCacheClusters on resource: arn:aws:elasticache:ap-northeast-2:499514681453:cluster:* because no identity-based policy allows the elasticache:DescribeCacheClusters action

  


## 레퍼런스 ##

* https://github.com/oliver006/redis_exporter/releases
  
* https://velog.io/@dev_leewoooo/Redis%EC%9D%98-metrics%EB%A5%BC-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81%ED%95%B4%EB%B3%B4%EC%9E%90
