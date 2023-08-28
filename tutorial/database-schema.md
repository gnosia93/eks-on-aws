### 로컬 PC에 MySQL 설치 ###  

유저는 root 이고, 패스워드는 admin22admin 으로 입력한다.
```
% brew install mysql
% mysql -V
mysql  Ver 8.1.0 for macos12.6 on arm64 (Homebrew)

% mysql_secure_installation
% ps aux | grep mysql
_mysql           51995   0.1  0.7 410164160 443200   ??  Ss    7:40PM   0:01.80 /usr/local/mysql/bin/mysqld --user=_mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --plugin-dir=/usr/local/mysql/lib/plugin --log-error=/usr/local/mysql/data/mysqld.local.err --pid-file=/usr/local/mysql/data/mysqld.local.pid --keyring-file-data=/usr/local/mysql/keyring/keyring --early-plugin-load=keyring_file=keyring_file.so
```

#### 로컬 DB 스키마 생성 ####
```
% mysql -u root -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.33 MySQL Community Server - GPL

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database shop;
mysql> use shop;
mysql> create table member( 
     member_id     int not null auto_increment, 
     password      char(12) not null, 
     name          char(10) not null, 
     phone_no      char(13) not null, 
     email_addr    char(32) not null, 
     PRIMARY KEY(member_id) 
);
mysql> show tables;
+----------------+
| Tables_in_shop |
+----------------+
| member         |
+----------------+
1 row in set (0.01 sec)

mysql> create user shop@'%' identified by 'shop';
Query OK, 0 rows affected (0.01 sec)

mysql> use mysql;
mysql> select host, user, account_locked from user;
+-----------+------------------+----------------+
| host      | user             | account_locked |
+-----------+------------------+----------------+
| %         | shop             | N              |
| localhost | mysql.infoschema | Y              |
| localhost | mysql.session    | Y              |
| localhost | mysql.sys        | Y              |
| localhost | root             | N              |
+-----------+------------------+----------------+
5 rows in set (0.00 sec)

mysql> grant all privileges ON shop.* TO shop@'%';
mysql> quit
Bye
```

### Stage / Production DB 스키마 생성 ###

stage, production 용 데이터베이스에 접속해서 유저 및 관련 테이블을 생성한다. 
cloud9 터미널을 이용하여 설치하고, root 패스워드는 admin22admin 이다. 
```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
```

DB_ADDR 를 ${STAGE_DB}, ${PROD_DB} 각각으로 설정하고 아래의 SQL 을 실행한다.
```
$ mysql -u root -p -h ${DB_ADDR}

Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 10
Server version: 8.0.33 MySQL Community Server - GPL

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> create database shop;
mysql> use shop;
mysql> create table member( 
     member_id     int not null auto_increment, 
     password      char(12) not null, 
     name          char(10) not null, 
     phone_no      char(13) not null, 
     email_addr    char(32) not null, 
     PRIMARY KEY(member_id) 
);
mysql> show tables;
+----------------+
| Tables_in_shop |
+----------------+
| member         |
+----------------+
1 row in set (0.01 sec)

mysql> create user shop@'%' identified by 'shop';
Query OK, 0 rows affected (0.01 sec)

mysql> use mysql;
mysql> select host, user, account_locked from user;
+-----------+------------------+----------------+
| host      | user             | account_locked |
+-----------+------------------+----------------+
| %         | shop             | N              |
| localhost | mysql.infoschema | Y              |
| localhost | mysql.session    | Y              |
| localhost | mysql.sys        | Y              |
| localhost | root             | N              |
+-----------+------------------+----------------+
5 rows in set (0.00 sec)

mysql> grant all privileges ON shop.* TO shop@'%';
mysql> quit
Bye
```


