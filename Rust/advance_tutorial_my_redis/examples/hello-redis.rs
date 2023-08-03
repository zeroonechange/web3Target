use tokio::task::yield_now;

use mini_redis::{ client, Result };
#[tokio::main]
async fn main() -> Result<()> {
    let mut client = client::connect("127.0.0.1:6379").await?;
    client.set("hello", "world".into()).await?;
    let result = client.get("hello").await?;
    println!("Got response: {:?}", result);
    Ok(())
}

use std::rc::Rc;

#[tokio::main]
async fn main1() {
    tokio::spawn(async {
        {
            let rc = Rc::new("hello");
            println!("{}", rc);
        }
        yield_now().await;
    });
}
