import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';

class LoginStatusProvide with ChangeNotifier {
  static LoginStatus _status;

  void setLoginStatus(LoginStatus status) {
    _status = status;

    notifyListeners();
  }

  static LoginStatus get loginStatus {
    return _status;
  }

  static bool get loggedOut {
    return _status == LoginStatus.logout;
  }

  static bool get onLine {
    return _status == LoginStatus.onLine;
  }
}
