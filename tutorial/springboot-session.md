
### admin 유저 생성 ###
cloud9 터미널에서 아래 명령어를 수행한다. 
```
STAGE_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-stage`].Endpoint.Address' --output text)
PROD_DB=$(aws rds describe-db-instances --query 'DBInstances[?DBInstanceIdentifier == `eks-mysql-prod`].Endpoint.Address' --output text)

DB_ADDR=${STAGE_DB}
echo ${DB_ADDR}

mysql -u shop -p -h ${DB_ADDR}
```

```
use shop;
insert into member(password, name, phone_no, email_addr) values('admin', 'admin', '000-000-0000', 'admin@shop.com');
commit;
select member_id, password, email_addr from shop where email_addr = 'admin@shop.com';
```

### build.gradle ###

```

```


## 레퍼런스 ##

* https://chb2005.tistory.com/173
* https://stir.tistory.com/256
