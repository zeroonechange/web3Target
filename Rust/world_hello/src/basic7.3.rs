// 特征对象
// 泛型  特征trait  特征对象  深入特征

pub trait Draw {
    fn draw(&self);
}

pub struct Button {
    pub width: u32,
    pub height: u32,
    pub label: String,
}

impl Draw for Button {
    fn draw(&self) {
        println!("draw button");
    }
}

pub struct SelectBox {
    pub width: u32,
    pub height: u32,
    pub options: Vec<String>,
}

impl Draw for SelectBox {
    fn draw(&self) {
        println!("draw selectbox");
    }
}

pub struct Screen {
    pub components: Vec<Box<dyn Draw>>,
}

impl Screen {
    pub fn run(&self) {
        for component in self.components.iter() {
            component.draw();
        }
    }
}

fn main() {
    let screen = Screen {
        components: vec![
            Box::new(Button {
                width: 100,
                height: 100,
                label: String::from("button"),
            }),
            Box::new(SelectBox {
                width: 100,
                height: 100,
                options: vec![String::from("yes"), String::from("no"), String::from("maybe")],
            })
        ],
    };

    screen.run();
}

trait Draw2 {
    fn draw(&self) -> String;
}
impl Draw2 for u8 {
    fn draw(&self) -> String {
        format!("draw u8 {}", *self)
    }
}
impl Draw2 for f64 {
    fn draw(&self) -> String {
        format!("draw f64 {}", *self)
    }
}
fn draw1(x: Box<dyn Draw2>) {
    x.draw();
}

fn draw2(x: &dyn Draw2) {
    x.draw();
}

fn dyn_test() {
    let x = 1.1f64;
    let y = 8u8;
    draw1(Box::new(x));
    draw1(Box::new(y));

    draw2(&x);
    draw2(&y);
}

// self 和  Self
trait Draw3 {
    fn draw(&self) -> Self;
}

#[derive(Clone)]
struct Button2;
impl Draw3 for Button2 {
    fn draw(&self) -> Self {
        return self.clone();
    }
}
