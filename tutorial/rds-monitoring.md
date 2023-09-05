## AMP / AMG 를 활용한 MySQL RDS 성능 모니터링 ##

2023 Amazon Linux 에 MySQL exporter 를 설치해서 RDS MySQL 서비스를 모니터링 하는 방법에 대해서 설명한다. 기본 인프라 빌드시 테라폼에 의해 EC2 인스턴스에 mariadb 가 자동으로 설치된다. 수동으로 mariadb 를 인스톨 하고자 하는 경우 아래 명령어를 실행하면 된다. 
```
sudo dnf update -y
sudo dnf install mariadb105-server -y
```
eks_mysql_exporter ec2 인스턴스에 mysql exporter 와 prometheus 를 설치할 예정이다. 
mysql exporter 는 RDS MySQL DB 계정을 이용하여 데이터베이스 성능 메트릭을 수집하고, prometheus 는 exporter 의 http 엔드포인트에 접근해서 메트릭을 TSDB 에 저장한다.   
prometheus 는 AMP(Amazon Managed Service for Prometheus) 와 Sigv4 인증을 통해 연동되어 있어서 MySQL DB 메트릭을 AMP 로 전송할 수 있다. 

![](https://github.com/gnosia93/eks-on-aws/blob/main/images/rds-monitoring-archi-2.png) 


### EC2 IAM Role 변경 ###
로컬 PC 에서 아래 명령어를 실행한다 (어드민 권한 필요)
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

aws iam attach-role-policy \
    --role-name MySQLPrometheusRole \
    --policy-arn arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess
```

eks_mysql_exporter 인스턴스 ID 와 인스턴스 프로파일 정보를 받아온다. 
```
INSTANCE_ID=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=eks_mysql_exporter" --query 'Reservations[].Instances[].InstanceId' --out text)
ASSOCIATION_ID=$(aws ec2 describe-iam-instance-profile-associations --query "IamInstanceProfileAssociations[?InstanceId=='${INSTANCE_ID}'].AssociationId" --out text)

echo "INSTANCE_ID=${INSTANCE_ID}, ASSOCIATION_ID=${ASSOCIATION_ID}"
```

ec2 인스턴스 프로파일을 만들고 기존 프로파일과 교체한다. 
```
aws iam create-instance-profile --instance-profile-name MySQLPrometheusRole-Instance-Profile

aws iam add-role-to-instance-profile --role-name MySQLPrometheusRole \
     --instance-profile-name MySQLPrometheusRole-Instance-Profile

aws ec2 replace-iam-instance-profile-association \
     --iam-instance-profile Name=MySQLPrometheusRole-Instance-Profile \
     --association-id ${ASSOCIATION_ID}
```

### mysql 모니터링 계정 생성 ###

eks_mysql_exporter EC2 터미널에서 stage / productiton DB 의 메트릭을 수집하기 위한 exporter DB 계정을 만든다.  
```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
echo ${DB_ADDR}
```
```
cat <<EOF > exporter.sql
CREATE USER 'exporter'@'%' IDENTIFIED BY 'exporter' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';
FLUSH PRIVILEGES;
EOF
```

mysql 에 로그인해서 exporter.sql 을 실행한다. root 패스워드는 admin22admin 이다.
```
mysql -u root -p -h ${DB_ADDR} < exporter.sql
```

생성된 exporter 계정정보를 조회한다.
```
mysql -u root -p -h ${DB_ADDR}
```
```
MySQL [mysql]> use mysql;
MySQL [mysql]> select host, user, account_locked, select_priv from user;
+---------------------------------------------------------------+------------------+----------------+-------------+
| host                                                          | user             | account_locked | select_priv |
+---------------------------------------------------------------+------------------+----------------+-------------+
| %                                                             | exporter         | N              | Y           |
| %                                                             | root             | N              | Y           |
| localhost                                                     | mysql.infoschema | Y              | Y           |
| localhost                                                     | mysql.session    | Y              | N           |
| localhost                                                     | mysql.sys        | Y              | N           |
| localhost                                                     | rdsadmin         | N              | Y           |
+---------------------------------------------------------------+------------------+----------------+-------------+
8 rows in set (0.000 sec)
```

### MySQL Exporter 설치 ###
exporter ec2 인스턴스에 설치한다. 
```
$ netstat -ln | grep mysql
unix  2      [ ACC ]     STREAM     LISTENING     72883    /var/lib/mysql/mysql.sock
```
```
MYSQL_EXPORTER_VERSION=0.15.0
wget https://github.com/prometheus/mysqld_exporter/releases/download/v${MYSQL_EXPORTER_VERSION}/mysqld_exporter-${MYSQL_EXPORTER_VERSION}.linux-amd64.tar.gz

tar xvfz mysqld_exporter-*.*-amd64.tar.gz
cd mysqld_exporter-*.*-amd64

cat <<EOF > my.cnf
[client]
#socket=/var/lib/mysql/mysql.sock
user=exporter
password=exporter
EOF
```

mysql exporter 를 실행한다. (9104 Listen)
```
./mysqld_exporter \
--mysqld.address="${DB_ADDR}:3306" \
--config.my-cnf="./my.cnf" \
--web.listen-address=0.0.0.0:9104 \
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
--collect.slave_hosts
```

curl 을 이용하여 메트릭이 수집되는지 확인한다. 
```
curl http://localhost:9104/metrics
```

[결과]
```
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:220 level=info msg="Starting mysqld_exporter" version="(version=0.15.0, branch=HEAD, revision=6ca2a42f97f3403c7788ff4f374430aa267a6b6b)"
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:221 level=info msg="Build context" build_context="(go=go1.20.5, platform=linux/amd64, user=root@c4fca471a5b1, date=20230624-04:09:04, tags=netgo)"
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:233 level=info msg="Scraper enabled" scraper=global_status
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:233 level=info msg="Scraper enabled" scraper=global_variables
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:233 level=info msg="Scraper enabled" scraper=slave_status
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:233 level=info msg="Scraper enabled" scraper=info_schema.innodb_cmp
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:233 level=info msg="Scraper enabled" scraper=info_schema.innodb_cmpmem
ts=2023-09-05T13:28:41.975Z caller=mysqld_exporter.go:233 level=info msg="Scraper enabled" scraper=info_schema.query_response_time
ts=2023-09-05T13:28:41.976Z caller=tls_config.go:274 level=info msg="Listening on" address=[::]:9104
ts=2023-09-05T13:28:41.976Z caller=tls_config.go:277 level=info msg="TLS is disabled." http2=false address=[::]:9104
```

아래와 같이 systemd 에 서비스로 등록한다.
```
sudo cat <<EOF > /etc/systemd/system/mysql-exporter.service
[Unit]
Description=Prometheus MySQL Exporter
After=network.target
User=ec2-user
Group=ec2-user

[Service]
Type=simple
Restart=always
ExecStart=/home/ec2-user/mysqld_exporter-0.15.0.linux-amd64/mysqld_exporter \
--config.my-cnf=/home/ec2-user/mysqld_exporter-0.15.0.linux-amd64/my.cnf \
--web.listen-address=0.0.0.0:9104 \
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
--collect.slave_hosts

[Install]
WantedBy=multi-user.target
EOF
```

```
sudo systemctl daemon-reload
sudo systemctl start mysql-exporter
sudo systemctl enable mysql-exporter
sudo systemctl status mysql-exporter
```

### 프로메테우스 설치 ###
eks_mysql_exporter ec2 인스턴스에 프로메테우스 최신 버전을 설치한다. [prometheus release](https://prometheus.io/download/)
```
PROMETHEUS_VERSION=2.46.0
cd ~
curl -LO https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar xvfz prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
cd prometheus-${PROMETHEUS_VERSION}.linux-amd64
```

AMP 주소를 확인하고, 로컬 프로메테우스 설정을 변경하여 실행한다.
```
WORKSPACE_ID=$(aws amp list-workspaces --alias eks-workshop | jq '.workspaces[0].workspaceId' -r)
AMP_ENDPOINT_URL=$(aws amp describe-workspace --workspace-id $WORKSPACE_ID | jq '.workspace.prometheusEndpoint' -r)
AMP_REMOTE_WRITE_URL=${AMP_ENDPOINT_URL}api/v1/remote_write
AWS_REGION=ap-northeast-2
```

기존 prometheus.yaml 을 아래의 설정으로 대체한다.
```
cat <<EOF > prometheus.yml
global:
  scrape_interval: 15s
  external_labels:
    monitor: 'prometheus'

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9104']

remote_write:
  -
    url: ${AMP_REMOTE_WRITE_URL}
    queue_config:
        max_samples_per_send: 1000
        max_shards: 200
        capacity: 2500
    sigv4:
         region: ${AWS_REGION}
EOF
```

```
./prometheus --config.file=prometheus.yml
```

[결과]
```
ts=2023-09-05T04:12:08.445Z caller=main.go:541 level=info msg="No time or size retention was set so using the default time retention" duration=15d
ts=2023-09-05T04:12:08.445Z caller=main.go:585 level=info msg="Starting Prometheus Server" mode=server version="(version=2.46.0, branch=HEAD, revision=cbb69e51423565ec40f46e74f4ff2dbb3b7fb4f0)"
ts=2023-09-05T04:12:08.445Z caller=main.go:590 level=info build_context="(go=go1.20.6, platform=linux/amd64, user=root@42454fc0f41e, date=20230725-12:31:24, tags=netgo,builtinassets,stringlabels)"
ts=2023-09-05T04:12:08.445Z caller=main.go:591 level=info host_details="(Linux 6.1.41-63.114.amzn2023.x86_64 #1 SMP PREEMPT_DYNAMIC Tue Aug  1 20:47:25 UTC 2023 x86_64 ip-10-1-2-79.ap-northeast-2.compute.internal (none))"
ts=2023-09-05T04:12:08.445Z caller=main.go:592 level=info fd_limits="(soft=65535, hard=65535)"
ts=2023-09-05T04:12:08.445Z caller=main.go:593 level=info vm_limits="(soft=unlimited, hard=unlimited)"
ts=2023-09-05T04:12:08.446Z caller=web.go:563 level=info component=web msg="Start listening for connections" address=0.0.0.0:9090
ts=2023-09-05T04:12:08.446Z caller=main.go:1026 level=info msg="Starting TSDB ..."
ts=2023-09-05T04:12:08.448Z caller=tls_config.go:274 level=info component=web msg="Listening on" address=[::]:9090
ts=2023-09-05T04:12:08.448Z caller=tls_config.go:277 level=info component=web msg="TLS is disabled." http2=false address=[::]:9090
ts=2023-09-05T04:12:08.450Z caller=head.go:595 level=info component=tsdb msg="Replaying on-disk memory mappable chunks if any"
ts=2023-09-05T04:12:08.450Z caller=head.go:676 level=info component=tsdb msg="On-disk memory mappable chunks replay completed" duration=1.612µs
ts=2023-09-05T04:12:08.450Z caller=head.go:684 level=info component=tsdb msg="Replaying WAL, this may take a while"
ts=2023-09-05T04:12:08.451Z caller=head.go:755 level=info component=tsdb msg="WAL segment loaded" segment=0 maxSegment=2
ts=2023-09-05T04:12:08.451Z caller=head.go:755 level=info component=tsdb msg="WAL segment loaded" segment=1 maxSegment=2
ts=2023-09-05T04:12:08.451Z caller=head.go:755 level=info component=tsdb msg="WAL segment loaded" segment=2 maxSegment=2
ts=2023-09-05T04:12:08.451Z caller=head.go:792 level=info component=tsdb msg="WAL replay completed" checkpoint_replay_duration=20.396µs wal_replay_duration=462.178µs wbl_replay_duration=137ns total_replay_duration=513.279µs
ts=2023-09-05T04:12:08.452Z caller=main.go:1047 level=info fs_type=XFS_SUPER_MAGIC
ts=2023-09-05T04:12:08.452Z caller=main.go:1050 level=info msg="TSDB started"
ts=2023-09-05T04:12:08.452Z caller=main.go:1231 level=info msg="Loading configuration file" filename=prometheus.yml
ts=2023-09-05T04:12:08.455Z caller=dedupe.go:112 component=remote level=info remote_name=b253e1 url=https://aps-workspaces.ap-northeast-2.amazonaws.com/workspaces/ws-a7486aec-8f79-4cf0-84a7-7d2715e86ef6/api/v1/remote_write msg="Starting WAL watcher" queue=b253e1
ts=2023-09-05T04:12:08.455Z caller=dedupe.go:112 component=remote level=info remote_name=b253e1 url=https://aps-workspaces.ap-northeast-2.amazonaws.com/workspaces/ws-a7486aec-8f79-4cf0-84a7-7d2715e86ef6/api/v1/remote_write msg="Starting scraped metadata watcher"
ts=2023-09-05T04:12:08.455Z caller=dedupe.go:112 component=remote level=info remote_name=b253e1 url=https://aps-workspaces.ap-northeast-2.amazonaws.com/workspaces/ws-a7486aec-8f79-4cf0-84a7-7d2715e86ef6/api/v1/remote_write msg="Replaying WAL" queue=b253e1
ts=2023-09-05T04:12:08.458Z caller=main.go:1268 level=info msg="Completed loading of configuration file" filename=prometheus.yml totalDuration=5.773867ms db_storage=767ns remote_storage=2.516235ms web_handler=270ns query_engine=483ns scrape=3.032784ms scrape_sd=17.958µs notify=824ns notify_sd=2.18µs rules=1.439µs tracing=6.566µs
ts=2023-09-05T04:12:08.458Z caller=main.go:1011 level=info msg="Server is ready to receive web requests."
ts=2023-09-05T04:12:08.458Z caller=manager.go:1009 level=info component="rule manager" msg="Starting rule manager..."
```

### AMG 대시보드 설정 ###

##### // 7362 #####
![](https://github.com/gnosia93/eks-on-aws/blob/main/images/prometheus-mysql.png)


## 트러블 슈팅 ##

* err="region not configured in sigv4 or in default credentials chain"   
-> 프로메테우스 prometheus.yml 파일의 sigv4 설정을 확인한다.

## 레퍼런스 ##

* https://velog.io/@sojukang/%EC%84%B8%EC%83%81%EC%97%90%EC%84%9C-%EC%A0%9C%EC%9D%BC-%EC%89%AC%EC%9A%B4-Prometheus-Grafana-%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81-%EC%84%A4%EC%A0%95-MySQL%ED%8E%B8

* https://grafana.com/oss/prometheus/exporters/mysql-exporter/?tab=installation

* https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-onboard-ingest-metrics-remote-write-EC2.html

* https://prometheus.io/docs/prometheus/latest/getting_started/

* https://dev.classmethod.jp/articles/try-creating-an-iam-role-in-aws-cli/

* https://aws.amazon.com/blogs/security/new-attach-an-aws-iam-role-to-an-existing-amazon-ec2-instance-by-using-the-aws-cli/

* [MySQL Exporter - Prometheus 연동](https://velog.io/@zihs0822/MySQL-Exporter-Prometheus-%EC%97%B0%EB%8F%99)

* https://chhanz.github.io/linux/2019/01/18/linux-how-to-create-custom-systemd-service/

