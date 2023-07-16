// 枚举
// 复合类型  字符串 元祖  结构体  枚举  数组

#[derive(Debug)]
enum Pokersuit {
    Club,
    Spade,
    Heart,
    Diamond,
}
#[derive(Debug)]
enum Pokersuit1 {
    Club(u8),
    Spade(u8),
    Heart(char),
    Diamond(char),
}

enum Message {
    Quit,
    Move {
        x: i32,
        y: i32,
    },
    Write(String),
    ChangeColor(i32, i32, i32),
}

enum Websocket {
    Tcp(Websocket<TcpStream>),
    Tls(Websocket<TlsStream<TcpStream>>),
}

fn main() {
    let heard = Pokersuit::Heart;
    println!("{:?}", heard);

    let club = Pokersuit1::Club(5);
    let heart = Pokersuit1::Heart('A');
    println!("{:?}", club);
    println!("{:?}", heart);

    let m1 = Message::Quit;
    let m2 = Message::Move { x: 1, y: 2 };
    let m3 = Message::ChangeColor(255, 255, 0);

    // 处理空值
    {
        enum Option<T> {
            Some(T),
            None,
        }

        let num = Some(5);
        let str = Some("hello");
        let x: Option<i32> = None;
    }
}
