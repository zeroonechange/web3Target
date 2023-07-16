// 模式适用场景
// 模式匹配   match 和 if let   解构Option   模式适用场景  全模式列表

// 字面值  数组 枚举  结构体 元祖  变量  通配符  占位符
fn main() {
    // if let  只匹配一个
    // while let  只要匹配就一直循环
    {
        let mut stack = Vec::new();
        stack.push(1);
        stack.push(2);
        stack.push(3);
        while let Some(top) = stack.pop() {
            println!("{}", top); // 3 2 1
        }
    }

    {
        let v = vec!['a', 'b', 'c'];
        for (index, value) in v.iter().enumerate() {
            println!("{} is at index {}", value, index);
        }
    }
}
fn foo(x: i32) {}

fn print_coordinates(&(x, y): &(i32, i32)) {
    println!("x: {}, y: {}", x, y);
}
