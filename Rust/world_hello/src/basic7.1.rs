// 泛型
// 泛型  特征trait  特征对象  深入特征

fn add<T: std::ops::Add<Output = T>>(x: T, y: T) -> T {
    x + y
}

struct Point<T> {
    x: T,
    y: T,
}
impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}
// 多类型
struct Point1<T, U> {
    x: T,
    y: U,
}
impl<T, U> Point1<T, U> {
    fn mixup<V, W>(self, other: Point1<V, W>) -> Point1<T, W> {
        Point1 { x: self.x, y: other.y }
    }
}
// 枚举 + 泛型
enum Option<T> {
    Some(T),
    None,
}
// 枚举  多类型泛型
enum Result<T, E> {
    Ok(T),
    Err(E),
}

fn main() {
    let _integer = Point { x: 5, y: 10 };
    let _float = Point { x: 1.0, y: 4.0 };

    let _p1 = Point1 { x: 1, y: 4.0 };
}
