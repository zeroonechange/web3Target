rust链表 皇冠上的明珠

```
第一本书-圣经   https://course.rs/about-book.html
官方文档        https://kaisery.github.io/trpl-zh-cn/title-page.html
通过例子学rust  https://rustwiki.org/zh-CN/rust-by-example/
```

```rust
不错的 unsafe 队列
    Rc 和 RefCell 对于简单任务非常ok  复杂任务就要歇菜
    使用 裸指针 + unsafe 单向链表
    将一个普通的引用变成裸指针: 强制转换 Coercions
    let raw_tail: *mut _ = &mut *new_tail;
    unsafe{ (*self.tail).next = Some(new_tail); }  创建原生指针安全 解引用不安全

Miri
    可以生成 Rust 的中间层表示 MIR，对于编译器来说，我们的 Rust 代码首先会被编译为 MIR ，然后再提交给 LLVM 进行处理
    通过 rustup component add miri 来安装它，并通过 cargo miri 来使用，同时还可以使用 cargo miri test 来运行测试代码
    miri 可以帮助我们检查常见的未定义行为(UB = Undefined Behavior)，以下列出了一部分:
        内存越界检查和内存释放后再使用(use-after-free)
        使用未初始化的数据
        数据竞争
        内存对齐问题
    UB 检测是必须的，因为它发生在运行时，因此很难发现，如果 miri 能在编译期检测出来，那自然是最好不过的。

$ rustup +nightly-2023-08-13 component add miri
$ rustup +nightly component add miri
$ cargo +nightly-2022-01-21 miri test

栈借用-rust来处理再借用的解决方案  指针混叠  俩个指针指向的内存区域存在重叠
    严格的借用规则是我们的后盾：要么同时存在一个可变引用，要么同时存在多个不可变引用，这种规则简直完美避免了：两个指针指向同一块儿重叠内存区域，而其中一个是可变指针。
使用栈来存放嵌套的借用 存在多个借用 同一时间只有一个可边引用访问目标内存  使用 unsafe 借用检查器无法帮助我们
只有栈顶是处于live状态被借用
访问栈顶下面元素时，该元素会变为live，栈顶会弹出，弹出的元素无法再被借用

对裸指针进行拷贝
一旦开始使用裸指针 就要尝试只使用它

案例:  &mut -> *mut -> &mut -> *mut
unsafe {
    let mut data = 10;
    let ref1 = &mut data;
    let ptr2 = ref1 as *mut _;
    let ref3 = &mut *ptr2;
    let ptr4 = ref3 as *mut _;
    // Access things in "borrow stack" order
    *ptr4 += 4;
    *ref3 += 3;
    *ptr2 += 2;
    *ref1 += 1;
    println!("{}", data);
}

不允许我们对数组的不同元素进行单独的借用 - 将一个数组分成多个部分

裸指针可以被简单的拷贝只要它们共享同一个借用

无法将一个不可变的引用转换成可变的裸指针
    let ptr4 = sref3 as *const i32 as *mut i32;
先将不可变引用转换成不可变的裸指针，然后再转换成可变的裸指针

在借用栈中，一个不可变引用，它上面的所有引用( 在它之后被推入借用栈的引用 )都只能拥有只读的权限。

Box 在某种程度上类似 &mut，因为对于它指向的内存区域，它拥有唯一的所有权。

将安全的指针 & 、&mut 和 Box 跟不安全的裸指针 *mut 和 *const 混用是 UB 的根源之一
当使用裸指针时，Option 对我们是相当不友好的
借用 Box，再借用一个裸指针，然后先弹出该裸指针，再弹出 Box
从安全的东东开始，将其转换成裸指针，最后再将裸指针转回安全的东东以实现安全的 drop
    let x = Box::new(String::from("Hello"));
    let ptr = Box::into_raw(x);  // 消费掉 Box (拿走所有权)，返回一个裸指针
    let x = unsafe { Box::from_raw(ptr) };  // 使用 Box::from_raw 来清理内存


```

```rust
不咋样的双端队列   让Rc可变
    使用 RefCell  拥有不可变引用的同时修改目标数据  Cell 和 RefCell 没啥区别  Cell<T> 适用于 T 实现了 Copy 不会panic  而 RefCell提供引用 会panic
    Cell 可无限 get 和  set
    内部可变性？ 对一个不可变的值进行可变借用  let x=5;  let y=&mut x;
    常见组合 Rc + RefCell  前者实现一个数据拥有多个所有者 后者实现了数据的可变性
        Cell::from_mut，该方法将 &mut T 转为 &Cell<T>
        Cell::as_slice_of_cells，该方法将 &Cell<[T]> 转为 &[Cell<T>]

        Cell 和 RefCell 都为我们带来了内部可变性这个重要特性，同时还将借用规则的检查从编译期推迟到运行期，但是这个检查并不能被绕过，该来早晚还是会来，RefCell 在运行期的报错会造成 panic
        RefCell 适用于编译器误报或者一个引用被在多个代码中使用、修改以至于难于管理借用关系时，还有就是需要内部可变性时。
        从性能上看，RefCell 由于是非线程安全的，因此无需保证原子性，性能虽然有一点损耗，但是依然非常好，而 Cell 则完全不存在任何额外的性能损耗。
        Rc 跟 RefCell 结合使用可以实现多个所有者共享同一份数据，非常好用，但是潜在的性能损耗也要考虑进去，建议对于热点代码使用时，做好 benchmark

        Option<>.take  clone   map
        borrow_mut()
        RecCekk.into_inner()
        Rc::try_unwrap(xx).ok().unwrap().into_inner().elem

        while self.pop_front().is_some() {}

        self.head.as_ref().map( |node|  {
            Ref::map(node.borrow(), |node|  &node.elem)
        })

        RefMut::map(node.borrow(), |node|  &node.elem)
```

```rust
持久化单向链表   共享所有权
使用 RC/ARC   clone
为啥要用 Option<Rc<Node<T>>>  而不是  Rc<Node<T>>  因为 option也有这种功能

    option.take()
    option.as_ref().and_then()
    option.as_deref()
Rc::try_unwrap(node)


```

```rust
还可以的单向链表  -- peek intoIter  Iter  IterMut

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

    as_deref() 代替类似 map(|node| &**node)  而 as_deref_mut() 代替 map(|node| &mut**node)



```

```rust
不太优秀的单向链表  -- 基操

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
