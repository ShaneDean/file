# 前言

本文是对《[图解密码技术](https://item.jd.com/11942019.html)》厚到薄的阅读总结。

# 密码学家的6个工具箱
- 对称密码
    - 通过相同的密钥来对目标信息进行加密解密
    - 加密解密的过程就是执行异或操作，因为第一次执行异或操作等于加密，第二次执行异或操作等于解密。
    - 密码算法可以分为分组密码和流密码两种：流密码是对一串数据进行连续处理，因此需要保持内部状态（一次性密码）；而分组密码处理完一个分组就结束了了，不需要通过内部状态来记录加密的进度（DES、三重DES、AES）。
    - 分组密码迭代的方法就是分组密码的模式，包括ECB、CBC、CFB、OFB、CTR。

对称密码是一种用相同的密钥进行加密和解密的技术，用于确保消息的机密性。在对称密码的算法方面，目前主要使用的是AES。尽管对称密码能够确保消息的机密性，但需要解决将解密密钥配送给接收者的密钥配送问题。

- 公钥密码
    - 公钥用来加密，私钥用来解密。
    - 公钥密码的运行速度远远低于对称密码，一般的通信过程会组合使用公钥密码和私钥。
    - 对称密码用来加解密数据，公钥密码用来传输对称密钥。
    - 使用接收者的公钥来加密对称密钥并发送；只有接收者拥有该公钥对应的私钥并能成功解密获得对称密钥。

公钥密码是一种用不同的密钥进行加密和解密的技术，和对称密码一样用于确保消息的机密性。使用最广泛的一种公钥密码算法RSA。和对称密码相比，公钥密码的速度非常慢，因此一般会和对称密码组合成混合密码系统来使用。公钥密码能够解决对称面中的密钥交换的问题，但存在通过中间人攻击被伪装的风险，因此需要对带有数字签名的公钥进行认证

- 单向散列函数
    - 输入消息和输出散列值，单向散列函数所输出的散列值的长度是固定的。
    - 具备抗碰撞性、具备单向性、

单向散列函数是一种将长消息转换为短散列值的技术，用于保证消息的完整性。目前广泛使用SHA-2，存在全新结构的SHA-3算法。单向散列函数可以单独使用，也可以用作消息认证码、数字签名以及伪随机数生成器等技术的组成元素来使用。

- 消息认证码
    - 消息认证码的输入包括任意长度的消息和一个发送者与接收者之间共享的密钥，他可以输出固定长度的值，这个数据称为MAC值
    - 是一种与密钥相关的单向散列函数
    - 确保不能根据MAC值来推测出双方通信的密钥

消息认证码时一种能够识别通信对象发送的消息是否被篡改的认证技术，用于验证消息的完整性，以及对消息进行认证。消息认证码能够对通信对象进行认证，但无法对第三方进行认证。

- 数字签名
    - 用私钥加密来生成签名，用公钥解密来验证签名。
    - 签名针对单向散列函数的散列值。
    - 这里用来代表一种只有只有该密钥的人才能够生成的信息。

数字签名是一种能够对第三方进行消息认证，并能够防止通信对象作出否认的认证技术。公钥基础设施（PKI）中使用的证书，技术在对公钥加上认证机构的数字签名所构成的。需要验证公钥的数字签名，需要通过某种途径获取认证机构自身的合法公钥。

- 伪随机数生成器
    - 随机数性质分为：随机性、不可预测性、不可重现性。逐步严格。分别命名为弱伪随机数、强伪随机数和真随机数。
    - 根据传感器收集的热量、声音的变化等事实上无法预测和重现的自然现象来生产的随机数列的硬件被称为随机数生成器
    - 生成随机数的软件称为伪随机数生成器。
    - 伪随机数生成器具有内部状态，需要种子（seed）来进行内部的初始化。
    - java.util.Random不能用于安全相关用途，使用java.security.SecureRandom的类。

随机数生成器是一种能够生成不可预测的比特序列的技术，由密码和单向散列函数技术构成。伪随机数生成器用于生成密钥、初始化向量和nonce（用于避免重放攻击只是用一次的数字）等

这些工具箱的作用如下图

![作用](https://github.com/ShaneDean/file/blob/master/blog/sec/sec_threaten_and_cryptographic_technique.png?raw=true)

![工具箱](https://github.com/ShaneDean/file/blob/master/blog/sec/sec-tool-kit.png?raw=true)



# 对比

对称密码和公钥密码的对比

\  | 对称密码 | 公钥密码
---|---|---
**发送者** | 共享密钥加密 | 用公钥加密
**接收者** | 共享密钥解密   | 用私钥解密
**密钥配送问题** | 存在   | 不存在，单公钥需要另外认证
**机密性** | 满足   | 满足

公钥密码和数字签名的对比

\  | 私钥 | 公钥
---|---|---
**公钥密码** | 接收者解密时候使用 | 发送者加密时候使用
**数字签名** | 签名者生成签名时使用   | 验证者验证签名时使用
**谁持有密钥**？ | 个人持有 | 任何人都可以持有

消息认证码和数字签名对比

\  | 消息认证码 | 数字签名
---|---|---
**发送者** | 用共享密钥计算MAC值 | 用私钥生成签名
**接收者** | 用共享密钥计算MAC值   | 用公钥验证签名
**密钥配送问题** | 存在   | 不存在，单公钥需要另外认证
**完整性** | 满足   | 满足
**认证** | 满足（仅限通信双方）   |  满足（可使用于任何第三方）
**防止否认** | 不满足   | 满足


# 其他

## 证书  

证书是用来对公钥的合法性进行证明的技术。 公钥证书包含姓名、组织、邮箱、地址等个人星系，以及属于此人的公钥，并由认证机构追加数字签名。

认证机构是能够认定“公钥确实属于此人”并能够生成数字签名的个人活组织。认证机构中有国际性组织和政府设立的组织，也有通过提供认证服务来盈利的一般企业。

证书标准规范：X.509


## PKI

公钥基础设施（Public-Key Infrastructure)是为了能够更好地运用公钥而制定的一些列规范和规格的总称。

主要包含3个要素：用户（使用PKI的人）、认证机构（颁发证书的人）、仓库（保存证书的数据库）

关系如下：

![pki元素](https://github.com/ShaneDean/file/blob/master/blog/sec/sec_elements_of_pki.png?raw=true)


## 密钥

密钥就是一个十分巨大的数字，密钥空间是密钥的长度，它的大小决定了可能出现的密钥的总数量和暴力破解的难度。

密钥和明文是等价的。

生成密钥的最好方法是使用随机数。密码学用途的伪随机数生成器必须专门针对密码学用途而设计。

## PGP
提供现代密码软件所必需的几乎全部所有功能，如：对称密码、公钥密码、数字签名、单向散列函数、证书、压缩、文本和二进制转换、大文件的拆分与合并、钥匙串管理。