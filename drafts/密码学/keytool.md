[参考1](https://zhuanlan.zhihu.com/p/56948979) 、 [参考2](https://www.chinassl.net/ssltools/keytool-commands.html)


# 步骤
## 创建私钥库

```
keytool -genkey -alias privatekey -keysize 1024 -keystore privateKeys.store -validity 3650
```

## 导出本地证书

## 导入