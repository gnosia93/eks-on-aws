MySQL 데이터베이스에서 메트릭을 수집해서 AMG 로 보내기 위해, ec2 인스턴스를 하나 만든다. 

```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
```


### mysql 계정 생성 ###

mysql 에서 메트릭을 수집하기 위해서 collector DB 계정을 만든다. cloud9 터미널에서 아래 명령어를 수행한다. 
```
cat <<EOF > coll.sql
CREATE USER 'coll'@'%' IDENTIFIED BY 'coll';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'coll'@'%';
GRANT SELECT ON performance_schema.* TO 'coll'@'%';
FLUSH PRIVILEGES;
EOF
```

mysql 에 로그인해서 coll.sql 을 실행한다. 
```
mysql -u root -p -h ${DB_ADDR} 
```

### 프로메테우스 설치 ###

AWS EC2 콘솔에서 eks_ec2_mysql_collector 서버를 확인 후 ssh 로 로그인 한다.
```
global:
  scrape_interval:     15s    

scrape_configs:
  - job_name : 'rds'    
    static_configs:
      - targets: ['${STAGE_DB}:3306']  
        labels:
          name: 'stage-db'    
      - targets: ['${PROD_DB}:3306']
        labels:
          name: 'prod-db'
```

## 레퍼런스 ##

* https://omty.tistory.com/54
* https://observiq.com/blog/how-to-monitor-mysql-with-opentelemetry
* https://stackoverflow.com/questions/71646503/how-to-monitor-aws-rds-vis-prometheus-using-cloudwatch-exporter
* https://github.com/nerdswords/yet-another-cloudwatch-exporter/tree/master
* https://aws.amazon.com/blogs/mt/enhance-observability-for-amazon-rds-custom-for-sql-server-using-amazon-managed-service-for-prometheus-and-amazon-managed-grafana/
* https://medium.com/@Amet13/sending-aws-metrics-into-prometheus-using-operator-and-cloudwatch-exporter-180481cce2a6
