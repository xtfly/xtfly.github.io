---
title: "[c++]自己实现的queue"
date: "2009-06-20"
categories:
 - "技术"
tags:
 - "cpp"

---

周末在家，自己用C++练一下手，用顺序存储与链表存储实现了队列queue。queue是一种先进先出的结构，有很多的应用，比如消息队列。

## 顺序存储实现：

```
template<typename T, size_t SIZE>  
class Queue  
{  
public:  
    Queue() :  m_front(0), m_rear(0)  
    {  
    }  
    ~Queue()  
    {  
    }  
    void clear()  
    {  
        m_front = 0;  
        m_rear = 0;  
    }  
    const bool empty() const  
    {  
        return m_front == m_rear;  
    }  
    const int size() const  
    {  
        int s = (m_rear - m_front + (int)SIZE) % (int)SIZE ;  
        return s;  
    }  
    bool push(const T& t)  
    {  
        int pos = (m_rear + 1) % (int)SIZE;  
        //printf("/n m_rear = %d", pos);  
        if (pos == m_front)  
        {  
            return false;// it's full  
        }  
        m_rear = pos;  
        m_data[m_rear] = t;  
        return true;  
    }  
    T& pop()  
    {  
        if (empty())  
        {  
            throw Error<T>("Overflow");  
        }  
        m_front = (m_front + 1) % (int)SIZE;  
        //printf("/n m_front = %d", m_front);  
        return m_data[m_front];  
    }  
    T& getfront()  
    {  
        return m_data[m_front];  
    }  
    // 遍历所有的节点  
    void traverse( void (*func)(T&) )  
    {  
        if ( empty() ) { return;}  
        for (int idx = m_front + 1; idx != m_rear + 1; idx++)  
        {  
            if ( idx == (int)SIZE)  
            {  
                idx %= (int)SIZE;  
            }  
            //printf("/n idx = %d", idx);  
            func(m_data[idx]);  
        }  
    }  
private:  
    T m_data[SIZE];  
    int m_front;  
    int m_rear;  
};  
```

## 链表存储实现：

```
template<typename T>  
struct QNode  
{  
    QNode() : m_pNext(NULL)  
    {  
    }  
    T m_data;  
    QNode* m_pNext;  
};  
template<typename T>  
class LQueue  
{  
    typedef QNode<T> TQNode;  
public:  
    LQueue()  
    {  
        TQNode* pTemp = NULL;  
        NEW(pTemp, TQNode() );  
        m_pFront = m_pRear = pTemp;  
        m_size = 0;  
    }  
    ~LQueue()  
    {  
        clear();  
        DELETE(m_pFront);  
    }  
    void clear()  
    {  
        TQNode* pTemp = m_pFront->m_pNext;  
        while(NULL != pTemp )  
        {  
            TQNode* pTemp2 = pTemp->m_pNext;  
            DELETE(pTemp);  
            pTemp = pTemp2;  
        }  
        m_pFront->m_pNext = NULL;  
        m_size = 0;  
    }  
    const bool empty() const  
    {  
        return m_pFront == m_pRear;  
    }  
    const int size() const { return m_size;}  
    bool push(const T& t)  
    {  
        TQNode* pTemp = NULL;  
        NEW(pTemp, TQNode() );  
        if ( NULL == pTemp) { return false;}  
        pTemp->m_data = t;  
        pTemp->m_pNext = m_pRear->m_pNext;  
        m_pRear->m_pNext = pTemp;  
        m_pRear = pTemp;  
        m_size++;  
        return true;  
    }  
    T pop()  
    {  
        if (empty())  
        {  
            throw Error<T>("Overflow");  
        }  
        TQNode* pTemp = m_pFront->m_pNext;  
        T t = pTemp->m_data;  
        m_pFront->m_pNext = pTemp->m_pNext;  
        if (NULL == m_pFront->m_pNext)  
        {  
            m_pRear = m_pFront;  
        }  
        DELETE(pTemp);  
        m_size--;  
        return t;  
    }  
    T& getfront()  
    {  
        if (empty())  
        {  
            throw Error<T>("Overflow");  
        }  
        TQNode* pTemp = m_pFront->m_pNext;  
        T t = pTemp->m_data;  
        return t;  
    }  
    // 遍历所有的节点  
    void traverse( void (*func)(T&) )  
    {  
        if ( empty() ) { return;}  
        TQNode* pTemp = m_pFront->m_pNext;  
        while(NULL != pTemp)  
        {  
            func(pTemp->m_data);  
            pTemp = pTemp->m_pNext;  
        }  
    }  
private:  
    TQNode* m_pFront;  
    TQNode* m_pRear;  
    int m_size;  
};  
```

## 测试代码：

```
void print_queue(int& a)  
{  
    printf("%d/t", a);  
}  
void test_queue()  
{  
    LQueue<int> queue;  
    //Queue<int, 4> queue;  
    queue.push(1);  
    queue.push(2);  
    queue.push(3);  
    queue.pop();  
    queue.pop();  
    queue.pop();  
    queue.push(1);  
    queue.push(2);  
    queue.push(3);  
    printf("/n1 : size: %d /n", queue.size() );  
    queue.traverse(print_queue);  
    queue.pop();  
    printf("/n2 : size: %d /n", queue.size() );  
    queue.traverse(print_queue);  
    queue.push(4);  
    printf("/n3 : size: %d /n", queue.size() );  
    queue.traverse(print_queue);  
    queue.clear();  
    printf("/n4 : size: %d /n", queue.size() );  
    queue.traverse(print_queue);  
}  
 ```
