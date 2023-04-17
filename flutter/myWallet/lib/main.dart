import 'package:flutter/material.dart';

import 'package:mywallet/wallet/account_utils.dart';
import 'package:web3dart/crypto.dart';
import 'package:mywallet/wallet/encrypted_signer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'my wallet',
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
  int _counter = 0;

  void _createAccount() async{
    var signerSalt = bytesToHex(AccountUtils.randomBytes(16, secure: true));
    EncryptedSigner account = await AccountUtils.createAccount(salt: signerSalt, password: "12345678");
    print("address: ${account.publicAddress}  encrypted privateKey: ${account.encryptedPrivateKey}  salt: ${account.salt}");
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
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

                },
                child: const Text('import account')
            ),
            ElevatedButton(
                onPressed: () {

                },
                child: const Text('export account')
            ),
            const Text("\$0.00", style: TextStyle(fontSize: 30),),
            ElevatedButton(
                onPressed: () {

                },
                child: const Text('get account balance')
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () {

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
