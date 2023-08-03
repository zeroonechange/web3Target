```rust
解析数据帧
    客户端每次请求就是一个帧  数据单元  将字节流转换成帧组成的流
    缓冲读取 Buffered Read
        BytesMut
        parse_frame  缓冲区 buffer cursor 游标跟踪
        在网络编程中  通过字节数组和游标的方式读取数据是非常普遍的
        自动实现 T: BufMut 内部游标
    缓冲写入 Buffered Write
        BufWrite 结构体 先写到缓冲区 填满后刷到socket



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
