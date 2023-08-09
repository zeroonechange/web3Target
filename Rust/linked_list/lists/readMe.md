rust链表 皇冠上的明珠

```rust

Option
用 Option.take 方法来替代 mem::replace

泛型支持 所有类型的值

定义peek 函数   返回表头元素的引用

Option.as_ref()  将一个 Option<T> 变成一个 Option<&T>      不可变引用
Option.as_mut()  将一个 Option<T> 变成一个 Option<&mut T>    可变引用


每个集合都应该实现3种迭代器
IntoIter - T             类型迭代器的 next 方法会拿走被迭代值的所有权
IterMut - &mut T         是可变借用
Iter - &T                是不可变借用

```

```rust
    指针类型: &, &mut, Box, Rc, Arc, *const, *mut, NonNull
    所有权、借用、继承可变性、内部可变性、Copy
    所有的关键字：struct、enum、fn、pub、impl、use, ...
    模式匹配、泛型、解构
    测试、安装新的工具链、使用 miri
    Unsafe: 裸指针、别名、栈借用、UnsafeCell、变体 variance
是的，链表就是这么可怕，只有将这些知识融会贯通后，你才能掌握



Box: 智能指针  分配在堆上  一切对象皆Box   实现了Deref 和 Drop 特征  前者有引用功能 后者作用域后数据清除
Rc, Arc: 通过引用计数的方式，允许一个数据资源在同一时刻拥有多个所有者   前者适用于单线程，后者适用于多线程
裸指针: 绕过借用规则，可同时拥有一个数据的可变、不可变指针，甚至还能拥有多个可变的指针
                *const T 和 *mut T，它们分别代表了不可变和可变   * 只是类型名称的一部分，并没有解引用的含义
Copy : 只拷贝栈上的数据  浅拷贝  非常快  |||  而clone 就是深拷贝  deep copy
模式匹配: match  if-let  while-let
解构: (a,b)=(1,2)   结构体 枚举 嵌套结构体和枚举 结构体和元组  数组

所有栈上的类型都必须在编译期有固定的长度，一个简单的解决方案就是使用 Box 将值封装到堆上，然后使用栈上的定长指针来指向堆上不定长的值


首先，考虑一个拥有两个元素的 List:
        [] = Stack
        () = Heap
        [Elem A, ptr] -> (Elem B, ptr) -> (Empty, *junk*)
这里有两个问题:
        最后一个节点分配在了堆上，但是它看上去根本不像一个 Node
        第一个 Node 是存储在栈上的，结果一家子不能整整齐齐的待在堆上了
这两点看上去好像有点矛盾：你希望所有节点在堆上，但是又觉得最后一个节点不应该在堆上。

那再来考虑另一种布局( Layout )方式：
        [ptr] -> (Elem A, ptr) -> (Elem B, *null*)
不再有junk   junk是什么？  看看枚举的内存布局
---------------------------------------------
枚举类型的内存布局( Layout )
enum Foo {
   D1(u8),
   D2(u16),
   D3(u32),
   D4(u64)
}
枚举成员占用的内存空间大小跟最大的成员对齐，在这个例子中，所有的成员都会跟 u64 进行对齐。
---------------------------------------------
                pub struct Node {
                    pub elem: i32,
                    pub next: List,
                }

                pub enum List {
                    Empty,
                    More(Box<Node>),
                }
---------------------------------------------
                pub struct List {
                    head: Link,
                }

                enum Link {
                    Empty,
                    More(Box<Node>),
                }

                struct Node {
                    elem: i32,
                    next: Link,
                }
---------------------------------------------


在 Rust 中，有两个self，一个指代当前的实例对象，一个指代特征或者方法类型的别名
self指代的就是当前的实例对象，也就是 button.draw() 中的 button 实例，Self 则指代的是 Button 类型

std::men:replace 允许从一个借用中偷出一个值的同时再放入一个新值   std::mem::replace(&mut self.head, Link::Empty);   偷梁换柱
panics 发散函数  不返回任何值 用于需要返回任何类型的地方
使用 unimplemented!() 发生一个panic
结构体所有权   clone使用    &mut self 可以

自动化测试脚本
drop 的实现  &mut self 的匹配   fn drop(&mut self) {  match *self{ Link::EMpty=>{} }}    &mut self  --- *self
Box 的实现     fn drop(&mut self)  { self.ptr.drop();    deallocate(self.ptr);   }
while let使用  从右到左   +  Box 解引用
        let mut cur_link = mem::replace(&mut self.head, Link::Empty);
        while let Link::More(mut boxed_node) = cur_link{
                cur_link = mem:replace(&mut boxed_node, Link::Empty);
        }
```
