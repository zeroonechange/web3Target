# have fun

```rust
想做的事
      1.夹子机器人  清算机器人     闪电贷机器人
      2.逆向分析
      3.rust实际项目

rpc 免费节点  变换  不行就换节点

夹子  -- 换钱 uniswapv2 uniswapv3  监听 pending tx
清算  -- 借贷 aave v2 v3  compond  markerDao  拿到关键信息 得到健康因子  在交易后立马执行
闪电贷   检测关键函数    BalancerV2  AaveV2  dYdX  Uniswap V3   那为啥aave和unisawp的V3没有呢?

以太链为例  拿到 接口 和 地址
        uniswap v2/v3
        aave v2/v3
        compond
        markerDao
        BalancerV2
        dYdX

https://github.com/SunWeb3Sec/DeFiLabs  很多 采用的 foundry 架构
还需要整一个以 node 架构   执行js做 mempool 监听
```

## sandwich, liquidation, flashloan

## Foundry usage

```shell
$ export http_proxy='http://127.0.0.1:7890'
$ export https_proxy='http://127.0.0.1:7890'
$ export all_proxy='socks5://127.0.0.1:7890'
$ export ALL_PROXY='http://127.0.0.1:7890'

$ source /Users/jack/.zshenv
$ foundryup

$ forge init havefun
$ forge build
$ forge test

forge install transmissions11/solmate
forge install OpenZeppelin/openzeppelin-contracts
forge remappings


https://book.getfoundry.sh/
```

## Node usage

```js
npm init
npm i ethers@5.7.2 --save
npm i

node js/evmbot.js

```
