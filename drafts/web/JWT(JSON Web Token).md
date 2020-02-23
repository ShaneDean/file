# 前言
JSON Web Token （简称JWT）是一种跨域认证解决方案。[标准定义](https://tools.ietf.org/html/rfc7519)。它是用于在两者之间转让、传输的一个袖珍、URL安全的声明(claim)。这个声明在JWT中被解析成了JSON对象，一般作为JSON Web Signature（JWS）的载荷或JSON Web Encryption（JWE）中的文本出现，这样就可以被Message Authentication Code（MAC）或（和）加密进行完整性保护或数字签名。

[参考1](http://www.ruanyifeng.com/blog/2018/07/json_web_token-tutorial.html)[参考2](https://juejin.im/post/5cc5a4766fb9a032321986ad)[参考3](https://blog.fundebug.com/2018/07/12/what-is-jwt/)[官网](https://jwt.io/introduction/)

# 简介

# 结构
jwt 由三部分组成，每个部分通过 **.**来分隔。

- Header
- Payload
- Signature

最后的效果就是

    xxxxx.yyyyy.zzzzz

## header  （xxxxx）
这个部分一般由两部分内容组成

- typ  ： token的类型，一般是 JWT
- alg  ： 签名算法 一般是包括 HMAC\SHA256\RSA

例如：

```JSON
{
  "alg": "HS256",
  "typ": "JWT"
}
```

然后这个JSON对象就会被BASE64URL进行编码成为JWT的第一个部分，也就是 xxxxx的内容

## Payload (yyyyy)

这个部分就是载荷，包含着传输的声明(claims)。

声明(Claims) 是一个包含了实体对象(一般是user)和附加数据的清单

一般有3中类型的声明

- registered ：是一个预定义的非强制但建议的声明集合。包括:
    - iss   : issuer
    - exp   : expiration time
    - sub   : subject
    - aud   : audience
    - others
- public :  可以随便定义，为了避免歧义，建议参考[Specification Required](https://www.iana.org/assignments/jwt/jwt.xhtml)
- private ： 一般用来创建双方的共享信息，不属于registered和public里面的claim

效果如下：

```
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true
}
```

payload也会被BASE64URl编码，放在JWT的第二个部分中，也就是yyyyy部分

## Signature  (zzzzz)

这个签名  需要 编码后的 header \编码后的 payload、密钥(私)、header中的密钥算法来声称。

如果是 HMAC SHA256算法， 效果如下：

```
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret)
```

这个签名用来认证消息没有被修改过，因为token是被private key签名的，所以也能用来认证是谁发送的。

最后这部分也会被 BASE64URL编码， 放在JWT的第三个部分，也就是 zzzzz部分

## 整合起来

xxxxx.yyyyy.zzzzz的内容是由 **.** 分隔的3部分的Base64URL的内容，可以在HTML和HTTP环境中轻松的使用，比基于xml标准的SAML之类的方案简单多了。

下面是一个 例子 

![xx.yy.zz](https://cdn.auth0.com/content/jwt/encoded-jwt3.png)

可以通过 [jwt.io.debugger](https://jwt.io/)来调试

# 使用

在认证中，当用户成功使用他自己的认证信息登录进系统，一个JWT将会被返回。一旦TOKEN认证了，需要提高主义来避免安全问题。一般而言，保留token的时间比需要的时间更长。 当用户需要访问被保护的路径或资源时候，user agent会使用Bearer规则在 Authorization头中传输jwt，效果如下：

```
Authorization: Bearer <token>
```
这是一个无状态的认证机制，服务器通过检查 http 的Authorization中的JWT的有效性来保护route，如果存在，那么用户允许访问被保护的资源。JWT中也可以包含必要的数据，这样原来需要query db的操作就可以省略了。

因为JWT只存在于 Authorization header中，所以Cross-Origin Resource Sharing也不会存在问题，因为这中间不需要cookies。

下图体现了  client 如何获得jwt并使用它来访问资源

![how-to-access-resource](https://cdn2.auth0.com/docs/media/articles/api-auth/client-credentials-grant.png)

步骤: 

1.  client请求auth server。这里可以是另外一种认证流程，比如OpenId
2.  authorization生成后，auth server 返回 access token（jwt）给 client
3.  client使用 access token（jwt）来访问 被保护的资源 例如api

注意，token中的都是暴露给所有人的部分，哪怕别人不能修改，但是也能看到里面的内容，所以不要把需要保密的信息放在token中


# 特点

- JWT 默认是不加密，但也是可以加密的。生成原始 Token以后，可以用密钥再加密一次。
- JWT 不加密的情况下，不能将秘密数据写入 JWT。
- JWT 不仅可以用于认证，也可以用于交换信息。有效使用 JWT，可以降低服务器查询数据库的次数。
- JWT 的最大缺点是，由于服务器不保存 session 状态，因此无法在使用过程中废止某个 token，或者更改 token 的权限。也就是说，一旦 JWT 签发了，在到期之前就会始终有效，除非服务器部署额外的逻辑。
- JWT 本身包含了认证信息，一旦泄露，任何人都可以获得该令牌的所有权限。为了减少盗用，JWT 的有效期应该设置得比较短。对于一些比较重要的权限，使用时应该再次对用户进行认证。
- 为了减少盗用，JWT 不应该使用 HTTP 协议明码传输，要使用 HTTPS 协议传输

