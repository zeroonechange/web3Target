

# BLS 算法
```
	BLSAccount.sol				  内含entryPoint和聚合器 
	BLSAccountFactory.sol		  工厂方法部署BLSAccount合约
	BLSSignatureAggregator.sol	  聚合器 实现IAggregator里面三个方法 
			validateSignatures()		校验多个OP
			validateUserOpSignature()   校验一个OP
			aggregateSignatures()		将多个签名转化成一个
	没看到多签的逻辑  只是把多个op的签名 压缩成一个  然后统一去校验  
```

# Gnosis Safe 多签框架 - A multisignature wallet with support for confirmations using signed messages based on ERC191.
```
	GnosisSafe.sol			核心功能  设置和执行 
	OwnerManager.sol 		权限管理 signature和threshold 
	ModuleManager.sol		添加模块 继承其功能 例如交易需要多少签名 当日交易限制
	GnosisSafeProxy.sol & GnosisSafeProxyFactory.sol   可升级 工厂方法部署新合约
	FallbackManager.sol		自由执行其他逻辑 


	OwnerManager  维护一个环  管理 owner表  新增 删除 更新..  修改 threshold
						闭环	owners[0x1]=owners[0]
								owners[_0]=owners[_1]
								owners[_1]=owners[_2]
								owners[_2]=owners[0x1]
								
	ModuleManager  管理模块 通过合约执行交易   也是一个环  
				   维护一个 mapping(address => address) modules;  只要在这里面就能执行方法
				   
	FallbackManager	类似于代理合约  通过 fallback 来执行逻辑 

	核心方法:
		execTransaction(
			address to,
			uint256 value,
			bytes calldata data,
			Enum.Operation operation,
			uint256 safeTxGas,
			uint256 baseGas,
			uint256 gasPrice,
			address gasToken,
			address payable refundReceiver,
			bytes memory signatures
		) 		
			encodeTransactionData()   交易数据打包
			checkSignatures()		  校验签名 
				checkNSignatures()
					for()             循环 threshold 次
						(v, r, s) = signatureSplit() // 将签名分为 uint8 v, bytes32 r, bytes32
						v=0, v=1, v>30, else
			Guard(guard).checkTransaction		检查
			execute()						    执行
			handlePayment()						把合约的钱转出来 避免去执行其他东西
			Guard(guard).checkAfterExecution()  收尾校验
```

# 其他标准协议
```c
ERC165
	supportsInterface(bytes4 interfaceId)  是否包含某个接口实现 
	
ERC721	is ERC165			非同质化代币标准  NFT 
	ownerOf(uint256 tokenId)
	safeTransferFrom(address from,address to,uint256 tokenId,bytes calldata data)
	safeTransferFrom(address from,address to,uint256 tokenId)
	transferFrom(address from,address to,uint256 tokenId)
	approve(address to, uint256 tokenId)
	setApprovalForAll(address operator, bool _approved)
	getApproved(uint256 tokenId)
	isApprovedForAll(address owner, address operator)
	
	为了接受NFT的安全转账，则必须实现以下接口  ERC721TokenReceiver 
	
ERC777 is ERC20			尝试改进大家常用的 ERC20   
	name() symbol()	totalSupply()	balanceOf(address owner)
	granularity()	获得代币最小的划分粒度  最小的挖矿、发送及销毁粒度
	send(address recipient,uint256 amount,bytes calldata data)		给地址to发送 amount 数量的代币
	burn(uint256 amount, bytes calldata data)
	isOperatorFor(address operator, address tokenHolder) 	是否是某个持有者的操作员
	authorizeOperator(address operator)	设置一个第三方的 operator 地址作为msg.sender 的操作员，此操作员可以代表 msg.sender 发送和销毁代币
	revokeOperator(address operator)	移除 msg.sender 的 操作员权限
	defaultOperators() 					获取代币合约默认的操作员列表
		操作员（msg.sender）代表 from地址 给地址to发送 amount 数量的代币
	operatorSend(address sender,address recipient,uint256 amount,bytes calldata data,bytes calldata operatorData) 
		从 msg.sender 账号销毁 amount 数量的代币
	operatorBurn(address account,uint256 amount,bytes calldata data,bytes calldata operatorData)
	
	标准尝试改进大家常用的 ERC20 代币标准。 ERC777标准的主要优点有：
		使用和发送以太相同的理念发送token，方法为：send(dest, value, data).
		合约和普通地址都可以通过注册tokensToSend hook函数来控制和拒绝发送哪些token（拒绝发送通过在hook函数tokensToSend 里 revert 来实现）。
		合约和普通地址都可以通过注册tokensReceived hook函数来控制和拒绝接受哪些token（拒绝接受通过在hook函数tokensReceived 里 revert 来实现）。
		tokensReceived 可以通过hook函数可以做到在一个交易里完成发送代币和通知合约接受代币，而不像 ERC20 必须通过两次调用（approve/transferFrom）来完成。
		持有者可以"授权"和"撤销"操作员（operators: 可以代表持有者发送代币）。 这些操作员通常是（去中心化）交易所、支票处理机或自动支付系统。
		每个代币交易都包含 data 和 operatorData 字段， 可以分别传递来自持有者和操作员的数据。
		可以通过部署实现 tokensReceived 的代理合约来兼容没有实现tokensReceived 函数的地址
	
	新增一个操作员 角色 operator  可以操控别人的token  其他的没啥
	
	
ERC1155	is ERC165 	多代币标准
	safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) 
	safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)
	balanceOf(address _owner, uint256 _id)
	balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) 
	setApprovalForAll(address _operator, bool _approved)
	isApprovedForAll(address _owner, address _operator)
	
	必须实现 ERC1155TokenReceiver  才能使用 
	
	多个token  token[owner].balance 
	多个操作员 account[operator]=true 
	可以一次对多个token进行转账

```

# 框架主要逻辑
```c
EntryPoint.handleOps
	for()
		_validatePrepayment           
			_getRequiredPrefund				-计算需要多少gas 费
			_validateAccountPrepayment		-[常规校验1]  创建合约+EOA还要支付多少gas+AC校验+更新存款信息+计算已消耗多少gas
				_createSenderIfNeeded
				IAccount(sender).validateUserOp - 是否过期的时间就是这里返回的 
			_validatePaymasterPrepayment	-[paymaster校验2] entrypoint里面存的钱够不够  再去调用  paymaster 方法去校验   
				IPaymaster(paymaster).validatePaymasterUserOp  - 是否过期的时间就是这里返回的 
		_validateAccountAndPaymasterValidationData
			_getValidationData(validationData)				-解析 [校验常规校验1]  返回的数据 查看是否有聚合器  是否超出了校验时间
			_getValidationData(paymasterValidationData)		-解析 [paymaster校验2] 返回的数据 查看是否有聚合器  是否超出了校验时间
			
	for()
		_executeUserOp
			innerHandleOp
				Exec.call				-执行 AC 逻辑
				_handlePostOp			-计算OP总共消耗了多少gas   多余的更新 entrypoint 表 
	_compensate							-转账给 beneficiary   因为前面计算过了  更新了表 所以这里要退 
	

```


Implementation of contracts for [ERC-4337](https://eips.ethereum.org/EIPS/eip-4337) account abstraction via alternative mempool.

# Resources

[Vitalik's post on account abstraction without Ethereum protocol changes](https://medium.com/infinitism/erc-4337-account-abstraction-without-ethereum-protocol-changes-d75c9d94dc4a)

[Discord server](http://discord.gg/fbDyENb6Y9)

[Bundler reference implementation](https://github.com/eth-infinitism/bundler)

[Bundler specification test suite](https://github.com/eth-infinitism/bundler-spec-tests)
