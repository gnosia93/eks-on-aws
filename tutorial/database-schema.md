### DB 스키마 생성 ###

devel, stage, production 용 데이터베이스에 접속해서 유저 및 관련 테이블을 생성한다. 

```
export DB_ADDR=eks-mysql-stage.czed7onsq5sy.ap-northeast-2.rds.amazonaws.com
```

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


