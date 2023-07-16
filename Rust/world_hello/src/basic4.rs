// 流程控制
// if - else
// for
// continue  break
// while loop
fn main() {
    for i in 1..=5 {
        println!("{}", i);
    }
    for item in &[1, 2, 3] {
    }
    for item in &mut [1, 2, 3] {
        *item += 1;
    }
    let a = [4, 3, 2, 1];
    for (i, v) in a.iter().enumerate() {
        println!("{}:{}", i, v);
    }
    for _ in 0..10 {
    }

    for item in a {
    }

    {
        let mut n = 0;
        while n <= 5 {
            println!("{}", n);
            n += 1;
        }

        loop {
            if n > 5 {
                break;
            }
            print!("{}", n);
            n += 1;
        }
    }
    // for 循环效率最高
    // loop 是一个简单的无限循环
}
