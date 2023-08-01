use std::{ sync::{ mpsc, Arc, Mutex }, thread };

// 别名
// Box是什么？     允许分配内存到堆上  不想转移所有权时进行数据拷贝 只复制指向堆的指针 全局有效 一切皆对象 = 一切皆Box
// FnOnce是什么？  闭包   会拿走被捕获变量的所有权 只能运行一次   强制闭包取得捕获变量的所有权 使用 move
// Send是什么？    Send和Sync是Rust安全并发重中之重 实现Send可线程安全传递所有权   Sync则线程安全共享  几乎所有类型都默认实现了这俩个
// ‘static是什么？ 静态生命周期 和整个程序活一样久
type Job = Box<dyn FnOnce() + Send + 'static>;

// 线程池数据结构   获得要执行的代码  在具体的线程去执行
// Worker数组  存储具体的线程  探索下 thread::spawn 里面的 JoinHandle<T>  T是闭包 FnOnce
// sender
pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: Option<mpsc::Sender<Job>>,
}

impl ThreadPool {
    // 这个方法用来创建线程池  为啥不用 build？  new是简单的初始化一个实例  build是复杂的构建工作
    pub fn new(size: usize) -> ThreadPool {
        assert!(size > 0);
        // 使用消息通道 channel 作为任务队列   拿到  sender 和  receiver 发送端和接受端
        // 多生产者单消费者  无法克隆消费者
        // receiver之所以要用Arc是因为  没有实现copy  所有权在第一次使用时被拿走了  后面无法使用
        // 多个线程需要安全和共享使用receiver  Arc允许多个worker同时持有receiver
        // 而 mutex 可以确保一次只有一个worker能从receiver中接受消息
        // 每一个 worker 可安全持有 receiver
        let (sender, receiver) = mpsc::channel();
        let receiver = Arc::new(Mutex::new(receiver));
        // 容量
        let mut workers = Vec::with_capacity(size);
        // 按照大小 创建几个worker  将 receiver分发给每个worker
        for id in 0..size {
            workers.push(Worker::new(id, Arc::clone(&receiver)));
        }
        // 构建线程池  里面的 workers持有 消息通道的接受端
        ThreadPool { workers, sender: Some(sender) }
    }

    pub fn execute<F>(&self, f: F) where F: FnOnce() + Send + 'static {
        let job = Box::new(f); // 这里为啥还要用 Box去堆上分配内存？
        // 发送出去   这个 f 是 闭包 里面是具体的线程执行逻辑
        // 通过消息通道的发送端 将具体逻辑发送给给worker去执行
        self.sender.as_ref().unwrap().send(job).unwrap();
    }
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        drop(self.sender.take());
        for worker in &mut self.workers {
            println!("Shutting down worker {}", worker.id);
            if let Some(thread) = worker.thread.take() {
                thread.join().unwrap();
            }
        }
    }
}

// id 作为线程序号  为了打印
// thread 为了将 创建线程 和执行任务分开  里面存放实际的线程运行逻辑 需要的时候拿出来执行
struct Worker {
    id: usize,
    thread: Option<thread::JoinHandle<()>>,
}

impl Worker {
    // 创建一个 worker  传入id  和  接受端   开启一个线程一直循环  加锁接受消息
    fn new(id: usize, receiver: Arc<Mutex<mpsc::Receiver<Job>>>) -> Worker {
        // 死循环不断的接受任务  然后执行   有了别名 函数签名没有过度复杂
        // 为啥这里要用move?   强制闭包获得捕获变量的所有权 也就是receiver的所有权
        // 因为线程的启动时间和结束时间是不确定的   当主线程执行完  可能新线程还没结束甚至还没创建成功  对receiver引用就不合法
        // 使用 move 拿走 receiver的所有权
        let thread = thread::spawn(move || {
            loop {
                // lock 获取一个 mutex锁 获取锁内容后 调用 recv() 来接受消息  是阻塞的  没任务一直等待
                // Mutex<T> 同一个任务只会被一个 worker获取
                let message = receiver.lock().unwrap().recv();
                match message {
                    Ok(job) => {
                        println!("Worker {} got a job; executing.", id);
                        job();
                    }
                    Err(_) => {
                        println!("Worker {} disconnected; shutting down.", id);
                        break;
                    }
                }
            }
        });
        Worker { id, thread: Some(thread) }
    }
}
