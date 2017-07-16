---
title: "C++技巧之名字空间namespace"
date: "2009-07-13"
categories:
 - "技术"
tags:
 - "cpp"

---


C开发人员会经常使用`#define`即宏来声明常量，但宏却是全局的，对大的工程来说是很难维护，经常是导致名字冲突。还好，C++给我们带来了`namespace`名字空间。它的使用如下，名字空间可以把一组逻辑分组，同时名字空间也是一种作用域。
```
namespace outspname  
{   
   const int CVAR1 = 1;  
   const char* const CVAR2 = "33333";  
   void test();  

   namespace inspname  
   {  
      enum { A, B, C};  
      class Klass  
      {  
      };  
   }  
}
```
<!--more-->

但即使一个简单的名字空间，其中也有不少的玄机。

* 当某个名字在自己的空间之外使用，在反复地在前面加上名字空间作为限定词， 如:

    ```
    const int  local  = outspname::inspname::A
    ```

    这样写是不是很令人烦。在某个小的局部作用域内，我们可以通过一个使用声明。如:
    ```
    {  
       using outspname::inspname::A;  
       const int local = A;  
    }
    ```  


* 通过一个使用指令把该名字空间下所有的名字变成可用。

    如下所示，与第一点的用法区别，是`using` 后面有个`namespace`。同样只在转换时，或者在一个小的局部作用域内使用`using namesapce`，否则也会带来名字的污染。
    ```
    {  
      using namespace outspname;  
      const int local2 = CVAR1;  
      const int local2 = inspname::B;  
      {  
         using namespace inspname;  
         Klass* p = new Klass();  
      }    
    }
    ```  

    但使用`using namespace`这种用法时，要注意下面一点，如在某个.h中声明了有`testname::test`的方法。
    ```
    namespace testname  
    {  
       void test(int param);  
    }
    ```  

    在其.cpp中，不能使用如下这种方式，test方法只是此编译单元的一个局部方法，并非testname名字空间的test方法实现。
    ```
    using testname;  
    void test(int param)  
    {  
    }
    ```  

    正确的使用方式是:
    ```
    namespace testname  
    {  
       void test(int param)  
       {  
       }  
    }  
    ```

    或者是
    ```
    void testname::test(int param)  
    {  
    }  
    ```


* 名字空间的别名，当名字空间很长或嵌套很深时，我们可以使用名字空间别名，用法如下：

    ```
    namespace oin = outspname::inspname;  
    ```


* 无名名字空间，无名名字空间主要是保持代码的局部性，使用如下：

    ```
    namespace   
    {  
      const int CVAR1 = 1;  
      void test();  
    }  
    ```

    但一定要注意的一点是，在C++编译器实现时，无名名字空间其实是有名字的，这个隐含的名字跟它所在编译单元名字相关。所以基于这一点，我们不能跨编译单元使用无名名字空间中的名字。上面的声明等价于:

    ```
    namespace $$$  
    {  
      const int CVAR1 = 1;  
      void test();  
    }

    using namespace $$$;

    ```

    其中`$$$`在其所在的作用域里具有惟一性的名字，每个编译单元里的无名名字空间也是互不相同的，`usingnamesapce  $$$`只是当前的编译单元的隐含名字，所以不能跨编译单元使用无名名字空间中的名字。假设上面的test方法在是a.h与a.cpp中定义与实现的，但在b.h或b.cpp中就不能直接使用test方法或CVAR1。因为在b的这个编译单元中链接的是b这个编译单元中的test符号，并非a编译单元中的test符号，也就会出现未定符号。


* 要避免名字空间使用很短的名字，也不能太长，更不能嵌套太深了，个人觉得不要超过4层。
