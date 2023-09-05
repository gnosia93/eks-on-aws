MySQL 데이터베이스에서 메트릭을 수집해서 AMG 로 보내기 위해, ec2 인스턴스를 하나 만든다. 

```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
```


### mysql 계정 생성 ###

cloud9 터미널에서 mysql 에서 메트릭을 수집하기 위해서 exporter DB 계정을 만든다.  
```
cat <<EOF > exporter.sql
CREATE USER 'exporter'@'%' IDENTIFIED BY 'exporter';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';
FLUSH PRIVILEGES;
EOF
```

mysql 에 로그인해서 exporter.sql 을 실행한다. 
```
mysql -u root -p -h ${DB_ADDR} 
```

### IAM Role 생성 및 EC2 Role 변경 ###
```
cat <<EOF > assumeRole.json
{
     "Version": "2012-10-17",
     "Statement": [
         {
         "Effect": "Allow",
         "Principal": {
             "Service": "ec2.amazonaws.com"
         },
         "Action": "sts:AssumeRole"
         }
     ]
}
EOF

aws iam create-role \
    --role-name MySQLPrometheusRole \
    --assume-role-policy-document file://assumeRole.json

aws iam attach-role-policy \
    --role-name MySQLPrometheusRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess

aws iam attach-role-policy \
    --role-name MySQLPrometheusRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonPrometheusFullAccess
```


인스턴스 ID 와 associate-id 를 찾는 스크립트를 만들어야 한다. 지금은 콘솔에서 셋팅한다.
```
INSTANCE_ID=i-04be78c6663268a7f
aws ec2 describe-iam-instance-profile-associations
```

```
aws iam create-instance-profile --instance-profile-name MySQLPrometheusRole-Instance-Profile
aws iam add-role-to-instance-profile --role-name MySQLPrometheusRole --instance-profile-name MySQLPrometheusRole-Instance-Profile
aws ec2 replace-iam-instance-profile-association --iam-instance-profile Name=MySQLPrometheusRole-Instance-Profile --instance-id ${INSTANCE_ID}
```

```
WORKSPACE_ID=$(aws amp list-workspaces --alias eks-workshop | jq '.workspaces[0].workspaceId' -r)
AMP_ENDPOINT_URL=$(aws amp describe-workspace --workspace-id $WORKSPACE_ID | jq '.workspace.prometheusEndpoint' -r)
AMP_REMOTE_WRITE_URL=${AMP_ENDPOINT_URL}api/v1/remote_write
```

### MySQL Exporter 설치 ###
```
MYSQL_EXPORTER_VERSION=0.15.0
wget https://github.com/prometheus/mysqld_exporter/releases/download/v${MYSQL_EXPORTER_VERSION}/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz

tar xvfz mysqld_exporter-*.*-amd64.tar.gz
cd mysqld_exporter-*.*-amd64
```


### 프로메테우스 설치 ###

AWS EC2 콘솔에서 eks_ec2_mysql_collector 서버를 확인 후 ssh 로 로그인 한다.

```
PROMETHEUS_VERSION=2.46.0
curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar xvfz prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64
```

[prometheus.yaml]
```
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:8000']

remote_write:
  -
    url: https://aps-workspaces.my-region.amazonaws.com/workspaces/my-workspace-id/api/v1/remote_write
    queue_config:
        max_samples_per_send: 1000
        max_shards: 200
        capacity: 2500
    sigv4:
         region: ap-northeast-2
```

```
prometheus --config.file=prometheus.yaml
```



## 레퍼런스 ##

* https://velog.io/@sojukang/%EC%84%B8%EC%83%81%EC%97%90%EC%84%9C-%EC%A0%9C%EC%9D%BC-%EC%89%AC%EC%9A%B4-Prometheus-Grafana-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-%EC%84%A4%EC%A0%95-MySQL%ED%8E%B8

* https://grafana.com/oss/prometheus/exporters/mysql-exporter/?tab=installation

* https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-remote-write-EC2.html

* https://prometheus.io/docs/prometheus/latest/getting_started/

* https://prometheus.io/download/

* https://dev.classmethod.jp/articles/try-creating-an-iam-role-in-aws-cli/

* https://aws.amazon.com/blogs/security/new-attach-an-aws-iam-role-to-an-existing-amazon-ec2-instance-by-using-the-aws-cli/
