import 'package:bot_toast/bot_toast.dart';
import 'package:candide_mobile_app/config/env.dart';
import 'package:candide_mobile_app/config/theme.dart';
import 'package:candide_mobile_app/screens/home/components/magic_relayer_widget.dart';
import 'package:candide_mobile_app/screens/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Env.initialize();  // 读取配置文件里面的东西   用 flutter_dotenv
  await Hive.initFlutter(); // 初始化 高性能数据库 Hive
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(  // stack 布局
        children: [
          GetMaterialApp(
            title: 'Candide',
            builder: BotToastInit(),    // 初始化 bot_toast 框架   显示 Toast + notification + loading + dialog
            navigatorObservers: [BotToastNavigatorObserver()], //
            debugShowCheckedModeBanner: false,
            theme: AppThemes.darkTheme,
            home: const SplashScreen(),  // 启动页
          ),
          const MagicRelayerWidget(),   // magic_sdk  认证  登录
        ],
      ),
    );
  }
}