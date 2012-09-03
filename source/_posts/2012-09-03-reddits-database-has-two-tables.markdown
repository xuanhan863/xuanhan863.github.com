---
layout: post
title: "架构学习: Reddit 的数据库只有两个表"
date: 2012-09-03 16:10
comments: true
categories: 
---

最近,<a href="http://www.reddit.com/r/IAmA/comments/z1c9z/i_am_barack_obama_president_of_the_united_states/">Obama现身Reddit</a>, 让这个一向以死忠Geek横行的小众技术社区又火了起来.

回顾Reddit 的架构史, 2010 年时, 该创始人Steve Huffman 在<a href="http://highscalability.com/blog/2010/5/17/7-lessons-learned-while-building-reddit-to-270-million-page.       html">High Scalability post from 2010</a> share 过一个ppt, 16页slides大致能一窥究竟.

> 题外话,很好奇Reddit 在<a
> href="http://www.rabbitmq.com/">RabbitMQ</a>使用方面有什么技巧?
> 至少在<a
> href="http://www.douban.com">豆瓣</a>
> RabbitMQ 貌似不太可控,一动不动就把整个机器的内存都吞光了.

 **总结的经验是: 开放 Schema,架构不要被模式化.** 

**同时也惊讶的得知他们的数据库中只有两个表**.


Reddit 当时花了很多时间和精力,试图保持数据库(<a href="http://www.postgresql.org">PostgreSQL</a>)的规范化和有条不紊.但当你打算新添加一列到千万量级的数据表时,数据库的行级锁会导致长时间的挂起, not work. 当然, 你也可以维护一个Master/Slave的结构, 进行热备或复制切换,但这无疑增加了运维的复杂度.

重新梳理问题. 不难发现, 在Reddit中, 一切都可以称之为一个Thing: 包括用户,链接,回复,subreddits等. Thing 有着共同的属性, 比如up/down的投票,类型和创建日期. 由Thing再衍生一个Data table. Data table有三列: 对应Thing的ID,键和值, 类json的数据格式( 和豆瓣的使用方法doml基本相近). 这样, 数据库的维护就变的简单,容易了.. 当增加新功能时, 只需要维护相应的Key/Value.

这样做的代价就是你没法使用关系型数据库的features. 没法进行表之间的join, 而且需要你自己维护一致性的问题. 但没有join, 也意味着简单使用一致性hash 就可以做到数据的散列分布, 数据表的切割也变的容易.

这类似于<a href="http://www.mongodb.org">MongoDB</a>, <a href="http://redis.io">Redis</a> 之类的 K/V型db. 它让你在存储数据时不必再考虑模式或索引的问题, 很容易地添加更多的类型到现有对象,更新或横向切分. 同时兼顾高性能 O(1).


从 Hacker News 的<a href="http://news.ycombinator.com/item?id=4468265">这个post</a> 看起来,他们为每个subreddit使用单独的数据库, 当然了, 还是<Thing, Data>.. 


可以自由转载,但请注明出处
