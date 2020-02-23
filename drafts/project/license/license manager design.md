# todo
-   汉化de.schlichtherle.license
-   解析properties文件的名称和实际要调整

明确属于某个产品的checker，没有特定的输入某个产品的checker代码
思考 如何通过配置信息强制约束代码的调用行为。


# properties

keystorePath = /xxxx/[user-id].pub_ks
licensepath = /xxxx/license.lic
alias = [product-id]   //省略
storepass = [customer-pass]
subject=
cipher= ""


## 步骤

1、管理员创建客户 ->   storepass
2、 管理员创建产品    ->     加解密的lic     prikey + pubkey （cipher） 
3、 客户创建产品版本  ->   明确产品    alias   ，  增加控制参数的 key    ,  生成开发的check.jar + 增加key.pub

公玥库密码
产品别名-alias   --  公玥库内 pubkey的别名 
产品的控制参数 的key


=》 使用jar


创建 证书时候 确定  cipher 






4、 客户创建用户      ->    客户subject  , 没有客户则是默认的 名称（用于开发）
5、 客户生成 证书     ->   增加extracontent中的 value
6、 运维下载证书


## 开发者

1、自己设计 控制参数
2、写完控制参数对应的predicate代码
3、需要一个zip包   ->   在LM中是customer -> 创建产品 ->定义版本  (控制参数 按照设计的定义 ) |->  生成license文件  确定value 
4、用下载的zip进行测试 、 完成
5、生成部署使用的license文件 部署


A-zip-1.0-dev 
A-zip-1.0-prod 

A-zip-2.0-dev
A-zip-2.0-prod


相同：  
控制参数 - key
公玥库密码


不同：
控制参数 - value
公私玥  cipher  - 密码


无所谓：

公玥库内密钥名称 alias



A-zip-dev
B-zip-dev

A-zip-1.0-prod-a
A-zip-1.0-prod-b
A-zip-1.0-dev

控制参数-参数key不一样
alias = [licenseid] 
extra content  =>   value

相同
storepass 
cipher
extra content => key
code


## license exception

LicenseException
-   LicenseContentException



# 步骤逻辑

产品和DEV 拥有 master key （每次相同）

license.lic文件 每次生产 使用 session key （每次不同）

加密 licenseContent的 CEK

每次加密 session Key的 KEK

LM 私有A 公钥B

某产品 私钥 X  公钥 Y

某证书  密钥 K

客户使用 生成 一次性 密码 P

LM  用 一次性密码 P 生产 密钥 K

证书由 密钥 K 加密  LicenseContent内容

LM  使用 私钥A  对 密钥K 进行 加密

LM  使用 产品 公钥 Y 对 证书 进行 摘要

LM 用私钥 A 对证书的摘要 进行数字签名



DEV  使用 LM 公钥Y  对 数字进行验证 

DEV  使用  产品 私钥 X 对 证书摘要 进行验证

DEV  使用 LM 公钥B 解密 密钥K 



## 要求

product-dev-checker.jar
-   确定这个证书是 LM 发布的
-   确定这个证书没有被修改过
-   用来解密证书的内容的密钥 应该是临时的
-   产品的开发环境下 不包含私有密钥  可以包含产品的公钥和LM的公钥
-   不同的产品的dev包应该不能共享？


dev 使用LM的公钥来确定 是 LM发布的
dev 使用一次性密钥来确认内容是没有被篡改的
dev 使用一次性密钥来解密 LM的内容

dev 拥有 LM的公钥  

需要 每次激活提供 license.lic + signature  + 一次性密钥

Customer 使用口令生成 一次性密钥
LM 用一次性口令来加密 license的Content => license.lic
LM 用一次性口令来加密 license的Content的摘要  => signature
LM 使用LM的私钥来对 signature进行数字签名






//dev 使用产品的公钥来解密  license的content的内容
//dev 使用一次性密钥来解密  临时 私钥 ，使用临时私钥来 确定 这个

