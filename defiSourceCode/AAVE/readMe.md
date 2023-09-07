```
非常有用的博客  节省了好多时间   要善于找资料
https://blog.wssh.trade/posts/aave-interactive
https://blog.wssh.trade/posts/aave-contract-part1/
https://blog.wssh.trade/posts/aave-contract-part2/
https://blog.wssh.trade/posts/aave-contract-part3/
```

```
InitializableImmutableAdminUpgradeabilityProxy     在 PoolConfigurator
aToken都是代理合约

        Initializable 合约    用 initializer 去代替构造函数进行初始化 确保只会执行一次  因为代理合约不会去调用构造函数
                bool initialized;
                bool initializing;
                modifier initializer() {  initializing || !initialized || isConstructor()   }
                function isConstructor() private view returns (bool)    汇编查看是否有
        单独使用  第一次就会改变 initialized=true  后面无法继续执行   如果多次重入 会执行 类似递归
        https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable

    VersionedInitializable   aave改进的 带版本控制
            uint256 lastInitializedRevision = 0;   用这个来代替 initialized  如果初始化成功了 版本号会变
            bool initializing;

    InitializableImmutableAdminUpgradeabilityProxy
            constructor(address admin) BaseImmutableAdminUpgradeabilityProxy(admin) 走父类构造函数
            function _willFallback()  走 BaseImmutableAdminUpgradeabilityProxy._willFallback()  sender!=admin

    InitializableUpgradeabilityProxy
            function initialize(address _logic, bytes memory _data)    初始化的方法

    BaseImmutableAdminUpgradeabilityProxy
            address immutable _admin;
            modifier ifAdmin()
            constructor(address admin)  设置 admin
            function upgradeToAndCall(newImplementation, calldata)  只能admin权限  先升级再 delegatecall

    BaseUpgradeabilityProxy
            event Upgraded      升级事件
            bytes32 IMPLEMENTATION_SLOT = uint256(keccak-256("eip1967.proxy.implementation"))-1  slot固定的
            function _implementation() override    返回实现地址
            function _upgradeTo(address newImplementation)
            function _setImplementation(address newImplementation)

    Proxy
            fallback()
            _implementation()
            function _delegate(address implementation)  最核心的方法  汇编写的  delegatecall
            function _willFallback()
            function _fallback()
```

```
AaveOracle.sol
        IAaveOracle + IPriceOracleGetter
        BASE_CURRENCY BASE_CURRENCY_UNIT  getAssetPrice
        event BaseCurrencySet AssetSourceUpdated FallbackOracleUpdated
        function ADDRESSES_PROVIDER setAssetSources setFallbackOracle getAssetsPrices
                         getSourceOfAsset getFallbackOracle

        总的来说  俩套方案 一个是 Chainlink 的报价 AggregatorInterface
                 还有个就是 备用的预言机  设置的时候 可以多个一起设置   获取价格的策略就是 优先预言机 如果没有 或 预言机价格不对 就走备用的
```

```
PoolConfigurator.sol
        IPoolConfigurator
                event ReserveInitialized ReserveBorrowing ReserveFlashLoaning CollateralConfigurationChanged
                          ReserveStableRateBorrowing ReserveActive ReserveFrozen ReservePaused ReserveDropped
                          ReserveFactorChanged BorrowCapChanged SupplyCapChanged LiquidationProtocolFeeChanged
                          UnbackedMintCapChanged EModeAssetCategoryChanged EModeCategoryAdded ReserveInterestRateStrategyChanged ATokenUpgraded StableDebtTokenUpgraded
                          VariableDebtTokenUpgraded DebtCeilingChanged SiloedBorrowingChanged BridgeProtocolFeeUpdated
                          FlashloanPremiumTotalUpdated FlashloanPremiumToProtocolUpdated BorrowableInIsolationChanged

            function initReserves updateAToken updateStableDebtToken updateVariableDebtToken
                     setReserveBorrowing configureReserveAsCollateral setReserveStableRateBorrowing
                     setReserveFlashLoaning setReserveActive setReserveFreeze setBorrowableInIsolation
                     setReservePause setReserveFactor setReserveInterestRateStrategyAddress
                     setPoolPause setBorrowCap setSupplyCap setLiquidationProtocolFee setUnbackedMintCap
                     setAssetEModeCategory setEModeCategory dropReserve updateBridgeProtocolFee
                     updateFlashloanPremiumTotal updateFlashloanPremiumToProtocol setDebtCeiling setSiloedBorrowing
        沃日  这么多set方法

        前面第一排 主要是代理合约的功劳  InitializableImmutableAdminUpgradeabilityProxy.sol

        后面的set方法 就是 从 pool 拿到配置  转成 memory  再设置回去  反正就一个slot 十多个参数 才会凑出这么多方法

        最后的 update 和 set 是一样的
```

```
Pool.sol
        Main point of interaction with an Aave protocol's market
         * - Users can:
         *   # Supply
         *   # Withdraw
         *   # Borrow
         *   # Repay
         *   # Swap their loans between variable and stable rate
         *   # Enable/disable their supplied assets as collateral rebalance stable rate borrow positions
         *   # Liquidate positions
         *   # Execute Flash Loans
        几乎协议所有的逻辑都集中在这里了

        Pool is VersionedInitializable, PoolStorage, IPool
                VersionedInitializable: 看起来是合约升级 类似 Initializable contract
                PoolStorage: 5张表  _reserves _usersConfig  _reservesList  _eModeCategories  _usersEModeCategory
                                         费用 _bridgeProtocolFee _flashLoanPremiumTotal _flashLoanPremiumToProtocol  _maxStableRateBorrowSizePercent  _reservesCount
                IPool: 池子基本接口    看最后的 前置知识

逻辑存放在 PoolLogic ReserveLogic EModeLogic SupplyLogic FlashLoanLogic BorrowLogic LiquidationLogic BridgeLogic
        这种代码编程的方式确实很舒服  很清晰  值得学习   把数据结构和逻辑的参数都放一个地方  拿到了传到里面去执行  也好搞测试  解耦

        所以要看具体的逻辑要去 各个 Logic去看  比如 LiquidationLogic 就一个公开的方法  饶是如此 也有500多行
        确实难搞   太复杂了   后面再去看


前置知识
------------------------------------------------------------------------
        IPool.sol
                event MintUnbacked, BackUnbacked, Supply, Withdraw, Borrow, Repay, SwapBorrowRateMode,
                          IsolationModeTotalDebtUpdated, UserEModeSet, ReserveUsedAsCollateralEnabled,
                          ReserveUsedAsCollateralDisabled, RebalanceStableBorrowRate, FlashLoan, LiquidationCall,
                          ReserveDataUpdated, MintedToTreasury,
                function mintUnbacked, backUnbacked, supply, supplyWithPermit, withdraw, borrow, repay,
                                 repayWithPermit, repayWithATokens, swapBorrowRateMode, rebalanceStableBorrowRate,
                                 setUserUseReserveAsCollateral, liquidationCall, flashLoan, flashLoanSimple, deposit
                                 getUserAccountData, initReserve, dropReserve, setReserveInterestRateStrategyAddress,
                                 setConfiguration, getConfiguration, getUserConfiguration, getReserveNormalizedIncome,
                                 getReserveNormalizedVariableDebt, getReserveData, finalizeTransfer, getReservesList,
                                 getReserveAddressById, ADDRESSES_PROVIDER, updateBridgeProtocolFee, updateFlashloanPremiums
                                 configureEModeCategory, getEModeCategoryData, setUserEMode, getUserEMode, mintToTreasury
                                 resetIsolationModeTotalDebt, MAX_STABLE_RATE_BORROW_SIZE_PERCENT, FLASHLOAN_PREMIUM_TOTAL
                                 BRIDGE_PROTOCOL_FEE, FLASHLOAN_PREMIUM_TO_PROTOCOL, MAX_NUMBER_RESERVES, rescueTokens,

                沃日  好多方法 主要是存钱取钱 还能借助EIP-713去Permit授权操控钱 清算 eMode 隔离模式 闪电贷 各种ptotocal fee
------------------------------------------------------------------------
```

```
PriceOracleSentinel.sol
        PoolAddressesProvider
        SequencerOracle
        gracePeriod   宽限期   当前时间-上次更新时间 > 这个值
        非常简单
        俩个 modifier  1. onlyPoolAdmin()   2. onlyRiskOrPoolAdmins()
        function _isUpAndGracePeriodPassed()  是否过了宽限期   其他都是设置方法 待限制
```

```
PoolAddressesProviderRegistry.sol

前置知识
------------------------------------------------------------------------
        IPoolAddressesProvider.sol
                各种事件
                event MarketIdSet, PoolUpdated, PoolConfiguratorUpdated, PriceOracleUpdated, ACLManagerUpdated,
                          ACLAdminUpdated, PriceOracleSentinelUpdated, PoolDataProviderUpdated, ProxyCreated, AddressSet
                setMarketId(string calldata newMarketId)
                setAddressAsProxy(bytes32 id, address newImplementationAddress)
                setAddress(bytes32 id, address newAddress)
                setPoolImpl(address newPoolImpl)
                setPriceOracle(address newPriceOracle)
                setACLManager(address newAclManager)
                setACLAdmin(address newAclAdmin)
                setPriceOracleSentinel(address newPriceOracleSentinel)
                setPoolDataProvider(address newDataProvider)
                这里面 代理 pool 价格预言机 权限管理  价格预言机哨兵 pooldataprovider

        ----------------------------------------------
        summary:
                IPoolDataProvider 里面全是get方法 提供token信息 emode 借贷费 等
                IPoolAddressesProvider 对各种重要的功能进行 get/set 例如 proxy pool 预言机 权限管理-admin PoolDataProvider
                IPool  主要是暴露给用户操作  1.存钱/取钱/清算/闪电贷  2.使用emode/隔离模式
        ----------------------------------------------
------------------------------------------------------------------------

        IPoolAddressesProviderRegistry
                event AddressesProviderRegistered, AddressesProviderUnregistered
                function getAddressesProvidersList, getAddressesProviderIdByAddress, getAddressesProviderAddressById
                                 registerAddressesProvider, unregisterAddressesProvider
                看起来就是对 PoolAddressesProvider 进行管理


        PoolAddressesProviderRegistry.sol
                这个合约  看它的数据结构 就知道它要放什么屁  简单

```

````
PoolAddressesProvider.sol

前置知识
------------------------------------------------------------------------
        IPoolAddressesProvider.sol
                各种事件
                event MarketIdSet, PoolUpdated, PoolConfiguratorUpdated, PriceOracleUpdated, ACLManagerUpdated,
                          ACLAdminUpdated, PriceOracleSentinelUpdated, PoolDataProviderUpdated, ProxyCreated, AddressSet
                setMarketId(string calldata newMarketId)
                setAddressAsProxy(bytes32 id, address newImplementationAddress)
                setAddress(bytes32 id, address newAddress)
                setPoolImpl(address newPoolImpl)
                setPriceOracle(address newPriceOracle)
                setACLManager(address newAclManager)
                setACLAdmin(address newAclAdmin)
                setPriceOracleSentinel(address newPriceOracleSentinel)
                setPoolDataProvider(address newDataProvider)
                这里面 代理 pool 价格预言机 权限管理  价格预言机哨兵 pooldataprovider

        ----------------------------------------------
        summary:
                IPoolDataProvider 里面全是get方法 提供token信息 emode 借贷费 等
                IPoolAddressesProvider 对各种重要的功能进行 get/set 例如 proxy pool 预言机 权限管理-admin PoolDataProvider
                IPool  主要是暴露给用户操作  1.存钱/取钱/清算/闪电贷  2.使用emode/隔离模式
        ----------------------------------------------
------------------------------------------------------------------------
那么这样看  这个就是各种 get/set 不应该有其他核心的东西咯   let's take a look~
        非常简单 有意思的是  地址存储思路
        一个mapping(bytes32, address) 其中 POOL, ACL_MANAGER等  key都是固定的

```solidity
  mapping(bytes32 => address) private _addresses;

  // Main identifiers  和上面的 _addresses配合使用 规定了 POOL ACL_MANAGER 等固定的key
  bytes32 private constant POOL = 'POOL';
  bytes32 private constant POOL_CONFIGURATOR = 'POOL_CONFIGURATOR';
  bytes32 private constant PRICE_ORACLE = 'PRICE_ORACLE';
  bytes32 private constant ACL_MANAGER = 'ACL_MANAGER';
  bytes32 private constant ACL_ADMIN = 'ACL_ADMIN';
  bytes32 private constant PRICE_ORACLE_SENTINEL = 'PRICE_ORACLE_SENTINEL';
  bytes32 private constant DATA_PROVIDER = 'DATA_PROVIDER';

  function setACLAdmin(address newAclAdmin) external override onlyOwner {
    address oldAclAdmin = _addresses[ACL_ADMIN];
    _addresses[ACL_ADMIN] = newAclAdmin;
    emit ACLAdminUpdated(oldAclAdmin, newAclAdmin);
  }
````

```


```

AaveProtocolDataProvider.sol

        DataTypes.sol
                ReserveConfigurationMap  池子的参数  全放在一个slot里面  从 bit 0 开始 到255 结束  牛

        ReserveConfiguration.sol  用来管理池子的参数 例如 loan value, LiquidationThreshold,
                reserve/borrowing/flashloaning enable, borrow/supply cap, fee, eMode category, debt ceiling
                各种掩码 二进制异或与运算  代码写的整洁

        UserConfiguration.sol     用户配置参数  Bitmap of the users collaterals and borrows
                一个 uint256  存放了127个 pair对 010101 一个放是否抵押 一个放是否借贷  又是各种掩码 二进制异或与运算
                相对池子Reserve配置来说  比较简单了  一个位图 能玩出多少花样呢

        WadRayMath.sol   计算库  看起来和 MathUtil 类似 提供 mul 和 div 方法
                俩种计算单元 Wad and Ray units  还提供了俩者转换的方法  一共 6个函数
                        wad 是 18位
                        ray 是 27位

        IStableDebtToken.sol
                event Mint, Burn
                function mint, burn, getAverageStableRate, getUserStableRate, getUserLastUpdated, getSupplyData
                                 getTotalSupplyLastUpdated, getTotalSupplyAndAvgRate, principalBalanceOf, UNDERLYING_ASSET_ADDRESS
                稳定债务token  个人感觉 结合ERC20 和 利率 债务 这些来看

        IScaledBalanceToken.sol
                event Mint, Burn
                function scaledBalanceOf, getScaledUserBalanceAndSupply, scaledTotalSupply, getPreviousIndex
                scaled 缩放 自由浮动  主要是balance 和 supply 利息

        IVariableDebtToken.sol
                function mint, burn, UNDERLYING_ASSET_ADDRESS
                浮动债务token  看起来和稳定债务token一样

        IPool.sol
                event MintUnbacked, BackUnbacked, Supply, Withdraw, Borrow, Repay, SwapBorrowRateMode,
                          IsolationModeTotalDebtUpdated, UserEModeSet, ReserveUsedAsCollateralEnabled,
                          ReserveUsedAsCollateralDisabled, RebalanceStableBorrowRate, FlashLoan, LiquidationCall,
                          ReserveDataUpdated, MintedToTreasury,
                function mintUnbacked, backUnbacked, supply, supplyWithPermit, withdraw, borrow, repay,
                                 repayWithPermit, repayWithATokens, swapBorrowRateMode, rebalanceStableBorrowRate,
                                 setUserUseReserveAsCollateral, liquidationCall, flashLoan, flashLoanSimple, deposit
                                 getUserAccountData, initReserve, dropReserve, setReserveInterestRateStrategyAddress,
                                 setConfiguration, getConfiguration, getUserConfiguration, getReserveNormalizedIncome,
                                 getReserveNormalizedVariableDebt, getReserveData, finalizeTransfer, getReservesList,
                                 getReserveAddressById, ADDRESSES_PROVIDER, updateBridgeProtocolFee, updateFlashloanPremiums
                                 configureEModeCategory, getEModeCategoryData, setUserEMode, getUserEMode, mintToTreasury
                                 resetIsolationModeTotalDebt, MAX_STABLE_RATE_BORROW_SIZE_PERCENT, FLASHLOAN_PREMIUM_TOTAL
                                 BRIDGE_PROTOCOL_FEE, FLASHLOAN_PREMIUM_TO_PROTOCOL, MAX_NUMBER_RESERVES, rescueTokens,

                沃日  好多方法 主要是存钱取钱 还能借助EIP-713去Permit授权操控钱 清算 eMode 隔离模式 闪电贷 各种ptotocal fee bridge不懂

        IPoolAddressesProvider.sol
                各种事件
                event MarketIdSet, PoolUpdated, PoolConfiguratorUpdated, PriceOracleUpdated, ACLManagerUpdated,
                          ACLAdminUpdated, PriceOracleSentinelUpdated, PoolDataProviderUpdated, ProxyCreated, AddressSet
                setMarketId(string calldata newMarketId)
                setAddressAsProxy(bytes32 id, address newImplementationAddress)
                setAddress(bytes32 id, address newAddress)
                setPoolImpl(address newPoolImpl)
                setPriceOracle(address newPriceOracle)
                setACLManager(address newAclManager)
                setACLAdmin(address newAclAdmin)
                setPriceOracleSentinel(address newPriceOracleSentinel)
                setPoolDataProvider(address newDataProvider)
                这里面 代理 pool 价格预言机 权限管理  价格预言机哨兵 pooldataprovider

        IPoolDataProvider.sol
                全是方法
                function ADDRESSES_PROVIDER, getAllReservesTokens, getAllATokens, getReserveConfigurationData
                                 getReserveEModeCategory, getReserveCaps, getPaused, getSiloedBorrowing, getDebtCeiling
                                 getLiquidationProtocolFee, getUnbackedMintCap, getDebtCeilingDecimals, getReserveData
                                 getATokenTotalSupply, getTotalDebt, getUserReserveData, getReserveTokensAddresses,
                                 getInterestRateStrategyAddress, getFlashLoanEnabled
                AaveProtocolDataProvider的抽象接口
                        主要是资产集合 atoken信息 emode类别 cap上限 池子是否暂停 清算协议费 债务上限 储蓄信息  总供应/债务

        ------------------------------------------------------------------------
        summary:
                IPoolDataProvider 里面全是get方法 提供token信息 emode 借贷费 等
                IPoolAddressesProvider 对各种重要的功能进行 get/set 例如 proxy pool 预言机 权限管理-admin PoolDataProvider
                IPool  主要是暴露给用户操作  1.存钱/取钱/清算/闪电贷  2.使用emode/隔离模式
        ------------------------------------------------------------------------


        AaveProtocolDataProvider.sol    王炸来了
                鸡毛啊   这个类非常简单
                        其实主要是操作 IPool 拿到 DataTypes.ReserveConfigurationMap  然后通过ReserveConfiguration去拿信息
                        其次是对各种 aToken-IERC20Detailed  IStableDebtToken IVariableDebtToken 去拿token的信息
        核心还是 Pool 数据都放在那里面  这个类似工具类  去Pool拿想要的数据  然后组装返回

```


```

ACLManager.sol 权限管理

ERC165 -supportsInterface

OpenZeppelin AccessControl.sol 权限管理
DEFAULT_ADMIN_ROLE
bytes32=>{ (address=>bool), adminRole }
表结构 第一个bytes32 就是权限的名称 一般由keccak256("MY_ROLE")生成
adminRole是一个address 表示这个权限的admin
(address=>bool) 是否有这个权限  
 核心: 权限role由俩部分组成 一个是普通的role 一个是上层的管理普通role的admin role
这样一来 如果有admin role 只需更新一个表就可以达到目标了 具体modifier和方法:
modifier onlyRole(bytes32 role)
hasRole(bytes32 role, address account)
\_checkRole(bytes32 role, address account)
getRoleAdmin(bytes32 role) 获取当前role的admin表
grantRole(bytes32 role,address account)
revokeRole(bytes32 role,address account)
renounceRole(bytes32 role, address account)
\_setupRole(bytes32 role, address account)
\_setRoleAdmin(bytes32 role, bytes32 adminRole)
\_grantRole(bytes32 role, address account)
\_revokeRole(bytes32 role, address account)

IACLManager.sol
POOL_ADMIN_ROLE
EMERGENCY_ADMIN_ROLE
RISK_ADMIN_ROLE
FLASH_BORROWER_ROLE
BRIDGE_ROLE
ASSET_LISTING_ADMIN_ROLE
反正是一堆 get 和 set admin role的方法 无所吊谓

```


```

看源码 核心类
https://docs.aave.com/developers/getting-started/readme  
 https://learnblockchain.cn/article/4397
https://github.com/Dapp-Learning-DAO/Dapp-Learning/blob/main/defi/Aave/whitepaper/AAVE_V3_Techpaper.md

        ACLManager.sol
                Access Control List Manager is the main registry of system roles and permissions.
                各种admin角色  各种权限管理  role汇总{FLASH_BORROWER, BRIDGE, ASSET_LISTING_ADMIN, RISK_ADMIN ACL_ADMIN, EMERGENCY_ADMIN, POOL_ADMIN}

        AaveProtocolDataProvider.sol
                Peripheral contract to collect and pre-process information from the Pool.
                获取协议各种参数  例如 all tokens, reserve configurations/caps/DATA, eMode category, paused,
                siloed assets(隔离资产), liquidation fee, debt ceiling(债务上限), aToken supply, total debt,
                interest rate strategy address

        PoolAddressesProvider.sol
                Addresses register of the protocol for a particular market. This contract is immutable and the address will never change.
                市场信息
                        get方法 marketId, address, pool address/configurator/DATAprovider, price oracle/sentinel(哨兵), ACL Manager/Admin,
                        write方法 marketId, address/asProxy, poolImpl, poolConfiguratorImp, PriceOracle, ACLAdmin, PriceOracleSentinel, PoolDataProvider

        PoolAddressesProviderRegistry.sol
                A register of the active [PoolAddressesProvider](./pooladdressesprovider.md) contracts, covering all markets. This contract is immutable and the address will never change.
                可看做是 PoolAddressesProvider 是一个外部只读工具类  只有2个get方法
                AddressesProviderList  AddressesProviderIdByAddress

        PriceOracleSentinel.sol
                This contract validates if the operations are allowed depending on the PriceOracle health.
                预言机哨兵
                        isBorrowAllowed isLiquidationAllowed getSequencerOracle getGracePeriod
                        setSequencerOracle setGracePeriod

        Pool.sol
                is the main user facing contract of the protocol. It exposes the liquidity management methods
                协议主要暴露给外面调用的方法
                write方法
                        supply        supplyWithPermit        withdraw        borrow        repay        repayWithPermit        repayWithATokens
                        swapBorrowRateMode        rebalanceStableBorrowRate        setUserUseReserveAsCollateral        liquidationCall
                        flashLoan        flashLoanSimple  mintToTreasury        setUserEMode  mintUnbacked        backUnbacked  rescueTokens
                get方法
                        getReserveData  getUserAccountData  getConfiguration  getUserConfiguration  getReserveNormalizedIncome
                        getReserveNormalizedDebt  getReservesList  getEModeCategoryData  getUserEMode

        PoolConfigurator.sol
                Risk or Pool Admins
                setSiloedBorrowing         Asset Listing or Pool Admins        Only Pool Admin

        AaveOracle.sol
                Contract to get asset prices, manage price sources and update the fallback oracle.
                Protocol V3 uses Chainlink Aggregators as the source of all asset prices.
                预言机 主要使用了 Chainlink的聚合器
                getAssetPrice        getAssetsPrices  getSourceOfAsset  getFallbackOracle
                setAssetSources  setFallbackOracle

```


```

看视频 https://www.youtube.com/watch?v=LzaS8IiqnPY  
 https://docs.aave.com/developers/getting-started/readme

AAVE
suppliers borrowers liquidators
ethereum avalanche amm fantom polygon arbitrum harmony
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
 @aave/contract-helpers ---- javascript sdk
Pool.sol { supply borrow repay withdraw }

Live Data  
 AaveProtocolDataProvider.sol

Historical Data
https://github.com/aave/protocol-subgraphs

```


```

看文档 https://docs.aave.com/hub/

Aavenomics
Governance
Policies
protocol policies - 安全 经济模型 扩张
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

1.白皮书 官网文档 翻译文档2.视频3.合约代码

```

```
