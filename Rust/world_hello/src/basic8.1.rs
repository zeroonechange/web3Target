// 动态数组
// 集合类型  动态数组   hashmap
fn main() {
    let mut v = Vec::new();
    v.push(1);

    let v1 = vec![1, 2, 3];
    let third = &v[2];
    println!("third = {}", third);

    match v.get(2) {
        // 安全  不回数组越界
        Some(third) => println!("third = {}", third),
        None => println!("no third"),
    }

    let mut v2 = vec![1, 2, 3, 4, 5];
    let first = &v2[0];
    // v2.push(6);  // 数组大小可变  会重新分配一块内存
    println!("first = {}", first);

    let v3 = vec![1, 2, 3];
    for i in &v3 {
        println!("i = {}", i);
    }

    let mut v4 = vec![1, 2, 3];
    for i in &mut v4 {
        *i += 1;
    }
}

#[derive(Debug)]
enum IpAddr {
    V4(String),
    V6(String),
}

fn main1() {
    let v = vec![IpAddr::V4(String::from("127.0.0.1")), IpAddr::V6(String::from("::1"))];
    for ip in v {
        println!("ip = {:?}", ip);
    }
}

trait IpAddrs {
    fn display(&self);
}
struct V4(String);

impl IpAddrs for V4 {
    fn display(&self) {
        println!("V4 = {}", self.0);
    }
}

struct V6(String);

impl IpAddrs for V6 {
    fn display(&self) {
        println!("V6 = {}", self.0);
    }
}

fn main2() {
    let v: Vec<Box<dyn IpAddrs>> = vec![
        Box::new(V4(String::from("127.0.0.1"))),
        Box::new(V6(String::from("::1")))
    ];
    for ip in v {
        ip.display();
    }
}

fn _sort() {
    let mut vec = vec![11, 2, 13, 4, 25];
    vec.sort_unstable();

    let mut vecf = vec![1.1, 0.2, 1.3, 4.1, 2.5];
    // vecf.sort_unstable();  // float 有个 NAN
    vecf.sort_unstable_by(|a, b| a.partial_cmp(b).unwrap());
}

// #[derive(Debug)]
#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
struct Person {
    name: String,
    age: u8,
}
impl Person {
    fn new(name: String, age: u8) -> Person {
        Person {
            name,
            age,
        }
    }
}
fn _sort_struct() {
    let mut people = vec![
        Person::new(String::from("张三"), 18),
        Person::new(String::from("李四"), 19),
        Person::new(String::from("王五"), 20)
    ];
    people.sort_unstable_by(|a, b| b.age.cmp(&a.age));
    println!("{:?}", people);
}
