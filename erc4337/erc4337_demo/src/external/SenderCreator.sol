// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

/**
 * helper contract for EntryPoint, to call userOp.initCode from a "neutral" address,
 * which is explicitly not the entryPoint itself.
 * 根据OP里面的 initCode 创建并返回地址 
 */ 
contract SenderCreator {

    /**
     * call the "initCode" factory to create and return the sender account address
     * @param initCode the initCode value from a UserOp. contains 20 bytes of factory address, followed by calldata
     * @return sender the returned address of the created account, or zero address on failure.
     */
    function createSender(bytes calldata initCode) external returns (address sender) {
        address initAddress = address(bytes20(initCode[0 : 20])); // walletFactory 的地址 
        bytes memory initCallData = initCode[20 :];  //  walletFactory.deployWallet 
        bool success;
        /* solhint-disable no-inline-assembly */
        assembly {
            // 通过汇编去调用外部合约 执行   walletFactory.deployWallet 方法   返回钱包地址
            success := call(gas(), initAddress, 0, add(initCallData, 0x20), mload(initCallData), 0, 32)
            sender := mload(0)
        }
        if (!success) {
            sender = address(0);
        }
    }
}
