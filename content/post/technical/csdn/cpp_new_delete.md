---
title: "用c++模板来展示new与delete操作符原理"
date: "2009-06-08"
categories:
 - "技术"
tags:
 - "c++"

---

C++中的new与delete可以认为是C中的malloc与free的升级版本。new包含两部分:

 * 第一部分是与malloc功能相同，是从堆上面申请内存块
 * 第二部是调用类的构造方法来初始化刚申请的内存。

delete是new的逆过程，先调用类的析构方法来反初始化，再把刚申请的内存还给堆。

new []与delete []是针对数组操作符，要注意是通过new []分配的对象，不能用delete来释放对象，否则会有内存泄漏。当然通过new分配的对象，不能用delete[]来释放对象。后面我会通过代码来说明为什么。
<!--more-->

下面是C++ 中的new与delete函数原型，申请内存失败会抛出异常bad_alloc

```c++
void* operator new(std::size_t) throw (std::bad_alloc);
void* operator new[](std::size_t) throw (std::bad_alloc);
void operator delete(void*) throw();
void operator delete[](void*) throw();
```

使用举例:

```c++
int* p1 = new int();
delete p2;

int* p2 = new int[5];
delete [] p2;
```

终于到了用模板来模拟new与delete操作符，代码中有注释说明，其中对于调用类的构造方法，采用一种C++标准中称作in-place construtor的方式。使用原型为T* = new(pbuff) T()，直译的话就是在pbuff这块内存构造T类，而不用再去堆上面申请内存。这种技巧大量应用在对象池的实现中，即pbuff这块内存可以挂在链表中反复地使用（这里先不展开说了）。

```c++
/**
 * A simulation of c++ new T() & new T(param) operation
 */  
struct NewObj {
    template <typename T>
    inline void operator()(T*& pObj) {
        // allocate memory form heap
        void * pBuff = malloc(sizeof(T));
        // call constructor
        pObj = new (pBuff) T();
    }

    template <typename T, typename P>
    inline void operator()(T*& pObj, const P& param) {
        // allocate memory form heap
        void * pBuff = malloc(sizeof(T));
        // call constructor, pass one param
        pObj = new(pBuff) T(param);
    }
};  

/**
 * A simulation of c++ delete T operation
 */  
struct DeleteObj {  
    template <typename T>  
    inline void operator()(T*& pObj) {  
        if ( NULL == pObj ) { return ;}  
        // call destructor  
        pObj->~T();  
        // free memory to heap  
        free((void*)pObj);  
        pObj = NULL;  
    }  
};  

/**
 * A simulation of c++ new T[N]() operation
 */  
struct NewObjArray {  
    template <typename T>  
    inline void operator()(T*& pObj, unsigned int size) {  
        // save the number of array elements in the beginning of the space.  
        long * pBuff = (long *) malloc (sizeof(T) * size + sizeof(long));  
        *((unsigned int *) pBuff) = size;  
        pBuff++;  

        // change pointer to T type, then can use pT++  
        T * pT = (T *) pBuff;  
        // save the pointer to the start of the array.  
        pObj = pT;  
        // now iterate and construct every object in place.  
        for (unsigned int i = 0; i < size; i++) {  
            new((void *) pT) T();  
            pT++;  
        }  
    }  
};  


/**
 * A simulation of c++ delete [] T operation
 */  
struct DeleteObjArray {  
    template <typename T>  
    inline void operator()(T*& pObj) {  
        unsigned int size = *((unsigned int *) ((long *) pObj - 1));  

        T * pT = pObj;  
        // call destructor on every element in the array.  
        for (unsigned int i = 0; i < size; i++) {  
            pT->~T();  
            pT++;  
        }  
        // free memory to heap.  
        free ((void *) ((long *) pObj - 1));  
        pObj = NULL;  
    }  
};  
```

测试代码:

```c++
struct TestClass {  
    TestClass() : mem1(0), mem2(0)  {}  

    TestClass(int m) : mem1(m), mem2(0) {}  
  
    int mem1;  
    long mem2;  
};  

void test_new_delete()  {  
    TestClass* p1 = NULL;  
    NewObj()(p1);  
    printf("%p/n", p1);  
    DeleteObj()(p1);  

    //  
    TestClass* p2 = NULL;  
    NewObj()(p2, 0);  
    printf("%p/n", p2);  
    DeleteObj()(p2);  

    //  
    TestClass* p3 = NULL;  
    NewObjArray()(p3, 5);  
    printf("%p/n", p3);  
    DeleteObjArray()(p3);  
}  
```

---------------------------------------
 > 测试环境为eclipse+cdt+ubuntu+gcc，注意头文件需要`#include<new>`，使用`#include<stdlib.h>`会导致编译不过，因为`in-place construtor`是C++中的新玩意。
