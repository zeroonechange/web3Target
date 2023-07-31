use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });

    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }

    neak_pointer();
}

fn neak_pointer() {
    let mut num = 5;
    let r1: *const i32 = &num as *const i32;
    unsafe {
        println!("r1 is {}", *r1);
    }
}
