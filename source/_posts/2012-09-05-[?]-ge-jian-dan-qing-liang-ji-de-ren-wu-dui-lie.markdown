---
layout: post
title: "又一个简单轻量级的任务队列"
date: 2012-09-05 10:52
comments: true
categories: 
---

Message queue作为服务器之间异步通信的标配, 自然不容忽视.


<a href="https://github.com/wavii/darner">Darner</a> 是一非常简单的消息队列服务器. 它不像<a href="http://redis.io/">redis</a> 之类的in-memory swap模式, 它设计初衷就是用来处理队列远远大于内存能否实际保存的大小. 和传统的企业级Message queue <a href="http://www.rabbitmq.com/">RabbitMQ</a>不同的是, Darner能保证进程挂掉后, 已发布但尚未消费的message不会丢失. 它通过<a href="https://code.google.com/p/leveldb/">Leveldb</a> 间接使用了内核的虚拟内存管理器. 相关话题: Leveledb是一个很赞的项目,由<a href="http://research.google.com/archive/bigtable.html">Bigtable</a>的设计和实现者: <a href="http://research.google.com/people/jeff/">Jeff Dean</a> 和 <a href="http://research.google.com/people/sanjay/">Sanjay Ghemawat</a>两位大牛发起. 因为一次写入操作只涉及一次磁盘append和一次内存写入,所以LevelDb非常适合写操作多于读操作的应用场合,之前做过on ssd的测试, merge+append的写入,对于ssd也很适用, 但就此继续说下去就喧宾夺主了, 在此不做拓展说明.

其结果就是一个持久化的队列server,无论队列大小,往往只使用少量的驻留内存,同时还能兼顾着高性能. 官方有一个公开的<a href="https://github.com/wavii/darner/blob/master/docs/benchmarks.md"> benchmark </a>

官方宣称,Darner是近分布式的: 一组队列Server 可以通过一个名称标识去标识; 每个队列都是遵循严格有序的FIFO, 同时一个querying由一组结构松散有序的Darner Server提供. Darner 也支持可靠的双向读取, 如果一个客户端还没来得及处理Message 就已被断开, 那这条未消费的Message将会被转发给下一个客户端(如果这个client是连接状态的), 保证高吞吐量的同时也保证了可靠性.

它用C++实现, 依赖于 <a href="http://www.boost.org/">Boost</a> 和 <a href="https://code.google.com/p/leveldb/">LevelDB</a>. 最初开发用于<a href="http://wavii.com/">wavii</a> (一个基于Facebook 的个性化订阅应用)的生产环境, 后被开源.

    git clone git://github.com/wavii/darner.git
    cd darner
    cmake . && make && sudo make install



** 看上去很美, 但还需要找时间实际评测. **
可能是使用不当吧, 目前用的RabbitMQ 太让人抓狂了.
