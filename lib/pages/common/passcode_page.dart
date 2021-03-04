import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/pages/index_page.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/security_utils.dart';

class PasscodePage extends StatefulWidget {
  PasscodePage({Key key}) : super(key: key);

  @override
  _PasscodePageState createState() => _PasscodePageState();
}

class _PasscodePageState extends State<PasscodePage> {
  final StreamController<bool> _verificationNotifier =
      StreamController<bool>.broadcast();

  @override
  void dispose() {
    _verificationNotifier.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*
      body: PasscodeScreen(
        title: Text(
          '请输入密码',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
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
      ),
      */
      body: SecurityUtils.passCodeScreen(
        '请输入密码',
        _verificationNotifier,
        passwordEnteredCallback: _onPasscodeEntered,
        isValidCallback: _authenticationPassed,
        cancelCallback: _onPasscodeCancel,
      ),
    );
  }

  void _onPasscodeCancel() {
    UserProvide().logout(keepSetting: true);
    _navigateToHome();
  }

  _onPasscodeEntered(String enteredPasscode) {
    bool isValid = (Prefs.passcode == enteredPasscode);
    _verificationNotifier.add(isValid);
    if (!isValid) {
      DialogUtils.showToast('密码不正确');
    }
  }

  _authenticationPassed() {
    _navigateToHome();
  }

  void _navigateToHome() {
    // 使用Navigator.of(context).pushNamedAndRemoveUntil()不成功
    // 可能是MaterialApp的onGenerateRoute未生效
    // 使用 pushAndRemoveUntil() 比 pushReplacement() 要好，因为可以保证清除所有路由
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) {
      return IndexPage();
    }), (Route<dynamic> route) => false);
  }
}
