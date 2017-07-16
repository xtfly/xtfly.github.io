---
title: "[C++] STL容器中erase方法的不同陷阱"
date: "2009-07-01"
categories:
 - "技术"
tags:
 - "cpp"

---


`STL`中的容器都有`erase`方法，容器的存储分为顺序存储(如`vector`)与链式存储(如`list,map`)。先以`map`为例:
```
typedef std::map<std::string, std::string> TStrMap;  
typedef TStrMap::iterator TStrMapIter;  
TStrMap strmap;  
TStrMapIter iter = strmap.find("somekey");  
strmap.erase(iter);
```  
这样使用`erase`方法没有任何问题，删除一个单结节之后，`stl`中的`iterator`都是与其中的数据元素关联的，关联的元素删除之后，`ite`r已就失效，`iter`理解为指向元素的指针，那删除之后可以简单理解为已是一个野指针。
<!--more-->

但有时我们一不注意，却会这样使用，这是错误的:
```
for(TStrMapIter iter= strmap.begin(); iter!= strmap.end();++iter)  
{  
   if ("somevalue" == iter->second )  
   {  
     strmap.erase(iter);  
   }  
}  
```
`iter`所指的元素删除之后，`++iter`是错误的，会导致程序的未知结果，`iter`一般是不会移到指向下一个元素。

对于`map`与`list`这样的链式存储结构。我们一般可以有两种解决办法:

##### 方法一
使用`erase(iter++)`，因为`iter2 = iter++`是`iter`先移到指向下一个节点，而`iter2`还是指向当前的节点。注意理解`iter++`与`++iter`的区别。
```
for(TStrMapIter iter= strmap.begin(); iter!= strmap.end();)  
{  
   if ("somevalue" == iter->second )  
   {  
     strmap.erase(iter++);  
   }  
   else  
   {  
     ++iter;   
   }  
}
```

##### 方法二
`erase`的返回值会指向下一个节点，记把下一节点赋给一个变量。
```
for(TStrMapIter iter= strmap.begin(); iter!= strmap.end();)  
{  
   if ("somevalue" == iter->second )  
   {  
     iter = strmap.erase(iter);  
   }  
   else  
   {  
     ++iter;  
   }  
}  
```

但对于顺序存储的vector也可以使用上述两种方法吗？很遗憾，第一种用法却是错误的，但第二种用法是正确的。因为顺序存储的容器一旦erase时，会涉及到数据移动，iterator所指的位置还是那个位置，但元素却移动了，iter++之后已不再你想要的元素位置了。

```
void test_vector_erase()  
{  
    typedef std::vector<int> TIntVec;  
    typedef TIntVec::iterator TIntVecIter;  
    TIntVec vec;  

    vec.push_back(1);  
    vec.push_back(2);  
    vec.push_back(3);  
    vec.push_back(4);  

    for (TIntVecIter iter = vec.begin(); iter != vec.end();)  
    {  
        std::cout << *iter << std::endl;  
        if (0 == *iter % 2)  
        {  
            vec.erase(iter++);  
        }  
        else  
        {  
            ++iter;  
        }  
    }  
}
```

它输出的结果却是未知的，我的测试环境为`"1，2，4，4"`。你可能发现原因，当删除`2`元素时，`3`往前移了，而`iter++`不是指到`3`，还是指到`4`了。当你使用`STL`容器中`erase`方法，那是一定要小心再小心，我也是被它戏弄了一下之后，才明白其中容易被忽视的这些细节。
