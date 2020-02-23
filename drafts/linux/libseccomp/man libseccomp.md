man seccomp

       #include <linux/seccomp.h>
       #include <linux/filter.h>
       #include <linux/audit.h>
       #include <linux/signal.h>
       #include <sys/ptrace.h>

       int seccomp(unsigned int operation, unsigned int flags, void *args);
       
       
seccomp()系统调用可以在Secure Computing 模式上操作调用的进程


支持的Operation包括：
    
    SECCOMP_SET_MODE_STRICT
        只允许调用 read(2),write(2),_exit(2)(不是exit_group(2)),sigreturn(2)。
        如果是其他的系统调用，得到的就是SIGKILL信号。
        这种模式比较适合需要调用不信任代码的number-crunching应用，比如从管道、socket中读取的
        
        注意：尽管calling thread 不需要在调用 sigprocmask(2) ，但它还可以使用 sigreturn(2) 来阻隔除了 SIGKILL和SIGSTOP 外的信号。同时也意味着 alarm(2) 对限制进程的执行时间也不再有效。
        必须使用SIGKILL来有效的去结束进程。
        可以通过使用timer_create(2) with SIGEV_SIGNAL and sigev_signo set to SIGKILL，或者使用setrlimit(2) 来设置hard limit for RLIMIT_CPU
        
        只有当内核开启CONFIG_SECCOMP选项的时候才有用。
        同时 flags的值必须是0，args的值必须是null
        通常是这样调用的
             prctl(PR_SET_SECCOMP, SECCOMP_MODE_STRICT);
             

    SECCOMP_SET_MODE_FILTER
        
        这个系统调用允许通过 args 变量传递一个指向 Berkeley Packet Filter (BPF)的指针 。
        这个指针是一个指向 scok_fprog的结构体；
        
        可以被设计来过滤任何系统调用和其参数。如果过滤器失效， seccomp()会调用失败，返回EINVAL in errno
        
        如果 fork(2) or clone(2) 被filter允许，那么任何子进程将会因为父进程而被强迫调用filter
        如果 execve(2)  被允许，现存的filter将会be preserved across a call to execve(2).
        
        为了使用SECCOMP_SET_MODE_FILTER 操作，任何一个调用者必须拥有 CAP_SYS_ADMIN的 能力，或者线程必须已经这是了 no_new_privs位; 
        如果这个位已经被线程的祖先设置了，那么这个线程需要调用  
            prctl(PR_SET_NO_NEW_PRIVS, 1);
        否则的话， SECCOMP_SET_MODE_FILTER 操作将会失败，并且会返回 EACCES  in errno。
        这个要求保证了未授权的进程不能应用一个恶意的filter，然后调用 set-user-ID或其他通过execve(2)执行的已授权的代码，从而potentially compromising that program。(Such a malicious filter might, for example, cause an attempt to use setuid(2) to set the caller's  user  IDs  to  non-zero  values  to
        instead  return  0 without actually making the system call.  Thus, the program might be tricked into retaining superuser privileges in circumstances where it is possible to influence it to do dangerous things because it did not actually drop privileges.)
        
        如果prctl(2) 或 seccomp(2) is allowed by the attached filter , further filters may be added. 这个会增加一些评估时间，但是允许futher reduction of the attack surface during execution of thread.
        
        SECCOMP_SET_MODE_FILTER只有当kernel配置了CONFIG_SECCOMP_FILTER启动有效
        
        如果flags is 0 
            prctl（PR_SET_SECCOMP, SECCOMP_MODE_FILTER, args);
        如果flags 是
        SECCOMP_FILTER_FLAG_TSYNC
            每当增加一个新的filter,会同步具有相同seccomp filter tree的进程所调用的所有thread.
            filter tree 是一个ordered list of filters attached to thread 。 (Attaching identical  fil‐ters in separate seccomp() calls results in different filters from this perspective.) 
            如果有一个线程不能同步同一个filter tree，那么这个调用将不会 attach 新的seccomp filter，并且会失败，返回第一个不能同步的线程的ID
            如果在相同进程上的另一个线程是 SECCOMP_MODE_STRICT 或者 如果它attached new seccomp filters fto itself ，diverging from the calling thread's filter three. 同步将会失败。
            
    Filters
        当通过SECCOMP_SET_MODE_FILTER来增加filter，args 会指向一个filter program:
     
           struct sock_fprog {
               unsigned short      len;    /* Number of BPF instructions */
               struct sock_filter *filter; /* Pointer to array of
                                              BPF instructions */
           };
        每个program 必须包含一个或多个BPF instructions:
        
           struct sock_filter {            /* Filter block */
               __u16 code;                 /* Actual filter code */
               __u8  jt;                   /* Jump true */
               __u8  jf;                   /* Jump false */
               __u32 k;                    /* Generic multiuse field */
           };
            
        When executing the instructions, the BPF program operates on the system call information made available (i.e., use the BPF_ABS addressing mode) as a (read-only) buffer of the following form：
    
           struct seccomp_data {
               int   nr;                   /* System call number */
               __u32 arch;                 /* AUDIT_ARCH_* value
                                              (see <linux/audit.h>) */
               __u64 instruction_pointer;  /* CPU instruction pointer */
               __u64 args[6];              /* Up to 6 system call arguments */
           };
           
        由于很多系统调用在不同的架构之间变换，并且允许用户空间的代码使用不同的架构调用，所以增加arch字段来进行检查就很有必要
        
        强烈推荐使用白名单模式，这样简单粗暴。黑名单的话得随时更新可能有风险的系统调用的名单，and it is often  possible  to alter the representation of a value without altering its meaning, leading to a  blacklist bypass.
        
        the arch field is not unique for all calling conventions. x86-64 ABI and the x32 ABI both use AUDIT_ARCH_X86_64 as arch, thy run on the same processor. Instead, the mask __X32_SYSCALL_BIT is used on the system call number to tell the two ABIS aqart.
        
        this means that in order to create a seccomp-based blacklist for system calls performed throgh the x86-64 ABI, it is necessary to not only check that arch equals AUDIT_ARCH_X86_64,but also to explicitly reject all system calls that contain __X32_SYSCALL_BIT in nr;
        
        instruction_pointer 字段提供 the address of the machine-language instruction that performed the system call. this might be usefull in conjunction with the use of /proc/[pid]/maps to perform checks based on which region (mapping) of the program made the system call.(probably, it is wise to lock down the mmap(2)) and mprotect(2)) system calls to prevent the program from subverting such checks.)
        
        when checking values from args against a blacklist, keep in mind that arguments are often silently truncated(截断) before being processed, but after the seccomp check. 例如， this happends if the i386 ABI is used on an x86-64 kernel: although the kernel will normally not look beyond the 32 lowest bits of the arguments ,the values of the full 64-bit registers will present in the seccomp data. A less surprising example is that if the x86_64 ABI is used to perform a system call that takes an argument of type int , the more-significant half of the argument register is ignored  by the system call, but visible in the seccomp data .
        
        一个seccomp filter 返回一个32wei的值，它由2部分组成
            the most significant 16 bits contain on of the "action" values listed below
            the least significant 16 bits are "data" to be associated with this return value.
            
        if multiple filters exit, they are all executed , in reverse order of  their addition to the filter tree-that is , the most recently installed filter is executed first.(注意所有的filter都会被执行，哪怕排在前面的filter 返回了 SECCOMP_RET_ACTION. 这么做是为了简化kernel代码，an to provide a tiny speed-up in the execution of sets of filters by avoiding a check for this uncommon case.) the return value for the evaluation of a given system call is the first-seen SECCOMP_RET_ACTION value of highest precedence (along with its accompanying data ) returned by execution of  all of the filters.
        
    可以被filter 返回的值是：
    
    SECCOMP_ERT_KILL
    
        这个值表示立即退出当前的进程，不在执行system call
        进程会被 SIGSYS 信号关掉
        
    SECCOMP_RET_TRAP
        
        this value results in the kernel sending a SIGSYS signal to the triggering process without executing the system call. Various fields will be set in the siginfo_t structure (sigaction(2)) associated with signal:
        
        si_signo will contain SIGSYS
        
        si_call_addr will show the address of the system call instruction
        
        si_syscall and si_arch will indicate which system call was attempted.
        
        si_code will contain SYS_SECCOMP
        
        si_errno will contain the SECCOMP_RET_DATA portion of the filter return value .
        
        the program counter will be as though the systemcall happened ,the return value register will contain an architecture-dependent value; if resuming execution , set it to something appropriate for the system call.
        
    SECCOMP_RET_ERRNO
        this value results in the SECCOMP_RET_DATA protion of the filter's return value being passed to user space as the errno value without executing the system call.
        
    SECCOMP_RET_TRACE
        when retruned , this value will case the kernel to attempt to notify a ptrace(2)-based tracer prior to executing the system call. If there si no tracer present , the system call is not executed and returns a failure status with error set to ENOSYS
        
        A tracer will be notified if it requests  PTRACE_O_TRACESECCOMP using ptrace(PTRACE_SETOPTIONS) the tracer will be notified of a PTRACE_EVENT_SECCOMP and the SECCOMP_RET_DATA portion of the filter's return value will be available to the tracer via PTRACE_GETEVENTMSG.
        
        the tracer can skip the system call by changing the system call number to -1. Alternatively, the tracer can change the system call requested by changing the system call to a valid system call number. If the tracer asks to skip the system call,then the system call will appear to return the value that the tracer puts int the return value register.
        
        the seccomp check will not be run again ater the tracer is notified.
        
    SECCOMP_RET_ALLOW
        this value results in the system call being executed .
        
返回值
    如果成功了seccomp() 返回0.
    在失败的情况下
        如果SECCOMP_FILTER_FLAG_TSYNC 被使用，返回值是造成synchronization failure的thread id
        
        其他情况下，返回-1，and errno is set to indicate the case of the error

错误原因
    EACCESS
        调用者没有 ACP_SYS_ADMIN capability ，或者 had not set  no_new_privs 在使用 SECCOMP_SET_MODE_FILTER之前
    
    EFAULT
        args 不是一个有效的地址
    
    EINVAL
        operation is unknown ， or, falgs are invalid for the given operation
        
    EINVAL 
        operation include BPF_ABS ,but the specified offset was not aligned 32-bit boundary or execeeded sizeof(struct seccomp_data)
    
    EINVAL a secure computing mode has already been set ,and operation differs from the existing seting
    
    EINVAL operation specified SECCOMP_SET_MODE_FILTER, but hte kernel was no build with CONFIG_SET_COMP_FILTER enabled.
    
    EINVAL operation specified SECCOMP_SET_MODE_FILTER,but the filter program pointed to by args was not valid or the length of the filter program was zero or exceeded BPF_MAXINSNS（4096） instructions
    
    ENOMEM out of memory
    
    ENOMEM the total length of all filter programs attached to the calling thread would exceed MAX_INSNS_PER_PATH (32768) instructions. Note that for the purpose of calculating this limit ,each already existing filter program incurs an overhead penalty of 4 instructions.
    
    ESRCH  another thread caused a failure during thread sync, but its ID could not be determined.
    
注意
    
    the seccomp filed of the /proc/[pid]/status file provides a method of viewing the seccomp mode of a process
    
    Seccomp-specific BPF detail
        * the BPF_H and BPF_B size modifiers are not supported: all operations must load a store(4-byts) words (BPF_W).
        
        * to access the contents of the seccomp_data buffer, user the BPF_ABS addressing mode modifier.
        
        *The BPF_LEN addressing mode modifier yields an immediate mode operand whose value is the size of the seccomp_data buffer.
    
    