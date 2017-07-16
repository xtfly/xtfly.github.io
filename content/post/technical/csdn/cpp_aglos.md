---
title: "[c++]常见的几个排序算法"
date: "2009-06-07"
categories:
 - "技术"
tags:
 - "cpp"

---

前一段时间需要任职资格考试，于是又拿起丢了几年的数据结构书看了看，温习了一下常见的几个排序算法。今天特把我写的学习代码贴了出来。排序的算法常见有插入排序，选择排序与交换排序，较复杂一点还有归并排序与基数排序，概念性的东西我就不多说了，大家可以找一本严老师数据结构书看看。读大学时不觉得怎么样，现在再来看看，又结合这几年的编程经验，通过C++风格函数子造了一遍轮子。
<!--more-->

## 排序算法

 * 先来一个排序中的比较函数子，实现是左值小于右值。

```
 template<typename T>
struct CmpFuctor
{
  bool operator()(const T& lhs, const T& rhs)
  {
    return lhs < rhs;
  }
};
```

  * 交换排序中用到的交换两个元素的函数。

```
template<typename T>
void swap(T* lhs, T* rhs)
{
  T tmp = *lhs;
  *lhs = *rhs;
  *rhs = tmp;
}
```

 *  排序前后，我们自然要观察前后元素的顺序，那也少了下面这个函数。即遍历整个数组，再回调函数指针func，把元素通过引用传递出来。

```
template<typename T>
void traverse(T* pArray, const int size, void (*func)(T&) )
{
  for(int idx =0; idx< size; idx++)
  {
    func(pArray[idx]);
  }
}
```

 *  我们先来看一个最简单的插入排序。

```
template<typename T, typename CMP >
void insertsort(T* pArray, const int size, CMP cmp)
{
  for(int idx =0; idx< size; idx++)
  {
    T temp = pArray[idx];
    int pos = idx -1;
    while( pos >= 0 && cmp(temp, pArray[pos]) ) // <
    {
      pArray[pos+1] = pArray[pos];
      pos--;
    }
    pArray[pos+1] = temp;
  }
}
```

 *  再对上面的插入排序改进，查找为折半插入排序。

```
template<typename T, typename CMP>
void binaryinsertsort(T* pArray, const int size, CMP cmp)
{
  for(int idx = 1; idx < size; idx++)
  {
    int left = 0;
    int right = idx -1;
    T temp = pArray[idx];
    while( left <= right)
    {
      int middle = (left + right) / 2;

      if ( cmp(temp, pArray[middle] )) // <
      {
        right = middle - 1;
      }
      else
      {
        left = middle + 1;
      }
    }

    int j = idx-1;
    for(; j >= right+1; j--)
    {
      pArray[j+1] = pArray[j];
    }
    pArray[right+1] = temp;

  }
}
```

 * 再来一个改进版的插入排序。

  是希尔排序。希尔排序的基本思想是：先将整个待排记录序列分割成若干小组（子序列），分别在组内进行直接插入排序，待整个序列中的记录“基本有序”时，再对全体记录进行一次直接插入排序。

```
template<typename T, typename CMP>
void shellsort(T* pArray, const int size, CMP cmp)
{
  int j = 0;
  int d = size / 2;

  // 通过增量控制排序的执行过程
  while( d > 0 )
  {
    for(int i = d; i< size;i++)
    {
      j = i - d;
      while(j >= 0)
      {
        // 对各个分组进行处理
        if ( cmp(pArray[j+d], pArray[j]) )
        {
          swap(&pArray[j], &pArray[j+d]);
          j -= d;
        }
        else
        {
          j = -1;
        }
      }
    }
    d /= 2; //递减增量d
  }
}
```

 * 下面是一种简单选择排序算法。

```
template<typename T, typename CMP>
void selectsort(T* pArray, const int size, CMP cmp)
{
  for(int idx = 0; idx < size; idx++)
  {
    for(int pos = idx + 1; pos < size; pos++)
    {
      if( cmp(pArray[pos], pArray[idx]) ) // <
      {
        swap(&pArray[pos], &pArray[idx]);
      }
    }
  }
}
```

 * 交换排序中最简单的冒泡排序。

 ```
 template<typename T, typename CMP>
void bubblesort(T* pArray, const int size, CMP cmp)
{
  for(int idx =0; idx < size; idx++)
  {
    for(int pos = 0; pos <= size - idx;pos++)
    {
      if( cmp(pArray[pos+1], pArray[pos]) ) // <
      {

        swap(&pArray[pos], &pArray[pos+1]);
      }
    }
  }
}
 ```

 * 交换排序中最简单的快速排序。

```
template<typename T, typename CMP>
int partition(T* pArray, int p, int r, CMP cmp)
{
  int i = p - 1;
  int j = 0;
  for(j = p; j < r; j++)
  {
    if(cmp(pArray[j], pArray[r])) //pArray[j] >= pArray[r]
    {
      i++;
      swap(&pArray[i], &pArray[j]);
    }
  }
  swap(&pArray[i + 1], &pArray[r]);
  return i + 1;
```

## 测试代码

```
void print(int& a)
{
  printf("%d/t", a);
}

int genrandom(int min, int max)
{
  return (min + (int)(((float)rand()/RAND_MAX)*(max - min)));
}

void random(int& a )
{
  a = genrandom(-50, 100);
}

void sort_test()
{
  int A[] = {4, 1, 44, -12, 5, 125, 30};
  int len = sizeof(A) / sizeof(int);

  //
  traverse(A, len, print);
  printf("/n");
  insertsort(A, len, CmpFuctor<int>() );
  traverse(A, len, print);
  printf("/n");

  //
  traverse(A, len, random);
  traverse(A, len, print);
  printf("/n");
  binaryinsertsort(A, len, CmpFuctor<int>() );
  traverse(A, len, print);
  printf("/n");

  //
  traverse(A, len, random);
  traverse(A, len, print);
  printf("/n");
  shellsort(A, len, CmpFuctor<int>() );
  traverse(A, len, print);
  printf("/n");


  //
  traverse(A, len, random);
  traverse(A, len, print);
  printf("/n");
  bubblesort(A, len, CmpFuctor<int>() );
  traverse(A, len, print);
  printf("/n");

  //
  traverse(A, len, random);
  traverse(A, len, print);
  printf("/n");
  selectsort(A, len, CmpFuctor<int>() );
  traverse(A, len, print);
  printf("/n");

  //
  traverse(A, len, random);
  traverse(A, len, print);
  printf("/n");
  quicksort(A, 0, len, CmpFuctor<int>() );
  traverse(A, len, print);
  printf("/n");

}
```

 ---------------------------------------
 > 上面的函数有C风格的函数指针与C++风格函数子（Functor，有时也叫函数对象），函数使用了C++中模板的一些特性，测试环境为eclipse+cdt+gcc。
