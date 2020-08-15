# lm2部署

安装centos7

```shell
yum install java-1.8.0-openjdk
rpm -Uvh https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm

yum install -y postgresql10-server


# 根据具体版本下载
wget http://172.16.6.189/pub/pkg_output/ks-others/LicenseManager-2.0/backend-v2.x.x-[XXXX].jar


/usr/pgsql-10/bin/postgresql-10-setup initdb
cd /var/lib/pgsql/10/data/
vi pg_hba.conf
```

![image-20200319144901301](C:\Users\thepa\AppData\Roaming\Typora\typora-user-images\image-20200319144901301.png)

```shell
systemctl restart postgresql-10
systemctl enable postgresql-10
su postgres
psql
	create user license password 'license';
	create database lm2 owner license template template0 encoding 'UTF-8';
	\q
exit
cd -

java -Dspring.datasource.url="jdbc:postgresql://127.0.0.1:5432/lm2" -Dspring.datasource.username="license" -Dspring.datasource.password="license" server.port=8888 -jar backend-v2.x.x-[XXXX].jar

```

