// 方法
fn main() {
    println!("Hello, world!");
}

struct Circle {
    x: f64,
    y: f64,
    radius: f64,
}

impl Circle {
    fn new(x: f64, y: f64, radius: f64) -> Circle {
        Circle {
            x,
            y,
            radius,
        }
    }
    fn area(&self) -> f64 {
        std::f64::consts::PI * self.radius * self.radius
    }
}

#[allow(unused)]
enum Message {
    Quit,
    Move {
        x: i32,
        y: i32,
    },
    Write(String),
    ChangeColor(i32, i32, i32),
}

impl Message {
    fn call(&self) {}
}

fn _main() {
    let m = Message::Write(String::from("hello"));
    m.call();
}
