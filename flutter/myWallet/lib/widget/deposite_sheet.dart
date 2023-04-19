
import 'package:flutter/material.dart';
import 'package:mywallet/wallet/encrypted_signer.dart';
import 'package:get/get.dart';
import 'package:mywallet/wallet/network.dart';
import 'package:mywallet/widget/theme.dart';
import 'package:mywallet/widget/utils.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class DepositSheet extends StatefulWidget {
  final EncryptedSigner account;

  const DepositSheet({Key? key, required this.account}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DepositSheet();
}

class _DepositSheet extends State<DepositSheet>{
  bool _addressCopied = false;
  late Network network;

  @override
  void initState() {
    NetworkUtil.initialize();
    network = NetworkUtil.instances[0];
    super.initState();
  }

  copyAddress() async{
    Utils.copyText(widget.account.publicAddress.hexEip55);
    setState(() {
      _addressCopied = true;
    });
    await Future.delayed(const Duration(seconds: 3));
    if(!mounted) return;
    setState(() {
      _addressCopied = false;
    });
  }

  @override
  Widget build(BuildContext context) {
      return Container(
        decoration: BoxDecoration(color: Get.theme.colorScheme.primary),
        child: Column(
          children: [
            const SizedBox(height: 35,),
            const Text("Fund your ", style: TextStyle(fontSize: 20, color: Colors.black),),
            const SizedBox(height: 5,),
            Text(network.name, style: TextStyle(fontFamily: AppThemes.fonts.gilroyBold, fontSize: 30, color: Colors.black, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic),),
            const SizedBox(height: 5,),
            const Text("Account", style: TextStyle(fontSize: 20, color: Colors.black),),
            const SizedBox(height: 15,),
            QrImage(data: widget.account.publicAddress.hexEip55, size: 250, errorCorrectionLevel: QrErrorCorrectLevel.Q, embeddedImage: const AssetImage("assets/img/logo.png"),),
            const SizedBox(height: 15,),
            Text(Utils.truncate(widget.account.publicAddress.hexEip55, trailingDigits: 6), style: const TextStyle(fontSize: 20, color: Colors.black),),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 65,
                  child: ElevatedButton(
                      onPressed: () {
                        final box = context.findRenderObject() as RenderBox?;
                        Share.share(widget.account.publicAddress.hexEip55, sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size); // 分享功能
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.transparent),
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(side: BorderSide(color: Get.theme.colorScheme.onPrimary, width: 1.5)))
                      ),
                      child: const Icon(PhosphorIcons.shareLight, color: Colors.black, size: 20,)),
                ),
                const SizedBox(width: 5,),
                AnimatedContainer(
                  duration: const Duration(microseconds: 350),
                  width: _addressCopied ? 115 : 65,
                  child: ElevatedButton(
                    onPressed: !_addressCopied ? copyAddress : null ,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      elevation: MaterialStateProperty.all(0),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        side: BorderSide(color: Get.theme.colorScheme.onPrimary, width: 1.5)
                      )),
                    ),
                    child: !_addressCopied ? const Icon(PhosphorIcons.copyLight, color: Colors.black, size: 20,)
                        : Row(
                           children: const [
                             Icon(Icons.check, color: Colors.green,),
                             SizedBox(width: 2,),
                             Text("Copied", style: TextStyle(color: Colors.green),),
                           ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            DepositAlertFundsLoss(network: network,),
            const SizedBox(height: 35,),
          ],
        ),
      );
  }
}

class DepositAlertFundsLoss extends StatelessWidget{
  final Network network;
  const DepositAlertFundsLoss({Key? key, required this.network}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onPrimary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(5),
      ),
      child: SizedBox(
        width: Get.width * 0.9,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 10,),
            Icon(PhosphorIcons.info, color: Get.theme.colorScheme.onPrimary,),
            const SizedBox(width: 5,),
            Flexible(
                child: RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    text: "this address is unique to",
                    style: TextStyle(fontSize: 13, fontFamily: AppThemes.fonts.gilroy, color: Get.theme.colorScheme.onPrimary),
                    children: [
                      TextSpan(
                        text: network.name,
                        style: TextStyle(fontFamily: AppThemes.fonts.gilroyBold)
                      ),
                      const TextSpan(
                        text: ".\n",
                      ),
                      const TextSpan(
                        text: "Only deposit from ",
                      ),
                      TextSpan(
                        text: network.name,
                        style: TextStyle(fontFamily: AppThemes.fonts.gilroyBold),
                      ),
                      const TextSpan(
                        text: ", otherwise funds ",
                      ),
                      TextSpan(
                        text: "will be lost.",
                        style: TextStyle(fontFamily: AppThemes.fonts.gilroyBold),
                      )
                    ]
                  ),
                ),
            ),
            const SizedBox(width: 10,),
          ],
        ),
      ),
    );
  }
}