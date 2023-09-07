
```
export EXPORTER_VERSION=v1.54.0
wget https://github.com/oliver006/redis_exporter/releases/download/${EXPORTER_VERSION}/redis_exporter-v1.54.0.linux-amd64.tar.gz

tar -zxvf redis_exporter-${EXPORTER_VERSION}.linux-arm.tar.gz

cd redis_exporter-v1.54.0.linux-amd64/
```

```
REDIS_ENDPOINT=$(aws elasticache describe-cache-clusters --show-cache-node-info \
--query 'CacheClusters[?starts_with(CacheClusterId, `eks-redis`)].CacheNodes[].Endpoint[].Address' --out text)
echo "${REDIS_ENDPOINT}"
```


./redis_exporter -redis.addr=${레디스 접속 address}

```



## 레퍼런스 ##

* https://github.com/oliver006/redis_exporter/releases
  
* https://velog.io/@dev_leewoooo/Redis%EC%9D%98-metrics%EB%A5%BC-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81%ED%95%B4%EB%B3%B4%EC%9E%90
