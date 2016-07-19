---
title: "C++技巧之栈变量的析构应用"
date: "2009-06-25"
categories:
 - "技术"
tags:
 - "cpp"

---



栈变量有一个好处，就是它退栈时会自动析构，并且在栈上对象生成比在堆上分配效率高很多。但每个线程的栈空间是有限的(创建线程时可以设置)，所以一般的临时小对象都会在栈上分配。
```
struct Test {};  

void test()  
{  
    Test stack_var; // a stack var;  
    Test stack_var2; //a stack var;  
    int *heap_var = new int; // a heap var  
}
```
上述的例子，`stack_var`与`stack_var2`都是一个栈变量，当然`stack_var`与`stack_var2`谁先从栈中分配，不的操作系统，内存管理方式也略有区别。更深一点讲，`heap_var`这个指针值也是一个栈变量承载，但`heap_var`所指的地址内容才是从堆上分配的内存空间。当退出`test`这个函数时，`stack_var`与`stack_var2`都会先调用`Test`的析构，再把其所在的内存空间回收到线程栈中。

在一些场景下，我们可以利用栈变量当退栈时会自动析构这特性，下面我将举两个应用例子。

##### 析构方法释放内存

从堆上面new出来的对象，在一个方法条件分支比较多的情况下，很容易在某个分支少写delete，就会造成内存的泄漏。于是我们可写一个这样的类，在它的析构方法中调用delete回收内存。
```
template <typename T>  
class ScopePtr  
{  
public:  
    ScopePtr(T *& pT) : m_pT(pT)  
    {  
    }  

    ~ScopePtr()  
    {  
        if ( NULL != m_pT )  
        {  
            delete m_pT;  
            m_pT = NULL;  
        }  
    }  
private:  
    typedef ScopePtr<T> TScopePtr;  

    ScopePtr(const TScopePtr &) {}  
    TScopePtr& operator = (const TScopePtr &) {}  

    T *& m_pT;  
};

// 使用方式如下：
void test_scope()  
{  
   Test* p = new Test;  
   ScopePtr<Test> tempScopePtr(p);  
}    
```

##### 析构方法打印日志

做软件，写debug日志是一个好的习惯，出问题时可以方便定位问题的发生源。下面的例子是实现是能记录函数在哪一行进入，在哪一行退出。如果函数某个地方抛异常了，则可以根据进入行与退出行相同一看便知。没有抛异常，也很方便查出是在哪个分支退出的。
```
#define LOG(fmt, ...) printf(fmt, __VA_ARGS__)  
#define __FUNC_TRACE__  

class FuncTracer  
{  
public:  
    FuncTracer(const char* func, const char* file, const int line) :  
        m_func(func), m_file(file), m_line(line)  
    {  
        LOG("Enter [%s][%d][%s]./n", m_file, m_line, m_func);  
    }  

    ~FuncTracer()  
    {  
        LOG("Exit [%s][%d][%s]./n", m_file, m_line, m_func);  
    }  

    inline void updateLine(const int line)  
    {  
        m_line = line;  
    }  

private:  
    const char* m_func;  
    const char* m_file;  
    int m_line;  
};  

#ifdef __FUNC_TRACE__  
 #define FUNC_TRACER()  FuncTracer __oFuncTracer(__FUNCTION__, __FILE__, __LINE__)  
 #define FUNC_RET(retVal)  do { __oFuncTracer.updateLine(__LINE__); return retVal; } while(0)  
 #define FUNC_RET_VOID()   do { __oFuncTracer.updateLine(__LINE__); return; } while(0)  
#else  
 #define FUNC_TRACER()  
 #define FUNC_RET(retVal) return retVal;  
 #define FUNC_RET_VOID()  return;  
#endif
```

上述的`__FUNCTION__`，`__FILE__`与`__LINE__`是编译期间的宏，是一个字符串常量，分别表示函数名，文件名与当前行数。但`__FUNCTION__`并非标准中定义的，各个编译器命名不同，更通用的宏可以使用`boost`中`BOOST_CURRENT_FUNCTION`。其中的`__FUNC_TRACE__`宏开关表示是否编译时开启函数跟踪。使用方式如下：
```
int test_trace()  
{  
  FUNC_TRACER();  
  if(...)  
  {   
     switch(...)  
     case  1:  
        FUNC_RET(1);  
     defualt:  
       FUNC_RET(0);  
     ....  
  }  
  FUNC_RET(1);  
}  
```
