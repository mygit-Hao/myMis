import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:passcode_screen/passcode_screen.dart';

class SecurityUtils {
  static StreamController<bool> _verificationNotifier;
  static bool _passcodeValid = false;
  static String _checkingPasscode;
  static LocalAuthentication _auth;

  static void dispose() {
    print('dispose');

    if (_verificationNotifier != null) {
      _verificationNotifier.close();
    }
  }

  static Future<bool> checkPasscode(
      BuildContext context, String passcode, String reason) async {
    _passcodeValid = false;
    _checkingPasscode = passcode;
    _initVerication();

    await _showPasscodeScreen(context, reason);

    return _passcodeValid;
  }

  static Future<bool> checkBiometrics(String reason) async {
    if (_auth == null) {
      _auth = LocalAuthentication();
    }
    bool authenticated = false;
    try {
      authenticated = await _auth.authenticateWithBiometrics(
          localizedReason: reason,
          androidAuthStrings: authAndroidStrings,
          useErrorDialogs: true,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print(e);
    }

    return authenticated;
  }

  static void _initVerication() {
    if (_verificationNotifier == null) {
      _verificationNotifier = StreamController<bool>.broadcast();
    }
  }

  static Future _showPasscodeScreen(BuildContext context, String title) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (context, animation, secondaryAnimation) =>
            _passcodeScreen(context, title),
      ),
    );
  }

  static Widget _passcodeScreen(BuildContext context, String title,
      {Function authenticationPassed}) {
    return passCodeScreen(
      title,
      _verificationNotifier,
      passwordDigits: _checkingPasscode.length,
      passwordEnteredCallback: _onPasscodeEntered,
      isValidCallback: authenticationPassed,
      cancelCallback: () {
        _onPasscodeCancel(context);
      },
    );

    /*
    return PasscodeScreen(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      passwordDigits: _checkingPasscode.length,
      passwordEnteredCallback: _onPasscodeEntered,
      isValidCallback: authenticationPassed,
      cancelCallback: () {
        _onPasscodeCancel(context);
      },
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
  }

  static Widget passCodeScreen(
      String title, StreamController<bool> verificationNotifier,
      {int passwordDigits = 6,
      Function(String) passwordEnteredCallback,
      Function isValidCallback,
      Function cancelCallback}) {
    return PasscodeScreen(
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white),
      ),
      passwordDigits: passwordDigits,
      passwordEnteredCallback: passwordEnteredCallback,
      isValidCallback: isValidCallback,
      cancelCallback: cancelCallback,
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
      shouldTriggerVerification: verificationNotifier.stream,
    );
  }

  static _onPasscodeEntered(String enteredPasscode) {
    _passcodeValid = (_checkingPasscode == enteredPasscode);
    _verificationNotifier.add(_passcodeValid);
    if (!_passcodeValid) {
      DialogUtils.showToast('密码不正确');
    }
  }

  static void _onPasscodeCancel(BuildContext context) {
    Navigator.pop(context);
  }
}
