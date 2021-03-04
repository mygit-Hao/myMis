import 'dart:async';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mis_app/common/biometrics.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/jpush_helper.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/login_info.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/scan_data.dart';
import 'package:mis_app/model/user_status.dart';
import 'package:mis_app/pages/home_page.dart';
import 'package:mis_app/pages/life_page.dart';
import 'package:mis_app/pages/mine_page.dart';
import 'package:mis_app/pages/office_page.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/approval_service.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/security_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/utils/xupdate_util.dart';
import 'package:mis_app/widget/easyrefresh_utils.dart';
import 'package:mis_app/widget/fab_bottom_app_bar.dart';
import 'package:provide/provide.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  static const int _itemScan = 1;
  static const int _itemSearch = 2;

  DateTime _lastPressedAt; //上次点击时间

  final List<Widget> _tabBodies = [
    // homePageWidget,
    HomePage(),
    OfficePage(),
    LifePage(),
    // _getMasterPage(HomePage()),
    // _getMasterPage(OfficePage()),
    // _getMasterPage(LifePage()),
    MinePage(),
  ];

  /*
  final List<BottomNavigationBarItem> _bottomTabs = [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('首页'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.business_center),
      title: Text('办公'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      title: Text('生活'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      title: Text('我的'),
    ),
  ];
  */

  final List<FABBottomAppBarItem> _bottomTabs = [
    FABBottomAppBarItem(iconData: Icons.home, text: '首页'),
    FABBottomAppBarItem(iconData: Icons.business_center, text: '办公'),
    FABBottomAppBarItem(iconData: Icons.chat, text: '生活'),
    FABBottomAppBarItem(iconData: Icons.person, text: '我的'),
  ];

  int _homeIndex = 0;
  LoginStatus _oldLoginStatus;
  List<Map<String, dynamic>> _popupItems = [
    /*
    {
      'name': '扫一扫',
      'value': _itemScan,
      'icon': ConstValues.icon_scan,
    },
    */
    {
      'name': '搜索',
      'value': _itemSearch,
      'icon': Icons.search,
    }
  ];
  // final StreamController<bool> _verificationNotifier =
  //     StreamController<bool>.broadcast();
  // 用于控制只作一次版本检查
  bool _versionChecked = false;
  bool _firstBuild = true;

  /*
  static Widget _getMasterPage(Widget page) {
    return FutureBuilder(
      future: _checkLogin(),
      // future: _initSignature(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
            return new Text('');

          case ConnectionState.waiting:
            return LoadingIndicator();

          case ConnectionState.done:
            // return HomePage();
            return page;
        }

        return Text('加载中........');
      },
    );
  }
  */

  @override
  void initState() {
    super.initState();

    _init();
  }

  /*
  @override
  void dispose() {
    _verificationNotifier.close();

    super.dispose();
  }
  */

  void _init() async {
    Global.mainContext = context;
    _oldLoginStatus = LoginStatusProvide.loginStatus;

    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    // SystemChrome.setEnabledSystemUIOverlays(
    //     [SystemUiOverlay.top, SystemUiOverlay.bottom]);

    // _checkLogin();

    // _updateUserStatus(context);

    SchedulerBinding.instance.addPostFrameCallback((Duration timestamp) {
      initEasyRefresh();

      // 由于XUpdate不支持iOS，所以启动时，只对Android做了版本检查
      // iOS平台在此检查
      // 把版本检查统一放在签名检查后
      /*
      if (Platform.isIOS) {
        checkAppVersion(context, false);
      }
      */
    });
  }

  static void _updateUserStatus(BuildContext context) async {
    if (LoginStatusProvide.loginStatus != LoginStatus.onLine) return;

    UserStatusModel result = await UserService.getStatus();
    if (result != null) {
      Provide.value<UserProvide>(context)
          .updateCountOfUnread(result.countOfUnreadNotification);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(context, width: 750, height: 1334);
    if (_firstBuild) {
      ConstValues.defaultFontSize =
          Theme.of(context).textTheme.bodyText1.fontSize;
      ConstValues.screenShortestSide = MediaQuery.of(context).size.shortestSide;
      ConstValues.screenLongestSide = MediaQuery.of(context).size.longestSide;

      // initScreenUtil(context);
      JPushHelper.initPlatformState(context);
      _firstBuild = false;
    }

    /*
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _homeIndex,
            items: _bottomTabs,
            onTap: (int index) async {
              await _checkLogin();
              if (_oldLoginStatus != Global.loginStatus) {
                Provide.value<UserProvide>(context).updateCurrentUserInfo();
                _oldLoginStatus = Global.loginStatus;
              }
              setState(() {
                _homeIndex = index;
              });
            },
          ),
          body: SafeArea(
            child: IndexedStack(
              index: _homeIndex,
              children: _tabBodies,
            ),
          ),
        );
      },
    );
    */

    return WillPopScope(
      onWillPop: () async {
        if ((_lastPressedAt == null ||
            (DateTime.now().difference(_lastPressedAt) >
                Duration(seconds: 1)))) {
          //两次点击间隔超过1秒则重新计时
          _lastPressedAt = DateTime.now();
          DialogUtils.showToast('再按一次退出应用');

          return false;
        }

        return true;
      },
      child: _mainWidget,
    );
  }

  Widget get _mainWidget {
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        /*
        if (Prefs.enabledPasscodeLogin && (!Prefs.enabledBiometricsLogin)) {
          return Scaffold(
            body: SecurityUtils.passCodeScreen(
              unlockReason,
              _verificationNotifier,
              passwordEnteredCallback: _onPasscodeEntered,
              isValidCallback: _authenticationPassed,
              cancelCallback: _onPasscodeCancel,
            ),
          );
        }
        */

        String title = value.appTitle;

        bool loggedOut = LoginStatusProvide.loggedOut;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: InkWell(
              child: Text(title),
              onTap: () {
                _changeArea();
              },
            ),
            actions: <Widget>[
              if (!loggedOut) _notificationWidget,
              if (!loggedOut) _popupMenuButton,
              /*
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // print('Search');
                },
              ),
              */
            ],
          ),
          /*
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _homeIndex,
            items: _bottomTabs,
            onTap: (int index) async {
              setState(() {
                _homeIndex = index;
              });
            },
          ),
          */

          bottomNavigationBar: FABBottomAppBar(
            color: Theme.of(context).textTheme.headline1.color,
            selectedColor: Theme.of(context).primaryColor,
            notchedShape: CircularNotchedRectangle(),
            items: _bottomTabs,
            onTabSelected: (int index) {
              setState(() {
                _homeIndex = index;
              });
            },
          ),
          floatingActionButton: FloatingActionButton(
              child: Icon(ConstValues.icon_scan),
              onPressed: () {
                _scan();
              }),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          body: SafeArea(
            child: FutureBuilder(
              future: _updateLoginStatus(context),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                // if (UserProvide.appLocked) {
                //   return Container();
                // }
                return IndexedStack(
                  index: _homeIndex,
                  children: _tabBodies,
                );
              },
            ),
          ),
        );
      },
    );
  }

  /*
  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = (Prefs.passcode == enteredPasscode);
    _verificationNotifier.add(isValid);
    if (!isValid) {
      DialogUtils.showToast('密码不正确');
    }
  }

  _authenticationPassed() {
    Provide.value<UserProvide>(context).setAppLocked(false);
  }

  void _onPasscodeCancel() async {
    await pop();
  }
  */

  Widget get _popupMenuButton {
    /*
    return PopupMenuButton<int>(
      icon: Icon(Icons.add_circle_outline),
      color: Colors.black,
      onSelected: _onPopupMenuItemSelected,
      offset: Offset(0, kToolbarHeight),
      itemBuilder: (BuildContext context) {
        return <PopupMenuEntry<int>>[
          _popupMenuItem('扫一扫', 1, ConstValues.icon_scan),
          _popupMenuItem('搜索', 2, Icons.search),
        ];
      },
    );
    */

    return PopupMenuButton<int>(
      icon: Icon(Icons.add_circle_outline),
      color: Colors.black,
      onSelected: _onPopupMenuItemSelected,
      offset: Offset(0, kToolbarHeight),
      itemBuilder: (BuildContext context) {
        return _popupItems.map((Map<String, dynamic> e) {
          return _popupMenuItem(e['name'], e['value'], e['icon']);
        }).toList();
      },
    );
  }

  void _onPopupMenuItemSelected(int value) {
    switch (value) {
      case _itemScan:
        _scan();
        break;
      case _itemSearch:
        _search();
        break;
      default:
    }
  }

  void _scan() async {
    if (LoginStatusProvide.loggedOut) return;

    ScanResult scanData = await BarcodeScanner.scan(
      options: ScanOptions(strings: scanOptionsStrings),
    );
    if ((scanData == null) ||
        (Utils.textIsEmptyOrWhiteSpace(scanData.rawContent))) return;

    ScanDataModel data = ScanDataModel.fromRawContent(scanData.rawContent);

    if (!data.valid) {
      DialogUtils.showToast('不是有效的操作码');
      return;
    }

    var list = data.typeList;

    switch (data.primaryType) {
      case scanTypeUuid:
        _processUuid(data.data);
        break;
      case scanTypeApproval:
        if (list.length >= 0) {
          _processApproval(list[1], data.data);
        }
        break;
      default:
        DialogUtils.showToast('暂不支持该操作');
    }
  }

  void _processApproval(String docType, String docId) async {
    var head = await ApprovalService.getHead(docType, docId);
    if ((head == null) || (!head.isValid)) {
      DialogUtils.showToast('没找到对应单据或没有权限查看');
      return;
    }

    Navigator.pushNamed(context, approvalHandlePath,
        arguments: {'docType': docType, 'docId': docId, 'isApprovaled': false});
  }

  void _processUuid(String data) async {
    RequestResult result = await UserService.getUuidInfo(data);
    if (result.success) {
      if (result.data['valid']) {
        String hostName = result.data['hostName'];
        String userName = result.data['userName'];

        String reason =
            '允许用户 ${Utils.toAutoCapitalize(userName)} 在电脑 $hostName 登录吗？';
        bool passed = false;

        if (Prefs.enabledBiometricsLogin && Biometrics.canCheckBiometrics) {
          passed = await SecurityUtils.checkBiometrics(reason);
        } else if (Prefs.enabledPasscodeLogin && (!Prefs.passcodeIsEmpty)) {
          passed = await SecurityUtils.checkPasscode(
              context, Prefs.passcode, reason);
        } else {
          passed = await DialogUtils.showConfirmDialog(context, reason,
              confirmText: '允许', confirmTextColor: Colors.orange);
        }

        if (passed) {
          result = await UserService.scanUuid(data);
          if (result.success) {
            DialogUtils.showToast('扫码成功');
          } else {
            DialogUtils.showToast(result.msg);
          }
        }
      } else {
        DialogUtils.showToast('${result.data['msg'] ?? "数据异常"}');
      }
    }
  }

  void _search() {
    print('search');
  }

  PopupMenuItem<int> _popupMenuItem(String itemName, int value, IconData icon) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        dense: true,
        title: Text(
          itemName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        leading: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
    /*
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.white,
        ),
        // SizedBox(width: 2.0),
        Text(
          itemName,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ],
    );
    */
  }

  Widget get _notificationWidget {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.message),
          onPressed: _openNotification,
        ),
        if (UserProvide.countOfUnread > 0)
          Positioned(
            top: 10.0,
            right: 10.0,
            child: Icon(
              Icons.lens,
              color: Colors.red,
              size: 6.0,
            ),
          ),
      ],
    );
  }

  void _openNotification() async {
    if (LoginStatusProvide.loggedOut) {
      DialogUtils.showToast('请先登录');
      return;
    }

    await Navigator.of(context).pushNamed(notificationPath);
    _updateUserStatus(context);
  }

  void _changeArea() async {
    if ((UserProvide.areaList == null) || (UserProvide.areaList.length <= 1)) {
      return;
    }

    if (!await isOnline) {
      return;
    }

    int selectedAreaIndex = UserProvide.currentAreaIndex;

    int index = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        var child = Column(
          children: <Widget>[
            ListTile(title: Text("请选择项目")),
            Expanded(
              child: ListView.builder(
                itemCount: UserProvide.areaList.length,
                itemBuilder: (BuildContext context, int index) {
                  return RadioListTile<int>(
                    value: index,
                    title: Text(UserProvide.areaList[index].shortName),
                    groupValue: selectedAreaIndex,
                    onChanged: (value) {
                      setState(() {
                        selectedAreaIndex = index;
                      });
                      Navigator.of(context).pop(index);
                    },
                  );
                },
              ),
            ),
          ],
        );

        return Dialog(child: child);
      },
    );
    if (index != null) {
      if (Provide.value<UserProvide>(context)
          .setAreaId(UserProvide.areaList[index].areaId)) {
        LoginInfo info = await UserService.currentUserLogin();
        if (info.success) {
          Provide.value<UserProvide>(context).updateCurrentUserInfo(info);
          Prefs.saveLoginedAreaId();
        }
      }
    }
  }

  static Future<void> _checkLogin(BuildContext context) async {
    if ((LoginStatusProvide.loginStatus == LoginStatus.offLine) &&
        (await isOnline)) {
      LoginInfo info = await UserService.currentUserLogin();
      if (info.success) {
        UserProvide().updateCurrentUserInfo(info);
        Provide.value<UserProvide>(context).updateCurrentUserInfo(info);

        _updateUserStatus(context);
      } else {
        DialogUtils.showToast('用户信息异常，请重新登录');
        UserProvide().logout(keepSetting: true);
      }
    }
  }

  Future<void> _updateLoginStatus(BuildContext context) async {
    /*
    if (UserProvide.appLocked) {
      if (!await SecurityUtils.checkBiometrics(unlockReason)) {
        await pop();
        return;
      }
      Provide.value<UserProvide>(context).setAppLocked(false);
    }
    */

    await _checkLogin(context);
    if (_oldLoginStatus != LoginStatusProvide.loginStatus) {
      Provide.value<UserProvide>(context).refreshCurrentUserInfo();
      _oldLoginStatus = LoginStatusProvide.loginStatus;

      if (UserProvide.currentUser.needSignature) {
        DialogUtils.showToast('今天还没有签名');
        await Navigator.pushNamed(context, signatureAddPath);
        UserProvide.currentUser.needSignature = false;
      }

      // 由于签名提示需旋转屏幕，与升级提示冲突，故改在签名后再检查版本升级
      if (!_versionChecked) {
        _versionChecked = true;

        if (Platform.isIOS) {
          checkAppVersion(context, false);
        } else {
          XUpdateUtil.checkUpdate();
        }
      }
    }
  }
}
