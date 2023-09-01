## 로컬 PC에 MySQL 설치 ##  

```
brew install mysql
mysql -V
```

mysql 데이터베이스의 보안 설정 강화를 위해 아래 명령어를 실행한다.
```
mysql_secure_installation
```

위 명령어를 결과 화면에서 아래의 예제와 같이 입력한다. brew 로 설치한 후 최초 실행시 mysql 의 root 패스워드는 root 이다. 아래의 예제에서 보이는 것처럼 admin22admin 으로 root 패스워드를 변경한다.
```
Securing the MySQL server deployment.

Enter password for user root:                    <------------ root 입력

VALIDATE PASSWORD COMPONENT can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD component?

Press y|Y for Yes, any other key for No: n
Using existing password for root.
Change the password for root ? ((Press y|Y for Yes, any other key for No) : y

New password:                        <-------------- admin22admin 입력

Re-enter new password:               <-------------- admin22admin 입력
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : y
Success.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : y
Success.

By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : y
 - Dropping test database...
Success.

 - Removing privileges on test database...
Success.

Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : y
Success.

All done!
```

```
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
     password      char(30) not null, 
     name          char(60) not null, 
     phone_no      char(30) not null, 
     email_addr    char(30) not null, 
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

## RDS MySQL 스키마 생성 ##

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
     password      char(30) not null, 
     name          char(60) not null, 
     phone_no      char(30) not null, 
     email_addr    char(30) not null, 
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

## 로컬 PC MySQL 삭제 ##

```
brew services stop mysql
brew uninstall mysql
rm -rf /usr/local/var/mysql
rm /usr/local/etc/my.cnf
```



## 레퍼런스 ##

* [mac mysql 설치](https://eunhee-programming.tistory.com/262)

