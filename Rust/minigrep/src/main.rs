use std::env;
use std::process;

use minigrep::Config;

// cargo run -- test poem.txt
fn main() {
    let config = Config::build(env::args()).unwrap_or_else(|err| {
        eprintln!("解析参数异常: {err}");
        process::exit(1);
    });

    println!("Searching for {}", config.query);
    println!("In file {}", config.file_path);

    // 简洁
    if let Err(e) = minigrep::run(config) {
        eprintln!("Application error: {e}");
        process::exit(1);
    }
}
