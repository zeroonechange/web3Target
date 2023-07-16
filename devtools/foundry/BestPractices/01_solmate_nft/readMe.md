# NFT 使用


```ssh
初始化项目  
forge init 01_solmate_nft 
cd 01_solmate_nft
安装依赖
forge install transmissions11/solmate Openzeppelin/openzeppelin-contracts
新增 remappings.txt   添加  openzeppelin-contracts/=lib/openzeppelin-contracts/  在第一行
forge remappings
forge build  

export RPC_URL=https://eth-goerli.g.alchemy.com/v2/ybl4NUkj7Q4_odQ1NWNL2ZyYCFcOMSd5
export PRIVATE_KEY=a028b80f557f2ff8edd2b39fe749b21c10669d78381df8c6e2f2afc362efa1ee

forge create NFT --rpc-url=$RPC_URL --private-key=$PRIVATE_KEY --constructor-args "FUCKME" "FM"
	RIVATE_KEY --constructor-args "FUCKME" "FM"
	[⠆] Compiling...
	No files changed, compilation skipped
	Deployer: 0x5E46077F3DD9462D9F559FF38F76d54F762e79fF
	Deployed to: 0x50Bc8E33B923F8E93AE9F1A127054aE5Ed6217BE
	Transaction hash: 0x451365164bb826d534f4dc80b2cf2ea462d593128e983a34fd888555a463726c
cast send --rpc-url=$RPC_URL 0x50Bc8E33B923F8E93AE9F1A127054aE5Ed6217BE "mintTo(address)" 0x5E46077F3DD9462D9F559FF38F76d54F762e79fF --private-key=$PRIVATE_KEY

source .env
forge script script/NFT.s.sol:MyScript --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
```
 