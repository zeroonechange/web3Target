import 'dart:convert';
import 'dart:math';

import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/scrypt.dart';
import 'package:steel_crypt/steel_crypt.dart';
import 'package:mywallet/contracts/gnosis_safe_proxy_facotry.dart';
import 'package:mywallet/wallet/encode_function_data.dart';
import 'package:mywallet/wallet/account.dart';
import 'package:mywallet/wallet/encrypted_signer.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/src/utils/length_tracking_byte_sink.dart';
import 'package:web3dart/web3dart.dart';

class AccountHelpers {

  // 输入  {密码=password + 盐=salt}   加密   => string 字符串
  static Future<String> _generatePasswordKey(Map args) async{
    final Scrypt scrypt = Scrypt();
    scrypt.init(ScryptParameters(16384, 8, 1, 32, base64Decode(args["salt"])));
    var passwordBytes = utf8.encode(args["password"]) as Uint8List;
    var keyBytes = scrypt.process(passwordBytes);
    return base64.encode(keyBytes);
  }

  // 启用一个单独的isolates线程  去加密密码
  static Future<String> _generatePasswordKeyThread(String password, String salt) async{
    var key = await compute(_generatePasswordKey, {'password': password, 'salt': salt});
    return key;
  }

  // 重新加密签名    先得到私钥   再通过 新密码和盐 得到密文1  再通过 AES 算法  用私钥 盐 和 密文1  得到一个新的 密文2
  // 钱包存储密码 就是 先通过密码+salt 得到一个密文1   密文1 再通过 私钥和盐 得到密文2
  static Future<bool> reEncryptSigner(EncryptedSigner encryptedSigner, String newPassword, {EthPrivateKey? credentials, String? password}) async{
    Uint8List privateKeyBytes;
    String base64Salt = base64Encode(hexToBytes(encryptedSigner.salt)); // 得到盐 转成 base64    string->bytes->base64 string
    if (credentials != null){
      privateKeyBytes = credentials.privateKey;
    }else{
      if (password == null) return false;
      var _credentials = await decryptSigner(encryptedSigner, password); //  得到 私玥
      if (_credentials == null) return false;
      privateKeyBytes = (_credentials as EthPrivateKey).privateKey;
    }
    String newPasswordKey = await _generatePasswordKeyThread(newPassword, base64Salt); // 新密码和盐  得到一个密文1
    AesCrypt aesCrypt = AesCrypt(padding: PaddingAES.pkcs7, key: newPasswordKey);  // 密文1 通过 AES 再解密  得到  密文2
    encryptedSigner.encryptedPrivateKey = aesCrypt.cbc.encrypt(     // AES 采用 cbc 加密  inp=私钥   iv=盐
        inp: bytesToHex(privateKeyBytes, include0x: true),
        iv: base64Salt
    ).toString();
    return true;
  }

  // 输入 encryptedSigner{salt, encryptedPrivateKey, publicAddress}  和 密码  == 得到私钥
  static Future<Credentials?> decryptSigner(EncryptedSigner encryptedSigner, String password) async {
    try {
      String base64Salt = base64Encode(hexToBytes(encryptedSigner.salt));  // 将 salt 转成  base64 string
      String passwordKey = await _generatePasswordKeyThread(password, base64Salt);  // 根据 salt 和 password  加密得到一个密文1
      AesCrypt aesCrypt = AesCrypt(padding: PaddingAES.pkcs7, key: passwordKey);    // 密文1再AES加密 得到一个密文2
      String privateKey = aesCrypt.cbc.decrypt(enc: encryptedSigner.encryptedPrivateKey, iv: base64Salt);  // 密文2 cbc 解密  输入 encryptedPrivateKey 和 salt   得到 privateKey
      var privateKeyBytes = hexToBytes(privateKey);  // 将 privateKey 转成 bytes
      if (privateKeyBytes.length > 32){
        int trim = privateKeyBytes.length - 32;
        privateKeyBytes = privateKeyBytes.sublist(trim);  // 拿到后32位的字节
      }
      return EthPrivateKey(privateKeyBytes);   // 返回
    } catch (e) {
      return null;
    }
  }

  // 恢复账号   chainId 名字 地址  盐  签名者ID集合
  static Future<Account> createRecovery({
    required int chainId,
    required String name,
    required EthereumAddress address,
    required String salt,
    required List<String> signersIds,
  }) async{
    return Account(
      chainId: chainId,
      name: name,
      address: address,
      salt: salt,
      signersIds: signersIds,
    );
  }

  // 创建加密签名   盐+密码    返回一个钱包账号  公钥和私钥
  static Future<EncryptedSigner> createEncryptedSigner({required String salt, required String password}) async{
    String base64Salt = base64Encode(hexToBytes(salt));  // 转成base64 string
    String passwordKey = await _generatePasswordKeyThread(password, base64Salt); // 通过盐和password 得到 密文1
    AesCrypt aesCrypt = AesCrypt(padding: PaddingAES.pkcs7, key: passwordKey);   // 设置 AES 算法 key=密文1
    var secureRandom = Random.secure();       // 随机数?
    EthPrivateKey signer = EthPrivateKey.createRandom(secureRandom); // 根据随机数创建 一个账号  包含私钥和公钥
    return EncryptedSigner(
      salt: salt,
      encryptedPrivateKey: aesCrypt.cbc.encrypt(         // 私钥不能直接存  需要 AES加密  加了盐
        inp: bytesToHex(signer.privateKey, include0x: true),
        iv: base64Salt
      ).toString(),
      publicAddress: signer.address    // 公钥  也就是地址
    );
  }

  // 多签地址
  static Future<Account> createAccount({
    required int chainId,
    required String name,
    required String salt,
    required List<String> signersIds,
    required List<EthereumAddress> signers,
    required EthereumAddress factory,
    required EthereumAddress singleton,
    required EthereumAddress entrypoint,
    required EthereumAddress fallbackHandler,
    required Web3Client client,
  }) async{
    return Account(
      chainId: chainId,
      name: name,
      address: EthereumAddress.fromHex(
        await getAccountAddress(
          client,
          factory,
          singleton,
          entrypoint,
          fallbackHandler,
          signers,
          BigInt.parse(salt, radix: 16),
        )
      ),
      salt: salt,
      signersIds: signersIds,
      factory: factory,
      singleton: singleton,
      fallback: fallbackHandler,
      entrypoint: entrypoint,
    );
  }

  // 生成多签地址
  static Future<String> getAccountAddress(Web3Client client, EthereumAddress factory, EthereumAddress singleton, EthereumAddress entryPoint, EthereumAddress fallbackHandler, List<EthereumAddress> signers, BigInt saltNonce) async {
    Uint8List initializer = hexToBytes(EncodeFunctionData.setupWithEntrypoint(
        signers,
        BigInt.one,
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
        Uint8List(0),
        fallbackHandler,
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
        BigInt.zero,
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
        entryPoint
    ));
    // proxyCreationCode
    Uint8List proxyBytecode = await IGnosisSafeProxyFactory.interface(address: factory, client: client).proxyCreationCode();
    // 数据
    Uint8List salt = keccak256(AbiUtil.solidityPack(["bytes32", "uint256"], [keccak256(initializer), saltNonce]));
    // 部署数据?
    Uint8List deploymentData = AbiUtil.solidityPack(["bytes", "uint256"], [proxyBytecode, BigInt.parse(singleton.hexNo0x, radix: 16)]);
    // 得到  create2 创建合约的地址
    return _AccountHelperUtils.getCreate2Address(
      factory,
      salt,
      keccak256(deploymentData),
    );
  }

  static Uint8List getInitCode(EthereumAddress singleton, EthereumAddress entryPoint, EthereumAddress fallbackHandler, List<EthereumAddress> signers, BigInt saltNonce){
    Uint8List initializer = hexToBytes(EncodeFunctionData.setupWithEntrypoint(
        signers,
        BigInt.one,
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
        Uint8List(0),
        fallbackHandler,
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
        BigInt.zero,
        EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
        entryPoint
    ));
    return hexToBytes(EncodeFunctionData.createProxyWithNonce(singleton, initializer, saltNonce));
  }

}


class _AccountHelperUtils {

  /*
   *得到 CREATE2 合约地址
   * 合约创建者的地址（address)
   * 作为参数的混淆值（salt）
   * 合约创建代码 (init_code)
   *  keccak256(0xff ++ address ++ salt ++ keccak256(init_code))[12:]
   */
  static getCreate2Address(EthereumAddress from, Uint8List salt, Uint8List initCodeHash){
    Uint8List ff = hexToBytes("0xff");
    String address = _getChecksumAddress(from.hex);
    LengthTrackingByteSink sink = LengthTrackingByteSink();
    //
    sink.add(ff);
    sink.add(hexToBytes(address));
    sink.add(salt);
    sink.add(initCodeHash);
    var sinkBytes = sink.asBytes();
    sink.close();
    // 获取 地址   对上面的字节进行 kecca256 就得到了地址?
    return _getChecksumAddress(bytesToHex(keccak256(sinkBytes), include0x: true).substring(12*2)); // equivalent to hexDataSlice in ethers (12 bytes * 2 (bytes length in hex))
  }

  static String _getChecksumAddress(String address){
    address = address.toLowerCase();
    var chars = address.substring(2).split("");
    var expanded = Uint8List(40);
    for (int i = 0; i < 40; i++) {
      expanded[i] = chars[i].codeUnitAt(0);
    }
    var hashed = keccak256(expanded);
    for (int i = 0; i < 40; i += 2) {
      if ((hashed[i >> 1] >> 4) >= 8) {
        chars[i] = chars[i].toUpperCase();
      }
      if ((hashed[i >> 1] & 0x0f) >= 8) {
        chars[i + 1] = chars[i + 1].toUpperCase();
      }
    }
    return "0x" + chars.join("");
  }
}