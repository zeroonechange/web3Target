// 格式化输出
fn _main_1() {
    println!("{:?}", (3, 4));
    println!("{value}", value = 4);
    println!("{:08}", 42); // 先输出8个0  后面俩个0替换成42
}

// print! println!  format!
fn main() {
    let s = "nidaye";
    let s1 = format!("{}, aaaaaa", s);
    println!("{:?}", s1);
    eprintln!("Error: could not complete task");
    // {}    std::fmt::Display
    // {:?}  std::fmt::Debug
    // {:#?} 和 {:?} 一样   更优美输出
    let v = vec![1, 2, 3];
    println!("{:?}", v);
    println!("{:#?}", v);

    let p = Person {
        name: "nidaye".to_string(),
        age: 18,
    };
    println!("{}", p);

    println!("{} {}", 1, 2);

    println!("{1} {} {0} {}", 1, 2);

    println!("{name} {age}", age = 19, name = "xxxx");

    let v = 3.1415926;
    println!("{:.2}", v);
    println!("{:+.2}", v);
    println!("{:.0}", v);
    println!("{:.1$}", v, 4);

    let s = "hi我是Sunface孙飞";
    println!("{:.3}", s);
    println!("bbb {:.*} ccc", 3, "aaa");

    // 宽度  对齐  精度   进制  指数    指针地址
    println!("hello ---{:5}---", "x");
    println!("hello ---{:1$}---", "x", 5);
    println!("hello ---{1:0$}---", 5, "x");
    println!("hello ---{:width$}---", "x", width = 5);

    println!("world ---{:5}---", 8);
    println!("world ---{:+}---", 8);
    println!("world ---{:05}---", 8);
    println!("world ---{:05}---", -8);

    // 二进制 => 0b11011!
    println!("{:#b}!", 27);
    // 八进制 => 0o33!
    println!("{:#o}!", 27);
    // 十进制 => 27!
    println!("{}!", 27);
    // 小写十六进制 => 0x1b!
    println!("{:#x}!", 27);
    // 大写十六进制 => 0x1B!
    println!("{:#X}!", 27);
    // 不带前缀的十六进制 => 1b!
    println!("{:x}!", 27);
    // 使用0填充二进制，宽度为10 => 0b00011011!
    println!("{:#010b}!", 27);

    println!("{:2e}", 1000000000); // => 1e9
    println!("{:2E}", 1000000000); // => 1E9

    let v = vec![1, 2, 3];
    println!("{:p}", v.as_ptr()); // => 0x600002324050

    let pppp = get_person();
    println!("{pppp}");
}

fn get_person() -> String {
    String::from("nidaye")
}

struct Person {
    name: String,
    age: u8,
}
use std::fmt;
impl fmt::Display for Person {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "大佬在上 小弟在下,name: {}, age: {}", self.name, self.age)
    }
}
