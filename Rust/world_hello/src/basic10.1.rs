// panice  不可恢复的错误
// panic!  和  Result
fn main1() {
    let v = vec![1, 2, 3];
    v[99];
}
// $ RUST_BACKTRACE=1 cargo run

use std::net::IpAddr;
fn main() {
    let home = "127.0.0.1".parse().unwrap(); // 反正解析失败就 panic  不处理错误
}
