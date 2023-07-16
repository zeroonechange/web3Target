 



```c 
第三方库的熟悉    https://pub.dev/ 

  # Essential
  web3dart: ^2.5.1         		和 eth 交互的  rpc-api  发送交易   生成私玥  调用 合约函数  监听事件 
  wallet_dart:             		自己写的钱包框架   包装 
    git:
      url: https://github.com/candidelabs/wallet-dart.git
      ref: main
  ens_dart: ^1.0.0         		ENS - ethereum name service  账号-域名解析 
  magic_sdk: ^2.0.2        		认证  登录
  dio: ^4.0.6              		HTTP 请求库 支持全局配置、Restful API、FormData、拦截器、 请求取消、Cookie 管理、文件上传/下载、超时以及自定义适配器等
  eth_sig_util: ^0.0.9         	签名工具 - 私玥  还原
  walletconnect_dart: ^0.0.11 	通过扫描二维码连接dapp
  # Auth
  biometric_storage: ^4.1.3		文件加密存储 例如密码 私玥等 不能很多数据
  # State
  get: ^4.6.5					framework{ navigation, snackbars/dialog/bottomSheets, state manage, data put/access, storage, theme, validator}
								好东西啊  1.状态管理-往里放变量 另一个地方取   2.路由管理-没有context  3.依赖管理-往里面放Controller 全局都可以取  
  event_bus: ^2.0.0				观察者-订阅者模式 
  hive: ^2.2.3					key-value 高性能数据库  比 sqlite 好多了  完全由 dart 编写
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^8.0.0   存储安全的数据  用RSA算法去加密AES算法的密钥  RSA的密钥存在keystore里面 
  # UI
  animations: ^2.0.3			Material motion 动画 
  pinput: ^2.2.23				类似那种短信验证码输入页面 
  flutter_awesome_alert_box: ^2.1.1   弹窗 
  bot_toast: ^4.0.2					  不止Toast  还能notification  loading  dialog
  modal_bottom_sheet: ^3.0.0-pre	   底部弹窗 类似ios的分享图片 	
  qr_flutter: ^4.0.0				   显示二维码 
  lottie: ^1.4.1						解析 adobe after 效果 
  salomon_bottom_bar: ^3.3.1			主页底部 navigation  bar
  pull_to_refresh_flutter3: ^2.0.1		上拉加载和下拉刷新
  blockies: ^0.1.2						将hash转换成图片 类似于github的头像 
  keyboard_actions: ^4.1.0				键盘
  onboarding: ^3.1.0					第一次使用 欢迎页  三个翻转页
  cached_network_image: ^3.2.3			图片缓存 
  expandable: ^5.0.1					类似于 更多 箭头  显示更多UI
  info_popup: ^2.4.6					popup window  弹窗
  # Typography
  phosphor_flutter: ^1.4.0				icon 集合   类似于阿里的 iconfan 
  font_awesome_flutter: ^10.1.0			字体集合 
  flutter_svg: ^1.1.1+1					加载svg 图片
  # Misc
  url_launcher: ^6.1.5					类似 webview 加载url 
  flutter_dotenv: ^5.0.2				加载 .env 配置信息 
  share_plus: ^6.2.0					分享功能
  qr_code_scanner: ^1.0.0				二维码扫描
  intl: ^0.17.0							国际化  翻译 数字 性别 日期格式化和解析  
  logger: ^1.1.0						logcat 打印日志 
  package_info_plus: ^3.0.2				获取packageinfo 
  pausable_timer: ^1.0.0+6				timer 
  short_uuids: ^2.0.0					生成UUID 
  flutter_cache_manager: ^3.3.0			文件缓存 可以设置保存多久
  permission_handler: ^10.2.0			申请权限 
```


```c
经典案例分析
android_view/android_view 知识点:
	FlutterEngine  	加载flutter 入口点
	ChangeNotifier + ChangeNotifierProvider +  Consumer  类似于观察者模式-监听数据变化  
	routes 路由 
	SizedBox.expand + Stack 布局  
	DecoratedBox  +  BoxDecoration  布局  修饰器
	Positioned.fill + Opacity + FittedBox 布局 
	Center + Column  布局    居中布局 
	Column +  mainAxisAlignment: MainAxisAlignment.center   对齐方式
	SizedBox   空白间隔  类似 anchor 
	url_launcher   加载 url  类似 webview  


例如 Center 和 Container
例如 Row、Column、ListView 和 Stack
使用 Scaffold widget，它提供默认的 banner 背景颜色，还有用于添加抽屉、提示条和底部列表弹窗的 API
使用 mainAxisAlignment 和 crossAxisAlignment 属性控制行或列如何对齐其子项
使用 Expanded widget，可以调整 widgets 的大小以适合行或列
为两类：widgets 库 中的标准 widgets 和 Material 库 中的 widgets
ListTile 是 Material 库 中专用的行 widget，它可以很轻松的创建一个包含三行文本以及可选的行前和行尾图标的行

```
