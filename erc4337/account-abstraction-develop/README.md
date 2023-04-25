
# 个人总结
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
