---
title: "c++实现的stack"
date: "2009-06-11"
categories:
 - "技术"
tags:
 - "c++"
toc: true
---

还是前一段时间需要任职资格考试，自己练习一下栈stack的简易实现，今天把它贴出来，暴露的接口与STL类似，没有实现iterator迭代器。实现有两种方式， 基于顺序存储与链式存储。栈的特点是“后进先出”，在数学表达式运算，编译语法分析中，程序函数调用时最为常见。
<!--more-->

## 公共宏与异常类

```c++
#define NEW(var, T) do { /  
   try {                 /  
       var = new T;      /  
   } catch(...) {        /  
       var = NULL;       /  
   }                     /  
} while(0)  

#define DELETE(var) do { /  
    if(NULL != var) {    /  
       delete var;       /  
       var = NULL;       /  
    }                    /  
} while(0)  

template<typename T>  
struct Error {  
   Error(const char* pszInfo = "Overflow") {  
     printf("/nThrow a error, Info :%s/n", pszInfo);  
   }  
};
```
## 顺序存储

顺序存储，模板实现，其中参数T为栈的存储类型，参数SIZE表示最大存储的个数。

```c++
template<typename T, size_t SIZE>  
class Stack {  
public:  
    Stack() :  
        m_size(0) {  
    }  
    ~Stack() {}  

    bool push(const T& t) {  
        if (m_size == SIZE) {  
            return false;  
        }  

        m_data[m_size] = t;  
        m_size++;  
        return true;  
    }  

    T& pop() {  
        if (0 == m_size) {  
            throw Error<T> ("Overflow");  
        } else {  
            T& t = m_data[m_size];  
            m_size--;  
            return t;  
        }  
    }  

    void clear() {  
        m_size = 0;  
    }  

    const bool empty() const {  
        return 0 == m_size;  
    }  

    const size_t size() const {  
        return m_size;  
    }  

    // 遍历所有的节点  
    void traverse(void(*func)(T&)) {  
        if (empty()) {  
            return;  
        }  

        for (size_t idx = 0; idx < m_size; ++idx) {  
            func(m_data[idx]);  
        }  
    }  

private:  
    T m_data[SIZE];  
    size_t m_size;  
};  
```

## 链式存储

链式存储，也是模板实现，内部结构为一单向链表。入栈的元素加到链表的表头。

```c++
template<typename T>  
struct SNode {  
    T m_data;  
    SNode* m_pNext;  

    SNode() :  
        m_pNext(NULL) {  
    }  
};  

template<typename T>  
class LStack {  
    typedef SNode<T> TNode;  
public:  
    LStack() :  
        m_size(0)  
    {  
        NEW(m_pTop, TNode());  
        if (NULL != m_pTop) {  
            m_pTop->m_pNext = NULL;  
        }  
    }  

    ~LStack() {  
        clear();  
        DELETE(m_pTop);  
    }  

    void clear() {  
        if (NULL == m_pTop) {  
            return;  
        }  

        TNode* pTemp = m_pTop->m_pNext;  
        while (NULL != pTemp) {  
            TNode* pTemp2 = pTemp->m_pNext;  
            DELETE(pTemp);  
            pTemp = pTemp2;  
        }  
        m_pTop->m_pNext = NULL;  
        m_size = 0;  
    }  

    const bool empty() const {  
        return (NULL == m_pTop || NULL == m_pTop->m_pNext) ? true : false;  
    }  

    const size_t size() const {  
        return m_size;  
    }  

    bool push(const T& t) {  
        if (NULL == m_pTop)  
        {  
            return false;  
        }  

        TNode* pTemp = NULL;  
        NEW(pTemp, TNode());  
        if (NULL == pTemp) {  
            return false;  
        }  
        pTemp->m_data = t;  
        pTemp->m_pNext = m_pTop->m_pNext;  
        m_pTop->m_pNext = pTemp;  

        m_size++;  

        return true;  
    }  

    T& pop() {  
        TNode* pTemp = m_pTop->m_pNext;  
        if (NULL == pTemp) {  
            throw Error<T> ("Overflow");  
        }  

        T t = pTemp->m_data;  
        m_pTop->m_pNext = pTemp->m_pNext;  
        DELETE(pTemp);  
        m_size--;  
        return t;  
    }  

    // 遍历所有的节点  
    void traverse(void(*func)(T&)) {  
        if (empty()) {  
            return;  
        }  
        TNode* pTemp = m_pTop->m_pNext;  
        while (NULL != pTemp) {  
            func(pTemp->m_data);  
            pTemp = pTemp->m_pNext;  
        }  
    }  

private:  
    TNode* m_pTop;  
    size_t m_size;  
};
```

## 测试代码

```c++
void print_stack(int& a) {  
    printf("%d/t", a);  
}  

void test_stack() {  
    printf("stack test /n");  
    //Stack<int, 4> stack;  
    LStack<int> stack;  

    stack.push(1);  
    stack.push(2);  
    stack.push(3);  
    stack.pop();  
    stack.pop();  
    stack.pop();  
    stack.push(1);  
    stack.push(2);  
    stack.push(3);  

    printf("/n1 : size: %d /n", stack.size());  
    stack.traverse(print_stack);  

    stack.pop();  
    printf("/n2 : size: %d /n", stack.size());  
    stack.traverse(print_stack);  

    stack.push(4);  
    printf("/n3 : size: %d /n", stack.size());  
    stack.traverse(print_stack);  

    stack.pop();  
    printf("/n4 : size: %d /n", stack.size());  
    stack.traverse(print_stack);  

    stack.clear();  
    printf("/n5 : size: %d /n", stack.size());  
    stack.traverse(print_stack);  
}  
```
