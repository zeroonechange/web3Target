import 'package:web3dart/web3dart.dart';
import 'package:mywallet/contracts/factories/SocialRecoveryModule.g.dart';

class ISocialModule {
  static SocialRecoveryModule interface({required EthereumAddress address, required Web3Client client}) => SocialRecoveryModule(address: address, client: client);
}