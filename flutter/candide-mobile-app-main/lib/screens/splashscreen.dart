import 'package:candide_mobile_app/config/network.dart';
import 'package:candide_mobile_app/controller/persistent_data.dart';
import 'package:candide_mobile_app/controller/settings_persistent_data.dart';
import 'package:candide_mobile_app/controller/signers_controller.dart';
import 'package:candide_mobile_app/screens/home/home_screen.dart';
import 'package:candide_mobile_app/screens/onboard/components/wallet_onboarding.dart';
import 'package:candide_mobile_app/screens/onboard/create_account/pin_entry_screen.dart';
import 'package:candide_mobile_app/utils/events.dart';
import 'package:candide_mobile_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:wallet_dart/wallet/account_helpers.dart';
import 'package:web3dart/web3dart.dart';

//启动页
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // 跳转到主页
  navigateToHome(){
    PersistentData.loadExplorerJson(PersistentData.selectedAccount, null);  // 从数据库加载数据
    SettingsData.loadFromJson(null);      // 数据库加载 当前货币
    Get.off(const HomeScreen());        // 路由跳转到主页
  }

  // 认证
  authenticate() async {
    Get.to(PinEntryScreen(  // pin 认证
      showLogo: true,
      promptText: "Enter PIN code",
      confirmMode: false,
      onPinEnter: (String pin, _) async {
        var cancelLoad = Utils.showLoading();
        Credentials? credentials = await AccountHelpers.decryptSigner(
          SignersController.instance.getSignerFromId("main")!,
          pin,
        );
        if (credentials == null){
          cancelLoad();
          eventBus.fire(OnPinErrorChange(error: "Incorrect PIN"));
          return null;
        }
        SignersController.instance.storePrivateKey("main", credentials as EthPrivateKey);
        cancelLoad();
        Get.back(result: true);
        navigateToHome();
      },
    ));
  }

  // 初始化  异步的
  initialize() async {
    await Future.wait([
      Hive.openBox("signers"), // 签名 打开表?
      Hive.openBox("wallet"),  // 钱包
      Hive.openBox("settings"), // 设置
      Hive.openBox("state"),
      Hive.openBox("activity"),
      Hive.openBox("wallet_connect"),
      Hive.openBox("tokens_storage"),
    ]);
    Networks.initialize();  // 初始化 RPC 网络  货币  chainId  entryPoint 合约地址 其他合约地址 ...
    Networks.configureVisibility(); // 是否可见  Network.visible 参数
    PersistentData.loadSigners();   // 从数据库中加载签名 需要解密  web3dart
    PersistentData.loadAccounts();  // 从数据库中加载账号
    SettingsData.loadFromJson(null);  // 数据库加载 货币符号
    //
    if (PersistentData.accounts.isEmpty){ // 没有账号
      Get.off(const WalletOnboarding());   // 引导页
    }else{
      eventBus.fire(OnAccountChange());    // 好像没看到有订阅者监听
      authenticate();               // pin 认证  去 PinEntryScreen
    }
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  // 先执行 build 方法  再跑 initState 方法
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(  // 居中
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/logov3.svg",
              width: Get.width * 0.8,
              color: Get.theme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
