// 特征trait   抽象类
// 泛型  特征trait  特征对象  深入特征

use std::{ fmt::Display, process::Output };

pub trait Summary {
    fn summarize(&self) -> String;
    fn summarize_default(&self) -> String {
        // 默认实现
        String::from("Read more....")
    }
}
pub struct Post {
    pub title: String,
    pub author: String,
    pub content: String,
}

impl Summary for Post {
    fn summarize(&self) -> String {
        format!("标题是{} - 作者是{} - 内容是{}", self.title, self.author, self.content)
    }
}

pub struct Weibo {
    pub username: String,
    pub content: String,
}

impl Summary for Weibo {
    fn summarize(&self) -> String {
        format!("昵称是{} - 内容是{}", self.username, self.content)
    }
}

fn main1() {
    let post = Post {
        title: String::from("rust "),
        author: String::from("jack"),
        content: String::from("---i love rust--- its like my old friends"),
    };
    println!("{}", post.summarize());

    let weibo = Weibo {
        username: String::from("jack"),
        content: String::from("hello"),
    };

    println!("{}", weibo.summarize());
}

// 特征作为函数参数  类似于传接口给函数   具体实现靠子类
pub fn notify(item: &impl Summary) {
    println!("breaking news : {}", item.summarize());
}

pub fn notify_normal<T: Summary>(item: &T) {
    print!("breaking news : {}", item.summarize());
}
//多个相同类型特征
pub fn notify_multi<T: Summary>(item1: &T, item2: &T) {}

pub fn notify_more<T: Summary + Display>(item: &T) {}

// 多个特征  多参
fn some_func<T: Display + Clone, U: Clone + PartialOrd>(t: &T, u: &U) -> i32 {
    1
}

// 用表达式解决  好看
fn some_func2<T, U>(t: &T, u: &U) -> i32 where T: Display + Clone, U: Clone + PartialOrd {
    1
}

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self {
            x,
            y,
        }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x > self.y {
            println!("the largest member is {}", self.x);
        } else {
            println!("the largest member is {}", self.y);
        }
    }
}

// 特征作为函数返回值
fn returns_summarizable() -> impl Summary {
    Weibo {
        username: String::from("jack"),
        content: String::from("hello"),
    }
}

// 只能返回一个具体的类型
fn return_summarizable(_switch: bool) -> impl Summary {
    // if switch {
    Post {
        title: String::from("rust "),
        author: String::from("jack"),
        content: String::from("---i love rust--- its like my old friends"),
    }
    // }
    // else {
    //     Weibo {
    //         username: String::from("jack"),
    //         content: String::from("hello"),
    //     }
    // }
}

fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];
    for &item in list {
        if item > largest {
            largest = item;
        }
    }
    largest
}

fn main2() {
    let number_list = vec![34, 12, 22, 100, 56];
    let resut = largest(&number_list);
    println!("the largest number is {}", resut);

    let char_list = vec!['y', 'm', 'a', 'q'];
    let result = largest(&char_list);
    println!("the largest char is {}", result);

    println!("=============================");
    let a: i32 = 10;
    let b: u16 = 100;
    let b_ = b.try_into().unwrap();
    if a < b_ {
        println!("ten is less than one hundred {b_}");
    }
}

use std::ops::Add;

#[derive(Debug)] // 用了这玩意 就可以打印
struct Point<T: Add<T, Output = T>> {
    x: T,
    y: T,
}
impl<T: Add<T, Output = T>> Add for Point<T> {
    type Output = Point<T>;
    fn add(self, p: Point<T>) -> Point<T> {
        Point { x: self.x + p.x, y: self.y + p.y }
    }
}
fn add<T: Add<T, Output = T>>(a: T, b: T) -> T {
    a + b
}

fn main3() {
    let p1 = Point { x: 1.1f32, y: 1.1f32 };
    let p2 = Point { x: 2.1f32, y: 2.1f32 };
    println!("{:?}", add(p1, p2));

    let p3 = Point { x: 1i32, y: 1i32 };
    let p4 = Point { x: 2i32, y: 2i32 };
    println!("{:?}", add(p3, p4));
}

//  自定义打印

use std::fmt;

#[derive(Debug, PartialEq)]
enum FileState {
    Open,
    Closed,
}

#[derive(Debug)]
struct File {
    name: String,
    data: Vec<u8>,
    state: FileState,
}

impl Display for FileState {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match *self {
            FileState::Open => write!(f, "open"),
            FileState::Closed => write!(f, "closed"),
        }
    }
}

impl Display for File {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "{} -------- {}", self.name, self.state)
    }
}

impl File {
    fn new(name: &str) -> File {
        File {
            name: String::from(name),
            data: Vec::new(),
            state: FileState::Closed,
        }
    }
}

fn main() {
    let f6 = File::new("f6.txt");
    println!("{:?}", f6); // 这个用系统的  全打印
    println!("{}", f6); // 这个用到了自定义的
}
