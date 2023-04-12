


```c
给 Android 开发者的 Flutter 指南


Flutter 中 View 的大致对应着 Widget
如果一个 Widget 会变化（例如由于用户交互），它是有状态的。然而，如果一个 Widget 响应变化，它的父 Widget 只要本身不响应变化，就依然是无状态的。

在 Flutter 中你需要使用 Navigator 和 Route 在同一个 Activity 内的不同界面间进行跳转
Route 是应用内屏幕和页面的抽象，Navigator 是管理路径 route 的工具
Navigator 可以通过对 route 进行压栈和弹栈操作实现页面的跳转。 Navigator 的工作原理和栈相似，你可以将想要跳转到的 route 压栈 (push())，想要返回的时候将 route 出栈 (pop())。

Flutter 可以通过直接和 Android 层通信并请求分享的数据来处理接收到的 Android intent

Dart 有一个单线程执行的模型，同时也支持 Isolate （在另一个线程运行 Dart 代码的方法），它是一个事件循环和异步编程方式。除非你创建一个 Isolate，否则你的 Dart 代码会运行在主 UI 线程，并被一个事件循环所驱动。Flutter 的事件循环对应于 Android 里的主 Looper——也即绑定到主线程上的 Looper
如果你在执行和 I/O 绑定的任务，例如存储访问或者网络请求，那么你可以安全地使用 async/await，并无后顾之忧。再例如，你需要执行消耗 CPU 的计算密集型工作，那么你可以将其转移到一个 Isolate 上以避免阻塞事件循环，就像你在 Android 中会将任何任务放到主线程之外一样。
Isolate 是独立执行的线程，不会和主执行内存堆分享内存

虽然 http 包没有 OkHttp 中的所有功能，但是它抽象了很多通常你会自己实现的网络功能，这使其本身在执行网络请求时简单易用。

在 pubspec.yaml 文件中定义在 Flutter 里使用的外部依赖。 pub.dev 是查找 Flutter packages 的好地方

在 Android 中，一个 Activity 代表用户可以完成的一件独立任务。一个 Fragment 代表一个行为或者用户界面的一部分。 Fragment 用于模块化你的代码，为大屏组合复杂的用户界面，并适配应用的界面。在 Flutter 中，这两个概念都对应于 Widget。
在 Android 中，你可以覆写 Activity 的生命周期方法来监听其生命周期，也可以在 Application 上注册 ActivityLifecycleCallbacks。在 Flutter 中，这两种方法都没有，但是你可以通过绑定 WidgetsBinding 观察者并监听 didChangeAppLifecycleState() 的变化事件来监听生命周期。
可以被观察的生命周期事件有： 
	inactive — 应用处于非活跃状态并且不接收用户输入。 
	detached — 应用依然保留 flutter engine，但是全部宿主 view 均已脱离。 
	paused — 应用当前对用户不可见，无法响应用户输入，并运行在后台。这个事件对应于 Android 中的 onPause()； 
	resumed — 应用对用户可见并且可以响应用户的输入。这个事件对应于 Android 中的 onPostResume()；
	suspending — 应用暂时被挂起。这个事件对应于 Android 中的 onStop； iOS 上由于没有对应的事件，因此不会触发此事件。

在 Android 中，LinearLayout 用于线性布局 widget 的——水平或者垂直。在 Flutter 中，使用 Row 或者 Column Widget 来实现相同的效果。
你可以通过组合使用 Column、Row 和 Stack Widget 实现 RelativeLayout 的效果。你还可以在 Widget 构造器内声明孩子相对父亲的布局规则。

在 Android 中，使用 ScrollView 布局 widget—— 如果用户的设备屏幕比应用的内容区域小，用户可以滑动内容。 在 Flutter 中，实现这个功能的最简单的方法是使用 ListView widget。
从 Android 的角度看，这样做可能是杀鸡用牛刀了，但是 Flutter 中 ListView widget 既是一个 ScrollView，也是一个 Android 中的 ListView。

两种添加触摸监听器
	如果 Widget 支持事件监听，那么向它传入一个方法并在方法中处理事件。例如，RaisedButton 有一个 onPressed 参数
	如果 Widget 不支持事件监听，将 Widget 包装进一个 GestureDetector 中并向 onTap 参数传入一个方法
使用 GestureDetector 可以监听非常多的手势
在 Android 中，你需要更新 adapter 并调用 notifyDataSetChanged。 在 Flutter 中，如果你准备在 setState() 里更新一组 widget，你很快会发现你的数据并没有更新到界面上。
这是因为当 setState() 被调用的时候， Flutter 渲染引擎会查看 Widget 树是否有任何更改。当引擎检查到 ListView，他会执行 == 检查，并判断两个 ListView 是一样的。没有任何更改，所以也就不需要更新。 
更新 ListView 的一个简单方法是，在 setState() 里创建一个新的 List，并将数据从旧列表拷贝到新列表。虽然这个方法很简单，就如下面例子所示，但是并不推荐在大数据集的时候使用。
使用 ListView.Builder。这个方法非常适用于动态列表或者拥有大量数据的列表。这基本上就是 Android 里的 RecyclerView，会为你自动回收列表项

自定义字体
使用 GPS 传感器
使用相机
使用 Firebase
使用 NDK
在 Android 中，你可以使用 SharedPreferences API 来存储少量的键值对。 在 Flutter 中，使用 Shared_Preferences 插件 实现此功能。这个插件同时包装了 Shared Preferences 和 NSUserDefaults（iOS 平台对应 API）的功能。
在 Android 中，你会使用 SQLite 来存储可以通过 SQL 进行查询的结构化数据。 在 Flutter 中，使用 SQFlite 插件实现此功能。

```