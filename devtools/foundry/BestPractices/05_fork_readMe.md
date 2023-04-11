


```c
anvil --fork-url https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3   分叉主网
export ALICE=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266							本地网络生成的账号
export DAI=0x6b175474e89094c44da98b954eedeac495271d0f							DAI 上面的合约地址
export LUCKY_USER=0x6FF8E4DB500cBd77d1D181B8908E022E29e0Ec4A					真实持有人的地址
cast call $DAI "balanceOf(address)(uint256)" $ALICE                             查看余额
cast call $DAI "balanceOf(address)(uint256)" $LUCKY_USER
cast rpc anvil_impersonateAccount $LUCKY_USER								    冒充持有人 去发送东西 
cast send $DAI --from $LUCKY_USER "transfer(address,uint256)(bool)" $ALICE 147851621172240086   	转账
cast call $DAI "balanceOf(address)(uint256)" $ALICE                             再次查看余额  会改变
cast call $DAI "balanceOf(address)(uint256)" $LUCKY_USER

这个是fork主网  然后冒充真实地址  最后一系列操作  
```

