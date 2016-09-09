---
title: "Go map key类型分析"
date: "2016-09-04"
categories:
 - "技术"
tags:
 - "go"
toc: true

---

团队成员中大多是原来做Java，深受Java的影响，对于使用map问得最多的：map的key如何计算它的HashCode。下面试图通过讲解一些类型知识来解答。

## map的key类型

map中的key可以是任何的类型，只要它的值能比较是否相等，Go的[语言规范](http://golang.org/ref/spec#Comparison_operators)已精确定义，Key的类型可以是：
 
- 布尔值
- 数字
- 字符串
- 指针
- 通道
- 接口类型
- 结构体
- 只包含上述类型的数组。
 
但不能是：

- slice
- map
- function
<!--more-->
Key类型只要能支持`==`和`!=`操作符，即可以做为Key，当两个值`==`时，则认为是同一个Key。

## 比较相等

我们先看一下样例代码：

```
package main

import "fmt"

type _key struct {
}

type point struct {
	x int
	y int
}

type pair struct {
	x int
	y int
}

type Sumer interface {
	Sum() int
}

type Suber interface {
	Sub() int
}

func (p *pair) Sum() int {
	return p.x + p.y
}

func (p *point) Sum() int {
	return p.x + p.y
}

func (p pair) Sub() int {
	return p.x - p.y
}

func (p point) Sub() int {
	return p.x - p.y
}

func main() {
	fmt.Println("_key{} == _key{}: ", _key{} == _key{}) // output: true

	fmt.Println("point{} == point{}: ", point{x: 1, y: 2} == point{x: 1, y: 2})     // output: true
	fmt.Println("&point{} == &point{}: ", &point{x: 1, y: 2} == &point{x: 1, y: 2}) // output: false

	fmt.Println("[2]point{} == [2]point{}: ", 
	  [2]point{point{x: 1, y: 2}, point{x: 2, y: 3}} == [2]point{point{x: 1, y: 2}, point{x: 2, y: 3}}) //output: true

	var a Sumer = &pair{x: 1, y: 2}
	var a1 Sumer = &pair{x: 1, y: 2}
	var b Sumer = &point{x: 1, y: 2}
	fmt.Println("Sumer.byptr == Sumer.byptr: ", a == b)        // output: false
	fmt.Println("Sumer.sametype == Sumer.sametype: ", a == a1) // output: false

	var c Suber = pair{x: 1, y: 2}
	var d Suber = point{x: 1, y: 2}
	var d1 point = point{x: 1, y: 2}
	fmt.Println("Suber.byvalue == Suber.byvalue: ", c == d)  // output: false
	fmt.Println("Suber.byvalue == point.byvalue: ", d == d1) // output: true

	ci1 := make(chan int, 1)
	ci2 := ci1
	ci3 := make(chan int, 1)
	fmt.Println("chan int == chan int: ", ci1 == ci2) // output: true
	fmt.Println("chan int == chan int: ", ci1 == ci3) // output: false
}
```

上面的例子让我们较直观地了解结构体，数组，指针，chan在什么场景下是相等。我们再来看Go语言规范中是怎么说的：

- Pointer values are comparable. Two pointer values are equal if they point to the same variable or if both have value nil. Pointers to distinct zero-size variables may or may not be equal.当指针指向同一变量，或同为nil时指针相等，但指针指向不同的零值时可能不相等。
- Channel values are comparable. Two channel values are equal if they were created by the same call to make or if both have value nil.Channel当指向同一个make创建的或同为nil时才相等
- Interface values are comparable. Two interface values are equal if they have identical dynamic types and equal dynamic values or if both have value nil.从上面的例子我们可以看出，当接口有相同的动态类型并且有相同的动态值，或者值为都为nil时相等。要注意的是：参考[理解Go Interface](/post/technical/2016/0803_go_interface/)
- A value x of non-interface type X and a value t of interface type T are comparable when values of type X are comparable and X implements T. They are equal if t's dynamic type is identical to X and t's dynamic value is equal to x.如果一个是非接口类型X的变量x，也实现了接口T，与另一个接口T的变量t，只t的动态类型也是类型X，并且他们的动态值相同，则他们相等。
- Struct values are comparable if all their fields are comparable. Two struct values are equal if their corresponding non-blank fields are equal.结构体当所有字段的值相同，并且没有 相应的非空白字段时，则他们相等，
- Array values are comparable if values of the array element type are comparable. Two array values are equal if their corresponding elements are equal.两个数组只要他们包括的元素，每个元素的值相同，则他们相等。

注意：Go语言里是无法重载操作符的，struct是递归操作每个成员变量，struct也可以称为map的key，但如果struct的成员变量里有不能进行`==`操作的，例如slice，那么就不能作为map的key。

## 类型判断

判断两个变量是否相等，首先是要判断变量的动态类型是否相同，在runtime中，`_type`结构是描述最为基础的类型（`runtime/type.go`），而map, slice, array等内置的复杂类型也都有对应的类型描述（如maptype，slicetype，arraytype）。

```
type _type struct {
	size       uintptr
	ptrdata    uintptr 
	hash       uint32
	tflag      tflag
	align      uint8
	fieldalign uint8
	kind       uint8
	alg        *typeAlg
	gcdata    *byte
	str       nameOff
	ptrToThis typeOff
}
...
type chantype struct {
	typ  _type
	elem *_type
	dir  uintptr
}
...
type slicetype struct {
	typ  _type
	elem *_type
}
...
```

其中对于类型的值是否相等，需要使用到成员`alg *typeAlg`(`runtime/alg.go`)，它则持有此类型值的hash与equal的算法，它也是一个结构体:

```
type typeAlg struct {
	// function for hashing objects of this type
	// (ptr to object, seed) -> hash
	hash func(unsafe.Pointer, uintptr) uintptr
	// function for comparing objects of this type
	// (ptr to object A, ptr to object B) -> ==?
	equal func(unsafe.Pointer, unsafe.Pointer) bool
}
```

`runtime/alg.go`中提供了各种基础的`hash func`与 `equal func`，例如：

```
func strhash(a unsafe.Pointer, h uintptr) uintptr {
	x := (*stringStruct)(a)
	return memhash(x.str, h, uintptr(x.len))
}

func strequal(p, q unsafe.Pointer) bool {
	return *(*string)(p) == *(*string)(q)
}
```

有了这些基础的`hash func`与 `equal func`，再复杂的结构体也可以按字段递归计算hash与相等比较了。那我们再来看一下，当访问map[key]时，其实现对应在`runtime/hashmap.go`中的`mapaccess1`函数:

```
func mapaccess1(t *maptype, h *hmap, key unsafe.Pointer) unsafe.Pointer {
	...
	alg := t.key.alg
	hash := alg.hash(key, uintptr(h.hash0)) // 1
	m := uintptr(1)<<h.B - 1
	b := (*bmap)(add(h.buckets, (hash&m)*uintptr(t.bucketsize))) // 2
	...
	top := uint8(hash >> (sys.PtrSize*8 - 8))
	if top < minTopHash {
		top += minTopHash
	}
	for {
		for i := uintptr(0); i < bucketCnt; i++ {
			...
			k := add(unsafe.Pointer(b), dataOffset+i*uintptr(t.keysize))
			if alg.equal(key, k) { // 3
				v := add(unsafe.Pointer(b), dataOffset+bucketCnt*uintptr(t.keysize)+i*uintptr(t.valuesize))
				...
				return v
			}
		}
	...
	}
}

```

mapaccess1的代码还是比较多的，简化逻辑如下（参考注释上序列）：

1. 调用`key`类型的`hash`方法，计算出`key`的`hash`值
2. 根据`hash`值找到对应的桶`bucket`
3. 在桶中找到`key`值相等的map的`value`。判断相等需调用`key`类型的`equal`方法

到现在我们也就有了初步了解，map中的`key`访问时同时需要使用该类型的`hash func`与 `equal func`，只要`key`值相等，当结构体即使不是同一对象，也可从map中获取相同的值，例如：

```
m := make(map[interface{}]interface{})
m[_key{}] = "value"
if v, ok := m[_key{}];ok {
	fmt.Println("%v", v) // output: value
}
```

----
参考：   
[1] https://blog.golang.org/go-maps-in-action   
[2] https://golang.org/ref/spec#Comparison_operators   
