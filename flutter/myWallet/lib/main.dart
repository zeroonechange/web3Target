import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:mywallet/wallet/account_utils.dart';
import 'package:mywallet/widget/deposite_sheet.dart';
import 'package:web3dart/crypto.dart';
import 'package:mywallet/wallet/encrypted_signer.dart';
import 'package:mywallet/wallet/balance_service.dart';

import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:get/get.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my wallet',
      builder: BotToastInit(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'my wallet demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var PWD = "12345678";
  late EncryptedSigner _account;
  late String _pk;
  String balance = "\$0.00";

  void _createAccount() async{
    print('------_createAccount--------');
    var signerSalt = bytesToHex(AccountUtils.randomBytes(16, secure: true));
    _account = await AccountUtils.createAccount(salt: signerSalt, password: PWD);
    print("address: ${_account.publicAddress}  encrypted privateKey: ${_account.encryptedPrivateKey}  salt: ${_account.salt}");
  }

  void _exportAccount() async{
    print('------_exportAccount--------');
    _pk = await AccountUtils.getPrivateKey(PWD, _account);
  }

  void _importAccount() async{
    print('------_importAccount--------');
    String pk = await AccountUtils.importAccountByPK(_pk) ?? "" ;
  }

  void _getTotalBalance() async{
    print('------_getTotalBalance--------');
    balance  = await BalanceService.getTotalBalance(_account.publicAddress.hex);
    setState(() {
      balance;
    });
  }

  void _receive() async{
    showBarModalBottomSheet(
        context: context,
        backgroundColor: Get.theme.canvasColor,
        builder: (context) => SingleChildScrollView(
          controller: ModalScrollController.of(context),
          child: DepositSheet(account: _account),
    ));
  }


  void _test() async{

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () {
                  _createAccount();
                },
                child: const Text('create account')
            ),
            ElevatedButton(
                onPressed: () {
                  _exportAccount();
                },
                child: const Text('export account')
            ),
            ElevatedButton(
                onPressed: () {
                  _importAccount();
                },
                child: const Text('import account')
            ),
            Text(balance, style: const TextStyle(fontSize: 30),),
            ElevatedButton(
                onPressed: () {
                  _getTotalBalance();
                },
                child: const Text('get account balance')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {
                        _receive();
                    },
                    child: const Text('Receive')
                ),
                ElevatedButton(
                    onPressed: () {

                    },
                    child: const Text('Send')
                ),
                ElevatedButton(
                    onPressed: () {

                    },
                    child: const Text('Swap')
                ),
              ],
            ),
            ElevatedButton(
                onPressed: () {

                },
                child: const Text('fetch Recent History')
            ),

          ],
        ),
      ),
    );
  }
}
