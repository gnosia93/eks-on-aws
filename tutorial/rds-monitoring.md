*****
Under development.
*****


### mysql 모니터링 계정 생성 ###

eks_mysql_exporter 터미널에서 mysql 에서 메트릭을 수집하기 위해서 exporter DB 계정을 만든다.  
```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
```
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
로컬 PC 에서 아래 명령어를 실행한다.
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

### MySQL Exporter 설치 및 Systemd 서비스 등록 ###
exporter ec2 인스턴스에 설치한다. 
```
MYSQL_EXPORTER_VERSION=0.15.0
wget https://github.com/prometheus/mysqld_exporter/releases/download/v${MYSQL_EXPORTER_VERSION}/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz

tar xvfz mysqld_exporter-*.*-amd64.tar.gz
cd mysqld_exporter-*.*-amd64
```
아래 명령어를 이용하여 linux 서비스로 등록한다. 
```
[Unit]
Description=Prometheus MySQL Exporter
After=network.target
User=prometheus
Group=prometheus

[Service]
Type=simple
Restart=always
ExecStart=/opt/mysqld_exporter-0.14.0.linux-amd64/mysqld_exporter \
--config.my-cnf=/etc/mysql/my.cnf \
--web.listen-address=0.0.0.0:9104 \
--collect.engine_tokudb_status \
--collect.global_status \
--collect.global_variables \
--collect.info_schema.clientstats \
--collect.info_schema.innodb_metrics \
--collect.info_schema.innodb_tablespaces \
--collect.info_schema.innodb_cmp \
--collect.info_schema.innodb_cmpmem \
--collect.info_schema.processlist \
--collect.info_schema.processlist.min_time=0 \
--collect.info_schema.query_response_time \
--collect.info_schema.replica_host \
--collect.info_schema.tables \
--collect.info_schema.tables.databases=‘*’ \
--collect.info_schema.tablestats \
--collect.info_schema.schemastats \
--collect.info_schema.userstats \
--collect.mysql.user \
--collect.perf_schema.eventsstatements \
--collect.perf_schema.eventsstatements.digest_text_limit=120 \
--collect.perf_schema.eventsstatements.limit=250 \
--collect.perf_schema.eventsstatements.timelimit=86400 \
--collect.perf_schema.eventsstatementssum \
--collect.perf_schema.eventswaits \
--collect.perf_schema.file_events \
--collect.perf_schema.file_instances \
--collect.perf_schema.file_instances.remove_prefix=false \
--collect.perf_schema.indexiowaits \
--collect.perf_schema.memory_events \
--collect.perf_schema.memory_events.remove_prefix=false \
--collect.perf_schema.tableiowaits \
--collect.perf_schema.tablelocks \
--collect.perf_schema.replication_group_members \
--collect.perf_schema.replication_group_member_stats \
--collect.perf_schema.replication_applier_status_by_worker \
--collect.slave_status \
--collect.slave_hosts \
--collect.heartbeat \
--collect.heartbeat.database=true \
--collect.heartbeat.table=true \
--collect.heartbeat.utc


[Install]
WantedBy=multi-user.target
```


### 프로메테우스 설치 ###
exporter ec2 인스턴스에 설치한다.
```
PROMETHEUS_VERSION=2.46.0
curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar xvfz prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64
```

AMP 주소를 확인 및 설정하고 프로메테우스를 실행한다.

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

* [MySQL Exporter - Prometheus 연동](https://velog.io/@zihs0822/MySQL-Exporter-Prometheus-%EC%97%B0%EB%8F%99)
