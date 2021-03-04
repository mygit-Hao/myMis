import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/app_info.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/pages/common/login_page.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/widget/setting_divider.dart';
import 'package:mis_app/widget/large_button.dart';
import 'package:mis_app/widget/setting_item.dart';
import 'package:provide/provide.dart';

class MinePage extends StatefulWidget {
  MinePage({Key key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        /*
        return Scaffold(
          appBar: AppBar(
            title: Text('我的'),
          ),
          body: SafeArea(
            child: Container(
              child: ListView(
                children: _itemList(context),
              ),
            ),
          ),
        );
        */
        return SafeArea(
          child: Container(
            child: ListView(
              children: _itemList(context),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _itemList(BuildContext context) {
    bool loggedOut = LoginStatusProvide.loggedOut;

    List<Widget> list = List<Widget>();
    list.addAll([
      _userItem,
      SettingDivider(),
      _signatureItem(context),
      SettingDivider(),
      _securityItem(context),
      SettingDivider(),
      _versionItem(context),
      SettingDivider(),
    ]);

    list.addAll([
      SizedBox(
        height: 25.0,
      ),
      LargeButton(
        title: loggedOut ? '登录' : '退出登录',
        onPressed: () {
          if (loggedOut) {
            _login(context);
          } else {
            _logout(context);
          }
        },
      ),
    ]);

    return list;
  }

  /*
  void _showPasscodeScreen(PasscodeStep step, String title,
      {bool replacingRoute = false}) {
    _currentStep = step;

    if (replacingRoute) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              _passcodeScreen(title),
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              _passcodeScreen(title),
        ),
      );
    }
  }
  */

  void _logout(BuildContext context) async {
    await UserService.logout();

    Provide.value<UserProvide>(context).logout();
    /*
    setState(() {
      _getLoginMethod();
    });
    */
  }

  void _login(BuildContext context) {
    DialogUtils.showToast('请先登录');
    Navigator.pushNamed(context, loginPath);
  }

  Widget get _userItem {
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        String displayName = UserProvide.displayUserName;

        return SettingItem(
          onTap: () {
            // print('点击了用户');
            Navigator.pushNamed(context, userInfoPath);
          },
          leading: Icon(
            Icons.person,
            size: defaultIconSize,
            color: Colors.lightBlue,
          ),
          title: Row(
            children: <Widget>[
              Text(
                '用户：',
              ),
              Text(
                displayName,
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          trailing: Container(
            width: ScreenUtil().setWidth(100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Icon(
                  // IconData(0xe7b8, fontFamily: 'MyIcons'),
                  ConstValues.icon_qrcode,
                  size: defaultIconSize,
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _signatureItem(BuildContext context) {
    return SettingItem(
      onTap: () {
        _navigateTo(context, signaturePath);
      },
      leading: Icon(
        // IconData(0xe6fe, fontFamily: 'MyIcons'),
        ConstValues.icon_pen,
        size: defaultIconSize,
        color: Colors.green,
      ),
      title: Text('签名设置'),
    );
  }

  Widget _securityItem(BuildContext context) {
    return SettingItem(
      onTap: () {
        // Navigator.pushNamed(
        //   context,
        //   securityPath,
        // );
        _navigateTo(context, securityPath);
      },
      leading: Icon(
        Icons.security,
        size: defaultIconSize,
        color: Colors.blue,
      ),
      title: Text('帐号与安全'),
    );
  }

  Widget _versionItem(BuildContext context) {
    return SettingItem(
      onTap: () {
        checkAppVersion(context, true);
      },
      leading: logoImage(defaultIconSize, defaultIconSize),
      // title: Text('版本号：${AppInfo.appFullVersion}'),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '版本号： '),
            TextSpan(
              text: '${AppInfo.appFullVersion}',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String newPath) {
    bool loggedOut = LoginStatusProvide.loggedOut;

    if (loggedOut) {
      DialogUtils.showToast('请先登录');
      // Navigator.pushNamed(context, getRedirectPath(loginPage, newPath));
      Navigator.pushNamed(context, loginPath,
          arguments: {REDIRECT_PATH: newPath});

      return;
    }

    Navigator.pushNamed(context, newPath);
  }
}
