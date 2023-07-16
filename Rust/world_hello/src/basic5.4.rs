// 全模式列表
// 模式匹配   match 和 if let   解构Option   模式适用场景  全模式列表
fn main() {
    {
        let x = 1;
        match x {
            1 => println!("one"),
            2 => println!("two"),
            3 => println!("three"),
            _ => println!("other"),
        }
    }

    {
        let x = Some(5);
        let y = 10;
        match x {
            Some(50) => println!("Got 50"),
            Some(z) => println!("Matched, z = {:?}", z), // 匹配任何值 变量遮蔽
            _ => println!("Default case, x = {:?}", x),
        }
        println!("at the end: x = {:?}, y = {:?}", x, y);
    }

    {
        let x = 5;
        match x {
            1..=5 => println!("one through five"),
            _ => println!("something else"),
        }

        let x = 'c';
        match x {
            'a'..='j' => println!("early ASCII letter"),
            'k'..='z' => println!("late ASCII letter"),
            _ => println!("something else"),
        }
    }

    {
        struct Point {
            x: i32,
            y: i32,
        }

        let p = Point { x: 0, y: 7 };
        let Point { x: a, y: b } = p; // 解构
        assert_eq!(a, 0);
        assert_eq!(b, 7);

        let p = Point { x: 0, y: 7 };
        let Point { x, y } = p; // 俩种解构方式
        assert_eq!(x, 0);
        assert_eq!(y, 7);

        match p {
            Point { x, y: 0 } => println!("On the x axis at {}", x), // y=0
            Point { x: 0, y } => println!("On the y axis at {}", y), // x=0
            Point { x, y } => println!("On neither axis: ({}, {})", x, y), // x!=0 && y!=0
        }
    }

    {
        enum Message {
            Quit,
            Move {
                x: i32,
                y: i32,
            },
            Write(String),
            ChangeColor(i32, i32, i32),
        }

        let msg = Message::ChangeColor(0, 160, 255);
        match msg {
            Message::Quit => {
                println!("The Quit variant has no data to destructure.");
            }
            Message::Move { x, y } => {
                println!("Move in the x direction {} and in the y direction {}", x, y);
            }
            Message::Write(text) => println!("Text message: {}", text),
            Message::ChangeColor(r, g, b) => {
                println!("Change the color to red {}, green {}, and blue {}", r, g, b);
            }
        }
    }

    {
        enum Color {
            Rgb(i32, i32, i32),
            Hsv(i32, i32, i32),
        }

        enum Message {
            Quit,
            Move {
                x: i32,
                y: i32,
            },
            Write(String),
            ChangeColor(Color),
        }
        // 枚举里面的枚举还能匹配
        let msg = Message::ChangeColor(Color::Hsv(0, 160, 255));
        match msg {
            Message::ChangeColor(Color::Rgb(r, g, b)) => {
                println!("Change the color to red {}, green {}, and blue {}", r, g, b);
            }
            Message::ChangeColor(Color::Hsv(h, s, v)) => {
                println!("Change the color to hue {}, saturation {}, and value {}", h, s, v);
            }
            _ => (),
        }
    }

    {
        struct Point {
            x: i32,
            y: i32,
        }

        let ((a, b), Point { x, y }) = ((11, 22), Point { x: 0, y: 7 });
        println!("a: {}, b: {}, x: {}, y: {}", a, b, x, y);
    }

    // 数组 & 不定长数组
    {
        let arr: [u16; 2] = [114, 232];
        let [x, y] = arr;
        println!("x: {}, y: {}", x, y);

        let arr: &[u16] = &[114, 232];
        if let [x, ..] = arr {
            assert_eq!(x, &114);
        }
        if let [.., y] = arr {
            assert_eq!(y, &232);
        }
        let arr: &[u16] = &[];
        assert!(matches!(arr, [..]));
        assert!(!matches!(arr, [x, ..]));
    }
    // 忽略
    {
        let mut setting_value = Some(5);
        let new_setting_value = Some(10);
        match (setting_value, new_setting_value) {
            (Some(_), Some(_)) => {
                println!("Can't overwrite an existing customized value");
            }
            _ => {
                setting_value = new_setting_value;
            }
        }
        println!("setting is {:?}", setting_value);
    }

    {
        let numbers = (2, 4, 8, 16, 32);
        match numbers {
            (first, _, third, _, fifth) => {
                println!("Some numbers: {}, {}, {}", first, third, fifth);
            }
        }
    }

    // 下划线不会转移所有权
    {
        let s = Some(String::from("Hello"));
        // if let Some(_s) = s {   // s的值传递给了 _s
        if let Some(_) = s {
            //  如果只使用下划线就不会转移所有权
            println!("found a string");
        }
        println!("{:?}", s);
    }

    // 使用 .. 忽略剩余值
    {
        struct Point {
            x: i32,
            y: i32,
            z: i32,
        }
        let origin = Point { x: 0, y: 0, z: 0 };
        match origin {
            Point { x, .. } => println!("x is {}", x),
        }
    }

    {
        let num = Some(4);
        match num {
            Some(x) if x < 5 => println!("less than five"), // print this
            Some(x) => println!("{}", x),
            None => (),
        }
        println!("{:?}", num);

        // 加 if
        let x = Some(5);
        let y = 10;
        match x {
            Some(50) => println!("Got 50"),
            Some(n) if n == y => println!("Matched, n = {:?}", n), // 使用外部变量 没有覆盖任何值
            _ => println!("Default case, x = {:?}", x),
        }
        println!("at the end: x = {:?}, y = {:?}", x, y);
    }

    {
        let x = 4;
        let y = false;
        match x {
            4 | 5 | 6 if y => println!("yes"), // (4 or 5 or 6) && y = false  always
            _ => println!("no"),
        }
    }

    // @ bind  绑定
    {
        enum Message {
            Hello {
                id: i32,
            },
        }
        let msg = Message::Hello { id: 5 };
        match msg {
            Message::Hello { id: id_variable @ 3..=7 } => {
                // 34567
                println!("Found an id in range: {}", id_variable);
            }
            Message::Hello { id: 10..=12 } => {
                println!("Found an id in another range");
            }
            Message::Hello { id } => {
                println!("Found some other id: {}", id);
            }
        }
    }
    // @ bind 绑定 还能堆目标进行解构
    {
        #[derive(Debug)]
        struct Point {
            x: i32,
            y: i32,
        }
        let p @ Point { x: px, y: py } = Point { x: 10, y: 23 };
        println!("p.x = {}, p.y = {}", px, py);
        println!("p = {:?}", p);

        let point = Point { x: 10, y: 5 };
        if let p @ Point { x: 10, y } = point {
            println!("x is 10 and y is {} in {:?}", y, p);
        } else {
            println!("x was not 10 :(");
        }
    }
}
