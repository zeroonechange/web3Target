/** 
 * 模块  Module
项目 package     包含 Cargo.toml  只能包含一个库 library的包 和多个二进制可执行的包
            1. 二进制package  cargo new xxx 
            2. 库package     cargo new xxx --lib   只能被引用  不能独立运行 
包 Crate         独立可编译单元   例如 use rand;
模块  Module
use  受限引入模块

.
├── Cargo.toml
├── Cargo.lock
├── src
│   ├── main.rs             默认二进制包
│   ├── lib.rs              唯一库包
│   └── bin
│       └── main1.rs        其余二进制包
│       └── main2.rs        其余二进制包
├── tests                   集成测试文件
│   └── some_integration_tests.rs
├── benches                 基准性能测试 
│   └── simple_bench.rs
└── examples                项目示例
    └── simple_example.rs
*/
fn main() {}

// 代码 去看   lib.rs
