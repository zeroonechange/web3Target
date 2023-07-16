use num::complex::Complex;

fn _forever() -> ! {
    loop {
    }
}

fn _add(i: i32, j: i32) -> i32 {
    i + j
}
fn _add_with_extra(x: i32, y: i32) -> i32 {
    let x = x + 1;
    let y = y + 1;

    {
        let z = {
            let x = 3;
            x + 1
        };
        let _y = if z % 2 == 1 { "odd" } else { "even" };
        let _m = if x % 2 == 1 { "odd" } else { "even" };
    }

    x + y
}

fn main1() {
    let a = Complex { re: 2.1, im: -1.2 };
    let b = Complex::new(11.1, 22.2);
    let result = a + b;
    println!("{} + {}i", result.re, result.im);

    let result = true;
    if result {
        return;
    }

    {
        for i in 1..=5 {
            println!("{}", i);
        }

        for i in 'a'..='z' {
            println!("{}", i);
        }
    }

    {
        let a: i32 = 2;
        let b: i32 = 3;
        println!("(a & b) value is {}", a & b);
        println!("(a | b) value is {}", a | b);
        println!("(a ^ b) value is {}", a ^ b);
        println!("!b value is {}", !b);
        println!("(a << b) value is {}", a << b);
        println!("(a >> b) value is {}", a >> b);
    }

    {
        let guess = "42".parse::<i32>().unwrap();
        println!("{}", guess);
        let guess = "42".parse::<i32>().expect("not a number");
        println!("{}", guess);
    }

    {
        let a: u8 = 255;
        let b = a.wrapping_add(20);
        println!("{}", b);

        let x = 0.1;
        let y: f32 = 0.2;

        // assert!(x + y == 0.3);
        // assert!(0.1 + 0.2 == 0.3);
    }

    {
        let abc: (f32, f32, f32) = (0.1, 0.2, 0.3);
        let xyz: (f64, f64, f64) = (0.1, 0.2, 0.3);
        println!("abc f32");
        println!("0.1 + 0.2 : {:x}", (abc.0 + abc.1).to_bits());
        println!("      0.3 : {:x}", abc.2.to_bits());
        println!();

        println!("xyz f64");
        println!("0.1 + 0.2 : {:x}", (xyz.0 + xyz.1).to_bits());
        println!("      0.3 : {:x}", xyz.2.to_bits()); // 高精度会丢失
        println!();

        assert!(abc.0 + abc.1 == abc.2);
        // assert!(xyz.0 + xyz.1 == xyz.2); // 不一致
    }

    {
        let x = (-42.0_f32).sqrt();
        if x.is_nan() {
            println!("NaN  未定义的数学行为");
        }
        // assert_eq!(x, x);
    }

    {
        let _tweney = 20;
        let _tweney_one = 21i32;
        let _one_milli64: i64 = 1_000_000;
        let _forty_twos = [42.0, 42f32, 42.0_f32];
    }
}
