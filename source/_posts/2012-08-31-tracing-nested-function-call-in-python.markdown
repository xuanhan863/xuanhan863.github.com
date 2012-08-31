---
layout: post
title: "在Python 中跟踪嵌套函数调用"
date: 2012-08-31 15:21
comments: true
categories: 
---

有时,当执行复杂的函数调用时,特别是那些涉及到递归算法的函数,很希望能跟踪到它的函数调用堆栈,能跟踪到在执行过程中实际使用了哪些参数和返回值, 但又不想使用诸如pdb之类的debug工具.

下面是一个简单的Python decorator（适用于2.7和3.2 +）

    import sys
    from functools import wraps
    
    class TraceCalls(object):
        """ 
            使用这个decorator 可以追踪到函数递归调用的深度.
        """
        def __init__(self, stream=sys.stdout, indent_step=2, show_ret=False):
            self.stream = stream
            self.indent_step = indent_step
            self.show_ret = show_ret
    
            # This is a class attribute since we want to share the indentation
            # level between different traced functions, in case they call
            # each other.
            TraceCalls.cur_indent = 0
    
        def __call__(self, fn):
            @wraps(fn)
            def wrapper(*args, **kwargs):
                indent = ' ' * TraceCalls.cur_indent
                argstr = ', '.join(
                    [repr(a) for a in args] +
                    ["%s=%s" % (a, repr(b)) for a, b in kwargs.items()])
                self.stream.write('%s%s(%s)\n' % (indent, fn.__name__, argstr))
    
                TraceCalls.cur_indent += self.indent_step
                ret = fn(*args, **kwargs)
                TraceCalls.cur_indent -= self.indent_step
    
                if self.show_ret:
                    self.stream.write('%s--> %s\n' % (indent, ret))
                return ret
            return wrapper


我们可以这样用它:

    @TraceCalls()
    def iseven(n):
        return True if n == 0 else isodd(n - 1)
    
    @TraceCalls()
    def isodd(n):
        return False if n == 0 else iseven(n - 1)
    
    print(iseven(7))


输出它的函数堆栈调用层级:

    iseven(7)
      isodd(6)
        iseven(5)
          isodd(4)
            iseven(3)
              isodd(2)
                iseven(1)
                  isodd(0)
    False

这个decorator tracer 还有几个有用的参数:

    stream: 打印跟踪输出,默认情况下输出到到sys.stdout.
    indent_step: 定义每个嵌套调用,有多少个空间字符的缩进.
    show_ret: 设置为true时,显示每个调用的返回值.



    @TraceCalls(indent_step=4, show_ret=True)
    def flatten(lst):
        if isinstance(lst, list):
            return sum((flatten(item) for item in lst), [])
        else:
            return [lst]
    
    list(flatten([1, 2, [3, [4, 5], 6, [7, [9], 12]], 4, [6, 9]]))



调整后的输出:

    flatten([1, 2, [3, [4, 5], 6, [7, [9], 12]], 4, [6, 9]])
        flatten(1)
        --> [1]
        flatten(2)
        --> [2]
        flatten([3, [4, 5], 6, [7, [9], 12]])
            flatten(3)
            --> [3]
            flatten([4, 5])
                flatten(4)
                --> [4]
                flatten(5)
                --> [5]
            --> [4, 5]
            flatten(6)
            --> [6]
            flatten([7, [9], 12])
                flatten(7)
                --> [7]
                flatten([9])
                    flatten(9)
                    --> [9]
                --> [9]
                flatten(12)
                --> [12]
            --> [7, 9, 12]
        --> [3, 4, 5, 6, 7, 9, 12]
        flatten(4)
        --> [4]
        flatten([6, 9])
            flatten(6)
            --> [6]
            flatten(9)
            --> [9]
        --> [6, 9]
    --> [1, 2, 3, 4, 5, 6, 7, 9, 12, 4, 6, 9]



