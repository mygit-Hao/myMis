import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mis_app/common/biometrics.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/security_utils.dart';
import 'package:mis_app/widget/setting_divider.dart';
import 'package:mis_app/widget/setting_item.dart';

enum PasscodeStep {
  firstPasscode,
  confirmPasscode,
  resetPasscode,
}

class SecurityPage extends StatefulWidget {
  SecurityPage({Key key}) : super(key: key);

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  static const String _cancelledValue = 'cancelled';

  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();
  // final LocalAuthentication auth = LocalAuthentication();

  String _firstPasscode;
  String _confirmPasscode;
  PasscodeStep _currentStep;
  bool _passcodeValid = false;
  bool _enabledPasscodeLogin = false;
  bool _enabledBiometricsLogin = false;

  @override
  void initState() {
    super.initState();

    _getLoginMethod();
  }

  void _getLoginMethod() {
    _enabledPasscodeLogin = Prefs.enabledPasscodeLogin;
    _enabledBiometricsLogin = Prefs.enabledBiometricsLogin;
  }

  @override
  void dispose() {
    _verificationNotifier.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('帐号与安全'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    bool canCheckBiometrics = Biometrics.canCheckBiometrics;

    return Container(
      child: ListView(
        children: [
          _changePasswordItem(context),
          SettingDivider(),
          _passcodeItem(context),
          SettingDivider(),
          _passcodeLoginItem(),
          SettingDivider(),
          if (canCheckBiometrics) _biometricsItem(),
          if (canCheckBiometrics) SettingDivider(),
        ],
      ),
    );
  }

  Widget _changePasswordItem(BuildContext context) {
    return SettingItem(
      onTap: () {
        /*
        // bool logined = Global.logined;
        bool logined = LoginStatusProvide.loginStatus != LoginStatus.logout;

        if (!logined) {
          Utils.showToast('请选登录');
          // Application.router.navigateTo(context, Routes.loginPage);

          // String path = '${Routes.loginPage}?redirect_path=change_password';
          // Application.router.navigateTo(context, path);
          Application.router.navigateTo(
              context, Routes.getRedirectPath(loginPage, changePasswordPage));

          return;
        }

        Application.router.navigateTo(context, changePasswordPage);
        */

        // _navigateTo(context, changePasswordPath);
        Navigator.pushNamed(
          context,
          changePasswordPath,
        );
      },
      leading: Icon(
        Icons.vpn_key,
        size: defaultIconSize,
        color: Colors.orange,
      ),
      title: Text('更改登录密码'),
    );
  }

  Widget _passcodeItem(BuildContext context) {
    return SettingItem(
      onTap: () {
        bool loggedOut = LoginStatusProvide.loggedOut;

        if (loggedOut) {
          DialogUtils.showToast('请先登录');
          // Application.router.navigateTo(context, loginPage).then((value) {});
          Navigator.pushNamed(context, loginPath);

          return;
        }

        if (Prefs.passcodeIsEmpty) {
          // _showPasscodeScreen(PasscodeStep.firstPasscode, '请输入密码');
          _setPasscode();
        } else {
          // _showPasscodeScreen(PasscodeStep.resetPasscode, '请输入旧密码');
          _resetPasscode();
        }
      },
      leading: Icon(
        Icons.dialpad,
        size: defaultIconSize,
        color: Colors.purple,
      ),
      title: Prefs.passcodeIsEmpty ? Text('设置数字密码') : Text('修改数字密码'),
    );
  }

  void _setPasscode() async {
    var result = await _showPasscodeScreen(PasscodeStep.firstPasscode, '请输入密码');

    if (result == _cancelledValue) return;

    _showPasscodeScreen(PasscodeStep.confirmPasscode, '验证新密码');
  }

  void _resetPasscode() async {
    await _showPasscodeScreen(PasscodeStep.resetPasscode, '请输入旧密码');

    if (_passcodeValid) {
      _setPasscode();
    }
  }

  Future _showPasscodeScreen(PasscodeStep step, String title) {
    _currentStep = step;

    return Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _passcodeScreen(title),
      ),
    );
  }

  /*
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: authReason,
          androidAuthStrings: authAndroidStrings,
          useErrorDialogs: true,
          stickyAuth: true);
      if (authenticated) {
        /*
        Prefs.setFingerprintLogin();
        setState(() {
          _enabledFingerprintLogin = true;
          _enabledPasscodeLogin = false;
        });
        */
        setState(() {
          _enabledBiometricsLogin = true;
        });
        _updateLoginMethod();
      }
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
  }
  */

  void _onPasscodeEntered(String enteredPasscode) {
    _passcodeValid = false;

    if (_currentStep == PasscodeStep.firstPasscode) {
      _firstPasscode = enteredPasscode;
      _passcodeValid = true;
    } else if (_currentStep == PasscodeStep.resetPasscode) {
      _passcodeValid = (enteredPasscode == Prefs.passcode);

      if (!_passcodeValid) {
        DialogUtils.showToast('密码不正确');
      }
    } else if (_currentStep == PasscodeStep.confirmPasscode) {
      _passcodeValid = enteredPasscode == _firstPasscode;
      if (_passcodeValid) {
        _confirmPasscode = enteredPasscode;
      } else {
        DialogUtils.showToast('验证密码不一致');
      }
    }

    _verificationNotifier.add(_passcodeValid);
    /*
    if (_currentStep == PasscodeStep.firstPasscode) {
      _showPasscodeScreen(PasscodeStep.confirmPasscode, '验证新密码',
          replacingRoute: true);
    } else if (isValid && (_currentStep == PasscodeStep.resetPasscode)) {
      _showPasscodeScreen(PasscodeStep.firstPasscode, '请输入密码',
          replacingRoute: true);
    }
    */
  }

  void _onPasscodeCancel() {
    Navigator.pop(context, _cancelledValue);
  }

  Widget _biometricsItem() {
    return SwitchListTile(
      value: _enabledBiometricsLogin,
      title: Text('指纹/人脸解锁'),
      onChanged: (value) async {
        if (value) {
          // _authenticate();
          if (await SecurityUtils.checkBiometrics(authReason)) {
            setState(() {
              _enabledBiometricsLogin = true;
            });
            _updateLoginMethod();
          }
        } else {
          /*
          Prefs.resetAutoLogin();
          setState(() {
            _enabledFingerprintLogin = false;
          });
          */
          setState(() {
            _enabledBiometricsLogin = false;
          });
          _updateLoginMethod();
        }
      },
    );
  }

  Widget _passcodeScreen(String title) {
    /*
    return PasscodeScreen(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      passwordDigits: Global.passcodeLength,
      passwordEnteredCallback: _onPasscodeEntered,
      isValidCallback: _authenticationPassed,
      cancelCallback: _onPasscodeCancel,
      cancelButton: Text(
        cancelText,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        semanticsLabel: cancelText,
      ),
      deleteButton: Text(
        deleteText,
        style: const TextStyle(fontSize: 16, color: Colors.white),
        semanticsLabel: deleteText,
      ),
      // cancelLocalizedText: cancelText,
      // deleteLocalizedText: deleteText,
      shouldTriggerVerification: _verificationNotifier.stream,
    );
    */

    return SecurityUtils.passCodeScreen(
      title,
      _verificationNotifier,
      passwordDigits: Global.passcodeLength,
      passwordEnteredCallback: _onPasscodeEntered,
      isValidCallback: _authenticationPassed,
      cancelCallback: _onPasscodeCancel,
    );
  }

  void _authenticationPassed() {
    if (_currentStep == PasscodeStep.confirmPasscode) {
      // print(_confirmPasscode);
      Prefs.savePasscode(_confirmPasscode);
    }
  }

  Widget _passcodeLoginItem() {
    return SwitchListTile(
      value: _enabledPasscodeLogin,
      title: Text('数字解锁'),
      onChanged: (value) {
        if (Prefs.passcodeIsEmpty) {
          DialogUtils.showToast('请先设置数字密码');
          return;
        }

        /*
        if (value) {
          Prefs.setPasscodeLogin();
          setState(() {
            _enabledFingerprintLogin = false;
          });
        }
        */
        setState(() {
          _enabledPasscodeLogin = value;
        });
        _updateLoginMethod();
      },
    );
  }

  void _updateLoginMethod() {
    Prefs.setLoginMethod(_enabledPasscodeLogin, _enabledBiometricsLogin);
  }
}
