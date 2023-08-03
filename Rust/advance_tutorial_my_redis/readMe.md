```rust

Stream


select!
    允许等待多个计算操作 当其中一个操作完成就推出等待
    取消  drop掉一个future 意味着取消任务   async操作会返回一个future 惰性的 被poll调用才会执行 一旦future被释放 操作无法继续  所有相关的状态都会被释放
    select!  最多可以支持64个分支  <模式> = <async 表达式> => <结果处理>
    select!  宏开始执行后 所有分支开始并发执行 任何一个表达式完成  结果跟模式匹配成功 剩下表达式被释放
    返回值   还能返回一个值  必须一样的类型 否则报错
    错误传递  rust中用?   在select中使用 如果是在分支中 将结果变成一个 Result   如果是结果 则传播到 select! 之外
    模式匹配  <模式> = <async 表达式> => <结果处理>
    借用  当tokio生成 spwan任务时 其async语句块必须拥有数据的所有权  而 select! 没有这个限制
    可直接借用数据  进行并发
    如果在分支表达式进行俩次不可用借用 ok  如果是可变借用  报错
    如果在结果处理进行俩次可变借用  不会报错  ?   因为只会有一个分支结果被处理 另一个会被丢弃

    循环中使用   最常用的使用方式  哪个被先执行是不确定的

    tokio::spwan 会启动新的任务运行一个异步操作  每个任务都是独立被tokio调度运行  可能会运行中俩个不同的os线程  限制就是 不允许对外部环境中的值进行借用
    select!宏 在同一个任务中并发运行所有分支 单个任务实现了多路复用的功能


深入 async
    惰性  async fn xxx()   被调用时  只有 xxx().await 才会执行 这是一个 future
    原理 用到了 Pin   固定一个值  无法在内存中被移动
    async fun 返回了  future  后者需要通过不断的poll 才能往前推进状态  交给了 tokio的执行器 负责调用poll函数  推动 future执行  最终直至完成

    执行器 Excecutor   Waker 资源可以用它来通知正在等待的任务，该资源准备好可以运行了
    std::task::Context   .waker.wake()
    接收 wake 通知 相关联的任务放进执行器队列 等待执行器调用执行
    使用crossbeam 的消息通道    crossbeam="0.8"
    将 task 转化为 waker   使用  futures="0.3"   futures::task::ArcWake
    Waker是rust异步编程的基石   绝大多数使用 Notify就够了   tokio::sync::Notify
    这个提供了一个基础的任务通知机制  处理 waker 的细节

    async 是惰性的 执行器poll他们时才开始执行
    waker 是 future 被执行的关键  可链接起 future 任务和执行器
    当资源没有准备时  返回一个 Poll::Pending
    当资源准备好时  通过  waker.wake 发出通知
    执行器收到通知 调度该任务继续执行  资源已准备 任务可顺利往前推


解析数据帧
    客户端每次请求就是一个帧  数据单元  将字节流转换成帧组成的流
    缓冲读取 Buffered Read
        BytesMut
        parse_frame  缓冲区 buffer cursor 游标跟踪
        在网络编程中  通过字节数组和游标的方式读取数据是非常普遍的
        自动实现 T: BufMut 内部游标
    缓冲写入 Buffered Write
        BufWrite 结构体 先写到缓冲区 填满后刷到socket
        write_u8  写入一个字节
        write_all 写入所有数据
        write_decimal
        flush().await   将缓冲区数据立刻写入socket中

IO
    AsyncRead  AsyncWrite  工具 AsyncReadExt  AsyncWriteExt
        async fn read         将数据读入缓冲区 返回读取的字节数         AsyncReadExt::read
        async fn read_to_end  从字节流中读取所有的字节，直到遇到 EOF    AsyncReadExt::read_to_end
        async fn write        将缓冲区内容写到文件中 返回字节数         AsyncWriteExt::write
        async fn write_all    将缓冲区的内容全部写入到文件中            AsyncWriteExt::write_all

    tokio::io::copy 异步的将读取器( reader )中的内容拷贝到写入器( writer )中
    回声服务 echo   建立tcp连接 从socket读取的数据 原样的返回给客户端
        分离读写  将socket分离成一个读取器和写入器  任何一个读写器都可用 io::split 进行分离
            TcpStream::split       获取字节流引用 引用只能在同一个任务  没性能开销 无需Arc和Mutex
            TcpStream::into_split  可以在任务间移动  实现了 Arc
        手动拷贝




消息传递
    生产者-消费者  缓冲队列
    消息通道 channel
        mpsc      多生产-单消费       let (tx, rx) = mpsc::channel(32);  俩个句柄 发送句柄可以clone 接受无法clone
        oneshot   单生产-单消费       let (tx, rx) = oneshot::channel(); 无法对返回的俩个句柄进行clone
        broadcast 多生产-多消费
        watch     单生产-多消费
        async-channel 多生产-多消费 消息只能被一个消费者接受



共享状态
    多个连接之间共享  1.Mutex 共享访问   2.消息传递-新的异步任务
    Bytes 包:  克隆时不会克隆底层数据 是引用计数类型 和 Arc非常像
    hashmap 在多个线程共享 type DB =  Arc<Mutex<HashMap<String, Bytes>>>;  使用别名  太长了
    锁的使用 竞争不多用标准的 std::sync::Mutex  如果多则高性能的库  parking_lot::Mutex
    同步锁:  1.消息传递-新任务   2.锁分片
    在 await 期间持有锁
        1.提前释放 用 fn xxx{ {...} }   超出作用域
        2.把锁放结构体中 非异步方法中使用
        3.消息传递 - 异步任务


创建异步任务
    tokio::spawn(async move{ process(socket).await; });
    这个任务生命周期是  static   不能使用外部数据
    这个任务必须实现Send特征  .await调用 的数据必须全部实现Send特征  因为在阻塞挂起 恢复后继续执行  保存所有状态  线程间安全移动


```
