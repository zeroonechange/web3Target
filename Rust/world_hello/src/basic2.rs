// 所有权和借用
fn main1() {
    let mut s = String::from("hello");
    s.push_str(" world");
    println!("{:?}", s);

    let x = 5;
    let y = x;
    println!("{}, {}", x, y);

    let s1 = String::from("hello");
    let _s2 = s1;
    // s1 已经没引用了
    // println!("{}, {}", s1, s2);

    let s3 = "hello world";
    let s4 = s3;
    println!("{}, {}", s3, s4);

    let s5 = String::from("hello");
    let s6 = s5.clone();
    println!("{}, {}", s5, s6);

    {
        let x = 5;
        let y = &x;
        println!("{}, {}", x, *y);
        assert_eq!(5, x);
        assert_eq!(5, *y);
    }

    {
        let s1 = String::from("hello");
        let len = calculate_length(&s1); // 不可变引用
        println!("{}, {}", s1, len);
    }

    {
        let mut s1 = String::from("hello");
        change(&mut s1);
    }

    {
        let mut s = String::from("hello");
        let r1 = &mut s;
        let r2 = &mut s;
        println!("{}, {}", r1, r2); // 报错
    }

    {
        let mut s = String::from("hello");
        let r1 = &s;
        let r2 = &s;
        let r3 = &mut s; // 报错  可变引用和不可变引用不能同时存在
        println!("{}, {}, {}", r1, r2, r3);
    }

    {
        let mut s = String::from("hello");
        let r1 = &s;
        let r2 = &s;
        println!("{}, {}", r1, r2);

        let r3 = &mut s; // 报错  可变引用和不可变引用不能同时存在
        println!("{}", r3);
    }
}

fn calculate_length(s: &String) -> usize {
    // s.push_str(" world");
    s.len()
}
fn change(some_string: &mut String) {
    some_string.push_str(", world");
}

fn dangle() -> &String {
    let s = String::from("hello");
    // &s
}

fn dangle_safe() -> String {
    let s = String::from("hello");
    s
}
