// match  if let
// 模式匹配   match 和 if let   解构Option   模式适用场景  全模式列表
enum Direction {
    North,
    South,
    East,
    West,
}

enum IpAddr {
    Ipv4,
    Ipv6,
}

fn main() {
    {
        let direction = Direction::East;
        match direction {
            Direction::North => println!("North"),
            Direction::South | Direction::East => {
                println!("South");
            }
            _ => println!("West"),
        }
    }

    {
        let ip1 = IpAddr::Ipv6;
        let ip_str = match ip1 {
            IpAddr::Ipv4 => "127.0.0.1",
            _ => "::1",
        };
        println!("{}", ip_str);
    }
}

#[derive(Debug)]
enum UsState {
    Alabama,
    Alaska,
}
enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(UsState),
}
//无非就是一些 枚举的 匹配   枚举嵌套枚举  传参
fn _value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => 1,
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        }
    }
}

enum Action {
    Say(String),
    MoveTo(i32, i32),
    ChangeColor(i32, i32, i32),
}

fn _main() {
    let actions = [
        Action::Say(String::from("hello")),
        Action::MoveTo(0, 0),
        Action::ChangeColor(0, 0, 0),
    ];
    for action in actions {
        match action {
            Action::Say(s) => {
                println!("{}", s);
            }
            Action::MoveTo(x, y) => {
                println!("Move to ({}, {})", x, y);
            }
            Action::ChangeColor(r, g, b) => {
                println!("Change color ({}, {}, {})", r, g, b);
            }
        }
    }
}

fn _if_let() {
    {
        let v = Some(3u8);
        match v {
            Some(3) => println!("three"),
            _ => (),
        }
    }

    {
        let v = Some(3u8);
        if let Some(3) = v {
            println!("three");
        }
    }
}

enum MyEunum {
    A,
    B,
}
// 过滤
fn _matches_test() {
    let v = vec![MyEunum::A, MyEunum::B, MyEunum::A];
    v.iter().filter(|x| matches!(x, MyEunum::A));

    let foo = 'f';
    assert!(matches!(foo, 'A'..='Z' | 'a'..='z'));

    let bar = Some(4);
    assert!(matches!(bar, Some(x) if x > 2));
}

fn _var_cover() {
    let age = Some(30);
    println!("before match   age = {:?}", age);
    match age {
        Some(x) if x < 40 => println!("young"),
        _ => (),
    }
    println!("after match   age = {:?}", age);
}
