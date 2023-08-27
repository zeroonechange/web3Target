
```
看源码  核心类 
    https://docs.aave.com/developers/core-contracts/aclmanager  

```


```
看视频  https://www.youtube.com/watch?v=LzaS8IiqnPY  
       https://docs.aave.com/developers/getting-started/readme

AAVE
    suppliers  borrowers  liquidators
    ethereum  avalanche  amm  fantom  polygon arbitrum harmony 
what's new at V3?
    
    capital efficiency
        portals: 跨链资产自由兑换 mint/burn 
        eMode: 同category的币利用率很高 CF(collateral factor) 抵押额度
               稳定币 {USDT DAI USDC, CF=98%} 
               eth eMode {ETH stETH alETH, CF=95%}  
               BTC eMode {WBTC renBTC, CF=95%}
    
    risk & security
        supply & borrow caps  dao自治设置不同的存款/借款上限 
        isolation Mode  资产隔离  新token被隔离后被质押 只能借稳定币 
        risk Admins 风险管理员 评估和控制风险参数例如利率之类 不需要每次都提案通过 
        listing Admins  管理和控制平台上可用的资产列表   
    
    other features
        permit   是一种机制，允许用户以一种授权方式访问和使用其代币  EIP-2612 签名授权给其他去访问自己的token
        repayment with aTokens  把债务做成 token   mint就是负债  burn就是还债 
        simplified flashloan 降低20%的gas费
        authorized flash borrowers     AAVE合约授权的闪电借贷者 被允许低手续费进行闪电借贷
        listed assets can support multiple token incentives  多种代币激励

Smart contract
    @aave/core-v3 
    @aave/core-periphery-v3    
    @aave/contract-helpers     ---- javascript sdk 
        Pool.sol  { supply   borrow   repay   withdraw }

Live Data  
    AaveProtocolDataProvider.sol

Historical Data 
    https://github.com/aave/protocol-subgraphs

```


```
看文档   https://docs.aave.com/hub/ 

Aavenomics
    Governance
        Policies
            protocol policies  - 安全 经济模型 扩张
                risk policies - 参数调整 利率 借贷率
                improvement policies - 合约，智利合约，安全模块合约
                incentives policies - 安全激励Safety Incentives(SI), 生态激励-LP和清算Ecosystem Incentives(EI)
            market policies - 创建货币市场，确定资产，参数，抵押品，借贷模式，风险配置，利率模型
        Genesis Governance

    Safety Module
        短缺事件 防止踩踏 过量AAVE流入市场

    Incentives Policy & AAVE Reserve
        安全模块激励     流动性激励

    Flashpaper
        LEND 100:1 AAVE 迁移  总供应量=16M    Safety Module
    Terminology
        Aave Genesis Governance     Aave Improvement Proposals
        Backstop    Ecosystem Incentives/Reserve
        Recovery Issusnace      Safety Incentives/Module

Risk
    Risk Framework
    Asset Risk
    Interest Rate Model
        Interest Rate Simulation
    Liquidity Risk


Developers
    Doc
    GHO develope doc

```


```
1.白皮书 官网文档  翻译文档 
2.视频
3.合约代码

```
