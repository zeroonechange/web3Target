# Foundry 使用指南啊

大纲

### 命令大全

### 基本使用

### 安装

Foundry 包括了 三个库 forge cast anvil  
 forge 用于测试  
 cast 命令行交互工具
anvil 提供本地区块节点
最后还有一些经典的例子 best practices

### 命令大全

```c
命令大全:
General Commands
	forge help 			Display help information about Forge.
	forge completions 	Generate shell autocompletions for Forge.  自动补全

Project Commands
	forge init 		Create a new Forge project.
	forge install 	Install one or multiple dependencies.
	forge update 	Update one or multiple dependencies.
	forge remove 	Remove one or multiple dependencies.
	forge config 	Display the current config.
	forge remappings 	Get the automatically inferred remappings for this project.
	forge tree 			Display a tree visualization of the project's dependency graph.
	forge geiger     Detects usage of unsafe cheat codes in a foundry project and its dependencies. 查看哪些地方用了作弊码

Build Commands
	forge build 		Build the project's smart contracts.
	forge clean 		Remove the build artifacts and cache directories.
	forge inspect 		Get specialized information about a smart contract.  比如abi  bytecode  assembly  method   gas  storagelayout doc  metadata  ...

Test Commands
	forge test 		 Run the project's tests.
	forge snapshot 	 Create a snapshot of each test's gas usage.

Deploy Commands
	forge create			Deploy a smart contract.
	forge verify-contract	Verify smart contracts on Etherscan.
	forge verify-check 		Check verification status on Etherscan.
	forge flatten			Flatten a source file and all of its imports into one file.  把多个 sol 文件 合并到一个文件里面去

Utility Commands
	forge debug				Debug a single smart contract as a script.
	forge bind				Generate Rust bindings for smart contracts.
	forge cache				Manage the Foundry cache.
	forge cache clean		Cleans cached data from ~/.foundry.
	forge cache ls			Shows cached data from ~/.foundry.
	forge script			Run a smart contract as a script, building transactions that can be sent onchain.
	forge upload-selectors	Uploads abi of given contract to https://sig.eth.samczsun.com function selector database.
	forge doc				Generate documentation for Solidity source files.
```

### 基本使用

```c

创建新的项目
	$ forge init hello_foundry
	$ forge build
	$ forge test

导入一个项目
	$ git clone https://github.com/abigger87/femplate
	$ cd femplate
	$ forge install
	$ forge build
	$ forge test

安装依赖
	$ forge install transmissions11/solmate
	$ forge install transmissions11/solmate@v7
	remapping 依赖库  通过 remappingx.txt
更新依赖
	$ forge update lib/solmate
移除依赖
	$ forge remove solmate
	$ forge remove lib/solmate


工程布局
.
├── foundry.toml			   配置文件
├── lib
│   └── forge-std
│       ├── LICENSE-APACHE
│       ├── LICENSE-MIT
│       ├── README.md
│       ├── foundry.toml
│       ├── lib
│       └── src
├── script
│   └── Counter.s.sol
├── src
│   └── Counter.sol
└── test
    └── Counter.t.sol

7 directories, 8 files


------------------------------
Forge
	tests, builds, and deploys your smart contracts
测试
	所有测试都是由 solidity 写的 不是 ethers.js
	都放在/test 目录下  文件形式 xx.t.sol
	可以单独跑一个测试   用过滤词 --match-contract  和  --match-test
		$ forge test --match-contract ComplicatedContractTest --match-test testDeposit
		还有其他过滤词  --no-match-contract and --no-match-test
	也可以单独跑一个测试文件     过滤词  --match-path   当然也有 --no-match-path
		$ forge test --match-path test/ContractB.t.sol
	打印日志  -v    分别为 -vv  -vvv -vvvv -vvvvv    v越多  打印出来的东西就越多
		-vv    输出所有测试的 logs
		-vvv   输出失败测试的 stack trace
		-vvvv  输出 stack trace， 并输出失败用例的 setup
		-vvvvv 输出 stack trace 和 setup
	可以re-run 测试  当改了一些东西    只会再跑那些改动过的测试方法   forge test --watch
	如果要re-run 所有测试  使用  forge test --watch --run-all 命令

写测试
	标准库 forge-std   导入 import "forge-std/Test.sol";
	测试都部署在 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84
	测试方法不要用 internal 或  private 修饰
	setup 方法共享  创建一个 help abstract 合约 然后继承
cheatcodes
	作弊码能操控区块链的数据  例如改变区块 自己的地址  部署在 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
	通过 vm 实例获取作弊码
	testFailXXX 开头的 如果执行合约函数 异常 revert 了  那么测试函数直接是 passed
		如果 改成 testXXX  如果 revert 会告诉我们到底发生了什么   例如 revert Unauthorized();
		但如果要通过  那么 在测试方法最前面添加 vm.expectRevert(Unauthorized.selector); 就直接 passed
	expectEmit 针对 事件 Event   最多三个 indexed  构成一个 topic  可以用来在区块链上进行搜索
		vm.expectEmit(true, true, false, true);  想检查 第一个 第二个的 indexed 在topic 中  第三个不检查了  第四个是data 也检查
		这里有个很奇怪的设定 在 vm.expectEmit() 后要主动去 emit Event 里面的参数要和 合约函数执行的一样才行
		也就是 测试框架 先 emit 一个 event  然后目标合约再 emit 一次  俩个对比ok  才 passed
标准库
	代码在 lib/forge-std/src 下
		Vm.sol: Up-to-date cheatcodes interface
		console.sol and console2.sol: Hardhat-style logging functionality
		Script.sol: Basic utilities for Solidity scripting
		Test.sol: A superset of DSTest containing standard libraries, a cheatcodes instance (vm), and Hardhat console
	分别是 作弊码的接口  打日志  脚本工具  测试类的父类  里面包含了标准库 vm实例  和 hardhat日志输出
		vm.startPrank(alice);  // Access Hevm via the `vm` instance
		assertEq(dai.balanceOf(alice), 10000e18); // Assert and log using Dappsys Test
		console.log(alice.balance);   // Log with the Hardhat `console` (`console2`)
		deal(address(dai), alice, 10000e18);  // Use anything from the Forge Std std-libraries
	导入使用
		import "forge-std/Vm.sol";
		import "forge-std/console.sol";
		import "forge-std/console2.sol";   // 这个包含补丁 解码trace 不适用于hardhat
	六大标准库
		Std Logs         lib/forge-std/lib/ds-test/src/test.sol
		Std Assertions   同上
		Std Cheats       lib/forge-std/src/StdCheats.sol
		Std Errors		 lib/forge-std/src/StdError.sol
		Std Storage		 lib/forge-std/src/StdStorage.sol   操控合约storage
		Std Math		 lib/forge-std/src/StdMath.sol
理解Traces
	得到 trace for failing tests(-vvv) or all tests(-vvvv)
	trace 里面包含的信息如下:
	  [<Gas Usage>] <Contract>::<Function>(<Parameters>)
		├─ [<Gas Usage>] <Contract>::<Function>(<Parameters>)
		│   └─ ← <Return Value>
		└─ ← <Return Value>
	trace 里面可能包含 子 trace  例如 debugging 里面的东西一样
	颜色设定如下:
		Green: For calls that do not revert
		Red: For reverting calls
		Blue: For calls to cheat codes
		Cyan: For emitted logs
		Yellow: For contract deployments
	一个函数的 gas usage 可能 和子函数的 gas usage 对不上 那是因为有额外的操作  forge尽可能的做到 实际不可能
Fork Testing
	俩种模式
	Forking Mode  分叉模式  用一个单独的分叉进行所有测试
		在一个fork环境上跑所有的测试   forge test --fork-url <your_rpc_url>
		下面的信息就是fork时候带来的
			block_number
			chain_id
			gas_limit
			gas_price
			block_base_fee_per_gas
			block_coinbase
			block_timestamp
			block_difficulty
		模拟真实的网络环境  可以指定区块号 例如 forge test --fork-url <your_rpc_url> --fork-block-number 1
		如果 --fork-url 和  --fork-block-number 都指定了 那么就缓存下来了 为后面的测试使用
			缓存位于 ~/.foundry/cache/rpc/<chain name>/<block number>
			移除缓存  可以删除文件夹 或 使用命令  forge clean
			也可以追加命令 --no-storage-caching
			或 foundry.toml 文件 配置  no_storage_caching and rpc_storage_caching
		trace 优化: 把区块链浏览器的  API key 传进去即可   这个东西可以设置为环境变量
			forge test --fork-url <your_rpc_url> --etherscan-api-key <your_etherscan_api_key>
	Forking Cheatcodes    分叉作弊码模式
		每个测试函数都是独立fork EVM环境    每个测试的 state 都是在 setup 后的复制
		可以使用 createFork 创建 fork     都带有 uint256 的  forkId  在创建的时候初始化
		选择环境: selectFork(forkId)
		createSelectFork: 就是 先创建fork-createFork  然后选择当前Fork - selectFork
		每一刻只能有一个fork处于激活状态  其他的可以通过 activeFork 再次激活使用
		运行原理:
			每个fork是独立的EVM  使用了独立的storage 唯一不同的就是 msg.sender 和 测试合约本身
			测试合约的改动会保持  尽管fork切来切去的 因为 test contract是一个 persistent account
			persistent account 理解为本地memory
			只有 msg.sender 和 test contract  是 persistent
			但是其他 account 可以通过 makePersistent 使其成为 persistent


Advance Testing
	Fuzz Testing			瀑布测试  生成很多随机参数去测试
		和普通测试类似  把参数暴露出来  框架默认生成256个场景数据  scenarios  可以在配置文件里面改 FOUNDRY_FUZZ_RUNS
		如果要过滤  使用 vm.assume(amout> 0.1 ether);
		测试报告里面 [PASS] testWithdraw(uint96) (runs: 256, μ: 19078, ~: 19654)    μ是平均数  ~是中位数

	Invariant Testing  		invariant: never changing
		在fuzzing的基础上  函数随机执行  看看合约是否有逻辑错误
		俩个维度  runs   depth
			runs:  执行的次数 - 多个函数生成执行顺序然后执行    也就是说 先把多个函数生成一个执行顺序  然后执行 例如 abc   acb 不知道有没有重复的
			depth: 如果一个函数 revert  那么 depth 就会自增
		和标准测试方法一样  用前缀表示  function invariant_A()
		一个好的 Invariants 应该包含多个函数执行 而且在不同的区块状态下 fuzzing测试也不出错
			拿 uniswap 举例  xy=k  所有用户的余额应该等于总供给
				assertGe(token.totalAssets(),token.totalSupply())
				assertEq(token.totalSupply(),sumBalanceOf)
				assertEq(pool.outstandingInterest(),test.naiveInterest())
		带条件的 invariants   不一定每一个都是 true    带有条件 if(protocalCondition) return;  最好用  if(protocalCondition) { assertLe(val1, val2);  return; }
		Invariant Targets :  可以自定义一些东西
			Target Senders      fuzzer 选择随机的地址作为 msg.sender
			Target Selectors    特定合约 - 子函数集合
			Target Artifacts   用于 代理合约  测试ABI
			Target Artifact Selectors  代理合约
			优先级 targetSelectors | targetArtifactSelectors > excludeContracts | excludeArtifacts > targetContracts | targetArtifacts
		测试帮助函数
			excludeContract(address newExcludedContract_)          添加到 不包含目标合约集合  添加了这个合约不会去执行
			excludeSender(address newExcludedSender_)	           添加到 不包含 msg.sender 集合
			excludeArtifact(string memory newExcludedArtifact_)	        ...不包含在artifacts
			targetArtifact(string memory newTargetedArtifact_)	        ...包含在artifacts
			targetArtifactSelector(FuzzSelector memory newTargetedArtifactSelector_)	添加到 FuzzSelectors - 用于artifact selectors  - ABI
			targetContract(address newTargetedContract_)			添加到 包含目标合约集合  添加了这个合约会去执行
			targetSelector(FuzzSelector memory newTargetedSelector_)	添加到 FuzzSelectors - 用于 contract selectors - 正常使用
			targetSender(address newTargetedSender_)	           添加到 包含 msg.sender 集合   随机的 msg.sender 从这里面拿
		Setup     目标合约通过以下三个方法设置
			1.手动添加到 targetContracts
			2.部署合约的时候在 setup 方法 自动把目标合约添加进去   也可以在这里 removed 掉
		例子
		写一个目标合约  三个变量  俩个方法  方法1:输入amount v1和v3 累加   方法2:输入amount v2和v3 累加  都是uint256
		测试方法  setup() 部署目标合约  俩个测试方法  invariant_A(){ assertEq(v1+v2, v3); }  invariant_B(){ assertEq(v1+v2, v1); }
		运行测试结果   方法1 和 方法2 跑的概率是 50%  可能会溢出导致revert 默认是 fail_on_revert = false 所以整个测试流程还会继续
			[PASS] invariant_A() (runs: 256, calls: 3840, reverts: 1208)
			[PASS] invariant_B() (runs: 256, calls: 3840, reverts: 1208)
		Handler 函数
		  这个是为了解决一些函数执行要准备一些东西才能避免失败 比如执行 deposite前 必须有钱才行  不然会 revert
		  handler 就是把逻辑给包装一下  放到最前面执行 避免失败
		  如果没 handler 执行顺序 step1: call function    step2: Assert all invariant
		  有了 handler   执行顺序 step1: call function in handler   step2: route calls to protocol   step3: assert all invariant
		  就是把之前全局无序的执行顺序  改成局部有序的去执行  乱中有细
		ghost variables  通过在测试类中添加全局变量 在每一个测试方法中修改  最后去对比
		bound(x, min, max)  确保 x在[min,max]内  确保成功执行函数   和 fail_on_revert = false  类似
		例如: assets = bound(assets, 0, 1e30);  源码在 StdUtils.sol/_bound(uint256, uint256, uint256)
		更高级的用法 用于 modifier
			address[] public actors;
			address internal currentActor;
			modifier useActor(uint256 actorIndexSeed) {
				currentActor = actors[bound(actorIndexSeed, 0, actors.length - 1)];
				vm.startPrank(currentActor);
				_;
				vm.stopPrank();
			}
		如果测试方法用了这个 modifier 那么会对 actorIndexSeed 做一个规定  只能在 actors 数组内  fuzzing test 不会越界

	Differential Testing
		vm.ffi(CMDS) 执行脚本 获取结果返回 例如 cat xxx.txt  返回的就是 txt文本信息
		例如 Merkle 树   solidity有个库叫 Murky  但其他语言写的库 如 python  JavaScript typescript  可以通过 ffi 执行脚本生成 merkle树  然后和solidity的库去做对比
		不止是solidity和JavaScript做对比  还能其他任意的库  只要能通过脚本命令获得
		还能读取本地的txt文件 decode后  和任意的其他库去做对比   简单来说就是 ffi 执行脚本命令 拿到数据  和库去做对比

Deploying and Verifying
	一般用法
	$ forge create --rpc-url <your_rpc_url> --private-key <your_private_key> src/MyContract.sol:MyContract
	高阶用法  带了构造函数参数   区块链浏览器上校验源码
	$ forge create --rpc-url <your_rpc_url> \
		--constructor-args "ForgeUSD" "FUSD" 18 1000000000000000000000 \
		--private-key <your_private_key> \
		--etherscan-api-key <your_etherscan_api_key> \
		--verify \
		src/MyToken.sol:MyToken
	如果合约已经部署  可通过下面的例子去校验源码   加了 --watch 是为了查看结果
	$ forge verify-contract --chain-id 42 --num-of-optimizations 1000000 --watch --constructor-args \
		$(cast abi-encode "constructor(string,string,uint256,uint256)" "ForgeUSD" "FUSD" 18 1000000000000000000000) \
		--compiler-version v0.8.10+commit.fc410830 <the_contract_address> src/MyToken.sol:MyToken <your_etherscan_api_key>

	Submitted contract for verification:
					Response: `OK`
					GUID: `a6yrbjp5prvakia6bqp5qdacczyfhkyi5j1r6qbds1js41ak1a`
					url: https://kovan.etherscan.io//address/0x6a54…3a4c#code
	如果没收到结果  可通过   $ forge verify-check --chain-id 42 <GUID> <your_etherscan_api_key>   去查看是否
							Contract successfully verified.

Gas Tracking
	俩种方法  reports:合约中每个函数gas消耗    snapshots: 所有测试方法的gas消耗
	区别在于 reports 更细节  而 snapshots 生成速度更快
	Gas Reports
		可在 foundry.toml 中配置 哪些合约需要生成report
			gas_reports = ["MyContract", "MyContractFactory"]  //俩个合约
			gas_reports = ["*"]                                //所有合约
			gas_reports_ignore = ["Example"]                   //忽略掉这个合约
		forge test --gas-report
		也可以用过滤器 为一个 测试生成  $ forge test --match-test testBurn --gas-report

	Gas Snapshots
		可以对比前后优化的gas消耗
			$ forge snapshot
			$ cat .gas-snapshot
		过滤
			指定文件名  $ forge snapshot --snap <FILE_NAME>
			排序  --asc     --desc
			最大/小  --min <VALUE>   --max <VALUE>
			一个测试合约  $ forge snapshot --match-path contracts/test/ERC721.t.sol
		对比gas消耗   看起来 --diff 更好用  信息更多
			$ forge snapshot --diff .gas-snapshot   执行一遍然后对比.gas-snapshot   红色表示gas不一样
			$ forge snapshot --check .gas-snapshot  这里会把不同的地方给打印出来
Debugger
	$ forge debug --debug src/SomeContract.sol --sig "myFunc(uint256,string)" 123 "hello"
	感觉没 remix 好用


Cast
	命令行工具 和 主链交互 RPC calls
	可以 调用合约函数  发送交易   获取链上数据
	获取 DAI token的总供应量
		$ cast call 0x6b175474e89094c44da98b954eedeac495271d0f "totalSupply()(uint256)" --rpc-url https://eth-mainnet.alchemyapi.io/v2/Lc7oIGYeL_QvInzI0Wiu_pOZZDEKBrdf
	解码数据
		zeroonechange@3bet:~/foundry/hello_foundry$ cast 4byte-decode 0x1F1F897F676d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e7
		1) "fulfillRandomness(bytes32,uint256)"
		0x676d000000000000000000000000000000000000000000000000000000000000
		999


Anvil
	本地网络节点

Chisel
	就和 ethernaut 那里面的 控制台一样   输入后 立马返回输出

配置 foundry.toml

持续集成

VSCode 集成
	remappings
	dependencies
	formatter
	solc version

静态分析
	slither
	mythril

和 hardhat 集成

Best Practices
	合约部分
		1.不要导入整个文件  而是里面具体的合约名字 import {MyContract} from "src/MyContract.sol"   而不是 import "src/MyContract.sol"
		2.最开始导入 forge-std/  然后是 test/  script/ 最后是 src/
		3.导入 合约名字 最好是按照名字顺序来  例如 import {bar, foo} from "src/MyContract.sol"  而不是 foo 在 bar 的前面
		4.权衡全路径和相对路径
		5.复制库时 配置中使用 ignore=[] 避免 格式化文件
		6.使用 // forgefmt: disable-* 命令 忽略行 片段  会看起来更好
	测试部分
		1.对于测试文件 最好是 XXX.t.sol   脚本文件 XXX.t.sol
		2.不要在 setup 函数中 添加 assert
		3.单元测试  俩种方法组织测试   1) 把测试合约当作一个专有功能的整体 例如  contract Add 里面全是 add 方法的测试  2).传统的 针对一个合约全功能
		4.测试方法 和 合约的函数 顺序应该是一致
		5.命名 test_Description    testFuzz_Description    test_Revert[If|When]_Condition   testFork_Description   testForkFuzz_Revert[If|When]_Condition
		6.测试时候添加更多的反馈信息
	Fork 测试部分
		1.fork 测试 第一次很慢 需要和RPC交互 大约7分钟  后面就很快  因为缓存下来了
		2.fuzz 测试容易超过 RPC的每日最大请求数   最好是用 multicall  本地node
		3.使用 fork 测试时  不要用 --fork-url 最好写在配置文件里面
	测试不常规方法
		internal 函数  最好是再写一个合约类去继承  暴露出来  exposed_xxx()
		private 函数   目前没办法
	生成文档   forge doc


	使用 Solmate 偷取 NFT
	在Docker上使用Foundry
	测试EIP-712签名
	solidity脚本编写
	使用Cast和Anvil从主网上fork

```

### 安装

```c
windows 用  WSL
下个WSL Ubuntu
        wsl -l -v
        wsl --install -d Ubuntu
        wsl -l -o
如果要卸载就用    wsl --unregister Ubuntu

 先要解决网络代理的问题

 https://zhuanlan.zhihu.com/p/451198301

 Clash for Windows科学上网    打开 Allow Lan 然后看看IP地址 和端口

确保 git clone https://github.com/foundry-rs/forge-std.git  成功才能去 forge init
代理地址 一定要看Clash的代理地址  之前填错了  clone 不下来

export http_proxy='http://127.0.0.1:7890'
export https_proxy='http://127.0.0.1:7890'
export all_proxy='socks5://127.0.0.1:7890'
export ALL_PROXY='socks5://127.0.0.1:7890'

用 wget www.google.com  查看下是否可以了 最后

curl -L https://foundry.paradigm.xyz | bash

source /home/zeroonechange/.bashrc

foundryup

解决在 WSL terminal 中输入 code . 没有打开 VSCode的问题
找到路径  F:\allinweb3\dev\vscode\Microsoft VS Code\bin  添加到 windows 环境变量的 path 中去


https://github.com/foundry-rs/foundry
https://book.getfoundry.sh/getting-started/installation
https://learn.microsoft.com/zh-cn/windows/wsl/tutorials/wsl-vscode
https://www.luogu.com.cn/blog/Quank-The-OI-er/VSCode-On-Windows-10


mac OS
那个 安装后使用时  跑一下 source .bashrc     那个zsh 有点烦  之前博客没找到

```
