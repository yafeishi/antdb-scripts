#!/usr/bin/env python
# -*- coding: UTF-8 -*-

import psycopg2
import sys
import pprint

#adb_conn="dbname=postgres user=dang31 password=123 host=10.11.6.20 port=17322"
adb_conn="dbname=postgres user=dang31 password=123 host=10.1.226.201 port=17613"
pg962_conn="dbname=postgres user=danghb password=123 host=10.21.16.14 port=7632"

#conn = psycopg2.connect(database="postgres", user="dang31", password="123", host="10.1.226.201", port="17613")

#conn = psycopg2.connect("dbname=postgres user=sh2.2 password=123 host=10.1.226.201 port=17322")


#host=localhost port=5432 dbname=mydb user=postgres password=123456"


try:
   conn = psycopg2.connect(adb_conn)
except psycopg2.Error as e:
    print"Unable to connect!"
    print e.pgerror
    print e.diag.message_detail
    sys.exit(1)
else:
    print"Connected!"    
#conn = psycopg2.connect(database="postgres", user="dang31", password="123", host="10.1.226.201", port="17613")
    cur = conn.cursor()
#该程序创建一个光标将用于整个数据库使用Python编程。
print ("version:")
cur.execute("select version();")  
rows = cur.fetchall()
pprint.pprint(rows)
print ("create  table")
cur.execute("create table t_test (id int,name text);")   
print ("insert into table")
cur.execute("insert into t_test (id,name) values (%s,%s)",(1,'a'))
cur.statusmessage
cur.execute("insert into t_test (id,name) values (%s,%s)",(3,'b')) 
cur.mogrify("insert into t_test (id,name) values (%s,%s)",(3,'b')) 
cur.execute("select * from t_test;")
print ("fetchone")
row = cur.fetchone()
pprint.pprint(row)
cur.execute("select * from t_test;")
rows = cur.fetchall()
print ("fetchall")
pprint.pprint(rows)
print ("delete from table")
cur.execute("delete from t_test where id=%s",(3,)) 
cur.execute("select * from t_test;")
rows = cur.fetchall()
pprint.pprint(rows)
print ("update  table")
cur.execute("update  t_test set name=%s where id=%s",('c',1)) 
cur.execute("select * from t_test;")
rows = cur.fetchall()
pprint.pprint(rows)
print ("change share key  ")
cur.execute("alter table t_test distribute by hash(name) ");
print ("drop  table")
cur.execute("drop table if EXISTS  t_test ");

conn.commit()
#connection.commit() 此方法提交当前事务。如果不调用这个方法，无论做了什么修改，自从上次调用#commit()是不可见的，从其他的数据库连接。
conn.close() 
#connection.close() 此方法关闭数据库连接。请注意，这并不自动调用commit（）。如果你只是关闭数据库连接而不调用commit（）方法首先，那么所有更改将会丢失