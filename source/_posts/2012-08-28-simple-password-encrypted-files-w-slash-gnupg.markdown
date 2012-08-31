---
layout: post
title: "使用GnuPG 对文件进行对称加密"
date: 2012-08-28 13:45
comments: true
categories: 
---

在互联网上发送或共享一些文件文档,我可能希望它是安全的,加过密的,即使被截获,我也不希望出现类似于艳照门的事件,尽管在码农的生活中可能无艳可照... 
在 Linux 或 OSX, 我可以使用一个 <a href="http://huoxu.me/blog/2012/08/16/shi-yong-gnupg-dui-ri-zhi-jia-mi/"> GnuPG </a> 的工具对我想要对外共享的文件进行密码保护. 

    安装 GnuPG
    使用Gentoo. 
        
    sudo emerge gpg


    在Mac OSX 下可以使用 Homebrew:
        
    brew install gpg

加密一个敏感文件

    gpg -c sensitive.txt


因为是对称加密, 它会提示:
    
    Enter passphrase:
    Repeat passphrase: 


如果成功, 会生成一个sensitive.txt.gpg文件, 当然了, 它的内容是人类不可读的.


你可以随意分发传送这个文件..


接收方只需要对密文件:
    
    gpg sensitive.txt.gpg


当然了, 假设对方是知道你的对称密码的.

    gpg: CAST5 encrypted data
    Enter passphrase: 


输入密码短语后, 它会还原成原文件 sensitive.txt.


Dropbox作为云端文件存储利器, 方便的同时, 可能也会带来安全隐患, 很有必要对你存储的文件做一层加密.


使用基于gpg的Dropbox 加密项目, 基本可以做到无忧.

<a href="https://github.com/woodwardjd/lockbox/">https://github.com/woodwardjd/lockbox/</a>






