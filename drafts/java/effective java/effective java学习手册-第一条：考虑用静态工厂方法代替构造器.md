# 第一条：考虑用静态工厂方法代替构造器
我们先认识下这一条内容的两个概念：静态工厂方法、构造器。

静态工厂方法：类提供一个共有的静态工厂方法，它只是一个返回类型的实例的静态方法。

先举个**静态工厂方法**的例子

```
    //书中的例子
    public static Boolean valueOf(boolean b){
        return b ? Boolean.TRUE : boolean.FALSE;
    }

    //我的例子
    public static Person getDefaultPerson(){
        return new Person();
    }
    public static Person getPersonWithAgeAndName(int age,String name){
        return new Person(age , name);
    }
    public static Person getPersonLisi(){
        return new Person(4,"Lisi");
    }
```
我认为valueOf()和getPerson()都是静态工厂方法，因为：
1. 有Static关键字，静态的
2. 都返回类型实例




构造器就不细说了，举个**构造器**的例子

```
Class  Person{
    private int age;
    private String name;
    
    Person (){
        this.age = 3;
        this.name = "Zhang 3";
    }
    
    Person (int age , String name){
        this.age  = age;
        this.name = "Zhange San";
    }
}
    
    Person a = new Person();
    Person b = new Person(4,"Lisi");
```

###  优势1：静态工厂方法相对于构造器有名称
这个很明显，构造器只能是类的名称，通过不同的构造参数来区分功能；而静态工厂方法是一个自己定义的方法，复杂的业务逻辑可以用方法名称来提示。
比如静态工厂方法的例子中就用不同的名称来创建了不同的Person，构造器只能通过设置不同的参数来调用构造器。

### 优势2：不必再每次调用它们的时候都创建一个新的对象。
这个其实是静态工厂方法可以做到的一个特性。

举个例子

```
static Map<String, Person> cache = new ConcurrentHashMap<>();

public static Person getNewPerson(age,name){
    if(cache.containsKey(name)){
        return cache.get(name);
    }else{
        return cache.putIfAbsent(name,new Person(age,name));
    }
    
}

```
简单的按名称为KEY建立一个缓存库，每次取对象的时候去检查是否已经创建过了，如果创建过了就使用缓存返回，否则创建新的对象放到缓存中并返回。

//todo 
// == 和 equals()的区别


### 优势3：静态工厂方法可以返回类型的任何子类的对象。
不多说，举个例子
```
    Class Male extends Person{
        private String sex;
        Male(){
            super();
            this.sex = "男";
        }
        Male(int age,String name){
            super(age,name);
            this.sex = "男";
        }
    }
    
    ....
    
    public static Person getMale(age,name){
        return new Male(age,name);
    }
```

### 优势4：在创建参数化类型实例的时候，它使得代码更加简洁
这个特性在java8中已经内置支持了


### 缺陷1： 如果只有静态工厂方法而没有一个public或protected的构造器，这个类将没有办法子类化。
原文：The main disadvantage of providing only static factory methods is that classes without public or protected constructors cannot be subclassed.

举个例子

```
interface IPerson{
    public say();
}
Class Person implements IPerson{
    public say(){
        println("Person");
    }
}
class Male extends Person{
    @Override
    public sya(){
        println("Male");
        
    }
}

class Persons{
    //不可实例化
    Persons(){}
    
    public static IPerson getPerson(){
        return new Person();
    }
    public static IPerson getMail(){
        return new Male();
    }
}
```
这个时候我们只能

Persons.getPerson().say()

Persons.getMale().say()

这样使用Persons。

却不能定义一个Persons的子类去扩展它的功能。

### 第二个缺点它们与其他的静态方法没有实际上的区别
//todo 截下Intellij idea的structure的图  







