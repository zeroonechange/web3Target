
## 彻底搞明白   ERC-4337 协议
 
### Aggregator  BLS 签名算法
```c

```

### Paymaster
```c

```

### 简要
```c

User Operations：描述了用户的操作等信息。它由钱包 App 创建并提交给 Bundler
Bundlers：接收用户提交的 User Operation，把它放到 User Operation Mempool 中；监控 User Operation Mempool 中内容，把 User Operation 打包上链。具体来说， 用户通过 Bundler 的 RPC eth_sendUserOperation 可以提交 User Operation 到 User Operation Mempool 中；Bundler 调用 EntryPoint 合约的 handleOps 方法，可以把 User Operation 作为 handleOps 的参数提交上链。
EntryPoint 合约：User Operation 的入口合约，实现了 handleOps 等方法。不需要钱包开发者实现，目前社区已经部署上线了，合约地址为 0x0576a174D229E3cFA37253523E645A78A0C91B57 。
Account 合约：钱包开发者需要实现的合约，必须实现 validateUserOp （EntryPoint 合约的 handleOps 方法会调用它）来校验 User Operation 的合法性。
Aggregator 合约：它是一个可选的合约。如果想实现签名聚合，则钱包开发者需要实现它
Paymaster 合约：它是一个可选的合约。如果想实现使用其它代币支付 Gas 等功能，则钱包开发者需要实现它

普通用户一般使用的是 EOA 帐户类型。EOA 帐户提交 Tx 到链上时，需要使用私钥对 Tx 进行 ECDSA 签名；节点收到 Tx 后，会先校验 ECDSA 签名，签名通过后才会执行 Tx。我们可以 把对 Tx 的处理过程分为校验（Verification）和执行（Execution）两个阶段。 对于 EOA 帐户来说，Verification 阶段是固定不变的，就是校验 ECDSA 签名是否正确。
在 EIP 4337（Account Abstraction，简称 AA）中，把校验（Verification）和执行（Execution）两个阶段进行了解耦，让钱包开发者可以定制 Verfification 的逻辑，比如使用其它签名算法（如 BLS 签名）来校验合法性，或者使用多签机制来校验合法性。


对于 EIP 4337 Tx 来说，用户的操作被封装在了 User Operation 对象中，调用 Bundler 的 RPC eth_sendUserOperation 可以提交 User Operation 到 User Operation Mempool 中；Bundler 通过调用 EntryPoint 合约的 handleOps 方法（这时会创建一个由 Bundler EOA 帐户签名的普通的 Tx），可以把 User Operation 作为 handleOps 的参数提交上链
用户的 Account 合约不需要提前部署就可以直接得到地址用于收款。这是由于这个合约是 AccountFactory 合约通过 create2 来创建，所以在创建之前就可以确定 Account 合约的地址了。

EntryPoint 合约在 EIP 4337 中是一个非常重要的合约，它已经通过审计并部署在各个 EVM 兼容链上了，合约地址为 0x0576a174D229E3cFA37253523E645A78A0C91B57 。
EntryPoint 的主要逻辑可分为 Verification Loop 和 Execution Loop 两个大循环。 在 Verification Loop 中会校验每个 User Operation 的合法性（这个阶段中如果发现 Account 合约还不存在，则会创建 Account 合约）；在 Execution Loop 中执行每个 User Operation。

Account 合约就是用户的智能合约钱包。应该具备普通 EOA 钱包的所有能力，比如可以给别人转帐，可以调用其它的合约
对于 Account 合约，钱包开发者至少需要实现下面两个函数：
1、校验 User Operation 签名的函数：function validateUserOp (UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds) 
2、发起交易的函数，以实现给别人转帐或调用其它的合约

一个用户对应一个 Account 合约，而 Account 合约由 AccountFactory 合约通过 create2 创建，所以钱包开发者还需要实现 AccountFactory 合约

当 User Operation 的 paymasterAndData 字段不为空时，表示处理这个 User Operation 时使用 Paymaster，这样支付给 Bundler 的 Gas 不用 Account 合约出了

为了防止恶意的 Paymaster 进行 DoS 攻击，Paymaster 需要先质押一些 ETH 到 EntryPoint 合约中 

Bundler 是需要独立部署的程序，它的主要作用是打包多个 User Operations 上链，即创建 EntryPoint.handleOps() 交易。这里 stackup-bundler 有个 Bundler 的开源实现，如果不想自己部署，也可以直接使用 https://www.stackup.sh/ 提供的 Bundler 节点。

Bundler 调用链上 EntryPoint 合约来处理 User Operation 时会消耗 Gas，这个 Gas 显然不能由 Bundler 来出
分两种情况讨论 Bundler 是如何得到 Gas 费：
1.不使用 Paymaster 时（即 User Operation 的 paymasterAndData 字段为空）
	EntryPoint 合约的 handleOps 方法在它的 Verification Loop 中调用 Account 合约的 validateUserOp(userOp, userOpHash, aggregator, missingAccountFunds) 方法时，最后一个参数 missingAccountFunds 指定的就是 Account 合约需要转给 EntryPoint 合约的 Gas 费，在实现 validateUserOp 时，至少需要把这么多数量的 Gas 转给 EntryPoint 合约。如果转账的数量多于 missingAccountFunds ，则 EntryPoint 合约会给这个 Account 合约记帐（称为 Gas 帐户，它是 EntryPoint 合约的一个 mapping，可用于下次手续费的使用），通过 EntryPoint 合约中的方法 balanceOf/depositTo/withdrawTo 可以查看/增加/减少 Gas 账户。
2.使用 Paymaster 时（即 User Operation 的 paymasterAndData 字段不为空）
	必须事先在 EntryPoint 合约中为 Paymaster 充值一些手续费（也是通过 EntryPoint 合约中的方法 balanceOf/depositTo/withdrawTo 可以查看/增加/减少这个 Gas 帐户）。因为，EntryPoint 合约的 handleOps 方法在它的 Verification Loop 中调用 IPaymaster(paymaster).validatePaymasterUserOp 前会检查 Gas 账户上 Paymaster 的手续费是否足够，如果足够就直接从 Gas 帐户中扣除；如果不够就报错。有一些方式来维持这个 Gas 账户上有足够的 ETH，如：A、每次在 EntryPoint 合约调用 IPaymaster(paymaster).validatePaymasterUserOp 时，paymaster 合约通过调用 EntryPoint 的 depositTo 来往 Gas 帐户充值；B、部署监控程序监控这个账户余额，低于某阈值了，就调用 EntryPoint 的 depositTo 来充值。

EIP 4337 问题
	1.无法使用禁止了合约帐户的 DApp  require(tx.origin == msg.sender);
	2.无法使用不支持 EIP 1271 的 DApp   合约帐户无私钥，无法生成 EIP 191/EIP 712 所需要的签名数据



```

 
