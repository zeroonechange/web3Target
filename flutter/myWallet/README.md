# mywallet

a  wallet support ERC4337

## 大体架构
```c
 controller 用于和本地数据库, 网络交互   service 和合约交互 
 页面根据模块来划分  再去细分 component   比安卓要简单多了 
 
 框架层面  核心是 和web3交互的 web3dart   http请求的dio  路由跳转get   数据库hive  
          UI部分 千奇百怪的  又多又杂  
```

## 项目架构
```c
lib
    config			
        读取配置文件
        以太坊网络节点
        swap
        主题 theme
        top tokens 
    controller
        构建 transaction
        本地数据库使用方法封装 
        交易流程 pin密码  -> swap  
        钱包连接dapp
    models
        预估 gas 费
        构建OP
        gas费bean
        枚举操作类型
        服务端返回字段		
    screens
        components   确认弹窗  输入框外部border   switch   图标+文件控件组合  表格控件  selector控件
        home		 
            activity		交易活动记录
            components		输入地址+二维码扫描  二维码扫描  receive+send+swap   余额   token选择   删除确认  展示二维码弹窗...  
            guardians		恢复账号  
            send			发送金额给其他人 
            settings		app设置页面  
            swap			swap交互
            wallet_connect  钱包连接上RPC节点 
            wallet_selection	钱包账号选择
        onboard
            components		区块链RPC选择控件	     
            creat_account	创建新的账号
            recovery		恢复账号
        splashscreen		欢迎页
    services
        获取账户总的USD余额   先通过一个contract获取所有的token数量  再去 api.coingecko.com 获取实时价格  算出来得到
        Bundler   批量打包 - 给OP签名 - 向bundler发起请求 - 获取gas预估值 - 获取paymaster费用 - 获取op哈希 
        获取 swap 交易信息 例如 rate  amount LP 
        通过web3dart获取一个ECR20的信息  
        解析数据
        交易看门狗 - 获取交易状态  检查交易状态是否完成 
    utils
        常量
        货币  俩种token汇率转化  金额格式化  转行货币单位   格式化比率  
        eventbus的封装 
        路由封装
        常用工具方法   显示错误  复制  地址是否合法  随机数字   大小写判别  字符串连接  弹窗  键盘 
```

## 常用框架
```c
https://pub.dev/ 

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
  walletconnect_dart: ^0.0.11 	钱包通过扫描二维码连接dapp
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
  bot_toast: ^4.0.2					  不止Toast  还能 notification  loading  dialog
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
