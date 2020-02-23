# License证书2.0接口规范文档    

标签（空格分隔）： 主要内容：自定义接口的编写与返回值，如何调用接口，如何捕获自定义异常

---
##为使开发者能自定义证书管理属性，检查和验证证书各属性的正确性，和规范使用License2.0版本jar包自定义的接口方法，特编写此文档。文档将告知开发者如何正确在开发过程中，通过声明自定义接口并调用CheckUtil工具类方法，来检查证书的某个属性，并捕获异常来进行处理。

## 1. 自定义接口的规范##
    （1）imlements LicensePredicate类 ；
    （2）重写getFailMessage() ，返回值为String字符串；
        重写 getFailMessage() 方法，返回值为boolean类型 。
为更好理解，举个实例，如，将A系统当作一个需要证书管控的项目，限制A系统能生成的证书总数量为5个，则我们生成一个证书，定义了一个numberOfLicense属性，输入值为5，然后将证书导入A项目。
定义一个LicenseNumberCheck，
`public class LicenseNumberCheck implements AbstractLicensePredicate{}`
在接口中重写test方法,返回值为boolean类型，例子中content.getExtraContent方法读取出证书管控的属性--证书的最大数量，与当前A系统的证书数量进行比较

   `@Override`
   `public String getFailMessage() {
        return content.getExtraContent("numberOfLicense");
    }`
    `@Override
    public boolean test() {
        log.info("content.getExtraContent(\"numberOfLicense\")"+content.getExtraContent("numberOfLicense"));
        int num = getNum();
        if (num<=Integer.parseInt(content.getExtraContent("numberOfLicense")))
        {
            return true ;
        }
        return false ;
    }`
通过getNum()获得当前系统已经生成的证书数量，当生成证书数量大于5时，返回值为false，即不满足证书管控条件。

##  2. 调用接口的方法##
在你所想要放入的主程序执行过程中，进行接口的调用，进行证书属性验证。
首先要进行读取配置文件test.properties，test.properties文件中存放的是证书和keystore的路径，以及密码等信息。
例如：

    keystorePath=C:/Users/zouszh.HT/Desktop/bingo_0.0.1_phy.pub_ks
    alias=test
    storepass=abcd1234
    subject=bingo_0.0.1
    cipher=abcd1234
    licensePath=C:/Users/zouszh.HT/Desktop/test.lic

之后开始调用接口方法，我们已经自定义了一个接口LicenseNumberCheck,将其放入Class数组中（如果有多个检查的接口方法，可一起放入数组中），将数组传入jar包中的CheckUtils的check方法，即可对LicenseNumberCheck方法进行检查，当不满足条件即LicenseNumberCheck返回了false，会捕获一个CheckException异常。

    try {
            LicenseController.config(LicenseControllers.class, "/test.properties");
            Class[] licensePredicates = {LicenseNumberCheck.class};
            CheckUtil.getInstance().check(licensePredicates);
        }catch (CheckException e){
            log.info(e.getMessage());
            log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!证书数量监控触发!!!!!!!!!!!!!!!!!!!!");
            log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!证书数量监控触发!!!!!!!!!!!!!!!!!!!!");
            log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!证书数量监控触发!!!!!!!!!!!!!!!!!!!!");
            log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!证书数量监控触发!!!!!!!!!!!!!!!!!!!!");
            log.info("!!!!!!!!!!!!!!!!!!!!!!!!!!!证书数量监控触发!!!!!!!!!!!!!!!!!!!!");
        }

##   3. 捕获异常处理##
在证书使用检查通过时，异常不会被捕获，当证书使用检查未通过，我们可以通过getMessage()方法得到异常发生的原因，然后自行在后面进行异常处理，如弹出提示框提示用户证书不符合。



 
