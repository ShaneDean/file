# 前言

[参考1](https://www.ibm.com/developerworks/cn/web/wa-spring-security-web-application-and-fingerprint-login/index.html)

# 核心设计

spring security包括5个核心组件： SecurityContext 、 SecurityContextHolder、Authentication 、 Userdetails 、 AuthenticationManager

## SecurityContext

当用户通过Spring Security的检测之后，SecurityContext会存储当前用户的安全信息（Authentication）

## SecurityContextHolder

是一个存储SecurityContext对象的存储代理，包含3种存储模式：

- MODE_THREADLOCAL : SecurityContext 存储在线程中（默认）
- MODE_INHERITABLETHREADLOCAL : 同上，但子线程可以获得父线程中的SecurityContext
- MODE_GLOBAL：SecurityContext在所有线程中都相同

C端应用，用户登录完毕后，软件的整个生命周期中只有当前登录用户，适合MODE_GLOBAL模式，类似于存储于进程中，所以该进程的所有线程都可以访问。

## Authentication

表明当前用户是谁的验证信息，比如用户+密码就是一个验证信息，无论是否正确都是，区别在于Spring Security是否会校验失败。

```java
public interface Authentication extends Principal, Serializable {
    Collection<? extends GrantedAuthority> getAuthorities();    //获得用户权限信息，一般情况下获得的是角色信息
    Object getCredentials();    //获取证明用户认证的信息，通常情况下获取到的是密码等信息
    Object getDetails();    //获取用户的额外信息，比如ip、坐标（经纬度）
    Object getPrincipal();  //获取用户的身份信息，在未认证的情况下获取到的是用户名，在已认证的情况下获取到的是UserDetails（可视为用户对象的扩展）
    boolean isAuthenticated();  //获取当前的Authentication是否认证
    void setAuthenticated(boolean isAuthenticated); //设置当前的Authentication是否已认证。
}
```
在验证前，principal填充的是用户名，credentials填充的是密码，detail填充的是用户的ip或经纬度之类的信息。通过验证后，Spring security会Authentication重新注入，principal填充用户信息，authorities会填充用户的角色信息，authenticated会被设置为true。重新注入的authentication会被填充到SecurityContext中。

## Userdetails

提供Spring Security需要的核心信息。

```
public interface UserDetails extends Serializable {
    Collection<? extends GrantedAuthority> getAuthorities(); //获取用户权限。本质上是用户的角色信息
    String getPassword();   //获取密码
    String getUsername();   //获取用户名
    boolean isAccountNonExpired();  //账户是否过去
    boolean isAccountNonLocked();   //账户是否锁定
    boolean isCredentialsNonExpired();  //密码是否过期
    boolean isEnabled();    //账户是否可用
}
```

UserDetails是一个接口，实现类都会继承当前应用的用户信息类，并实现UserDetails的接口。假设自定义的用户信息类是User，自定义的CustomUserdetails继承User类并实现UserDetails接口。

## AuthenticationManager

AuthenticationManager负责校验Authentication对象，其中的authenticate函数中，开发人员实现了Authentication的校验逻辑。如果authenticate校验通过，返回一个重新注入的Authentication对象，校验失败，则抛出AuthenticationException异常。

```java
Authentication authenticate(Authentication authentication)throws AuthenticationException;
```

AuthenticationManager可以将异常抛出的更加明确

- 当用户不可用时抛出DisabledException
- 当用户被锁定时抛出LockedException
- 当用户密码错误时抛出BadCredentialsException

重新注入的Authentication会包含当前用户的详细信息，并且会被填充到SecurityContext中，这样验证流程就完成了，SecurityContext就可以通过Authentication来识别“你是谁”

## 验证流程

使用Spring Security的核心组件来实现一个最基本的用户名密码校验

```java
AuthenticationManager amanager = new CustomAuthenticationManager();
Authentication namePwd = new CustomAuthentication(“name”, “password”);
try {
    Authentication result = amanager.authenticate(namePwd);
    SecurityContextHolder.getContext.setAuthentication(result);
} catch(AuthenticationException e) {
    // TODO 验证失败
}
```

# web环境中的Spring Security组件

## FilterChainProxy

FilterChainProxy是FilterChain代理，FilterChain维护了一个Filter列队。

Spring Security在Web程序的入口是Filter，它在Filter中创建Authentication对象，并调用AuthenticationManager进行校验。

## ProviderManager

它是AuthenticationManager的实现类。但ProviderManager没有实现对Authentication的校验功能，而是采用代理模式，将校验功能交给AuthenticationProvider去实现。这样设可以在Web环境中支持多种不同的验证方式，如用户密码登录、短信登录、指纹登录等。不同的验证方式对应不同的AuthenticationProvider，ProviderManager将验证任务代理给对应的AuthenticationProvider。

```java
public Authentication authenticate(Authentication authentication) throws AuthenticationException {
	Class<? extends Authentication> toTest = authentication.getClass();

	for (AuthenticationProvider provider : getProviders()) {
		if (!provider.supports(toTest)) {
			continue;
		}
		try {
			result = provider.authenticate(authentication);

			if (result != null) {
				copyDetails(authentication, result);
				break;
			}
		}
		catch (XXXException e) {  ...  }
	}
    ...
}
```
ProviderManager维护了一个AuthenticationProvider的列队，当Authentication传入，通过supports函数查找待支持校验的AuthenticationProvider，没有找到支持的则抛出异常ProviderNotFoundException。

## AuthenticationProvider

AuthenticationProvider是一个接口
```
Authentication authenticate(Authentication authentication) throws AuthenticationException;   //用于校验 Authentication 对象
boolean supports(Class<?> authentication);  //用于判断 provider 是否支持校验 Authentication 对象
```
添加新的应用验证方式会后，验证逻辑需要写在对应的AuthenticationProvider中的authenticate函数。验证通过后返回一个重新注入的Authentication，验证失败则抛出AuthenticationException异常。


## Spring Security 在 Web 中的认证示例

在用户名密码登录中对应的 Filter 是 UsernamePasswordAuthenticationFilter。attemptAuthentication 函数会执行调用校验的逻辑。

```
public Collection<? extends GrantedAuthority> attemptAuthentication(String username, String password) throws RemoteAuthenticationException {
    UsernamePasswordAuthenticationToken request = new UsernamePasswordAuthenticationToken( username, password );
    try {
    	return authenticationManager.authenticate(request).getAuthorities();
    }
    catch (AuthenticationException authEx) {
    	throw new RemoteAuthenticationException(authEx.getMessage());
    }
```
调用AuthenticationManager执行校验逻辑，获取GrantedAuthority的集合。

在 UsernamePasswordAuthenticationFilter 父类 AbstractAuthenticationProcessingFilter 的 successfulAuthentication 函数中发现以下代码

```
protected void successfulAuthentication(HttpServletRequest request,
		HttpServletResponse response, FilterChain chain, Authentication authResult)
		throws IOException, ServletException {

    ...
	SecurityContextHolder.getContext().setAuthentication(authResult);
	...

```
successfulAuthentication 函数会把重新注入的 Authentication 填充到 SecurityContext 中，完成验证。

在 Web 中，AuthenticationManager 的实现类 ProviderManager 并没有实现校验逻辑，而是代理给 AuthenticationProvider, 在用户名密码登录中就是 DaoAuthenticationProvider。

DaoAuthenticationProvider 主要完成 3 个功能：获取 UserDetails、校验密码、重新注入 Authentication。 它使用了父类AbstractUserDetailsAuthenticationProvider的authenticate方法。

```
public Authentication authenticate(Authentication authentication) throws AuthenticationException {
    ...
    String username = (authentication.getPrincipal() == null) ? "NONE_PROVIDED" : authentication.getName(); //获取用户名
    ...
    UserDetails user = this.userCache.getUserFromCache(username); //是否在缓存用户中
    ...
    user = retrieveUser(username,(UsernamePasswordAuthenticationToken) authentication); //获取用户信息
    ...
    additionalAuthenticationChecks(user, (UsernamePasswordAuthenticationToken) authentication); //执行用户名密码检查
    ...
    return createSuccessAuthentication(principalToReturn, authentication, user); //重新注入Authentication
}
```

其中 retrieveUser \ additionalAuthenticationChecks 都在DaoAuthenticationProvider中实现

DaoAuthenticationProvider.retriverUser
```
    ...
	UserDetails loadedUser = this.getUserDetailsService().loadUserByUsername(username);  //获取UserDetails
	...
	
	...
	
	//一般是某个后台用户操作的类来实现UserDetailsService接口 ，通过 dao层api来获取实现了 UserDetails接口的用户实体类
	public class UserService implements UserDetailsService {
	...
    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        return userDao.findByName(username);
    }
	
```
DaoAuthenticationProvider.additionalAuthenticationChecks
```
...
String presentedPassword = authentication.getCredentials().toString();
if(!passwordEncoder.matches(presentedPassword, userDetails.getPassword())){  //通过passwordEncoder来判断db中的UserDetails和authentication中用户的密码
//如果匹配失败则抛出BadCredentialsException异常
    throw new BadCredentialsException(...)
}
```

