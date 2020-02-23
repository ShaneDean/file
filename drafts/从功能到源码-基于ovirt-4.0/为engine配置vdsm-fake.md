# 前言

应用vdsm-fake来为engine mock数据。

# 准备环境

准备ovirt-engine+vdsm-fake两台，配置完ovirt-enigne开发环境之后。

修改db，配置项来调过增加vds之后的安装工作
``` shell
vdc_options[InstallVds] = false
vdc_options[UseHostNameIdentifier] = true
vdc_options[HostPackagesUpdateTimeInHours] = 0
```




在vdsm-fake机器上，执行

```bash
cer_req_name="vdsmfake"

gass=123456
pkidir=/etc/pki/vdsmfake
keys="$pkidir/keys"
requests="$pkidir/requests"
mkdir -p "$keys" "$requests"
chmod 700 "$keys"

key="$keys/$cer_req_name.key"
req="$requests/$cer_req_name.req"

openssl genrsa -out "$key" -passout "pass:$pass" -des3 2048
openssl req -new -days 365 -key "$key" -out "$req" -passin "pass:$pass" -passout "pass:$pass" -batch -subj "/"

scp $req <ovirt_user>@<ovirt-engine-devel>/<dev-dir>/etc/pki/ovirt-engine/requests/
```
注意

-   ovirt_user          ： 你的开发机器的用户
-   ovirt-engine-devel  ： 你的开发机器的ip
-   dev-dir             :  engine 中 make install-dev 中的Prefix指定的路径


在 ovirt-engine 机器上

```bash
cer_req_name=vdsmfake
domain=test.test.com

# Whatever you want
subject="/C=US/O=$domain/CN=something.$domain"
PKIDIR=/home/nss/runtime/ovirt4.3/etc/pki/ovirt-engine
export PKIDIR
<dev-dir>/share/ovirt-engine/bin/pki-enroll-request.sh --name=$cer_req_name --subject=$subject

#The cert will be created in /etc/pki/ovirt-engine/certs/$cer_req_name.cer .

```

# 启动项目
在vdsm-fake机器上

```
git clone https://gerrit.ovirt.org/ovirt-vdsmfake

cd ovirt-vdsmfake

mvn clean install

mvn wildfly-swarm:package

java -jar target/vdsmfake-swarm.jar


```


# 创建fake host name


```bash
sudo -i
for i in `seq 0 10`; do echo 127.0.0.1 test$i >> /etc/hosts; done
```

Use `dnsmasq` for a more dynamic approach to make every X.vdsm.simulator resolve to an IP:

```bash
dnsmasq --address=/vdsm.simulator/127.0.0.1
```

Add 127.0.0.1 as a dns server:
```bash
cat /etc/resolv.conf
nameserver 127.0.0.1
```
如果是桌面版本，请直接在图形界面中增加dns， 然后
```
systemctl restart NetworkManager
```


# 增加fake host
在engine-dev机器上

```bash
function add_host {
  xml="<host><name>$2</name><address>$2</address><root_password>test</root_password></host>"
  curl -H "Accept: application/json" -H "Content-type: application/xml" -X POST --user $1 http://localhost:8080/ovirt-engine/api/hosts --data "$xml"
}

for i in `seq 0 10`; do add_host admin@internal:password test$i; done
```



# 注意

如果出现依赖找不到，在settings.xml中增加 jboss mirror
```xml
    <mirror>    
      <id>jboss-public-repository-group</id>    
      <mirrorOf>central</mirrorOf>    
      <name>JBoss Public Repository Group</name>    
      <url>http://repository.jboss.org/nexus/content/groups/public</url>    
    </mirror> 
```

当前执行通过的maven版本是3.5


执行 **dnsmasq --address=/vdsm.simulator/127.0.0.1** 时候报端口53被占用。

    netstat -tupln 


因为本机安装了libvirtd服务，它会使用dnsmasq，从而占用 53端口。



```
virsh net-list
virsh net-destory [name]
systemctl stop libvirtd
```

