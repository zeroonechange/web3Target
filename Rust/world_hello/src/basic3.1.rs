// 字符串
// 复合类型  字符串  元祖  结构体  枚举  数组

fn main1() {
    // let name = "tom jackson";
    let name = String::from("tom jackson");
    greet(name);

    let s = String::from("jerry");
    say_hello(&s);
    say_hello(&s[..]);
    say_hello(s.as_str());

    let hello = "中国人"; // 占用了 3*4 = 12 字节
    //String 是可变的     &str 是不可变的
    // 1. 追加 push
    {
        let mut s = String::from("hello");
        s.push_str(" world");
        println!("{}", s);
    }
    // 2.插入
    {
        let mut s = String::from("hello Rust");
        s.insert(5, ',');
        println!("{}", s);
        s.insert_str(6, "I like");
        println!("{}", s);
    }
    // 3. 替换
    {
        {
            let s = String::from("I like rust, learing rust is my favorite");
            let new_s = s.replace("rust", "Rust");
            dbg!(new_s);
        }

        {
            let mut s = String::from("I like rust, learing rust is my favorite");
            let new_s = s.replacen("rust", "Rust", 1);
            dbg!(new_s);
        }
        {
            let mut s = String::from("I like rust");
            s.replace_range(7..8, "R");
            dbg!(s);
        }
    }
    // 4 删除
    {
        {
            let mut pop = String::from("rust pop 中文!");
            let p1 = pop.pop();
            let p2 = pop.pop();
            dbg!(p1);
            dbg!(p2);
            dbg!(pop);
        }
        {
            let mut s = String::from("测试remove方法");
            println!("占{}个字节", std::mem::size_of_val(s.as_str()));
            s.remove(0);
            dbg!(s);
        }
        {
            let mut s = String::from("测试truncate");
            s.truncate(3);
            dbg!(s);
        }
        {
            let mut s = String::from("string clear");
            s.clear();
            dbg!(s);
        }
    }
    // 5. 连接
    {
        // +
        {
            let s1 = String::from("hello");
            let s2 = String::from("rust");
            let result = s1 + &s2;
            let mut result = result + "!";
            result += "!!!";
            println!("{}", result);

            let a1 = String::from("hello");
            let a2 = String::from("world");
            let a3 = String::from("tocix");
            let aaaa = a1 + " " + &a2 + " " + &a3;
            println!("{:?}", aaaa);
        }

        // format!()
        {
            let s1 = "hello";
            let s2 = String::from("rust");
            let s = format!("{} {}! ", s1, s2);
            println!("{}", s);
        }
    }

    {
        // 通过 \ + 字符的十六进制表示，转义输出一个字符
        let byte_escape = "I'm writing \x52\x75\x73\x74!";
        println!("What are you doing\x3F (\\x3F means ?) {}", byte_escape);

        // \u 可以输出一个 unicode 字符
        let unicode_codepoint = "\u{211D}";
        let character_name = "\"DOUBLE-STRUCK CAPITAL R\"";

        println!("Unicode character {} (U+211D) is called {}", unicode_codepoint, character_name);

        // 换行了也会保持之前的字符串格式
        // 使用\忽略换行符
        let long_string =
            "String literals
                        can span multiple lines.
                        The linebreak and indentation here ->\
                        <- can be escaped too!";
        println!("{}", long_string);
    }

    {
        println!("{}", "hello \\x52\\x75\\x73\\x74");
        let raw_str = r"Escapes don't work here: \x3F \u{211D}";
        println!("{}", raw_str);

        // 如果字符串包含双引号，可以在开头和结尾加 #
        let quotes = r#"And then I said: "There is no escape!""#;
        println!("{}", quotes);

        // 如果还是有歧义，可以继续增加，没有限制
        let longer_delimiter = r###"A string with "# in it. And even "##!"###;
        println!("{}", longer_delimiter);
    }

    {
        // 字符
        for c in "中国人".chars() {
            println!("{}", c);
        }

        // 字节
        for c in "中国人".bytes() {
            println!("{}", c);
        }
    }
}
fn say_hello(name: &str) {
    println!("hello {}", name)
}
fn greet(name: String) {
    println!("hello {}", name)
}
/*
#![allow(unused_variables)]
type File = String;
fn open(f: &mut File) -> bool {
    true
}
fn close(f: &mut File) -> bool {
    true
}
#[allow(dead_code)]
fn read(f: &mut File, save_to: &mut Vec<u8>) -> ! {
    unimplemented!()
}

fn main() {
    let mut f1 = File::from("f1.txt");
    open(&mut f1);
    close(&mut f1);
}
 */
