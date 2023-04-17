
import 'dart:convert';
import 'dart:math';

import 'package:mywallet/wallet/encrypted_signer.dart';
// import 'package:eth_sig_util/util/utils.dart';
// import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';

class AccountUtils{

  static Future<String> _generatePasswordKey(Map args) async{
    final Scrypt scrypt = Scrypt();
    // N：一般工作因数，迭代次数   r：用于底层哈希的块大小；微调相对内存成本   p：并行化因子；微调相对 cpu 成本
    scrypt.init(ScryptParameters(16384, 8, 1, 32, base64Decode(args["salt"])));  // 32长度
    var passwordBytes = utf8.encode(args["password"]) as Uint8List;
    var keyBytes = scrypt.process(passwordBytes);
    return base64.encode(keyBytes);
  }

  static Future<String> _generatePasswordKeyThread(String password, String salt) async{
    var key = await compute(_generatePasswordKey, {'password': password, 'salt': salt});
    return key;
  }

  // 输入盐 和 密码  通过密码和盐加密得到密文1  然后密文1 构建AES对称加密 将私钥加密
  static Future<EncryptedSigner> createAccount({required String salt, required String password}) async{
    String base64Salt = base64Encode(hexToBytes(salt));
    String passwordKey = await _generatePasswordKeyThread(password, salt);
    AesCrypt aesCrypt = AesCrypt(padding: PaddingAES.pkcs7, key: passwordKey);
    var secureRandom = Random.secure();
    EthPrivateKey signer = EthPrivateKey.createRandom(secureRandom);
    return EncryptedSigner(
      salt: salt,
      encryptedPrivateKey: aesCrypt.cbc.encrypt(inp: bytesToHex(signer.privateKey, include0x: true), iv: base64Salt).toString(),
      publicAddress: signer.address
    );
  }


  static Uint8List randomBytes(int length, {bool secure = false}) {
    assert(length > 0);

    final random = secure ? Random.secure() : Random();
    final ret = Uint8List(length);

    for (var i = 0; i < length; i++) {
      ret[i] = random.nextInt(256);
    }
    return ret;
  }
}