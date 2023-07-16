


## 结果
![avatar](/img/console_result.png)


## gas 消耗 
```shell   
使用AA 消耗了 8000436    
使用EOR 消耗  818185     是前者的 10% 
```
![avatar](/img/gas.png)


## 签名和校验签名的逻辑
```c

签名和校验签名的逻辑:

双椭圆曲线数字签名算法 ECDSA     
    签名= S(私钥,消息)     Verify={R(签名,消息)==公钥}    S=签名/加密   R=恢复公钥 

1.签名过程    简单来说就是  ECDSA.toEthSignedMessageHash(privateKey,  hash(Op.hash, entryPoint Address, chainId) )  ->  r,s,v
  
    userOpHash = entryPoint.getUserOpHash(userOp);
    // 根据哈希 和 Op 去签名 
    bytes memory signature = createSignature(userOp, userOpHash, ownerPrivateKey, vm);

    // 首先是 将消息哈希通过ECDSA转化   再用私钥签名  得到 v r s 连接起来就是签名 
    function createSignature(
        UserOperation memory userOp,  // 没用到
        bytes32 messageHash, // in form of ECDSA.toEthSignedMessageHash
        uint256 ownerPrivateKey,
        Vm vm
    ) pure returns (bytes memory) {
        bytes32 digest = ECDSA.toEthSignedMessageHash(messageHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        bytes memory signature = bytes.concat(r, s, bytes1(v));
        return signature;
    }    
    // 根据 (Op对象hash EntryPoint地址 chainid) 获取OpHash  
    function getUserOpHash(UserOperation calldata userOp) public view returns (bytes32) {
        return keccak256(abi.encode(userOp.hash(), address(this), block.chainid));
    }


2.校验过程      简单来说就是  messageHash = ECDSA.toEthSignedMessageHash( hash(Op.hash, entryPoint Address, chainId) )
                            ECDSA.recover(messageHash, userOp.signature);   // 签名和消息得到的东西是公钥 
    
    function _validateSignature(UserOperation calldata userOp, bytes32 userOpHash) internal view {
        bytes32 messageHash = ECDSA.toEthSignedMessageHash(userOpHash);  // 这个是算过的  和签名时候的 digest 一样的   hash(Op.hash, entryPoint Address, chainId)
        address signer = ECDSA.recover(messageHash, userOp.signature);  // 拿签名后的消息哈希和签名做恢复  得到的地址 必须对应私钥的公钥 
        require(signer == owner(), "SmartWallet: Invalid signature");
    }

```



