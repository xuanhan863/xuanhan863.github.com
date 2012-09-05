---
layout: post
title: "将Nginx的日志流重定向到Pipe另一端"
date: 2012-09-05 15:19
comments: true
categories: 
---

管道是类UNIX系统IPC通信最古老的方式, 长期以来深得程序员信赖, 童叟无欺, 老少咸宜.

Nginx日志统一使用scribe 收集方式. 步骤是先tail -f accesslog 通过unix pipe传给scribe buffer, 后者将收集到的日志流发往中心scribe sink. 

问题很明显, 1,整条链依赖于tail的稳定性, 前一阵发生过此类事故, 无奈将tail 改为xtail 之后,暂时稳定. 2,nginx 所在机器会写一份, 然后tail给scribe, 日志冗余,无法集中.

于是开垦荒地. 想到在nginx 进程内直接通过<a href="http://linux.die.net/man/2/pipe">Pipe</a>方式发给scribe. 

    #include<unistd.h>
    int pipe(int fd[2]);
    

在这里传递的参数fd[2],是两个文件描述符, 其中fd[0]为读的文件描述符,fd[1]为写的文件
描述符. 在nginx 父进程中声明了一个管道, 然后执行fork()函数创建一个子进程, 该子进程中保留了一个fd[2]的副本.我在子进程中关闭fd[0], 在父进程中关闭fd[1], 这样我从子进程写入信息,就可以从父进程读出来, 就建立了一个在父进程和子进程之间通信的通道.

假设我想要获取nginx 父进程的标准日志输出, 只需要将父进程的标准输出复制给fd[1],这样我们就可以从子进程中获取父进程的输出了.

这里, 使用了linux 标准的<a href="http://linux.die.net/man/2/dup2">dup2</a>函数..

    #include <unistd.h>
    int dup2(int oldfd,int fd);


dup2函数规定一个源描述符和目标描述符的id. dup2函数成功返回时,目标描述符(dup2函数的第二个参数)将变成源描述符(dup2函数的第一个参数)的复制品, 类似于两个文件描述符就都指向同一个文件.

其实, 我想做的功能, 在淘宝的<a href="http://tengine.taobao.org/">tengine</a> 中已经实现了.

代码:

        if ((pid = fork()) < 0) {
            goto err;
        } else if (pid > 0) { // 父
            op->pid = pid;
            
            if (op->open_fd->fd != NGX_INVALID_FILE) {
                if (close(op->open_fd->fd) == NGX_FILE_ERROR)                       {                                                      
                    ngx_log_error(NGX_LOG_EMERG, cycle->log, ngx_errno,
                                  "close \"%s\" failed",
                                  op->open_fd->name.data);
                }
            } //如果出错, 通过ngx_log_error方式记录
            //如果是PIPE方式的WRITE, 关闭fd[0]读描述符. 反之,则为nginx标准写,则关闭写描述符.
            if (op->type == NGX_PIPE_WRITE) {
                op->open_fd->fd = op->pfd[1];
                close(op->pfd[0]);
            } else {
                op->open_fd->fd = op->pfd[0];
                close(op->pfd[1]);
            }
        } else {  // 子进程
            // 这里使用linux dup2标准调用,实现将父进程的输出(也就是子进程的fd[0])复制给STDIN.
            if (op->type == 1) {
                close(op->pfd[1]);
                if (op->pfd[0] != STDIN_FILENO) {
                    dup2(op->pfd[0], STDIN_FILENO);
                    close(op->pfd[0]);
                }
            } else {
                close(op->pfd[0]);
                if (op->pfd[1] != STDOUT_FILENO) {
                    dup2(op->pfd[1], STDOUT_FILENO);
                    close(op->pfd[1]);
                }
            }
        }



具体实现很简洁, 于是我做成patch形式, 打入现版本的Nginx, 测试大约半个月了, 没出现过问题. 

