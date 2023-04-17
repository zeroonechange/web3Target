import 'package:animations/animations.dart';
import 'package:candide_mobile_app/config/theme.dart';
import 'package:candide_mobile_app/screens/onboard/components/onboard_disclaimer_screen.dart';
import 'package:candide_mobile_app/screens/onboard/create_account/create_account_main_screen.dart';
import 'package:candide_mobile_app/screens/onboard/recovery/recover_account_sheet.dart';
import 'package:candide_mobile_app/utils/guardian_helpers.dart';
import 'package:candide_mobile_app/utils/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// 欢迎页 下滑第三个页面   有动画效果
class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Offset _offsetValue = const Offset(0, 4);
  double _opacityValue = 0;
  double _scaleValue = 5.0;

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 200), (){
      setState(() {
        _opacityValue = 1;
        _scaleValue = 1;
        _offsetValue = const Offset(0, 0);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(   // 什么玩意儿
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50,),
            AnimatedSlide(            // 把 动画+图片 当作一个widget?
              offset: _offsetValue,
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 1000),
              child: AnimatedOpacity(
                opacity: _opacityValue,
                duration: const Duration(milliseconds: 600),
                child: AnimatedScale(
                  scale: _scaleValue,
                  curve: Curves.easeInExpo,
                  duration: const Duration(milliseconds: 1000),
                  child: SvgPicture.asset(
                    "assets/images/logo_cropped.svg",
                    width: 150,
                    height: 150,
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Text("CANDIDE", style: TextStyle(fontFamily: AppThemes.fonts.procrastinating, fontSize: 45, color: Get.theme.colorScheme.primary),),
            const Spacer(flex: 2,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: Get.width * 0.125),
              child: ElevatedButton(  // button 里面不能直接写 text  还得搞个 child 用来确定 text
                onPressed: () {
                  Get.to(
                    OnboardDisclaimerScreen(   // 对应 create a new wallet
                      onContinue: (){
                        Get.back();
                        // 跳转  goNext()   创建账号页面
                        Navigator.push(context, SharedAxisRoute(builder: (_) => const CreateAccountMainScreen(), transitionType: SharedAxisTransitionType.horizontal));
                      },
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)
                  )),
                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text("Create a new wallet", style: TextStyle(fontFamily: AppThemes.fonts.gilroyBold, fontSize: 17),)
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: Get.width * 0.125),
              child: TextButton(
                onPressed: () async {
                  await showBarModalBottomSheet(   // 对应 I already have a wallet  会显示一个弹窗   modal_bottom_sheet
                    context: context,
                    backgroundColor: Get.theme.canvasColor,
                    builder: (context) {
                      Get.put<ScrollController>(ModalScrollController.of(context)!, tag: "recovery_account_modal"); // 这是干啥子  放东西进一个全局的容器  get 使用
                      return const RecoverAccountSheet(
                          method: "social-recovery",
                          onNext: GuardianRecoveryHelper.setupRecoveryAccount
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(  borderRadius: BorderRadius.circular(15), )),
                  minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                  backgroundColor: MaterialStateProperty.all<Color>(Get.theme.cardColor),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text("I already have a wallet", style: TextStyle(fontFamily: AppThemes.fonts.gilroyBold, fontSize: 17, color: Get.theme.colorScheme.primary)),
                )
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

