import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

class NetworkUtil{
  static List<Network> instances = [];

  static initialize() {
    if(instances.isEmpty){
      instances.add(Network(
          name: 'Goerli test network',
          nativeCurrency: 'GoerliETH',
          chainId: BigInt.from(5),
          explorerUrl: 'https://goerli.etherscan.io',
          balanceUtilAddress: EthereumAddress.fromHex("0x2b591e99afe9f32eaa6214f7b7629768c40eeb39"),
          client:Web3Client('https://eth-goerli.g.alchemy.com/v2/WCyU-o-7hTqY5YekFvNMoWhJhlFnpijc', Client())
          // client:Web3Client('https://goerli.infura.io/v3/', Client())
      ));
    }
  }
}

class Network{
  String name;
  String nativeCurrency;
  BigInt chainId;
  String explorerUrl;
  EthereumAddress balanceUtilAddress;
  Web3Client client;

  Network({
    required this.name,
    required this.nativeCurrency,
    required this.chainId,
    required this.explorerUrl,
    required this.balanceUtilAddress,
    required this.client
  });
}