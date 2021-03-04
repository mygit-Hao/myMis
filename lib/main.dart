import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/app_info.dart';
import 'package:mis_app/common/biometrics.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/pages/common/passcode_page.dart';
import 'package:mis_app/pages/fingerprint_startup_page.dart';
import 'package:mis_app/pages/index_page.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/utils/security_utils.dart';
import 'package:provide/provide.dart';
import 'common/common.dart';
import 'common/global.dart';

// void main() => runApp(MyApp());
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Providers providers = Providers();

  UserProvide userProvider = UserProvide();
  LoginStatusProvide loginStatusProvider = LoginStatusProvide();
  WeekPlanProvide weekPlanProvide = WeekPlanProvide();

  providers
    ..provide(Provider<UserProvide>.value(userProvider))
    ..provide(Provider<LoginStatusProvide>.value(loginStatusProvider))
    ..provide(Provider<WeekPlanProvide>.value(weekPlanProvide));
  Global.init().then((e) {
    runApp(ProviderNode(
      child: MyApp(),
      providers: providers,
    ));
  });
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  DateTime _lastInactiveAt; //上次应用没响应（转到后台）
  bool _locking = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    SecurityUtils.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        // print('应用程序可见并响应用户输入。');
        // 未锁定、设置了生物解锁或数字解锁、应用转到后台超过限定时间，需要解锁
        if ((!_locking) &&
            (LoginStatusProvide.onLine) &&
            (Prefs.enabledBiometricsLogin || Prefs.enabledPasscodeLogin) &&
            (_lastInactiveAt != null) &&
            (DateTime.now().difference(_lastInactiveAt) >
                Duration(seconds: Global.lockAppAfterInactive))) {
          _lockApp();
        }
        break;
      case AppLifecycleState.inactive:
        // print('应用程序处于非活动状态，并且未接收用户输入');
        // 由于iOS应用从后台恢复的时候会触发AppLifecycleState.inactive，所以取消在此重置计时
        // _lastInactiveAt = DateTime.now();
        break;
      case AppLifecycleState.paused:
        // print('用户当前看不到应用程序，没有响应');
        if (!_locking) {
          _lastInactiveAt = DateTime.now();
        }
        break;
      case AppLifecycleState.detached:
        // print('应用程序将暂停。');
        break;
      default:
    }
  }

  void _lockApp() async {
    _locking = true;
    _lastInactiveAt = null;

    // Provide.value<UserProvide>(context).setAppLocked(false);
    bool passed = false;

    try {
      if (Prefs.enabledBiometricsLogin && Biometrics.canCheckBiometrics) {
        passed = await SecurityUtils.checkBiometrics(unlockReason);
      } else if (Prefs.enabledPasscodeLogin &&
          (!Prefs.passcodeIsEmpty) &&
          (Global.mainContext != null)) {
        passed = await SecurityUtils.checkPasscode(
            Global.mainContext, Prefs.passcode, unlockReason);
      } else {
        passed = true;
      }
    } finally {
      _locking = false;
      _lastInactiveAt = null;
    }

    if (!passed) {
      await pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(designScreenWidth, designScreenHeight),
      allowFontScaling: false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('en', ''),
          Locale(defaultLocale, defaultCountryCode)
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          // GlobalEasyRefreshLocalizations.delegate,
        ],
        onGenerateRoute: onGenerateRoute,
        // title: '伟明 MIS',
        title: AppInfo.appName,
        theme: ThemeData(
          // primarySwatch: Colors.blue,
          primarySwatch: defaultSwatch,
        ),
        // home: IndexPage(),
        home: _homePageWidget,
      ),
    );
  }

  Widget get _homePageWidget {
    // return IndexPage();

    if (Prefs.enabledBiometricsLogin) {
      return FingerprintStartupPage();
    } else if (Prefs.enabledPasscodeLogin) {
      return PasscodePage();
    } else {
      // 如果没有设置锁定密码，需要密码登录
      UserProvide().logout(keepSetting: true);

      return IndexPage();
    }
  }
}

/*
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      supportedLocales: [
        Locale('en', ''),
        Locale(defaultLocale, defaultCountryCode)
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        DefaultCupertinoLocalizations.delegate,
        // GlobalEasyRefreshLocalizations.delegate,
      ],
      onGenerateRoute: onGenerateRoute,
      title: '伟明 MIS',
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        primarySwatch: defaultSwatch,
      ),
      // home: IndexPage(),
      home: _homePageWidget,
    );
  }

  Widget get _homePageWidget {
    // return IndexPage();

    if (Prefs.enabledBiometricsLogin) {
      return FingerprintStartupPage();
    } else if (Prefs.enabledPasscodeLogin) {
      return PasscodePage();
    } else {
      // 如果没有设置锁定密码，需要密码登录
      UserProvide().logout(keepUserName: true);

      return IndexPage();
    }
  }
}
*/
