---
layout: post
title: "使用Gnupg 对日志加密"
date: 2012-08-16 18:22
comments: true
categories: 
---


**关于加密:**

你不应该为你的信息在储存和传送过程中的安全而担心. 国内局域网环境恶劣,众所周知.何况还有GFW..  

*现代密码学的发展使得普通人也可以使用加密技术*  比如<a href="http://www.gnupg.org/">GnuPG</a> 就可以帮你在数据传输过程中签名和加密,而且是跨平台的.

<a href="http://www.gnupg.org/">GnuPG</a> 采用 RSA 体系,这是一种非对称的加密方式.过程是:先生成一对密钥,私钥自己保存,而公钥可以公开到任意场景.数据发送方使用公钥加密的内容,只有你可以用私钥解开;你自己用私钥加密的内容,只有用你的公钥可以解开.so,你只需要公开你的公钥,对方就可以用你的公钥给你发送数据,这数据只有你可以解开;如果双方交换了各自的公钥,就可以实现双方相互之间的加密通讯了.

**使用:**

背景: 某项目的log数据, 机密且敏感. 

于是设计使用gnupg 为之传输加密.

使用<a href="http://code.google.com/p/python-gnupg/" >python-gnupg</a> .

使用很简单:

    import gnupg
    def encrypt_line(line):
        gpg = gnupg.GPG(gnupghome=GPG_HOME)
        encrypted_data = gpg.encrypt(line, '***@')
        encrypted_string = str(encrypted_data)
        print 'ok: ', encrypted_data.ok
        return encrypted_string


具体做法是, 使用具体机器名和邮箱作为sign, 生成一对公私钥. 私钥单独一台服务器保存..

python logging在代码里收集支付信息, 通过使用公钥加密, 丢给<a href="http://en.wikipedia.org/wiki/Syslog">syslog</a>, 转发至具体的日志server.

虽然流程繁琐, 但目前想来, 还算通用.













