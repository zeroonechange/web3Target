import 'dart:math';

import 'package:dio/dio.dart';
import 'package:mywallet/wallet/account_utils.dart';
import 'package:mywallet/wallet/encrypted_signer.dart';
import 'package:mywallet/wallet/network.dart';
import 'package:mywallet/wallet/top_tokens.dart';
import 'package:web3dart/web3dart.dart';

class BalanceService{
  static String abi = '[{"inputs":[{"internalType":"address","name":"user","type":"address"},{"internalType":"address[]","name":"tokens","type":"address[]"}],"name":"tokenBalances","outputs":[{"internalType":"uint256[]","name":"balances","type":"uint256[]"}],"stateMutability":"view","type":"function"}]';
  static String uniTokenAbi = '[{"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"address","name":"minter_","type":"address"},{"internalType":"uint256","name":"mintingAllowedAfter_","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"owner","type":"address"},{"indexed":true,"internalType":"address","name":"spender","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Approval","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"delegator","type":"address"},{"indexed":true,"internalType":"address","name":"fromDelegate","type":"address"},{"indexed":true,"internalType":"address","name":"toDelegate","type":"address"}],"name":"DelegateChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"delegate","type":"address"},{"indexed":false,"internalType":"uint256","name":"previousBalance","type":"uint256"},{"indexed":false,"internalType":"uint256","name":"newBalance","type":"uint256"}],"name":"DelegateVotesChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"minter","type":"address"},{"indexed":false,"internalType":"address","name":"newMinter","type":"address"}],"name":"MinterChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"from","type":"address"},{"indexed":true,"internalType":"address","name":"to","type":"address"},{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Transfer","type":"event"},{"constant":true,"inputs":[],"name":"DELEGATION_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"DOMAIN_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"PERMIT_TYPEHASH","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"address","name":"spender","type":"address"}],"name":"allowance","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"rawAmount","type":"uint256"}],"name":"approve","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"balanceOf","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"},{"internalType":"uint32","name":"","type":"uint32"}],"name":"checkpoints","outputs":[{"internalType":"uint32","name":"fromBlock","type":"uint32"},{"internalType":"uint96","name":"votes","type":"uint96"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"delegatee","type":"address"}],"name":"delegate","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"delegatee","type":"address"},{"internalType":"uint256","name":"nonce","type":"uint256"},{"internalType":"uint256","name":"expiry","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"delegateBySig","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"delegates","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getCurrentVotes","outputs":[{"internalType":"uint96","name":"","type":"uint96"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"account","type":"address"},{"internalType":"uint256","name":"blockNumber","type":"uint256"}],"name":"getPriorVotes","outputs":[{"internalType":"uint96","name":"","type":"uint96"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"minimumTimeBetweenMints","outputs":[{"internalType":"uint32","name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"dst","type":"address"},{"internalType":"uint256","name":"rawAmount","type":"uint256"}],"name":"mint","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"mintCap","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"minter","outputs":[{"internalType":"address","name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"mintingAllowedAfter","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"name","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"nonces","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"numCheckpoints","outputs":[{"internalType":"uint32","name":"","type":"uint32"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"owner","type":"address"},{"internalType":"address","name":"spender","type":"address"},{"internalType":"uint256","name":"rawAmount","type":"uint256"},{"internalType":"uint256","name":"deadline","type":"uint256"},{"internalType":"uint8","name":"v","type":"uint8"},{"internalType":"bytes32","name":"r","type":"bytes32"},{"internalType":"bytes32","name":"s","type":"bytes32"}],"name":"permit","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"minter_","type":"address"}],"name":"setMinter","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"internalType":"string","name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"dst","type":"address"},{"internalType":"uint256","name":"rawAmount","type":"uint256"}],"name":"transfer","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"internalType":"address","name":"src","type":"address"},{"internalType":"address","name":"dst","type":"address"},{"internalType":"uint256","name":"rawAmount","type":"uint256"}],"name":"transferFrom","outputs":[{"internalType":"bool","name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"}]';

  static Future<String> getTotalBalance(String publicAddress) async{
    NetworkUtil.initialize();
    Network network = NetworkUtil.instances[0];

    print('network : ${network.name}');
    // https://goerli.etherscan.io/address/0x20fa9db25828191606c863225d0bc812c1c8f614
    var balancesContract = DeployedContract(ContractAbi.fromJson(abi, "BalanceUtil"), network.balanceUtilAddress);
    // https://goerli.etherscan.io/address/0x1f9840a85d5af5bf1d1762f925bdaddc4201f984#code
    var uniContract = DeployedContract(ContractAbi.fromJson(uniTokenAbi, "Uni"), EthereumAddress.fromHex("0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984"));

    List<dynamic> _balancesResult = [];
    List<dynamic> _uniBalancesResult = [];

    List<EthereumAddress> tokenAddresses = TopTokens.ethTopTokens.map((e) => EthereumAddress.fromHex(e[1])).toList();
    String tokenNames = TopTokens.ethTopTokens.map((e) => e[0]).toList().join(",");

    late Response response;
    await Future.wait([
      //  去调用自己创建的合约 查询 token数量
      network.client.call(
            contract: balancesContract,
            function: balancesContract.function("tokenBalances"),
            params: [EthereumAddress.fromHex(publicAddress), tokenAddresses]
      ).then((value) => _balancesResult = value),

      // 调用 uniswap 的token余额
      network.client.call(
          contract: uniContract,
          function: uniContract.function("balanceOf"),
          params: [EthereumAddress.fromHex("0x5E46077F3DD9462D9F559FF38F76d54F762e79fF")]
          ).then((value) => _uniBalancesResult = value),
      //获取eth数量  https://www.coingecko.com/en/api/documentation
      // 通过 API 查询 实时价格   https://min-api.cryptocompare.com/documentation?key=Price&cat=multipleSymbolsPriceEndpoint
      Dio().get("https://min-api.cryptocompare.com/data/pricemulti?fsyms=$tokenNames&tsyms=USD").then((value) => response = value)
    ]);

    print('all balance: ${_balancesResult.toString()}');
    print('uni balance: ${_uniBalancesResult.toString()}');

    print('response: ${response.data.toString()}');
    response.data["ETH"];
    // 累加usd 的金额  得到最终价格   -- 因为我这号没钱  所以返回一个随机数了
    var re = Random.secure().nextInt(1000);
    return "\$$re";
  }


  static Future<String> sendETH(String password, EncryptedSigner account) async{
    NetworkUtil.initialize();
    Network network = NetworkUtil.instances[0];

    var response;
    var gasFee = 0;
    // https://api-goerli.etherscan.io/
    // https://api.etherscan.io/
    await Dio().get("https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=AX5NHJ2AMZGUWMM5AXQK43V318QW4YVFP9").then((value) =>
      response = value
    );

    print(response);
    gasFee = int.parse(response.data["result"]["SafeGasPrice"] as String);
    print('gasFee: $gasFee');

    // Unhandled Exception: RPCError: got code -32000 with msg "err:
    // max fee per gas less than block base fee: address 0x6f7F3E0Ff3bd4e6eCC50d2Ee60c38D28070116bD, maxFeePerGas: 61 baseFee: 3157421 (supplied gas 275010499)".
    var transaction = Transaction(
        to: EthereumAddress.fromHex("0x5E46077F3DD9462D9F559FF38F76d54F762e79fF"),  // account 1
        gasPrice: EtherAmount.inWei(BigInt.one),
        maxGas: 100000,
        value: EtherAmount.inWei(BigInt.from(100)),
    );

    var gasEstimate = await network.client.estimateGas(to: transaction.to, value: transaction.value, data: transaction.data);
    print('gasEstimate=$gasEstimate');

    var newTransaction  = Transaction(
        to: transaction.to,  // account 1
        gasPrice: transaction.gasPrice,
        maxGas: gasEstimate.toInt(),
        value: transaction.value,
    );

    // String pk = await AccountUtils.getPrivateKey(password, account);
    String pk = "0x761827f85f6b5cf3eaf3c5a8a930309438eec7950ebe2994302492a84b2124ed";  // account 2
    var credientials = EthPrivateKey.fromHex(pk);  // 私钥
    var re = await network.client.sendTransaction(
      credientials,
      newTransaction,
      fetchChainIdFromNetworkId: true,  // 加这俩个东西
      chainId: null,
    );
    print('sendETH result: $re');
    // 第一次  gas price: 1  maxGas: 100000    0x1e0b789ab7865608c2b9ed174748b0c912593c8e2f11395955e7334c8b5636cf
    // 第二次  gas price 拿的是以太坊的  gas 预估是 goerli 测试网的  试一试看看    0x6da1bdccaeb1170def2238c572df0971a28e93d389b1b87f3e8aaa2a47aaa5cd
    return re ?? "";
  }
}

