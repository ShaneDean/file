[参考](https://blog.csdn.net/superit401/article/details/52068004)

父类 : Person
```
public class  Person{
	String name;
	int age;
 
	{
		System.out.println("父类的非静态代码块");
	}
	
	static{
		System.out.println("父类的static代码块");
	}
	
	Person(){
		System.out.println("父类的无参构造函数");
	}
 
	Person(String name,int age){
		this.name=name;
		this.age=age;
		System.out.println("父类的有参构造函数");
	}
	
	void eat(){
		System.out.println("父类的吃饭");
	}
	public static void main(String[] args){
 
		System.out.println("父类主方法");
		Person p = new Person();
		p.eat();
	}
}

```
子类 : Student
```
public class  Student extends Person{
	int grade;
 
	{
		System.out.println("子类的非静态代码块");
	}
	
	static{
		System.out.println("子类的static代码块");
	}
	
	Student(){
		System.out.println("子类的无参构造函数");
	}
	
	Student(String name,int age){
 
		System.out.println("子类的有参构造函数："+name+","+age);
	}
 
	Student(String name,int age,int grade){
		
		this.grade=grade;
		System.out.println("子类的有参构造函数："+name+","+age+","+grade);
	}
	
	void eat(){
		System.out.println("子类的吃饭");
	}
	public static void main(String[] args){
		
		System.out.println("子类主方法");
		System.out.println("------------1-------------");
		Student s1 = new Student();
		System.out.println("------------2-------------");
		Student s2 = new Student("霸王谷",20,120);
		s1.eat();
		s2.eat();
	}
}

```

父类的静态代码块—>子类的静态代码块—>主方法（执行哪个程序就执行哪个程序的主方法）—>父类的非静态代码块—>父类的无参构造函数—>子类的非静态代码块—>子类的无参构造函数（若实际子类执行的是有参构造函数，则不执行无参构造函数）—>成员函数（指定执行哪个就执行哪个成员函数，若重写了父类成员函数，则只执行子类的成员函数）