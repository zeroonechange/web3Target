use std::env;
use std::fs;

// cargo run -- test sample.txt
fn main() {
    let args = env::args().collect::<Vec<String>>();
    let query = &args[1];
    let file_path = &args[2];
    println!("cmd: {}  \t file_path: {}", query, file_path);
    let contents = fs::read_to_string(file_path).expect("should have been able to read the file");
    println!("----------------------\n{}\n---------------------", contents);
}
