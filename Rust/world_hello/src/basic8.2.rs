// hashmap
// 集合类型  动态数组   hashmap

use std::collections::HashMap;

fn main() {
    let mut my_gems = HashMap::new();
    // let mut mapss = HashMap::with_capacity(3);
    my_gems.insert("red", 1);
    my_gems.insert("blue", 2);
    my_gems.insert("white", 3);
}

fn _create_1() {
    let teams_list = vec![
        ("china".to_string(), 100),
        ("usa".to_string(), 10),
        ("japan".to_string(), 50)
    ];
    let teams_map: HashMap<_, _> = teams_list.into_iter().collect();
    println!("{:?}", teams_map);
}

fn _search() {
    let mut scores = HashMap::new();
    scores.insert(String::from("blue"), 10);
    scores.insert(String::from("yellow"), 50);
    scores.insert(String::from("blue"), 200);
    let team_name = String::from("blue");
    let score = scores.get(&team_name);
    println!("{:?}", score);
}

fn _foreach() {
    let mut scores = HashMap::new();
    scores.insert(String::from("blue"), 10);
    scores.insert(String::from("yellow"), 50);
    for (key, value) in &scores {
        println!("{}: {}", key, value);
    }
}

fn _update() {
    let mut scores = HashMap::new();
    scores.insert(String::from("blue"), 10);
    scores.insert(String::from("yellow"), 50);
    scores.entry(String::from("blue")).or_insert(50);
    scores.entry(String::from("red")).or_insert(50);
    println!("{:?}", scores);
}

fn _count() {
    let text = "hello world wonderful world";
    let mut map = HashMap::new();
    for word in text.split_whitespace() {
        let count = map.entry(word).or_insert(0);
        *count += 1;
    }
    println!("{:?}", map);
}
