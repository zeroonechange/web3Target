# Anvil 使用指南啊

### 高阶使用
### 基本使用
### 命令帮助


本地测试网节点  输入 anvil  看到可用的帐户和私钥列表，以及节点正在侦听的地址和端口
挖矿模式: 交易提交后就挖   间隔一段时间挖   永不挖矿  
支持 http 和 websocket 连接
支持 RPC 方法 
支持 hardhat  只要是 anvil_*  命名开头的 
特殊方法  来自 Ganache 是 truffle 的一个部件  自动挖矿 间隔时间  snapshot  revert  时间戳调整  gas调整  ...

https://book.getfoundry.sh/reference/anvil/


### 高阶使用
```c
anvil_impersonateAccount   冒充账号
anvil_stopImpersonatingAccount 
anvil_getAutomine          是否自动挖矿
anvil_mine
anvil_dropTransaction      
anvil_reset
anvil_setRpcUrl
anvil_setBalance
anvil_setCode
anvil_setNonce
anvil_setStorageAt
anvil_setCoinbase
anvil_setLoggingEnabled
anvil_setMinGasPrice
anvil_setNextBlockBaseFeePerGas
anvil_dumpState 
anvil_loadState 
anvil_nodeInfo 

evm_setAutomine
evm_setIntervalMining
evm_snapshot
evm_revert
evm_increaseTime
evm_setNextBlockTimestamp
anvil_setBlockTimestampInterval
evm_setBlockGasLimit
evm_mine
anvil_enableTraces
eth_sendUnsignedTransaction
txpool_status
txpool_inspect
txpool_content

```


### 基本使用
```c
$ anvil
                             _   _
                            (_) | |
      __ _   _ __   __   __  _  | |
     / _` | | '_ \  \ \ / / | | | |
    | (_| | | | | |  \ V /  | | | |
     \__,_| |_| |_|   \_/   |_| |_|

    0.1.0 (f96e0ba 2023-03-03T01:46:09.705607549Z)
    https://github.com/foundry-rs/foundry

Available Accounts
==================

(0) "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266" (10000 ETH)
(1) "0x70997970C51812dc3A010C7d01b50e0d17dc79C8" (10000 ETH)
(2) "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC" (10000 ETH)
(3) "0x90F79bf6EB2c4f870365E785982E1f101E93b906" (10000 ETH)
(4) "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65" (10000 ETH)
(5) "0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc" (10000 ETH)
(6) "0x976EA74026E726554dB657fA54763abd0C3a0aa9" (10000 ETH)
(7) "0x14dC79964da2C08b23698B3D3cc7Ca32193d9955" (10000 ETH)
(8) "0x23618e81E3f5cdF7f54C3d65f7FBc0aBf5B21E8f" (10000 ETH)
(9) "0xa0Ee7A142d267C1f36714E4a8F75612F20a79720" (10000 ETH)

Private Keys
==================

(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
(2) 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a
(3) 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6
(4) 0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a
(5) 0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba
(6) 0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e
(7) 0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356
(8) 0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97
(9) 0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6

Wallet
==================
Mnemonic:          test test test test test test test test test test test junk
Derivation path:   m/44'/60'/0'/0/


Base Fee
==================

1000000000

Gas Limit
==================

30000000

Genesis Timestamp
==================

1678083843

Listening on 127.0.0.1:8545
```


### 命令帮助
```c
命令帮助   参数挺多的  
	$ anvil -h
	Commands:
	  completions        Generate shell completions script. [aliases: com]
	  generate-fig-spec  Generate Fig autocompletion spec. [aliases: fig]
	  help               Print this message or the help of the given subcommand(s)

	Options:
	  -h, --help     Print help (see more with '--help')
	  -V, --version  Print version

	Fork config:
		  --compute-units-per-second <CUPS>  Sets the number of assumed available compute units per second for this provider
	  -f, --fork-url <URL>                   Fetch state over a remote endpoint instead of starting from an empty state [aliases:
											 rpc-url]
		  --fork-block-number <BLOCK>        Fetch state from a specific block number over a remote endpoint
		  --fork-chain-id <CHAIN>            Specify chain id to skip fetching it from remote endpoint. This enables
											 offline-start mode
		  --fork-retry-backoff <BACKOFF>     Initial retry backoff on encountering errors
		  --no-rate-limit                    Disables rate limiting for this node provider. [aliases: no-rpc-rate-limit]
		  --no-storage-caching               Explicitly disables the use of RPC caching
		  --retries <retries>                Number of retry requests for spurious networks (timed out requests)
		  --timeout <timeout>                Timeout in ms for requests sent to remote JSON-RPC server in forking mode

	Environment config:
		  --block-base-fee-per-gas <FEE>  The base fee in a block [aliases: base-fee]
		  --chain-id <CHAIN_ID>           The chain ID
		  --code-size-limit <CODE_SIZE>   EIP-170: Contract code size limit in bytes. Useful to increase this because of tests.
										  By default, it is 0x6000 (~25kb)
		  --disable-block-gas-limit       Disable the `call.gas_limit <= block.gas_limit` constraint
		  --gas-limit <GAS_LIMIT>         The block gas limit
		  --gas-price <GAS_PRICE>         The gas price

	EVM options:
	  -a, --accounts <NUM>                     Number of dev accounts to generate and configure. [default: 10]
		  --balance <NUM>                      The balance of every dev account in Ether. [default: 10000]
		  --derivation-path <DERIVATION_PATH>  Sets the derivation path of the child key to be derived. [default:
											   m/44'/60'/0'/0/]
	  -m, --mnemonic <MNEMONIC>                BIP39 mnemonic phrase used for generating accounts
	  -p, --port <NUM>                         Port number to listen on. [default: 8545]
		  --steps-tracing                      Enable steps tracing used for debug calls returning geth-style traces [aliases:
											   tracing]
		  --timestamp <NUM>                    The timestamp of the genesis block

	Server options:
		  --allow-origin <ALLOW_ORIGIN>
			  Set the CORS allow_origin [default: *]
	  -b, --block-time <SECONDS>
			  Block time in seconds for interval mining. [aliases: blockTime]
		  --config-out <OUT_FILE>
			  Writes output of `anvil` as json to user-specified file
		  --dump-state <PATH>
			  Dump the state of chain on exit to the given file. If the value is a directory, the state will be written to
			  `<VALUE>/state.json`.
		  --hardfork <HARDFORK>
			  The EVM hardfork to use.
		  --host <IP_ADDR>
			  The host the server will listen on [env: ANVIL_IP_ADDR=]
		  --init <PATH>
			  Initialize the genesis block with the given `genesis.json` file.
		  --ipc [<PATH>]
			  Launch an ipc server at the given path or default path = `/tmp/anvil.ipc` [aliases: ipcpath]
		  --load-state <PATH>
			  Initialize the chain from a previously saved state snapshot.
		  --no-cors
			  Disable CORS
		  --no-mining
			  Disable auto and interval mining, and mine on demand instead. [aliases: no-mine]
		  --order <ORDER>
			  How transactions are sorted in the mempool [default: fees]
		  --prune-history [<PRUNE_HISTORY>]
			  Don't keep full chain history. If a number argument is specified, at most this number of states is kept in memory.
	  -s, --state-interval <SECONDS>
			  Interval in seconds at which the status is to be dumped to disk. See --state and --dump-state
		  --silent
			  Don't print anything on startup.
		  --state <PATH>
			  This is an alias for bot --load-state and --dump-state. It initializes the chain with the state stored at the file,
			  if it exists, and dumps the chain's state on exit
		  --transaction-block-keeper <TRANSACTION_BLOCK_KEEPER>
			  Number of blocks with transactions to keep in memory.
```