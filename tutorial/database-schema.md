### DB 스키마 생성 ###

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

% mysql -u shop -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 13
Server version: 8.0.33 MySQL Community Server - GPL

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| performance_schema |
| shop               |
+--------------------+
3 rows in set (0.00 sec)

mysql> use shop;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+----------------+
| Tables_in_shop |
+----------------+
| member         |
+----------------+
1 row in set (0.01 sec)
```    
