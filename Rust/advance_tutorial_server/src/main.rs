use hello::ThreadPool;
use std::fs;
use std::io::{ prelude::*, BufReader };
use std::net::{ TcpListener, TcpStream };
use std::thread;
use std::time::Duration;

fn main() {
    // 监听本地端口
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();
    // 创建线程池  实际启动了多个worker线程  里面持有消息通道的接受端  内部一直循环
    let pool = ThreadPool::new(4);
    // 处理每个客户端的请求
    for stream in listener.incoming() {
        let stream = stream.unwrap();
        println!("connection established");
        // 分发执行  将逻辑放进闭包  然后通过 消息通道的发送端发送出去   给worker去执行   具体执行还是worker里面的线程
        pool.execute(|| {
            handle_connection(stream);
        });
    }
    println!("Hello, world!");
}

// 作为闭包传递给线程池  然后通过消息通道发送给worker内部的线程去执行
fn handle_connection(mut stream: TcpStream) {
    // 读取缓冲区
    let buf_reader = BufReader::new(&mut stream);
    // 读取HTTP请求第一行    一般是  “GET / HTTP/1.1” 或   “GET /sleep HTTP/1.1”
    let request_line = buf_reader.lines().next().unwrap().unwrap();
    // 匹配 然后决定返回响应内容
    let (file_name, status_line) = match &request_line[..] {
        "GET / HTTP/1.1" => ("hello.html", "HTTP/1.1 200 OK"),
        "GET /sleep HTTP/1.1" => {
            thread::sleep(Duration::from_secs(5)); // 睡眠  这里不会阻塞  会释放cpu
            ("hello.html", "HTTP/1.1 200 OK")
        }
        _ => ("404.html", "HTTP/1.1 404 NOT FOUND"),
    };
    // 读取本地文件
    let contents = fs::read_to_string(file_name).unwrap();
    // 获取字符串长度
    let len = contents.len();
    // 组装响应报文
    let response = format!("{status_line}\r\nContent-Length: {len}\r\n\r\n{contents}");
    // 通过流  字节码 返回给客户端
    stream.write_all(response.as_bytes()).unwrap();
}
