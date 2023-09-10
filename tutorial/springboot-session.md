
```
mysql -u shop -p shop@
insert into member(password, name, phone_no, email_addr) values('admin', 'admin', '000-000-0000', 'admin@shop.com');
commit;
```


create table member( 
     member_id     int not null auto_increment, 
     password      char(30) not null, 
     name          char(60) not null, 
     phone_no      char(30) not null, 
     email_addr    char(30) not null, 
     PRIMARY KEY(member_id) 
);

## 레퍼런스 ##

* https://chb2005.tistory.com/173
