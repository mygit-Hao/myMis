import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/pages/common/passcode_page.dart';
import 'package:mis_app/pages/index_page.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/security_utils.dart';

class FingerprintStartupPage extends StatefulWidget {
  FingerprintStartupPage({Key key}) : super(key: key);

  @override
  _FingerprintStartupPageState createState() => _FingerprintStartupPageState();
}

class _FingerprintStartupPageState extends State<FingerprintStartupPage> {
  // final LocalAuthentication auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    // initScreenUtil(context);

    return SafeArea(
      child: Scaffold(
          body: FutureBuilder(
        future: _checkFingerprint(context),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // return Text('正在验证身份........');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(32.0),
                  child: logoImage(ScreenUtil().setHeight(128.0),
                      ScreenUtil().setWidth(128.0)),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    '正在验证身份........',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      )),
    );
  }

  Future _checkFingerprint(BuildContext context) async {
    // bool authenticated = await auth.authenticateWithBiometrics(
    //     localizedReason: authReason,
    //     androidAuthStrings: authAndroidStrings,
    //     useErrorDialogs: true,
    //     stickyAuth: true);

    bool authenticated = await SecurityUtils.checkBiometrics(authReason);

    if (!authenticated) {
      UserProvide().logout(keepSetting: true);
    }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) {
      // return IndexPage();
      if (authenticated && Prefs.enabledPasscodeLogin) {
        return PasscodePage();
      } else {
        return IndexPage();
      }
    }), (Route<dynamic> route) => false);
  }
}
