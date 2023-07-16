// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/NFT.sol";

contract MyScript is Script {
    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);  // 指示它使用该密钥来签署交易  广播事务日志将存储在 broadcast 目录中
        NFT nft = new NFT("FUCKME2", "FM2", "www.fuck.me/");
        vm.stopBroadcast();
    }
}
