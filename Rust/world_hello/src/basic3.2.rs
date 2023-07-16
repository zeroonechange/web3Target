// 元祖
// 复合类型  字符串 元祖  结构体  枚举  数组

fn main() {
    {
        let tup: (i32, f64, u8) = (500, 6.4, 1);
        let first = tup.0;
        let second = tup.1;
        let third = tup.2;
        println!("{}, {}, {}", first, second, third);
    }

    {
        let tup = (500, 6.4, 1);
        let (x, y, z) = tup;
        println!("{}, {}, {}", x, y, z);
    }

    {
        let s1 = String::from("hello");
        let (s2, len) = calculate_length(s1);
        println!("{} {}", s2, len);
    }
}

fn calculate_length(s: String) -> (String, usize) {
    let length = s.len();
    (s, length)
}
