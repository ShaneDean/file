# 前言

分析ovirt-engine服务配置启动的过程


# install phase


Makefile target
```
install-packaging-files:
    copy-recursive service\*  => 

```

## production mode install

spec文件中有这么一段代码

```
for service in ovirt-engine ovirt-engine-notifier ovirt-fence-kdump-listener ovirt-websocket-proxy; do
    cp ${service}.systemd   %{_unitdir}【等于/usr/lib/systemd/system】/${serviec}.service
done
```
表明 ovirt-engine.service注册到了系统中,可以通过 systemctl ${service} start/stop/restart/status来控制

[systemd_home](https://www.freedesktop.org/wiki/Software/systemd/),[systemd1](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-commands.html),[systemd2](http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html)


## development mode install



# config setup phase

## first time setup

## upgrade setup

# service start phase

## systemd

ovirt-engine.systemd

```
...
After=network.target postgresql.service
...
ExecStart=${PREFIX}/share/ovirt-engine/services/ovirt-engine/ovirt-engine.py --redirect-output --systemd=notify $EXTRA_ARGS start
EnvironmentFile=-/etc/sysconfig/ovirt-engine
...
```
 
```
    ovirt-engine.py start =>  java  -jar \"$JBOSS_HOME/jboss-modules.jar\" \
                                    -mp \"${JBOSS_MODULEPATH}\" \
                                    org.jboss.as.standalone 
```
[wildfly standalone setup](http://ksoong.org/jboss/2015/04/07/wildfly-standalone/)
## ovirt-engine in wildfly



