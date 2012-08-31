---
layout: post
title: "一个通用的C++ 单例模型 "
date: 2012-08-30 17:29
comments: true
categories: 
---


昨天,我发现一个问题,这是一年前未能解决的方案.这个问题很简单:创建一个通用的单例对象模型.对单例模型的定义是: "确保一个类只有一个实例,并提供一个全局访问点".

常见的版本是使用模板模式（CRTP）.先介绍CRTP,这个概念很简单,只是继承了一个模板基类,它允许创建静态多态性或者实例计数器... 可以参考维基百科对此的定义 <a href="http://en.wikipedia.org/wiki/Curiously_recurring_template_pattern">Curiously recurring template pattern</a>

使用CRTP的方式, 每次程序结束时, 我都需要显示调用一次 destroySingleton.
所以,我必须设计一个通用的解决方案,围绕整个对象生命周期, 从对象构造到它调用结束被析构.


最初,我使用两个阶级,两个构造函数,我虽然打的事实,不使用模板函数的实例,可以容忍不正确（没有类型检查，没有名字结合...这必须是有效的语法）。下面是一个例子：


    #include <string>
    
    template <class T>
    class Singleton
    {
    public:
      static T* get_instance(int v)
      {
        if (!instance_)
          instance_ = new T(v);
    
        return instance_;
      }
    
      static T* get_instance(std::string s)
      {
        if (!instance_)
          instance_ = new T(s);
    
        return instance_;
      } // Sounds familiar...
    
      static void destroy_instance()
      {
        delete instance_;
        instance_ = nullptr;
      }
    
    private:
      static T* instance_;
    };
    
    template <class T> T* Singleton<T>::instance_ = nullptr;
    
    // The classes that will be singletons:
    
    class Single: public Singleton<Single>
    {
    public:
      Single(std::string s): s_(s) {}
    
    private:
      std::string s_;
    };
    
    class Map: public Singleton<Map>
    {
    public:
      Map(int scale): scale_(scale) {}
    
    private:
      int scale_;
    };
    
    // How to create and destroy them:
    
    int main()
    {
      Single* s = Single::get_instance("Forever Alone");
      Map* m = Map::get_instance(42);
    
      // Use these singletons.
    
      Map::destroy_instance();
      Single::destroy_instance();
    }

这个版本实现了通用单例的一半,它完全非侵入式的转化为单例类.

事实上,必须建立两个GET_INSTANCE,因为它有两个不同的构造函数.由于可能对象构造函数的参数组合的数量是无限的,所以这个解决方案并不好.


昨天,研究了一下<a href="http://enki-tech.blogspot.fr/2012/08/c11-vector-improved-how-it-works.html"> C++ 11</a>机制, 发现它允许创建emplace_back. 其实,我们只需要创建一个GET_INSTANCE,作为参数传给构造函数.不重复,完全通用的,这就是我想要的.
下面是Singleton类的最终版本:

    #include <iostream>
    
    template <class T>
    class Singleton
    {
    public:
      template <typename... Args>
      static
      T* get_instance(Args... args)
      {
        if (!instance_)
          {
            instance_ = new T(std::forward<Args>(args)...);
          }
    
        return instance_;
      }
    
      static
      void destroy_instance()
      {
        delete instance_;
        instance_ = nullptr;
      }
    
    private:
      static T* instance_;
    };
    
    template <class T> T*  Singleton<T>::instance_ = nullptr;
    
    class Map: public Singleton<Map>
    {
      friend class Singleton<Map>;
    private:
      Map(int size_x, int size_y): size_x_{size_x}, size_y_{size_y} {}
    
    public:
      int size_x_;
      int size_y_;
    };
    
    int main()
    {
      Map* m = Map::get_instance(4, 5);
    
      std::cout << m->size_y_ << std::endl; // Outputs 5.
    
      Map::destroy_instance();
    }



简单翻译, 原文出处: <a href="http://enki-tech.blogspot.fr/2012/08/c11-generic-singleton.html">C++11: A generic Singleton</a>
自备翻墙.
