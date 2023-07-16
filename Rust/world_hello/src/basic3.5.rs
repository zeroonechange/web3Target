// 数组
// 复合类型  字符串 元祖  结构体  枚举  数组

use std::io;
fn main() {
    // 速度很快 长度固定 array      动态增长 性能损耗 Vector
    let a = [1, 2, 3, 4, 5];
    let months = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December",
    ];
    let a1: [i32; 5] = [1, 2, 3, 4, 5];
    let b1 = [3; 5];

    /* 
    a1[0];

    let mut index = String::new();
    io::stdin().read_line(&mut index).expect("Failed to read line");
    let index: usize = index.trim().parse().expect("Please type a number");
    let element = a[index];

    println!("the value of the element at index {} is {}", index, element);
    */

    let array: [String; 8] = std::array::from_fn(|i| String::from("rust is good"));
    println!("{:#?}", array);

    {
        let a: [i32; 5] = [1, 2, 3, 4, 5];
        let slice: &[i32] = &a[1..3];
        assert_eq!(slice, &[2, 3]);
    }
}

fn conclusion() {
    let one = [1, 2, 3];
    let two: [u8; 3] = [1, 2, 3];
    let blank1 = [0; 3];
    let blank2: [u8; 3] = [0; 3];

    let arrays: [[u8; 3]; 4] = [one, two, blank1, blank2];
    for a in &arrays {
        print!("{:?}", a);
        for n in a.iter() {
            print!("\t{} + 10 = {}", n, n + 10);
        }
        let mut sum: u8 = 0;
        for i in 0..a.len() {
            sum += a[i];
        }
        println!("\t({:?} = {})", a, sum);
    }
}
