// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.10;

import {AccessControl} from '../../dependencies/openzeppelin/contracts/AccessControl.sol';
import {IPoolAddressesProvider} from '../../interfaces/IPoolAddressesProvider.sol';
import {IACLManager} from '../../interfaces/IACLManager.sol';
import {Errors} from '../libraries/helpers/Errors.sol';

/**
 * @title ACLManager
 * @author Aave
 * @notice Access Control List Manager. Main registry of system roles and permissions.
 */
// 权限管理  好几个主要的管理者权限   权限由俩个等级的role组成  一个是admin role 另一个是普通的role
// giao 其实这个类  非常简单  核心是权限role的设计  还有其父类 openzeppelin AccessControl.sol的设计  非常清晰
contract ACLManager is AccessControl, IACLManager {
  // 下面都是各个权限的名字  一般由keccak256生成
  bytes32 public constant override POOL_ADMIN_ROLE = keccak256('POOL_ADMIN');
  bytes32 public constant override EMERGENCY_ADMIN_ROLE = keccak256('EMERGENCY_ADMIN');
  bytes32 public constant override RISK_ADMIN_ROLE = keccak256('RISK_ADMIN');
  bytes32 public constant override FLASH_BORROWER_ROLE = keccak256('FLASH_BORROWER');
  bytes32 public constant override BRIDGE_ROLE = keccak256('BRIDGE');
  bytes32 public constant override ASSET_LISTING_ADMIN_ROLE = keccak256('ASSET_LISTING_ADMIN');

  IPoolAddressesProvider public immutable ADDRESSES_PROVIDER; // 做啥的 暂时不明白  确定 admin 地址

  /**
   * @dev Constructor
   * @dev The ACL admin should be initialized at the addressesProvider beforehand
   * @param provider The address of the PoolAddressesProvider
   */
  constructor(IPoolAddressesProvider provider) {
    ADDRESSES_PROVIDER = provider;
    address aclAdmin = provider.getACLAdmin(); //确定协议 最高 admin 地址
    require(aclAdmin != address(0), Errors.ACL_ADMIN_CANNOT_BE_ZERO); // 不能为 0 地址
    _setupRole(DEFAULT_ADMIN_ROLE, aclAdmin); // 给 admin 上最高权限  由此衍生其他权限  那整个权限结构应该由三个等级组成了
  }

  /// @inheritdoc IACLManager
  // 给某个role设置admin 只能由最高权限来做  由此衍生其他权限
  function setRoleAdmin(
    bytes32 role,
    bytes32 adminRole
  ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
    _setRoleAdmin(role, adminRole);
  }

  /// @inheritdoc IACLManager
  function addPoolAdmin(address admin) external override {
    grantRole(POOL_ADMIN_ROLE, admin); // 限制加在了其父类
  }

  /// @inheritdoc IACLManager
  function removePoolAdmin(address admin) external override {
    revokeRole(POOL_ADMIN_ROLE, admin); // 限制加在了其父类
  }

  /// @inheritdoc IACLManager
  function isPoolAdmin(address admin) external view override returns (bool) {
    return hasRole(POOL_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function addEmergencyAdmin(address admin) external override {
    grantRole(EMERGENCY_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removeEmergencyAdmin(address admin) external override {
    revokeRole(EMERGENCY_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isEmergencyAdmin(address admin) external view override returns (bool) {
    return hasRole(EMERGENCY_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function addRiskAdmin(address admin) external override {
    grantRole(RISK_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removeRiskAdmin(address admin) external override {
    revokeRole(RISK_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isRiskAdmin(address admin) external view override returns (bool) {
    return hasRole(RISK_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function addFlashBorrower(address borrower) external override {
    grantRole(FLASH_BORROWER_ROLE, borrower);
  }

  /// @inheritdoc IACLManager
  function removeFlashBorrower(address borrower) external override {
    revokeRole(FLASH_BORROWER_ROLE, borrower);
  }

  /// @inheritdoc IACLManager
  function isFlashBorrower(address borrower) external view override returns (bool) {
    return hasRole(FLASH_BORROWER_ROLE, borrower);
  }

  /// @inheritdoc IACLManager
  function addBridge(address bridge) external override {
    grantRole(BRIDGE_ROLE, bridge);
  }

  /// @inheritdoc IACLManager
  function removeBridge(address bridge) external override {
    revokeRole(BRIDGE_ROLE, bridge);
  }

  /// @inheritdoc IACLManager
  function isBridge(address bridge) external view override returns (bool) {
    return hasRole(BRIDGE_ROLE, bridge);
  }

  /// @inheritdoc IACLManager
  function addAssetListingAdmin(address admin) external override {
    grantRole(ASSET_LISTING_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function removeAssetListingAdmin(address admin) external override {
    revokeRole(ASSET_LISTING_ADMIN_ROLE, admin);
  }

  /// @inheritdoc IACLManager
  function isAssetListingAdmin(address admin) external view override returns (bool) {
    return hasRole(ASSET_LISTING_ADMIN_ROLE, admin);
  }
}

/**
ACLManager.sol  权限管理 

ERC165  -supportsInterface  

OpenZeppelin  AccessControl.sol  权限管理
	DEFAULT_ADMIN_ROLE 
	bytes32=>{ (address=>bool), adminRole } 
		表结构 第一个bytes32 就是权限的名称 一般由keccak256("MY_ROLE")生成 
		adminRole是一个address 表示这个权限的admin 
		(address=>bool) 是否有这个权限  
	核心: 权限role由俩部分组成  一个是普通的role  一个是上层的管理普通role的admin role
	这样一来 如果有admin role 只需更新一个表就可以达到目标了  具体modifier和方法:
		modifier onlyRole(bytes32 role)
		hasRole(bytes32 role, address account)
		_checkRole(bytes32 role, address account)
		getRoleAdmin(bytes32 role)    获取当前role的admin表 
		grantRole(bytes32 role,address account)
		revokeRole(bytes32 role,address account)
		renounceRole(bytes32 role, address account)
		_setupRole(bytes32 role, address account)
		_setRoleAdmin(bytes32 role, bytes32 adminRole)
		_grantRole(bytes32 role, address account)
		_revokeRole(bytes32 role, address account)

IACLManager.sol 
	POOL_ADMIN_ROLE
	EMERGENCY_ADMIN_ROLE
	RISK_ADMIN_ROLE
	FLASH_BORROWER_ROLE
	BRIDGE_ROLE
	ASSET_LISTING_ADMIN_ROLE
	反正是一堆 get 和 set  admin role的方法  无所吊谓 

 */
