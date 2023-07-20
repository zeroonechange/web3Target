// 认识生命周期
fn main() {
    // &i32;
    // &'a i32;
    // &'a mut i32;

}

fn _longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}
//结构体生命周期
struct ImportantExcept<'a> {
    part: &'a str,
}
/**
 * 三条消除规则
 * 1. 函数每一个参数都有自己的生命周期
 * 2. 只有一个参数 那么它的生命周期会返回给输出
 * 3. 多个生命周期  有一个是self 那么会赋给所有输出
 */

/**
 * 方法的生命周期
 */
impl<'a> ImportantExcept<'a> {
    fn _annnoce_and_return_part0(&self, annoncement: &str) -> &str {
        println!("annnoce_and_return_part {}", annoncement);
        self.part
    }

    fn _annnoce_and_return_part<'b>(&'a self, annoncement: &'b str) -> &'a str {
        println!("annnoce_and_return_part {}", annoncement);
        self.part
    }

    fn _annnoce_and_return_part1<'b>(&'a self, annoncement: &'b str) -> &'b str where 'a: 'b {
        println!("annnoce_and_return_part {}", annoncement);
        self.part
    }
}

/**
 * 静态生命周期
 */
fn _main2() {
    let _s: &'static str = "hello";
}

use std::fmt::Display;
// 泛型  特征约束  生命周期
fn _longest_with_an_annoncement<'a, T>(x: &'a str, y: &'a str, ann: T) -> &'a str where T: Display {
    println!("annnoce!  {}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
