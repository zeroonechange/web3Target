use std::future::Future;
use std::pin::Pin;
use std::sync::{ Arc, Mutex };
use std::task::{ Context, Poll, Waker };
use std::thread;
use std::time::{ Duration, Instant };

struct Delay {
    when: Instant,
    // 用于说明是否已经生成一个线程
    // Some 代表已经生成， None 代表还没有
    waker: Option<Arc<Mutex<Waker>>>,
}

impl Future for Delay {
    type Output = ();

    fn poll(mut self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<()> {
        // 若这是 Future 第一次被调用，那么需要先生成一个计时器线程。
        // 若不是第一次调用(该线程已在运行)，那要确保已存储的 `Waker` 跟当前任务的 `waker` 匹配
        if let Some(waker) = &self.waker {
            let mut waker = waker.lock().unwrap();

            // 检查之前存储的 `waker` 是否跟当前任务的 `waker` 相匹配.
            // 这是必要的，原因是 `Delay Future` 的实例可能会在两次 `poll` 之间被转移到另一个任务中，然后
            // 存储的 waker 被该任务进行了更新。
            // 这种情况一旦发生，`Context` 包含的 `waker` 将不同于存储的 `waker`。
            // 因此我们必须对存储的 `waker` 进行更新
            if !waker.will_wake(cx.waker()) {
                *waker = cx.waker().clone();
            }
        } else {
            let when = self.when;
            let waker = Arc::new(Mutex::new(cx.waker().clone()));
            self.waker = Some(waker.clone());

            // 第一次调用 `poll`，生成计时器线程
            thread::spawn(move || {
                let now = Instant::now();

                if now < when {
                    thread::sleep(when - now);
                }

                // 计时结束，通过调用 `waker` 来通知执行器
                let waker = waker.lock().unwrap();
                waker.wake_by_ref();
            });
        }

        // 一旦 waker 被存储且计时器线程已经开始，我们就需要检查 `delay` 是否已经完成
        // 若计时已完成，则当前 Future 就可以完成并返回 `Poll::Ready`
        if Instant::now() >= self.when {
            Poll::Ready(())
        } else {
            // 计时尚未结束，Future 还未完成，因此返回 `Poll::Pending`.
            //
            // `Future` 特征要求当 `Pending` 被返回时，那我们要确保当资源准备好时，必须调用 `waker` 以通
            // 知执行器。 在我们的例子中，会通过生成的计时线程来保证
            //
            // 如果忘记调用 waker， 那等待我们的将是深渊：该任务将被永远的挂起，无法再执行
            Poll::Pending
        }
    }
}

use tokio::sync::Notify;
use std::sync::Arc;
use std::time::{ Duration, Instant };
use std::thread;

async fn delay(dur: Duration) {
    let when = Instant::now() + dur;
    let notify = Arc::new(Notify::new());
    let notify2 = notify.clone();

    thread::spawn(move || {
        let now = Instant::now();

        if now < when {
            thread::sleep(when - now);
        }

        notify2.notify_one();
    });

    notify.notified().await;
}
