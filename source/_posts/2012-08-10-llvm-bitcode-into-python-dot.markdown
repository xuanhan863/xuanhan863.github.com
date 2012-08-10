---
layout: post
title: "LLVM bitcode into Python.."
date: 2012-08-10 14:46
comments: true
categories: 
---



传统的Python程序员屌丝,可能会使用ctypes直接调用由C编译出来的函数,所谓的调用c的动态链接库.好处是接口简洁,兼容绝大部分的C类型数据结构..收益也很明显,大多都是为了解决性能上的问题. 

    import ctypes;
    h = ctypes.CDLL('**.so')


再说说LLVM (Low Level Virtual Machine) 一个低级别的虚拟机.. 但和JVM等等传统意义上的虚拟机不一样的是, LLVM能够在编译期优化、链接优化、甚至在线编译优化.

LLVM严格说来是一个编译器架构体系. 怎么说呢? 编译器的开发者仅需开发一个可以把原始码转换成LLVM的bitcode的格式(frontend),而转换至机器语言的部分则由另一批开发人员开发(backend). 这样做的好处是使得程序语言可以很轻松的跨越各种平台(LLVM在各个平台所使用的bitcode是一样的).


然后, 我想介绍的是这么一个东东: <a href="https://github.com/dabeaz/bitey">Bitey </a>

它可以把以上提到的两个概念衔接到一起... 它可以将LLVM的bitcode直接导入到Python中作为一个扩展模块.


开始前提是, 你开启了configure --enable-shared=yes编译选项. 和安装了[link text][1]llvm-py python for llvm扩展.

**Ok, 首先, 我写了一个很简单C版本的伪随机数生成器.**

    //srands.c
    #include <stdio.h>                                   
    #include <time.h>
    
    int srandom()
    {
        int i;
        srand( (unsigned)time( NULL ) );
        int random = rand();
        return random;
    }


然后, 我通过clang 把它编译成LLVM bitcode:

    bash % clang -emit-llvm -c srands.c
    

这将会生成一个srands.o文件,它包含了LLVM bitcode. 现在,只需把它导入到Python:

    >>> import bitey
    >>> import srands
    >>> srands.srandom()
    5788877353
    >>>


没错,就是这样.bitey不使用C编译器,连接器,或动态装载器. 你不需要写包装函数,只需要正常的实现一个C程序,然后,编译,导入和完成.

bitey兼容大多数C数据类型,包括整数,浮点数,void,指针,数组和结构体.事实上因为它复用了ctypes的基础接口.


下面是一个稍微复杂一点的结构体数据类型的交互:

    /* point.c */
    #include <math.h>
    
    struct Point {
        double x;
        double y;
    };
    
    double distance(struct Point *p1, struct Point *p2) {
        return sqrt((p1->x - p2->x)*(p1->x - p2->x) +
                    (p1->y - p2->y)*(p1->y - p2->y));
    }

And then 运行:

    % clang -emit-llvm -c point.c
    % python
    >>> import bitey
    >>> import point
    >>> p1 = point.Point(3,4)
    >>> p2 = point.Point(6,8)
    >>> point.distance(p1,p2)
    5.0
    >>>


需要说明的是,LLVM的bitcode不编码结构域的名称.因此,Bitey需将它们分配给这样的索引元素变量:

    >>> p1.e0         # (Returns the .x component)
    3
    >>> p1.e1         # (Returns the .y component)
    4


也可以使用LLVM "高级主题"中所说的预加载模块, 让你瞬间变身高富帅..

如果需要把两个LLVM的目标文件一起合并成一个单一的导入模块,使用llvm-ld命令:

    % llvm-ld point.o srands.o -b combined.o
    % python
    >>> import bitey
    >>> import combined
    >>> combined.srandom()
    5345345646
    >>> p1 = combined.Point(3,4)
    >>> p2 = combined.Point(6,8)
    >>> combined.distance(p1,p2)
    5.0
    >>>


很多时候,我们写的C代码需要链接外部库.于是在导入之前可以采取特殊的方法来加载库.
比如:

    # OS-X
    % gcc -bundle -export_dynamic srands.c -o libsrands.so
    
    # Linux
    % gcc -shared srands.c -o libsrands.so



现在,假设有一些C代码要访问这个库:

    /* sample.c */
    #include <stdio.h>
    extern int srandom();
    
    void print_srandom() {
        int n = 5;
        // 随机数生成,打印5次.
        while (n -- >= 0) {
            printf("%d\n", srandom());
        }
    }



你很希望它能正常执行, 但不幸的是, 它报错了...

    % clang -emit-llvm -c sample.c
    % python
    >>> import bitey
    >>> import sample
    LLVM ERROR: Program used external function 'srandom' which could not be resolved!
    %


不怕不怕... 问题可以这样解决:

     % python
     >>> import bitey
     >>> bitey.load_library("./libsrands.so")
    <CDLL './libsrands.so', handle 13203afc60 at 10179d190>
     >>> import sample
     >>> sample.print_srandom()
     354534534
     65645434
     5454535
     546456546645
     45345345
     >>>


需要说明的是,Bitey不使用C编译器,连接器,动态加载程序,或者涉及子进程调用.它是完全独立的,粘合了llvm-py和ctypes的功能.


自动绑定

在以上例子中,它使用import bitey的方式来识别和加载模块.如果你想跳过这一步,让一切自动,可以创建一个bitey.pth文件,它包含了下面的声明:

    ＃bitey.pth
    进口bitey

现在,只需要把这个文件复制到Python的site-packages目录下.


That's all..  : )





参考: <a href="https://github.com/dabeaz/bitey"> bitey on github </a>









  [1]: http://www.llvmpy.org
