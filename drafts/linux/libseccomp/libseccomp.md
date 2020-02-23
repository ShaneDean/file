#概述
seccomp(全称securecomputing mode) 是linuxkernel从2.6.23版本开始所支持的一种安全机制。
在Linux系统里,大量的系统调用(systemcall)直接暴露给用户态程序。
但是,并不是所有的系统调用都被需要,而且不安全的代码滥用系统调用会对系统造成安全威胁。
通过seccomp,我们限制程序使用某些系统调用,这样可以减少系统的暴露面,同时是程序进入一种“安全”的状态。

简单的理解，就是定义类似黑名单、白名单类似，告诉内核，每次内核在触发系统调用的时候都会去查看该名单，并根据查找情况执行下一个步骤是继续调用syscall 还是 触发其他工作。

						                   再简化使用过程	
		(1)根据需求设计过滤规则并告知kernel   ——>   (2)kernel执行过滤代码并根据结果交互决定下一步工作
		
其中重要的就是 规则怎么设计和如何与kernel交互，分别在下面两章介绍


#设计规则 ： BPF
关于BPF，最有名的就是 tcpdump，它就使用了BPF的规则来过滤包。

##起源
BPF可以追溯到一篇论文<The BSD Packet Filter: A New Architecture for User-level Packet Capture>，论文主要讲述的就是 使用 CFG模型（control flow graphic）取代 CSPF（tree）模型而演化出的一种新的过滤方案，文中还介绍了CFG模型的设计方案。

下面是两个方案的对比，规则是识别网络上的IP或ARP包

![filter-representations](https://github.com/ShaneDean/file/blob/master/blog/linux/filter-function-representations.png?raw=true)

下面是两个方案的对比，规则是识别主机foo的包

![figure 5](https://github.com/ShaneDean/file/blob/master/blog/linux/CFG-Filter-Function-for-host-foo.png?raw=true)

![figure 6](https://github.com/ShaneDean/file/blob/master/blog/linux/Tree-Filter-Function-for-host-foo.png?raw=true)

##语法

设计上CFG模型的图需要遵循它的语法来定义，这样它才能解析，下面是它的语法：

详细的指令集	见下表

![table-1](https://github.com/ShaneDean/file/blob/master/blog/linux/table-BPF-instruction.png?raw=true)

寻址模式	见下表

![table-2](https://github.com/ShaneDean/file/blob/master/blog/linux/table-2-BPF-addressing-modes.png?raw=true)


指令格式的定义如下

		---------------------------
		| opcode:16 | jt:8 | jf:8 |
		---------------------------
		|              k:32       |
		---------------------------

		opcode 去顶指令和取址模式
		jt 和 jf 用来进行条件跳转,t ture, f false
		k是用于各种目的的通用字段


加入如法内容后，途中就包含了控制的跳转逻辑

![figure 7](https://github.com/ShaneDean/file/blob/master/blog/linux/bpf-program-for-host-foo.png?raw=true)

##示例

一般过滤规则存在于两种形式，指令和伪代码

		//p-code
		sudo tcpdump -d -i lo tcp and dst port 7070  

		//指令格式
		sudo tcpdump -dd -i lo tcp and dst port 7070


#交互核心：seccomp系统调用

seccomp是一个直接和kernel交互的来完成在安全模式下的程序访问syscall的检查、控制逻辑，也可以通过prctl()来完成等效seccomp的任务。

##声明

	   #include <linux/seccomp.h>
	   #include <linux/filter.h>
	   #include <linux/audit.h>
	   #include <linux/signal.h>
	   #include <sys/ptrace.h>
	
	   int seccomp(unsigned int operation, unsigned int flags, void *args);
	   
##使用细节

其中 seccomp系统调用支持一下几种模式的使用

-	SECCOMP\_SET\_MODE\_STRIC
	
		这个属于严格模式，只允许调用 read(2),write(2),_exit(2)（不包括exit_group(2)) ,sigreturn(2)）
		如果是其他的系统调用，得到的就是SIGKILL信号。
		这种模式比较适合需要调用不信任代码的计算应用，比如从管道、socket中读取的代码
		只有当内核开启CONFIG_SECCOMP选项的时候才有用。
		同时 flags的值必须是0，args的值必须是null
		下面具有同等效果
			prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT);

-	SECCOMP\_SET\_MODE\_FILTER

		该操作符下，允许应用一个指向BPF的指针(args)
		该指针是 stuct sock_fprog  ， 这个结构体可以用来设计成一个filter 。
		如果filter是无效的，那么 seccomp会失效， 返回EINVAL in errno.
		
		其中 fork 和 clone 是被允许的， 但是子进程也需要遵守父进程定义的filter.
		如果是 execve 也被允许，现存的filter也将会被保存。
		
		注意： 要么每个调用者都必须拥有 CAP_SYS_ADMIN，要么调用thread 设置了 no_new_privs位。
		可以通过下面的来设置  prctl(PR_SET_NO_NEW_PRIVS, 1);
		不然就会失败，并返回 EACCES in errno
		
		prctl or seccomp 可以被允许增加新的filter，加的越多，过滤时间越长，但是减少的威胁也更多。
		需要内核开启CONFIG_SECCOMP_FILTER
		当flags 是0的时候  ,等效于下面的调用。
			prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, args);
			
		可选的flags值	
			SECCOMP_FILTER_FLAG_TSYNC
				新增一个filter，同步所有的共享通过一个 filter tree的 thread。 
				如果同一个进程中的另外个线程是SECCOMP_MODE_STRICT模式，那么就会失败。
		
		args 指向的是一个sock_fprog的结构体.
			stuct sock_fprog {
				unsigned short  len;		//数组长度
				struct sock_filter *filter;    //指向数组
			};
		至少包含一个 sock_filter
			struct sock_filter {
				__u16 code;		//filter code
				__u8	jt;			// jump true
				__u8	jf;			// jump false
				__u32	k;			// k
			};
			
		在执行指令的时候， BPF把信息存储下下面只读的Buffer中
			struct seccomp_data {
				int nr;		//系统调用号
				__u32 arch;	//架构值
				
				__u64	instruction_pointer;		//CPU 指针
				__U64  args[6];		//系统调用参数
			};
		
		由于x86支持用户空间代码调用不同架构的代码，所以需要确认arch字段。
		建议使用白名单模式，因为黑名单需要根据潜在的BUG及时的修订名单列表。
		instruction_pointer 提供执行系统调用的机器语言指令的地址。
		可以结合/proc/[pid]/maps来检查是哪个区域的程序执行了systemcall。  
		建议锁定 mmap和 mprotect系统调用防止恶意破坏上面的检查行为。
			
		seccomp filter返回一个32位数， 通常由两部分组成
			高16位：定义在 SECCOMP_RET_ACTION
			低16位：定义在 RECCOMP_RET_DATA
				
		所有的filter都会被执行，执行的顺序类似堆栈。
		哪怕其中一个filter返回SECCOMP_RET_KILL，剩下的filiter也都会继续执行。这样做的目的是简化kernel的代码。
		返给系统调用的值是最高调用顺序中第一次看到的SECCOMP_RET_ACTION。
		按照优先级降序，seccomp过滤器返回的值为：
			SECCOMP_RET_KILL
				直接退出
			SECCOMP_RET_TRAP
				不执行系统调用，发送一个SIGSYS信号给进程，所有的字段设置在 siginfo_t结构中，包括：				
					si_signo	//包含SIGSYS
					si_call_addr	//显示system call 的指令地址
					si_syscall 和si_arch	// 将指定那种system call 要访问
					si_code	// 包含 SYS_SECCOMP 
					si_errno	//包含 SECCOMP_RET_DATA部分
			RECCOMP_RET_ERRNO
				不执行系统调用，SECCOMP_RET_DATA将会通过errno被传递给用户空间
			RECCOMP_RET_TRACE
				以ptrace的方式运行
			SECCOMP_RET_ALLOW
				正常执行
				
seccomp的返回值
	
		0  ： 成功
		失败情况下： 如果  SECCOMP_FILTER_FALG_TSYNC 使用，返回造成同步失败的线程ID
		-1  ： 失败   通过errno来设置错误原因
		
错误号和对应的原因

		EACCESS
			没有设置 CAP_SYS_ADMIN 和 SECCOMP_SET_MODEL_FILTER 原因
		EFAULT
			args 为无效地址
		EINVAL
			情况1		operation 未知，或者flags 对于operation而言非法。
			情况2		operation 包含BPF_ABS，但是 offset 不对齐32位，或者越界 seccomp_data
			情况3		operation 指定的 模式和现存的冲突
			情况4		没有开启CONFIG_SECCOMP_FILTER 原因
			情况5		SECCOMP_SET_MODE_FILTER 情况下  args无效，或者， filte程序的lenght =0    || length > BPF_MAXINSNS (4096)
		ENOMEM
			情况1		内存溢出
			情况2		所有filter的程序的总数之和大于 MAX_INSNS_PER_PATH(32768)。 
						由于计算这个情况每个filter会导致4个指令的损失
		ESRCH
			不知道是别的地方的哪个线程导致的，
#libseccomp 
由于seccomp的使用过于负责，libseccomp就被创作出来。

					使用逻辑就变成了
		1）用户使用Libseccomp来设计规则	 -->  2) libseccomp根据用户设计的规则来解析成bpf规则   -->  3) kernel 解析规则
		
相对的好处：

-	让用户代码具有跨平台性质
-	设计规则变的更加简单
-	其他

##构建

    git clone https://github.com/seccomp/libseccomp.git
    //自己选择 tag 或 branch 默认最新
    ./autogen.sh            //需要autoconf automake
    ./configure
    make V=1
    make install
    make check
    
    在构建完成之后，doc/man目录下面有可以参考的手册，通过man xxxx 来查询详细的使用用法
    
##规则

			//初始化seccomp filter state
		scmp_filter_ctx seccomp_init(uint32_t def_action);
		int seccomp_reset(scmp_filter_ctx ctx, unit32_t def_action);
			def_action：
				SCMP_ACT_KILL , SCMP_ACT_TRAP , ACMP_ACT_ERRNO , SCMP_ACT_TRACE , SCMP_ACT_ALLOW
				
		//释放seccomp filter state  ,已经loaded into kernel不受影响
		void seccomp_release(scmp_filter_ctx ctx);
		//合并两个seccomp filter,src会被释放，不需要在调用 seccomp_release
		//filter值需要一致，架构需要重叠
		int seccomp_merge(scmp_filter_ctx dst, scmp_filter_ctx src);
		
		
		//架构管理
       uint32_t seccomp_arch_resolve_name(const char *arch_name);
       uint32_t seccomp_arch_native();
       int seccomp_arch_exist(const scmp_filter_ctx ctx, uint32_t arch_token);
       int seccomp_arch_add(scmp_filter_ctx ctx, uint32_t arch_token);
       int seccomp_arch_remove(scmp_filter_ctx ctx, uint32_t arch_token);
		
			uint32_t arch_token 由 SCMP_ARCH_* 定义的常量
			SCMP_ARCH_NATIVE 常量总是指向本地编译的架构
			当一个新的架构加进来的时候，老	的filter和它没关系，但是后面新增的filter都跟他相关。
			
		//属性管理
		int seccomp_attr_set(scmp_filter_ctx ctx,
								enum scmp_filter_attr attr, uint32_t value)
		int seccomp_attr_get(scmp_filter_ctx ctx,
								enum scmp_filter_attr attr, uint32_t *value)
		
			可选的scmp_filter_attr为
			
				SCMP_FLTATR_ACT_DEFAULT
					只读属性
				SCMP_FLTATR_ACT_BADARCH  	//def_action
					如果架构不匹配，那么默认 SCMP_ACT_KILL
				SCMP_FLTATR_CTL_NNP			//boolean
					定义NO_NEW_PRIVS在filter加载到内核之前就应该被启动。如果这个为0，那么会去检查 CAP_SYS_ADMIN，不然失败。默认1。
				SCMP_FLTATR_CTL_TSYNC		//boolean
					设置表示seccomp_load调用的时候需要全部同步filter
				SCMP_FLTATR_ATL_TSKIP		//boolean
					设置表示可以创建 -1的syscall	
		//导出seccomp filter
		int seccomp_export_bpf(const scmp_filter_ctx, int fd);		//bpf	--> Berkley Packet Filter
		int seccomp_export_pfc(const scmp_filter_ctx, int fd);		//pfc  --> Pseudo Filter Code
			
		//装载filter到kernel中
		int seccomp_load(scmp_filter_ctx ctx);  //成功的加载
		
		//增加 seccomp filter rule
		int SCMP_SYS(syscall_name);
		struct scmp_arg_cmp SCMP_CMP(unsigned int arg, enum scmp_compare op, ...);
		struct scmp_arg_cmp	SCMP_A0(enum scmp_compare op, ...);
		...
		struct scmp_arg_cmp SCMP_A5(enum scmp_compare op, ...);
		int seccomp_rule_add(scmp_filter_ctx ctx, uint32_t action ,	int syscall, unsigned int arg_cnt, ...);
		int seccomp_rule_add_exact(scmp_filter_ctx ctx, uint32_t action,	int syscall, unsigned int arg_cnt, ...);
		
		int seccomp_rule_add_array(scmp_filter_ctx ctx, uint32_t action, int syscall, unsigned int arg_cnt, const struct scmp_arg_cmp *arg_array);
		int seccomp_rule_add_exact_array(scmp_filter_ctx ctx, uint32_t action, int syscal, unsigned int arg_cnt, const struct scmp_arg_cmp *arg_array);
		
			新加入的filter rule需要load进 kernel才会生效
			SCMP_CMP（） 和 SCMP_A{0-5}()宏 生成一个 scmp_arg_cmp结构用到上面的函数中。
	
		
		//区分 seccomp filter 中的 syscall
		int seccomp_syscall_priority(scmp_filter_ctx ctx, int syscall, uint8_t priority);
		//解析syscall名称
		int seccomp_syscall_resolve_name(const char *name);
		int seccomp_syscall_resolve_name_arch(uint32_t arch_token, const char *name);
		int seccomp_syscall_resolve_name_rewrite(uint32_t arch_token, const char *name);
		char *seccomp_syscall_resolve_num_arch(uint32_t arch_torken, int num);
		
##源码分析
进入tests目录 

发现   [数字]-[名称].[c\py\tests] 。
其中  .c和 .py是测试的主题逻辑。
.test文件则是参与测试的样例数据
 
 
通过分析项目构建情况，其中主体的测试控制程序是 regression ， 它可以通过 -h 来查看使用方法

regression是一个shell程序，以第一个test为例，分析其代码：

		run_tests
		|       //其中举例 01-sim-allow.tests
		|		//		   01-sim-allow  01
		|-->	run_test $batch_name $testnum $line $test_type
		|			"01-sim-allow 	all	 0-350	N	N	N	N	N	N	ALLOW"  bpf-sim
	                |
		    		|		run_test_basic
		    		|		run_test_bpf_sim_fuzz
		    		|		run_test_bpf_valgrind
		    		|		run_test_live
		    		|-->	run_test_bpf_sim	 01-sim-allow  01	"01-sim-allow	 all	0-350	N	N	N	N	N	N	ALLOW" 
	    					|--> run_test_command "$testnumstr" "./$testname" "-b" 4 ""
				 					|-->  01-sim-allow
				 					
注意:由于参数较多，组合起来的测试方案多种多样，所以*xxxx.tests*文件中定义 range的模式，比0-300表示 0 到 300，regression会将这些表示拆开，然后分别执行，在对比日志的时候可以得到佐证。

进入 01-sim-alloc.c 代码	

	...
	ctx = seccomp_init(SCMP_ACT_ALLOW);
	...
	rc = util_filter_output(&opts,ctx);
	     |--> _ctx_valid(ctx)
	     |--> program = gen_bpf_generate((struct db_filter_col *) ctx);
	            |--> _gen_bpf_build_bpf(stcut bpf_state *state,const struct db_filter_col *col)
	            			|--> ???
	            			        |--> prctl(xxx)


更多测试案例分析  

		//TODO 


libseccomp核心代码包括
	
	seccomp.h
		定义了libseccomp核心的数据结构、开放接口和为跨平台定义的通用接口号
	
	api.c
		实现了libseccomp中所有提供给user space使用的接口  seccomp_xx_xx()
		并且使用API宏进行了包裹
	
	arch.c
	
	arch-{ArchName}.c		
		实现了arch_def结构体，其中定义了架构特性，比如最大长度，token, 大小端等等
		其中还将跟架构相关的处理函数通过指针函数暴露出去
	
	arch-{ArchName}-syscalls.c		
		定义了该架构中的syscall name <--> num的对应表
	
	db.c
		核心文件
		
		db_api_rule_list ：  用来存储syscall 、args 、action的双向链表
		
		db_arg_chain_tree :  类似于下面的效果
							
		   	O      <-->       O         <-->      O
					 (false) /  \  (true)
	                        /     \
	                       O       O
	                         
			其中还包含了 arg_num , arg_offset, scmp_compare_op , syscall_arg ,
					     action:{act_true, act_false, flag..} , refcnt;
		还定义了  db_chain_{op}（x,y)的操作宏，op包括 lt,eq,gt等		
		db_sys_list	: 保存系统调用的单向链表   

		db_filter_attr :filter属性
		
		db_filter :	每个具体的过滤器。
			包含了当前的架构信息， 被这个过滤管控的syscall， 用来测查的rulelist

		db_filter_snap : 过滤器集合的单向链表
		   包含了过滤器数组和长度
		   
		db_filter_col :  //TODO
		
		//TODO  控制逻辑
	
	gen_bpf.c	规则 --> bpf数据结构
	
	gen_pfc.c 规则 --> pfc
	
	hash.c	工具类
	
	system.c  使用seccomp系统调用接口实现目标效果


# 新架构增加分析

待完成的工作  

-	调用方法实例化和手册化 ， 设计案例和演示代码
-	梳理syscall，包括被管理和应某些特性而依赖的
- 	确认涉及到的kernel config参数支持情况
-  分析libseccomp转换代码
-  分析seccomp系统调用代码
-  熟悉架构情况
-  开始移植

