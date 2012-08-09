---
layout: post
title: "一个高效的Bresenham's 算法实现"
date: 2012-08-08 15:26
comments: true
categories: 
---

**Bresenham算法原理解释是**

**　　对各行,各列像素中心先构造一组虚拟网格线,按直线从起点到终点的顺序计算直线各垂直网格线的交点,然后确定该列像素中与此交点最近的像素. 
   并且可以采用增量计算,使得对于每一计算列列,只要检查一个误差项的符号,就可以确定该列所求的像素.**

**这里, 主要来介绍一种高效紧凑的算法实现.**

下面列出了四个C 程序的例子

具体的实现代码你也可以直接下载 <a href="http://free.pages.at/easyfilter/bresenham.c">bresenham.c</a>


<h1>Bresenham画线算法的一个简单的例子</h1>

    void plotLine(int x0, int y0, int x1, int y1)
    {
        int dx =  abs(x1-x0), sx = x0<x1 ? 1 : -1;
        int dy = -abs(y1-y0), sy = y0<y1 ? 1 : -1; 
        int err = dx+dy, e2; /* error value e_xy */
     
        for(;;){  /* loop */
          setPixel(x0,y0);
          if (x0==x1 && y0==y1) break;
          e2 = 2*err;
          if (e2 >= dy) { err += dy; x0 += sx; } /* e_xy+e_x > 0 */
          if (e2 <= dx) { err += dx; y0 += sy; } /* e_xy+e_y < 0 */
        }
    }

    
<td><img src="http://free.pages.at/easyfilter/line.png" alt="Line"></td></tr></tr>

<h1>这是一个画圆的算法实现</h1>

    void plotCircle(int xm, int ym, int r)
    {
       int x = -r, y = 0, err = 2-2*r; /* II. Quadrant */ 
       do {
          setPixel(xm-x, ym+y); /*   I. Quadrant */
          setPixel(xm-y, ym-x); /*  II. Quadrant */
          setPixel(xm+x, ym-y); /* III. Quadrant */
          setPixel(xm+y, ym+x); /*  IV. Quadrant */
          r = err;
          if (r <= y) err += ++y*2+1;           /* e_xy+e_y < 0 */
          if (r > x || err > y) err += ++x*2+1; /* e_xy+e_x > 0 or no 2nd y-step */
       } while (x < 0);
    }

<td><img src="http://free.pages.at/easyfilter/circle.png" alt="Line"></td></tr></tr>

<h1>矩形,椭圆形.</h1>

    void plotEllipseRect(int x0, int y0, int x1, int y1)
    {
       int a = abs(x1-x0), b = abs(y1-y0), b1 = b&1; /* values of diameter */
       long dx = 4*(1-a)*b*b, dy = 4*(b1+1)*a*a; /* error increment */
       long err = dx+dy+b1*a*a, e2; /* error of 1.step */
    
       if (x0 > x1) { x0 = x1; x1 += a; } /* if called with swapped points */
       if (y0 > y1) y0 = y1; /* .. exchange them */
       y0 += (b+1)/2; y1 = y0-b1;   /* starting pixel */
       a *= 8*a; b1 = 8*b*b;
    
       do {
           setPixel(x1, y0); /*   I. Quadrant */
           setPixel(x0, y0); /*  II. Quadrant */
           setPixel(x0, y1); /* III. Quadrant */
           setPixel(x1, y1); /*  IV. Quadrant */
           e2 = 2*err;
           if (e2 <= dy) { y0++; y1--; err += dy += a; }  /* y step */ 
           if (e2 >= dx || 2*err > dy) { x0++; x1--; err += dx += b1; } /* x step */
       } while (x0 <= x1);
       
       while (y0-y1 < b) {  /* too early stop of flat ellipses a=1 */
           setPixel(x0-1, y0); /* -> finish tip of ellipse */
           setPixel(x1+1, y0++); 
           setPixel(x0-1, y1);
           setPixel(x1+1, y1--); 
       }
    }

<td><img src="http://free.pages.at/easyfilter/ellipse.png" alt="Line"></td></tr></tr>

<h1>渐变的贝塞尔曲线<Bézier curve>.</h1>

    void plotBasicBezier(int x0, int y0, int x1, int y1, int x2, int y2)
    {                            
      int sx = x2-x1, sy = y2-y1;
      long xx = x0-x1, yy = y0-y1, xy;         /* relative values for checks */
      double dx, dy, err, cur = xx*sy-yy*sx;                    /* curvature */
    
      assert(xx*sx <= 0 && yy*sy <= 0);  /* sign of gradient must not change */
    
      if (sx*(long)sx+sy*(long)sy > xx*xx+yy*yy) { /* begin with longer part */ 
        x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur;  /* swap P0 P2 */
      }  
      if (cur != 0) {                                    /* no straight line */
        xx += sx; xx *= sx = x0 < x2 ? 1 : -1;           /* x step direction */
        yy += sy; yy *= sy = y0 < y2 ? 1 : -1;           /* y step direction */
        xy = 2*xx*yy; xx *= xx; yy *= yy;          /* differences 2nd degree */
        if (cur*sx*sy < 0) {                           /* negated curvature? */
          xx = -xx; yy = -yy; xy = -xy; cur = -cur;
        }
        dx = 4.0*sy*cur*(x1-x0)+xx-xy;             /* differences 1st degree */
        dy = 4.0*sx*cur*(y0-y1)+yy-xy;
        xx += xx; yy += yy; err = dx+dy+xy;                /* error 1st step */    
        do {                              
          setPixel(x0,y0);                                     /* plot curve */
          if (x0 == x2 && y0 == y2) return;  /* last pixel -> curve finished */
          y1 = 2*err < dx;                  /* save value for test of y step */
          if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; } /* x step */
          if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; } /* y step */
        } while (dy < 0 && dx > 0);   /* gradient negates -> algorithm fails */
      }
      plotLine(x0,y0, x2,y2);                  /* plot remaining part to end */
    }  
 
<td><img src="http://free.pages.at/easyfilter/bezier.png" alt="Line"></td></tr></tr>


<h2>算法特点:</h2>

> 通用: 线,圆形,椭圆形,贝塞尔曲线等.
> 
> 快速: 绘制复杂曲线非常快.
>
> 简单: 短而紧凑.
> 
> 精确: 近似的精确曲线.
