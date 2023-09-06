// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.0;


// struct 设计原则    能省空间就节省  不能就直接放 
library DataTypes {
  // 池子的配置
  struct ReserveData {
    //stores the reserve configuration
    ReserveConfigurationMap configuration;  // 大量配置
    //the liquidity index. Expressed in ray
    uint128 liquidityIndex;  // 流动性池自创立到更新时间戳之间的累计利率(贴现因子)
    //the current supply rate. Expressed in ray
    uint128 currentLiquidityRate; // 当前的存款利率
    //variable borrow index. Expressed in ray
    uint128 variableBorrowIndex;  // 浮动借款利率自流动性池建立以来的累计利率(贴现因子)
    //the current variable borrow rate. Expressed in ray
    uint128 currentVariableBorrowRate; //当前的浮动利率
    //the current stable borrow rate. Expressed in ray
    uint128 currentStableBorrowRate;   //当前固定利率
    //timestamp of last update
    uint40 lastUpdateTimestamp; // 上次数据更新时间戳
    //the id of the reserve. Represents the position in the list of the active reserves
    uint16 id;
    //aToken address
    address aTokenAddress;
    //stableDebtToken address
    address stableDebtTokenAddress;
    //variableDebtToken address
    address variableDebtTokenAddress;
    //address of the interest rate strategy
    address interestRateStrategyAddress;  // 利率策略合约地址
    //the current treasury balance, scaled
    uint128 accruedToTreasury;  // 当前准备金余额
    //the outstanding unbacked aTokens minted through the bridging feature
    uint128 unbacked;  // 通过桥接功能铸造的未偿还的无担保代币
    //the outstanding debt borrowed against this asset in isolation mode
    uint128 isolationModeTotalDebt;  // 以该资产借入的未偿债务的单独模式
  }

  // 池子的参数  全放在一个slot里面   从 bit 0 开始 到255 结束  牛 
  struct ReserveConfigurationMap {
    //bit 0-15: LTV
    //bit 16-31: Liq. threshold
    //bit 32-47: Liq. bonus
    //bit 48-55: Decimals   质押代币(ERC20)精度 
    //bit 56: reserve is active    质押品可以使用
    //bit 57: reserve is frozen    质押品冻结，不可使用
    //bit 58: borrowing is enabled  
    //bit 59: stable rate borrowing enabled
    //bit 60: asset is paused
    //bit 61: borrowing in isolation mode is enabled
    //bit 62: siloed borrowing enabled
    //bit 63: flashloaning enabled
    //bit 64-79: reserve factor    储备系数，即借款利息中上缴AAVE风险准备金的比例
    //bit 80-115 borrow cap in whole tokens, borrowCap == 0 => no cap     代币贷出上限
    //bit 116-151 supply cap in whole tokens, supplyCap == 0 => no cap
    //bit 152-167 liquidation protocol fee
    //bit 168-175 eMode category
    //bit 176-211 unbacked mint cap in whole tokens, unbackedMintCap == 0 => minting disabled   无存入直接铸造的代币数量上限(此变量用于跨链)
    //bit 212-251 debt ceiling for isolation mode with (ReserveConfiguration::DEBT_CEILING_DECIMALS) decimals   隔离模式中此抵押品的贷出资产上限
    //bit 252-255 unused

    uint256 data;  // 特么的可真牛  靠掩码和二进制运算去修改 
  }

  struct UserConfigurationMap {
    /**
     * @dev Bitmap of the users collaterals and borrows. It is divided in pairs of bits, one pair per asset.
     * The first bit indicates if an asset is used as collateral by the user, the second whether an
     * asset is borrowed by the user.
     */
    uint256 data;
  }

  // eMode  
  struct EModeCategory {
    // each eMode category has a custom ltv and liquidation threshold
    uint16 ltv;
    uint16 liquidationThreshold;
    uint16 liquidationBonus;
    // each eMode category may or may not have a custom oracle to override the individual assets price oracles
    address priceSource;
    string label;
  }

  // 利率模式  稳定的和浮动的
  enum InterestRateMode {NONE, STABLE, VARIABLE}

  // 缓存 
  struct ReserveCache {
    uint256 currScaledVariableDebt; // 当前经过贴现的可变利率贷款总额 
    uint256 nextScaledVariableDebt; 
    uint256 currPrincipalStableDebt;
    uint256 currAvgStableBorrowRate;
    uint256 currTotalStableDebt;
    uint256 nextAvgStableBorrowRate;
    uint256 nextTotalStableDebt;
    uint256 currLiquidityIndex;
    uint256 nextLiquidityIndex;
    uint256 currVariableBorrowIndex;
    uint256 nextVariableBorrowIndex;
    uint256 currLiquidityRate;
    uint256 currVariableBorrowRate;
    uint256 reserveFactor;
    ReserveConfigurationMap reserveConfiguration;
    address aTokenAddress;
    address stableDebtTokenAddress;
    address variableDebtTokenAddress;
    uint40 reserveLastUpdateTimestamp;
    uint40 stableDebtLastUpdateTimestamp;
  }

  // 执行清算的参数 
  struct ExecuteLiquidationCallParams {
    uint256 reservesCount;
    uint256 debtToCover;
    address collateralAsset;
    address debtAsset;
    address user;
    bool receiveAToken;
    address priceOracle;
    uint8 userEModeCategory;
    address priceOracleSentinel;
  }

  // 执行供应的参数  应该就是存款  把token放到池子里 
  struct ExecuteSupplyParams {
    address asset;
    uint256 amount;
    address onBehalfOf;
    uint16 referralCode;
  }

  // 执行借钱的参数  
  struct ExecuteBorrowParams {
    address asset;
    address user;
    address onBehalfOf;
    uint256 amount;
    InterestRateMode interestRateMode;
    uint16 referralCode;
    bool releaseUnderlying;
    uint256 maxStableRateBorrowSizePercent;
    uint256 reservesCount;
    address oracle;
    uint8 userEModeCategory;
    address priceOracleSentinel;
  }

  // 还钱的参数
  struct ExecuteRepayParams {
    address asset;
    uint256 amount;
    InterestRateMode interestRateMode;
    address onBehalfOf;
    bool useATokens;
  }

  // 取款的参数
  struct ExecuteWithdrawParams {
    address asset;
    uint256 amount;
    address to;
    uint256 reservesCount;
    address oracle;
    uint8 userEModeCategory;
  }

  // 设置用户EMode的模式
  struct ExecuteSetUserEModeParams {
    uint256 reservesCount;
    address oracle;
    uint8 categoryId;
  }

  // 转账参数
  struct FinalizeTransferParams {
    address asset;
    address from;
    address to;
    uint256 amount;
    uint256 balanceFromBefore;
    uint256 balanceToBefore;
    uint256 reservesCount;
    address oracle;
    uint8 fromEModeCategory;
  }

  // 闪电贷参数 
  struct FlashloanParams {
    address receiverAddress;
    address[] assets;
    uint256[] amounts;
    uint256[] interestRateModes;
    address onBehalfOf;
    bytes params;
    uint16 referralCode;
    uint256 flashLoanPremiumToProtocol;
    uint256 flashLoanPremiumTotal;
    uint256 maxStableRateBorrowSizePercent;
    uint256 reservesCount;
    address addressesProvider;
    uint8 userEModeCategory;
    bool isAuthorizedFlashBorrower;
  }

  // 简单闪电贷参数
  struct FlashloanSimpleParams {
    address receiverAddress;
    address asset;
    uint256 amount;
    bytes params;
    uint16 referralCode;
    uint256 flashLoanPremiumToProtocol;
    uint256 flashLoanPremiumTotal;
  }

  // 闪电贷还钱参数
  struct FlashLoanRepaymentParams {
    uint256 amount;
    uint256 totalPremium;
    uint256 flashLoanPremiumToProtocol;
    address asset;
    address receiverAddress;
    uint16 referralCode;
  }

  // 计算用户账号数据参数
  struct CalculateUserAccountDataParams {
    UserConfigurationMap userConfig;
    uint256 reservesCount;
    address user;
    address oracle;
    uint8 userEModeCategory;
  }

  // 校验借钱参数
  struct ValidateBorrowParams {
    ReserveCache reserveCache;
    UserConfigurationMap userConfig;
    address asset;
    address userAddress;
    uint256 amount;
    InterestRateMode interestRateMode;
    uint256 maxStableLoanPercent;
    uint256 reservesCount;
    address oracle;
    uint8 userEModeCategory;
    address priceOracleSentinel;
    bool isolationModeActive;
    address isolationModeCollateralAddress;
    uint256 isolationModeDebtCeiling;
  }

  // 校验清算参数
  struct ValidateLiquidationCallParams {
    ReserveCache debtReserveCache;
    uint256 totalDebt;
    uint256 healthFactor;
    address priceOracleSentinel;
  }

  // 计算利率参数
  struct CalculateInterestRatesParams {
    uint256 unbacked;
    uint256 liquidityAdded;
    uint256 liquidityTaken;
    uint256 totalStableDebt;
    uint256 totalVariableDebt;
    uint256 averageStableBorrowRate;
    uint256 reserveFactor;
    address reserve;
    address aToken;
  }

  // 初始化池子参数
  struct InitReserveParams {
    address asset;
    address aTokenAddress;
    address stableDebtAddress;
    address variableDebtAddress;
    address interestRateStrategyAddress;
    uint16 reservesCount;
    uint16 maxNumberReserves;
  }
}
