---
title: "C++技巧之operator操作符"
date: "2009-06-24"
categories:
 - "技术"
tags:
 - "cpp"

---

这篇博文是以前很久写的，贴在我的早期一个blog中，今天google一下，发现还真有不少人转载，可惜并不注明出处。那时觉得`operator`比较好玩。C++有时它的确是个耐玩的东东。`operator`它有两种用法，一种是`operator overloading`（操作符重载），一种是`operator casting`（操作隐式转换）。

#### operator overloading

C++可以通过operator 重载操作符，格式如下：类型`T operator 操作符 ()`，如比重载`+`，如下所示
```
template<typename T> class A  
{  
public:  
    const T operator + (const T& rhs)  
    {  
     return this->m_ + rhs;  
    }  
private:  
    T m_;  
};
```
又比如STL中的函数对象，重载`()`，这是C++中较推荐的写法，功能与函数指针类似，如下所示
```
template<typename T> struct A  
{  
   T operator()(const T& lhs, const T& rhs){ return lhs-rhs;}  
};  
```

#### operator casting

C++可以通过operator 重载隐式转换，格式如下： `operator` 类型`T ()`，如下所示
```
class A  
{  
public:  
   operator B* () { return this->b_;}   
   operator const B* () const {return this->b_;}      
   operator B& () { return *this->b_;}  
   operator const B& () const {return *this->b_;}   

private:  
   B* b_;  
};  
```
`A a;`当`if(a)`，编译时转换成`if(a.operator B*())`，其实也就是判断`if(a.b_)`.
