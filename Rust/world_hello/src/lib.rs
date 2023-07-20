pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
}
// 所有模块均在同一个文件中    代码组织
/**
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment 
 */
mod front_of_house {
    // 使用mod 创建模块    可嵌套  可定义各种rust类型 例函数 结构体 枚举 特征等
    mod hosting {
        fn add_to_waitlist() {}
        fn seat_at_table() {}
    }

    mod serving {
        fn take_order() {}
        fn serve_order() {}
        fn take_payment() {}
    }
}
//父子模块
// Rust 出于安全的考虑，默认情况下，所有的类型都是私有化的，包括函数、方法、结构体、枚举、常量，是的，就连模块本身也是私有化的。
// 在中国，父亲往往不希望孩子拥有小秘密，
// 但是在 Rust 中，父模块完全无法访问子模块中的私有项，但是子模块却可以访问父模块、父父..模块的私有项。
mod front_of_housee {
    pub mod hosting {
        pub fn add_to_waitlist() {}
    }
}
pub fn eat_at_restaurant() {
    crate::front_of_housee::hosting::add_to_waitlist(); // 绝对路径
    front_of_housee::hosting::add_to_waitlist(); // 相对路径
}

// 使用 super

fn serve_order() {
    self::back_to_house::cook_order();
}

mod back_to_house {
    fn fix_incorrect_order() {
        cook_order();
        super::serve_order();
        crate::serve_order()
    }
    pub fn cook_order() {}
}

/*
 * 结构体和枚举的可见性
 * 将结构体设置为 pub，但它的所有字段依然是私有的
 * 将枚举设置为 pub，它的所有字段也将对外可见
 */

mod front_of_hose; // 要有 这个文件 front_of_hose.rs
pub use crate::front_of_hose::hosting;

pub fn eat_restauranttt() {
    hosting::add_to_waitlist();
}

pub use crate::front_of_hose::hosting::add_to_waitlist;

pub fn eat_restaurantttttt() {
    add_to_waitlist();
}

use std::fmt::Result;
use std::io::Result as IoResult;
fn f1() -> Result {}
fn f2() -> IoResult {}

// 引入第三方包
// 修改 Cargo.toml 文件，在 [dependencies] 区域添加一行：rand = "0.8.3"
// use xxx::{self, yyy}，表示，加载当前路径下模块 xxx 本身，以及模块 xxx 下的 yyy
// use std::collections::*;   引入模块下的所有项

//  受限可见性    pub(crate)    某些可见  某些不可见
pub mod a {
    pub const I: i32 = 3;

    fn semisecret(x: i32) -> i32 {
        use self::b::c::J;
        x + J
    }

    pub fn bar(z: i32) -> i32 {
        semisecret(I) * z
    }
    pub fn foo(y: i32) -> i32 {
        semisecret(I) + y
    }

    /** 限制可见性语法 
        pub 意味着可见性无任何限制
        pub(crate) 表示在当前包可见
        pub(self) 在当前模块可见
        pub(super) 在父模块可见
        pub(in <path>) 表示在某个路径代表的模块中可见，其中 path 必须是父模块或者祖先模块
     */
    mod b {
        pub(in crate::a) mod c {
            // 只有a才能访问它 J
            pub(in crate::a) const J: i32 = 4;
        }
    }
}

// final example
mod my_mod {
    fn private_function() {
        println!("called `my_mod::private_function()`");
    }

    pub fn function() {
        println!("called `my_mod::function()`");
    }

    pub fn indirect_access() {
        println!("called `my_mod::indirect_access()`");
        private_function();
    }

    pub mod nested {
        pub fn function() {
            println!("called `my_mod::nested::function()`");
        }
        #[allow(dead_code)]
        fn private_function() {
            println!("called `my_mod::nested::private_function()`");
        }
        pub(in crate::my_mod) fn public_function_in_my_mod() {
            println!("called `my_mod::nested::public_function_in_my_mod(), that \nbelongs `");
            public_function_in_nested()
        }
        pub(self) fn public_function_in_nested() {
            println!("called `my_mod::nested::public_function_in_nested()`");
        }

        pub(super) fn public_function_in_super_mod() {
            println!("called `my_mod::nested::public_function_in_super_mod()`");
        }
    }

    pub fn call_public_function_in_my_mod() {
        print!("called `my_mod::call_public_function_in_my_mod()`");
        nested::public_function_in_my_mod();
        print!(">");
        nested::public_function_in_super_mod();
    }

    pub(crate) fn public_function_in_crate() {
        println!("called `my_mod::public_function_in_crate()`");
    }

    mod private_nested {
        #[allow(dead_code)]
        pub fn function() {
            println!("called `my_mod::private_nested::function()`");
        }
    }
}

fn function() {
    println!("called `function()`");
}

fn main() {
    function();
    my_mod::function();

    my_mod::indirect_access();
    my_mod::nested::function();
    my_mod::call_public_function_in_my_mod();

    my_mod::public_function_in_crate()
}
