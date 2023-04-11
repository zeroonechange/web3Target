// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import {EntryPoint} from "src/external/EntryPoint.sol";
import {IWallet} from "src/wallet/interface/IWallet.sol";
import {WalletFactory} from "src/wallet/WalletFactory.sol";
import {PayMaster} from "src/wallet/PayMaster.sol";
import {UserOperation} from "src/interface/UserOperation.sol";
import {createSignature} from "test/utils/createSignature.sol";
import {getUserOpHash} from "test/utils/getUserOpHash.sol";
import {MockERC20} from "test/unit/mock/MockERC20.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "openzeppelin-contracts/utils/cryptography/ECDSA.sol";

/*
题目:
    了解ERC 4337后编写简单的Demo，并测算128笔TX，使用EOA方式和使用4337聚合提交的GAS消耗对比
    ERC4337提案：https://eips.ethereum.org/EIPS/eip-4337
    实现要求：
        1.需要实现 EntryPoint 调用 AA 账户合约发出 ERC20 Transfer
        2.需要实现防重放攻击(Nonce值)
        3.需要得出 EOA方式 和使用 4337 聚合提交 在128笔 ERC20 Transfer中整体的GAS消耗对比数据
        4.实现交易TX签名校验（可选）
BG: 用foundry走 fork节点    俩个测试账号:   
    0x5E46077F3DD9462D9F559FF38F76d54F762e79fF   a028b80f557f2ff8edd2b39fe749b21c10669d78381df8c6e2f2afc362efa1ee
    0x6f7F3E0Ff3bd4e6eCC50d2Ee60c38D28070116bD   761827f85f6b5cf3eaf3c5a8a930309438eec7950ebe2994302492a84b2124ed  

思路:  
    因为不牵涉复杂的逻辑  考虑去掉 paymaster 和  聚合器  
    EntryPoint 只需要实现一个 function handleOps(UserOperation[] calldata ops, address payable beneficiary) external; 方法  其他可以放弃 
     1).钱包合约 里面有了一个方法用于转账  withdrawERC20(address , address , uint256 )  直接上 https://abi.hashex.org/  组装 calldata即可  
     2).重放攻击在 SmartWallet.validateUserOp() 方法有所提及  
     3).gas 消耗对比   写俩个函数  跑完后 用 foundry 做对照   使用参考: https://book.getfoundry.sh/forge/gas-snapshots
     4).签名校验原理参考  readMe.md 文件

具体测试细节:
    1.部署 entry Point 
    2.部署 walletFactory   
    3.构建 UserOperation  
                准备好 initCode  创建 SmartWallet 合约   也就是钱包地址
                准备好 callData  用于 ERC20 Transfer 
    3.构建 128个 UserOperation 
    4.调用 entry point 合约去执行 
    5.写一个 用 EOA 方式 进行 128笔 转账  
    6.跑一次得到 gas 消耗对比 
 */
contract DifferTest is Test {
    address account1 = 0x5E46077F3DD9462D9F559FF38F76d54F762e79fF;
    uint256 private_key1 = 0xa028b80f557f2ff8edd2b39fe749b21c10669d78381df8c6e2f2afc362efa1ee;
    address account2 = 0x6f7F3E0Ff3bd4e6eCC50d2Ee60c38D28070116bD;
    uint256 private_key2 = 0x761827f85f6b5cf3eaf3c5a8a930309438eec7950ebe2994302492a84b2124ed;
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    uint256 constant TRANSFER_TIMES = 128;

    EntryPoint entryPoint;
    WalletFactory walletFactory;
    address payable beneficiary = payable(account2); // 用账号1 作为钱包控制人  账号2 作为接收方
    address walletOwner = address(account1);
    uint256 ownerPrivateKey; // account 1

    bytes32 public userOpHash;
    uint256 missingWalletFunds;
    uint256 salt = uint256(0x101);
    UserOperation userOp;

    function setUp() public {
        vm.startPrank(account1); // 作弊码 模拟当前发起人 msg.sender = account 1
        vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 17005409);
        entryPoint = new EntryPoint();
        walletFactory = new WalletFactory();
        // 钱包地址
        address wallet = walletFactory.computeAddress(address(entryPoint), walletOwner, salt);
        deal(account1, 1  ether); // 作弊码 给EOA账号充钱
        deal(address(this), 1  ether);
        deal(address(entryPoint), 1 ether);
        deal(address(wallet), 1  ether);

        deal(address(USDT), account1, 5 * 1e3 ether);
        deal(address(USDT), wallet, 5 * 1e3 ether);

        userOp = UserOperation({
            sender: wallet,
            nonce: 0, // 钱包合约此时还没部署
            initCode: "",
            callData: "",
            callGasLimit: 2_000_000,
            verificationGasLimit: 3_000_000,
            preVerificationGas: 1_000_000,
            maxFeePerGas: 1_000_105_660,
            maxPriorityFeePerGas: 1_000_000_000,
            paymasterAndData: "",
            signature: ""
        });

        // 设置部署钱包合约的代码
        bytes memory initCode = abi.encodePacked(
            abi.encodePacked(address(walletFactory)),
            abi.encodeWithSelector(walletFactory.deployWallet.selector, address(entryPoint), walletOwner, salt)
        );
        userOp.initCode = initCode;

        // function withdrawERC20(address token, address to, uint256 amount)
        bytes memory callData = abi.encodeWithSignature("transferMoney(address,address,uint256)", USDT, account2, 1 ether);
        userOp.callData = callData;

        // 对Op进行签名
        userOpHash = entryPoint.getUserOpHash(userOp);
        bytes memory signature = createSignature(userOpHash, private_key1, vm);
        userOp.signature = signature;
    }

    // 测试签名流程
    function atestSignature() public{
        console2.log("account1=", account1);
        console2.log("private_key1=", private_key1);
        console2.logBytes(userOp.signature);

        bytes32 messageHash = ECDSA.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(messageHash, userOp.signature);
        console2.log("signer=", signer);
        assertEq(account1, signer);
    }

    // 走 AA
    function testBatchTransfer() public {
        UserOperation[] memory userOps = new UserOperation[](TRANSFER_TIMES);
        for(uint i=0; i<TRANSFER_TIMES; i++)
            userOps[i] = userOp;

        // UserOperation[] memory userOps = new UserOperation[](1);
        // userOps[0] = userOp;

        entryPoint.handleOps(userOps, beneficiary);
        
        uint256 ethBalance1 = account1.balance;
        uint256 ethBalance2 = account2.balance;
        uint entryPointEthBalance = address(entryPoint).balance;
        uint walletEthBalance = userOp.sender.balance;

        console2.log("-- testBatchTransfer -- eth balance of account 1: ", ethBalance1);
        console2.log("-- testBatchTransfer -- eth balance of account 2: ", ethBalance2);
        console2.log("-- testBatchTransfer -- eth balance of account entryPoint: ", entryPointEthBalance);
        console2.log("-- testBatchTransfer -- eth balance of account wallet: ", walletEthBalance);

        uint256 balance1 = IERC20(USDT).balanceOf(account1);
        uint256 balance2 = IERC20(USDT).balanceOf(account2);
        uint256 entryPointBalance = IERC20(USDT).balanceOf(address(entryPoint));
        uint256 walletBalance = IERC20(USDT).balanceOf(userOp.sender);
        
        console2.log("-- testBatchTransfer -- balance of account 1: ", balance1);
        console2.log("-- testBatchTransfer -- balance of account 2: ", balance2);
        console2.log("-- testBatchTransfer -- balance of account entryPoint: ", entryPointBalance);
        console2.log("-- testBatchTransfer -- balance of account wallet: ", walletBalance);
        assertEq(balance2, TRANSFER_TIMES * 1e18);
    }

    // 走 EOA
    function testEOATransfer() public {
        console2.log("-- testEOATransfer --before transfer balance of this: ", IERC20(USDT).balanceOf(address(this)));
        for (uint256 i = 0; i < TRANSFER_TIMES; i++) {
            (bool success,) = USDT.call(abi.encodeWithSelector(0xa9059cbb, account2, 1 ether));
        }
        console2.log("-- testEOATransfer --after  transfer balance of this: ", IERC20(USDT).balanceOf(address(this)));
        unchecked {
            uint256 balance = IERC20(USDT).balanceOf(account2);
            console2.log("-- testEOATransfer -- balance of account 2: ", balance);
            assertEq(balance, TRANSFER_TIMES * 1e18);
        }
    }
}
