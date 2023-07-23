use core::fmt;

// 深入特征
// 泛型  特征trait  特征对象  深入特征

trait Container {
    type A;
    type B;
    fn contains(&self, a: &Self::A, b: &Self::B) -> bool;
}
fn difference<C: Container>(container: &C) {}

use std::ops::Add;
#[derive(Debug, PartialEq)]
struct Point {
    x: i32,
    y: i32,
}
impl Add for Point {
    type Output = Point; //
    fn add(self, other: Point) -> Point {
        Point { x: self.x + other.x, y: self.y + other.y }
    }
}

fn main1() {
    assert_eq!(Point { x: 1, y: 2 } + Point { x: 3, y: 4 }, Point { x: 4, y: 6 });
}

struct Millimeter(i32);
struct Meters(u32);

// impl Add<Meters> for Millimeter {
//     type Output = Millimeter;
//     fn add(self, other: Meters) -> Millimeter {
//         Millimeter(self.0 + other.0 * 10000)
//     }
// }

trait Animal {
    fn baby_name() -> String;
}
struct Dog;
impl Dog {
    // 扩展函数
    fn baby_name() -> String {
        String::from("Spot")
    }
}

impl Animal for Dog {
    // 实现接口 抽象类
    fn baby_name() -> String {
        String::from("puppy")
    }
}

fn main() {
    println!("{}", Dog::baby_name());
    println!("{}", <Dog as Animal>::baby_name()); // 完全限定语法
}

impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}
