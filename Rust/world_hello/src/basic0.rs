struct Struct {
    e: i32,
}

fn main1() {
    let x = 5;
    let x = x + 1;
    {
        let x = x * 2;
        println!("the value in inner scope is: {}", x);
    }
    println!("the value of x is: {}", x);

    let space = "     ";
    let space = space.len();
    println!("the value of space is: {}", space);

    /*
    const a: i32 = 1;
    const MAX_POINTS: u32 = 100_100;

    let (a, b, c, d, e); // 五个变量
    (a, b) = (1, 2); // 给 a b 赋值
    [c, .., d, _] = [1, 2, 3, 4, 5]; // 给 c d 赋值
    (Struct { e, .. } = Struct { e: 5 }); // 给 e 赋值
    assert_eq!([1, 2, 1, 4, 5], [a, b, c, d, e]);
    println!("{} {} {} {} {}", a, b, c, d, e);

    let (a, mut b): (bool, bool) = (true, false);
    println!("a={:?}, b={:?}", a, b);
    b = true;
    assert_eq!(a, b);

    let mut x = 5;
    println!("the value is {}", x);
    x = 6;
    println!("the value is {}", x);

    let _x = 1;
    let _y = 2;

    
    
    let penguin_data =
        "\
   common name,length (cm)
   Little penguin,33
   Yellow-eyed penguin,65
   Fiordland penguin,60
   Invalid,data
   ";

    let records = penguin_data.lines();

    for (i, record) in records.enumerate() {
        if i == 0 || record.trim().len() == 0 {
            continue;
        }

        let fields: Vec<_> = record
            .split(',')
            .map(|field| field.trim())
            .collect();
        if cfg!(debug_assertions) {
            eprintln!("debug: {:?} -> {:?}", record, fields);
        }

        let name = fields[0];
        if let Ok(length) = fields[1].parse::<f32>() {
            println!("-----{} {}cm", name, length);
        }
    }

    
    let southern_german  = "";
    let chinese = "你好世界";
    let english: &str = "hello world";
    let regiions = [southern_german, chinese, english];
    
    for item in regiions.iter() {
        println!("---1----{}", &item);
    }

    for item in regiions{
        println!("----2---{}", &item);
    }

    let aa = 12; 
    let str = "what the fuck"; 
    println!("{} {}", aa, str);

    println!("Hello, world!"); 
    
    */
}
