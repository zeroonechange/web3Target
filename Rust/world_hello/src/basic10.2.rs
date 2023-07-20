// Result  可恢复的错误
// panic!  和  Result
use std::fs::File;
fn _main1() {
    let f = File::open("hello.txt");
    let f = match f {
        Ok(file) => file,
        Err(error) => {
            panic!("Problem opening the file: {:?}", error);
        }
    };
}

use std::io::ErrorKind;
fn _main2() {
    let f = File::open("hello.txt");
    let f = match f {
        Ok(file) => file,
        Err(error) =>
            match error.kind() {
                ErrorKind::NotFound =>
                    match File::create("hello.txt") {
                        Ok(fc) => fc,
                        Err(e) => panic!("Problem creating the file: {:?}", e),
                    }
                other_error => {
                    panic!("Problem opening the file: {:?}", other_error);
                }
            }
    };
}

fn _main3() {
    let f = File::open("hello.txt").unwrap(); // 失败就直接panic  直接崩溃
    let g = File::open("hello.txt").expect("fail to open "); // 失败就直接panic  带上错误提示信息
}

use std::io::{ self, Read };
fn _read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");
    let mut f = match f {
        Ok(file) => file,
        Err(e) => {
            return Err(e);
        }
    };
    let mut s = String::new();
    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}

// ??   宏   比match 更胜一筹
fn _read_username_from_file2() -> Result<String, io::Error> {
    let mut f = File::open("username.txt")?; // 可能异常
    let mut s = String::new();
    f.read_to_string(&mut s)?; // 可能异常
    Ok(s) // 最终走到这肯定成功
}

fn _open_file() -> Result<File, Box<dyn std::error::Error>> {
    let f = File::open("hello.txt")?;
    Ok(f)
}

fn _read_username_from_file3() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("username.txt")?.read_to_string(&mut s)?;
    Ok(s)
}

use std::fs;
fn _read_username_from_file4() -> Result<String, io::Error> {
    fs::read_to_string("hello.txt")
}

// 用于option的返回
fn _first(arr: &[i32]) -> Option<&i32> {
    let v = arr.get(0)?;
    Some(v)
}

fn _first1(arr: &[i32]) -> Option<&i32> {
    arr.get(0)
}

fn _last_char_of_first_line(text: &str) -> Option<char> {
    text.lines().next()?.chars().last()
}

// 传播错误
fn main() {}
