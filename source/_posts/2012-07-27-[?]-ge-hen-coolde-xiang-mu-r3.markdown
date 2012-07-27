---
layout: post
title: "一个很cool的项目: r³"
date: 2012-07-27 18:28
comments: true
categories: 
---


r³ 是一个基于python的map reduce 引擎. 后端使用redis, 它的设计理念是:To be simple.

和任意一个MapReduce理论完备的项目[Haoop,Spark,Dpark..etc]一样.
它也分为: 输入流, mappers 和 reducers, 三个处理步骤.

![image alt][6]

<h3>图显示不了了, 原因不明</h3>

实践验证理论, Let's do it.

先简单的通过pip安装:

    pip install r3
  
安装完之后, 会有三个命令:r3-app, r3-map,  r3-web.

看一个常见的Mapreduce场景计算: 对文档单词量的统计.

得有一个存储数据的地方,我先假设你有一个redis实例, 运行在 127.0.0.1:7778

运行:

    r3-app --redis-port=7778 --redis-pass=r3 -c config.py

上边运行的config.py, 作为一个接口配置, 它包含了输入和reduce的输出:

    INPUT_STREAMS = [
        'test.count_words_stream.CountWordsStream'
    ]
    
    REDUCERS = [
        'test.count_words_reducer.CountWordsReducer'
    ]

Ok, 首先接触Input Stream.

一个典型的输入流场景,对文档样本进行计数的话,首先应该打开输入流处理器类的文件,读取文件中的行,然后返回的每一行给r3-app.

**input stream**

它可能是这样的:

    from os.path import abspath, dirname, join
    
    class CountWordsStream:
        job_type = 'count-words'
        group_size = 1000
    
        def process(self, app, arguments):
            with open(abspath(join(dirname(__file__), 'chekhov.txt'))) as f:
                contents = f.readlines()
    
            return [line.lower() for line in contents]


指定一个job的类型: job_type = 'count-words'
group_size = 1000,指定了一个输入流的大小.. 比如:1000, 那每个mapper分配到的处理大小就是1000行, 每1000行, 当做一次Input Stream做一次map.


**Running Mappers**

使用一个CountWordsMapper类来运行我们的映射.

    r3-map --redis-port=7778 --redis-pass=r3 --mapper-key=mapper-1 --mapper-class="test.count_words_mapper.CountWordsMapper"


它继承自r3 worker的Mapper类.

    from r3.worker.mapper import Mapper
    
    class CountWordsMapper(Mapper):
        job_type = 'count-words'
    
        def map(self, lines):
            return list(self.split_words(lines))
    
        def split_words(self, lines):
            for line in lines:
                for word in line.split():
                    yield word, 1

**Reducing**


在所有Input Stream都已经被Mapper合并处理后.. 这是一个连续的过程.. 我猜想, 应该和Dpark 类似, 也是lazy的. 需要数据时才会真正计算.

那么, Reduce 应该这样写了:


    from collections import defaultdict
    
    class CountWordsReducer:
        job_type = 'count-words'
    
        def reduce(self, app, items):
            word_freq = defaultdict(int)
            for line in items:
                for word, frequency in line:
                    word_freq[word] += frequency
    
            return word_freq

必须得指定job_type, 这可是reduce和map的血脉关系所在.. = =


**测试**

我们已经有一个R3应用程序运行在[http://localhost:8888][2].

通过[http://localhost:8888/count-words][3] 访问我们刚刚的文档统计job.


**r³ 基于web的监控台 **


![image alt][4]


**状态**

![image alt][5]


项目地址: `[https://github.com/heynemann/r3][6]`


  [1]: https://github.com/heynemann/r3/raw/master/r3.png
  [2]: http://localhost:8888/count-words
  [3]: http://localhost:8888/count-words
  [4]: https://github.com/heynemann/r3/raw/master/r3-web-4.jpg
  [5]: https://github.com/heynemann/r3/raw/master/r3-web-3.jpg
  [6]: https://github.com/heynemann/r3
