---
layout: post
title: "怎么创建可靠的网络服务?"
date: 2012-08-08 18:53
comments: true
categories: 
---

还记得若干年前的c10k问题,现今软硬件的不断更迭,开源社区的蓬勃壮大,各种问题,似乎已不是什么问题.
但还是萌生了一些想法,在此分享一些运营技巧,不限语言, 不限网站.

创建可扩展的和可靠的服务归结为以下:

**监视一切:**
    必须有一个清晰的画面在任何时间上发生了什么事.过去的表现如何,
    重视日志,记录应用程序中的可觉察指标,并尽量将其可视化,可视化响应时间,pv,以及等等..
    使用Google Analytics是不够的,你还需要更多强大的辅助工具.

**积极主动:**
    主动备份和尽早对未来负载做好规划预期,不要等到网站失去响应的时候才开始想到优化.
    如果可以,度量关于你的系统可以处理多少更多的用户,这样就可以采取猜测预估,认为哪些策略可以适用.

**当崩溃发生时的通知:**
    使用诸如<a href="http://pingdom.com/">PingDom</a>类的服务
    或者像<a href="http://github.com/amix/crash_hound">crash_hound</a>的开源库.


**你可以使用的工具**

我用了很多工具,没有必要重新造轮子,我强烈推荐他们.

**不要失去对任何事物的实时监控权**

我读到有关<a href="https://github.com/etsy/statsd/">statsd</a>和<a href="http://graphite.wikidot.com/">Graphite</a>, 和拜读了这篇文章<a href="http://instagram-engineering.tumblr.com/post/20541814340/keeping-instagram-up-with-over-a-million-new-users-in">Keeping Instagram up with over a million new users in twelve hours. </a>

读完这篇文章后,我很兴奋,我花了一天时间去安装statsd+Graphite和运行。Graphite起步有点复杂,但收益很明显,我必须说,它改变了我的生活.这个设置可以让你实时跟踪,却没有任何性能损失（statsd使用非阻塞的UDP通讯）.我跟踪的平均响应时间,错误的数量,注册量,同步命令的平均响应时间等等,跨服务器和跨服务.

这是非常有用的,比如当你做了很多的部署,但你却可以很快地看到你的最新部署是否引入错误或性能问题.

下面是我的Graphite dashboards:

<img src="http://amix.dk/uploads/statsd.png"></img>


**监视性能,如果系统崩溃时能立刻得到通知**

Pingdom 是非常有用的一个服务,因为它可以在世界多个地点跟踪性能,当你的网站崩溃时,它可以短信通知你. 并且Pingdom也是公开的,可以让用户跟踪你的正常运行时间和性能（对用户而言,这是非常有用的服务）.

还有一些强大的工具,比如<a href="http://github.com/amix/crash_hound">crash_hound</a>,可以让你的程序得到通知. 例如:我收到一条短信,条件是,如果一个队列crash或它已经失去处理能力. 而我们的通知模块中,大部分都是安装使用不到10行代码的小脚本.

Pingdom的显页面的样子:

<img src="http://amix.dk/uploads/pingdom.png"></img>


**central logger 记录每一个错误**

我们有一个中央的日志处理系统,记录着每一个错误,并显示在一个中央位置,对应每一个错误,我们可以看到一个请求的上下文环境.这是一个非常必要的Web服务工具，因为它使你跟踪错误变的非常容易.

下面是我们的中央记录器看起来像:

<img src="http://amix.dk/uploads/central_logger.png"></img>


我相信有很多开源工具可以做到这一点（但我没有找到最适合我们的,所以我们自己实现了一套）.

**SQL monitor**

我们有一个SQL聚合查询,它记录着最耗时或最耗资源的查询记录.我们也有一个请求的记录,记录着同样的数据.

如果你想知道你的代码,哪一部分是值得的优化, 那么这两个工具必不可少.

我之前开源了一个工具<a href="http://amix.dk/blog/viewEntry/19359">request logger</a>（它使用非常简单,而且很容易hack.）

这里有一个截图:

<img src="http://amix.dk/uploads/request_logger.jpg"></img>


**监控服务器**

亚马逊AWS托管是一种特权，因为他们提供了很多伟大的监控工具（如CPU使用率和报警等,如果你的服务器可能使用超额的资源, 那么这种监控就很有必要）.

以及一些开源工具。在Plurk(一个类微博的网站)，我们使用<a href="http://www.cacti.net/">Cacti</a> 和 <a href="http://www.nagios.org/">Nagios</a>,这两个都是很复杂和强大的工具,值得你花时间去深入研究它, 因为它们可以给你以很cool的可视化图像形式显示正在运行的服务器和服务的状态.

下面是一些亚马逊的监测工具的截图:

<img src="http://amix.dk/uploads/ec2.png"></img>

我希望这些经验对你们有用.将来如:central logger or SQL monitor 这类有效的监控工具都将开源.

敬请关注,一如既往:happy hacking!



蹩脚译文出自: <a href="http://amix.dk/blog/post/19709#How-to-create-very-reliable-web-services">How to create very reliable web services </a>   Thanks amix.
