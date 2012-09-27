---
layout: post
title: "C++ 11标准的shared_ptr 智能指针"
date: 2012-09-27 21:10
comments: true
categories: 
---


**shared_ptr是什么?**
------------------

上规模的C/C++项目,都有一个共同问题 - 内存管理. 
飞来飞去的Point, 谁来申请, 谁来释放, 内存泄露了又该找谁? 于是就有了共享指针的想法,也称为智能指针.shared_ptr 就是其一种实现, 它在一块内存上标记一个所有权,说明自己在用. 只要有一个人还申明有"所有权", 内存就不会被释放.


> **"Use shared_ptr as a last resort"**     
> **- Bjarne Stroustrup**

这里引用了C++之父说的一句话: "在万不得已的情况下使用共享指针"

这里基于OOP去耦原则,尽量避免内存之间的共享拷贝, 因为一旦出错, 调试将会带来很大的麻烦. 当然, 你也可以考虑使用它的替代品, C++ 11 支持的scoped_ptr, 它会在编译器加以提示.


基本的 shared_ptr 说明
----------------------

C++ TR1 介绍shared_ptr(Boost库), 你可以认为这是一个引用计数指针. 每次有人获取这个指针的"所有权",计数器就会相应的递增. 当这个指针超出范围,或者是明确的调用reset to null,则计数器递减. 当计数器达到0时,它引用的这块内存会被自动回收. 这意味着如果使用shared_ptr持有我们所有的指针,我们可以容易地避免内存访问越界,覆盖,泄露问题.(shared_ptr确保适当的虚函数被调用,前提是你实现了相应的析构函数)

下面是一个小例子，一个shared_ptr： 

    #include <memory>
    
    using namespace std;
    
    void my_function() {
        shared_ptr<int> my_ptr(new int(9001));
        shared_ptr<int> also_ptr = my_ptr;
        // 内部引用计数为2,这块内存将不会被delete. 
        // 直到两个 shared_ptrs 都调用了reset()函数, 相当于对引用计数清零释放.
        my_ptr.reset();
        also_ptr.reset();
        // Note: auto-deletion!
    }

使用的shared_ptr有许多细微之处, 最常见的一种是循环引用, 若一个shared_ptr对象指针最终指向自己（反向引用）的情况下, 它就不知道该怎么办了. 可以使用标准库的 weak_ptrs 来避免.


