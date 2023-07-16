// 结构体
// 复合类型  字符串 元祖  结构体  枚举  数组

#[derive(Debug)]
struct User {
    active: bool,
    username: String,
    email: String,
    signed_in_count: u64,
}

#[derive(Debug)]
struct File {
    name: String,
    data: Vec<u8>,
}

fn main() {
    let mut user1 = User {
        active: true,
        username: String::from("jack"),
        email: String::from("jack@qq.com"),
        signed_in_count: 1,
    };
    user1.email = String::from("jack@qqqqqq.com");

    let user2 = User {
        email: String::from("jack@aaaaaa.com"),
        ..user1
    };
    println!("{}", user1.active);
    // println!("{:?}", user1);  //所有权没了  但不代表内部的字段都没了

    {
        let f1 = File {
            name: String::from("f1.txt"),
            data: Vec::new(),
        };
        let f1_name = &f1.name;
        let f1_length = &f1.data.len();
        println!("{:?}", f1);
        println!("{} is {} bytes long", f1_name, f1_length);
    }

    {
        struct Color(i32, i32, i32);
        struct Point(i32, i32, i32);
        let _black = Color(0, 0, 0);
        let _origin = Point(0, 0, 0);
    }
    {
        struct AlwaysEqual;
        let subject = AlwaysEqual;
        // impl someTrait for AlwaysEqual {}
    }

    {
        #[derive(Debug)]
        struct Rectangle {
            width: u32,
            height: u32,
        }
        let rect1 = Rectangle {
            width: 30,
            height: 50,
        };
        dbg!(&rect1); // 宏  拿走所有权  打印  最终返回所有权
        println!("{:?}", rect1);
    }
}

fn _build_user(email: String, username: String) -> User {
    User {
        active: true,
        username,
        email,
        signed_in_count: 1,
    }
}
