import 'dart:math';

import 'package:mis_app/common/common.dart';
import 'package:mis_app/model/login_user.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const String keyHistorySelectStaff = 'history_select_staff';
  static const String keyHistorySelectUser = 'history_select_user';
  static const String keyHistorySelectCust = 'history_select_cust';
  static const String keyHistorySelectSalesPrice = 'history_select_sales_price';
  static const String keyHistorySearchInventory = 'history_search_inventory';
  static const String keyHistorySearchVehicleRequest =
      'history_search_vehicle_request';
  static const String keyHistorySampleDelivery = 'history_sample_delivery';
  static const String keyVisitReportList = 'visit_report_list';
  static const String keyVIsitReportStr = 'visit_report_string';
  static const String keyHistorySelectDept = 'history_select_dept';
  static const String keyHistorySelectSampleItem = 'history_select_sample_item';
  static const String keySignatureWidth = 'signature_with';
  static const String keySignatureColor = 'signature_color';

  static const String _keyLastLoginUserName = 'last_login_user';
  static const String _keyLastLoginUserId = 'last_login_user_id';
  static const String _keyLastUserMd5Password = 'pwd';
  static const String _keyLoginStatus = 'login_status';
  static const String _keyPasscode = 'passcode';
  static const String _keyLoginMethod = 'login_method';
  static const String _keyApprovaledDaysIndex = 'approvaled_days_index';
  static const String _keyLoginedAreaId = 'logined_area_id';
  static const String _keyRecentFunctions = 'recent_functions';
  static const String _keyBadge = 'badge';

  static const int _loginMethodUndefined = 0;
  static const int _loginMethodPasscode = 1;
  static const int _loginMethodBiometrics = 2;
  static const int _loginMethodTwoFactor = 3;

  static const int _maxRecentFunctionsCount = 8;

  static const int _defaultSignatureWidthIndex = 0;
  static const int _defaultSignatureColorIndex = 1;

  static SharedPreferences _prefs;
  static String _lastLoginUserName;
  static String _lastLoginUserId;
  static String _lastUserMd5Password;
  static LoginStatus _lastLoginStatus;
  static String _passcode;
  static int _loginMethod;
  static List<int> _recentFunctionIds = [];
  static int _badge;

  static int get badge {
    return _badge;
  }

  static void setBadge(int badge) {
    if (badge != _badge) {
      _badge = badge;
      _setPrefsIntValue(_keyBadge, _badge);
    }
  }

  static void _initRecentFunctions() {
    List<String> values = _prefs.getStringList(_keyRecentFunctions);
    if (values != null) {
      _recentFunctionIds = values.map((e) => int.parse(e)).toList();
    }
  }

  static void _removeRecentFunctions() {
    _prefs.remove(_keyRecentFunctions);
    _recentFunctionIds.clear();
  }

  static List<int> get recentFunctionIds {
    return _recentFunctionIds;
  }

  static bool updateRecentFunctions(int functionId) {
    if (functionId <= 0) return false;

    // 如果是第1项就不需要更新，直接返回
    if ((_recentFunctionIds.length > 0) &&
        (_recentFunctionIds[0] == functionId)) return false;

    List<int> newList = [functionId];
    _recentFunctionIds.remove(functionId);
    int len = min(_recentFunctionIds.length, _maxRecentFunctionsCount - 1);
    newList.addAll(_recentFunctionIds.getRange(0, len));
    _recentFunctionIds = newList;

    List<String> list = _recentFunctionIds.map((e) => e.toString()).toList();
    _prefs.setStringList(_keyRecentFunctions, list);

    return true;
  }

  static String getApprovaledDaysIndex() {
    String value = _prefs.getString(_keyApprovaledDaysIndex);
    return value;
  }

  static void setApprovaledDaysIndex(int index) {
    _prefs.setString(_keyApprovaledDaysIndex, index.toString());
  }

  static bool get enabledBiometricsLogin {
    return (_loginMethod == _loginMethodBiometrics) ||
        (_loginMethod == _loginMethodTwoFactor);
  }

  static bool get enabledPasscodeLogin {
    return ((_loginMethod == _loginMethodPasscode) ||
            (_loginMethod == _loginMethodTwoFactor)) &&
        !Utils.textIsEmpty(passcode);
  }

  static bool get passcodeIsEmpty {
    return Utils.textIsEmpty(passcode);
  }

  static String get lastLoginUser {
    return _lastLoginUserName;
  }

  static String get passcode {
    return _passcode;
  }

  static Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _getUserPrefs();
  }

  static int getSignatureWidthIndex() {
    return _getPrefsIntValue(keySignatureWidth, _defaultSignatureWidthIndex);
  }

  static void setSignatureWidthIndex(int widthIndex) {
    _setPrefsIntValue(keySignatureWidth, widthIndex);
  }

  static int getSignatureColorIndex() {
    return _getPrefsIntValue(keySignatureColor, _defaultSignatureColorIndex);
  }

  static void setSignatureColorIndex(int colorIndex) {
    _setPrefsIntValue(keySignatureColor, colorIndex);
  }

  static void _getUserPrefs() {
    _lastLoginUserName = _prefs.getString(_keyLastLoginUserName);
    _lastLoginUserId = _prefs.getString(_keyLastLoginUserId);
    _lastUserMd5Password = _prefs.getString(_keyLastUserMd5Password);
    _passcode = _prefs.getString(_keyPasscode);
    _badge = _getPrefsIntValue(_keyBadge);

    _initRecentFunctions();

    String area = _prefs.getString(_keyLoginedAreaId);
    int areaValue;
    if (area != null) {
      areaValue = int.tryParse(area);
    }
    UserProvide().setAreaId(areaValue ?? 0);

    UserProvide.setCurrentUser(
        _lastLoginUserId, _lastLoginUserName, _lastUserMd5Password);

    String status = _prefs.getString(_keyLoginStatus);
    int statusValue;
    if (status != null) {
      statusValue = int.tryParse(status);
    }
    // print('statusValue: ' + statusValue.toString());
    _lastLoginStatus = statusValue == null
        ? LoginStatus.logout
        : LoginStatus.values[statusValue];

    if (_lastLoginStatus == LoginStatus.onLine) {
      _lastLoginStatus = LoginStatus.offLine;
    }

    _loginMethod = _getPrefsIntValue(_keyLoginMethod);

    // _currentUser.loginStatus = _lastLoginStatus;
    LoginStatusProvide().setLoginStatus(_lastLoginStatus);
    // print('lastLoginStatus: $_lastLoginStatus');

    // print('last login: $lastLogin');
  }

  static void saveLoginedAreaId() {
    int areaId = UserProvide.currentLoginedAreaId;
    _prefs.setString(_keyLoginedAreaId, areaId.toString());
  }

  static void _clearLoginedAreaId() {
    _prefs.remove(_keyLoginedAreaId);
  }

  static Future saveLastLogin(
      LoginUserModel user, String password, LoginStatus status) async {
    String statusValue = status.index.toString();

    String userId = "";
    String userName = "";

    if (user != null) {
      userId = user.userId;
      userName = user.userName;
    }

    _lastLoginUserId = userId;
    _lastLoginUserName = userName;

    // print(statusValue);

    _prefs.setString(_keyLastLoginUserId, userId);
    _prefs.setString(_keyLastLoginUserName, (userName ?? '').trim());
    // _prefs.setString(
    //     _keyLastUserMd5Password, UserProvide.getMd5Password(password));
    updatePassword(password);
    _prefs.setString(_keyLoginStatus, statusValue);

    // print('save last login');
  }

  static void updatePassword(String password) {
    _prefs.setString(
        _keyLastUserMd5Password, UserProvide.getMd5Password(password));
  }

  static Future clearLastLogin() async {
    String statusValue = LoginStatus.logout.index.toString();

    String userId = "";
    String userName = "";

    _lastLoginUserId = userId;
    _prefs.setString(_keyLastLoginUserId, userId);

    _lastLoginUserName = userName;
    _prefs.setString(_keyLastLoginUserName, userName);

    _prefs.setString(_keyLastUserMd5Password, "");
    _prefs.setString(_keyLoginStatus, statusValue);
  }

  static void clearUserLogin() async {
    clearLastLogin();
    removePasscode();
    resetAutoLogin();
    _clearLoginedAreaId();
    _removeRecentFunctions();
  }

  static Future savePasscode(String passcode) async {
    _passcode = passcode;
    _prefs.setString(_keyPasscode, passcode);
  }

  static void removePasscode() {
    savePasscode("");
  }

  // static void setPasscodeLogin() {
  //   _setLoginMethod(_loginMethodPasscode);
  // }

  // static void setFingerprintLogin() {
  //   _setLoginMethod(_loginMethodFingerprint);
  // }

  // static void setTwoFactorLogin() {
  //   _setLoginMethod(_loginMethodTwoFactor);
  // }

  static void setLoginMethod(bool passcodeLogin, bool biometricsLogin) {
    int loginMethod;
    if (passcodeLogin && biometricsLogin) {
      loginMethod = _loginMethodTwoFactor;
    } else if (!passcodeLogin && biometricsLogin) {
      loginMethod = _loginMethodBiometrics;
    } else if (passcodeLogin && !biometricsLogin) {
      loginMethod = _loginMethodPasscode;
    } else {
      loginMethod = _loginMethodUndefined;
    }

    _setLoginMethod(loginMethod);
  }

  static void resetAutoLogin() {
    _setLoginMethod(_loginMethodUndefined);
  }

  static void _setLoginMethod(int loginMethod) async {
    _loginMethod = loginMethod;

    await _setPrefsIntValue(_keyLoginMethod, _loginMethod);
  }

  static int _getPrefsIntValue(String key, [int defaultValue = 0]) {
    int result = defaultValue;
    String value = _prefs.getString(key);
    if (!Utils.textIsEmpty(value)) {
      int i = int.tryParse(value);
      if (i != null) result = i;
    }

    return result;
  }

  static Future _setPrefsIntValue(String key, int value) async {
    _prefs.setString(key, value.toString());
  }

  static void saveSelectHistory(String key, List<String> histories) async {
    await _prefs.setStringList(key, histories);
  }

  static List<String> getSelectHistory(String key) {
    return _prefs.getStringList(key);
  }

  static void saveVisitReportList(String key, List<String> list) async {
    await _prefs.setStringList(key, list);
  }

  static List<String> getVisitReportList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  static void saveVisitReportStr(String key, String str) async {
    await _prefs.setString(key, str);
  }

  static String getVisitReportStr(String key) {
    return _prefs.getString(key) ?? '';
  }

  /*
  static void saveSelectStaffHistory(List<String> histories) async {
    // await _prefs.setStringList(_keyHistorySelectStaff, histories);
    saveSelectHistory(keyHistorySelectStaff, histories);
  }

  static List<String> getSelectStaffHistory() {
    // return _prefs.getStringList(_keyHistorySelectStaff);
    return getSelectHistory(keyHistorySelectStaff);
  }
  */

  // static void setEnabledFingerprint(bool value) async {
  //   _enabledFingerprint = value;

  //   await setPrefsBoolValue(_keyEnabledFingerprint, _enabledFingerprint);
  // }

  // static Future setPrefsBoolValue(String key, bool value) async {
  //   String prefsValue = value ? "1" : "0";
  //   _prefs.setString(key, prefsValue);
  // }

  // static bool _getPrefsBoolValue(String key) {
  //   bool result = false;
  //   String value = _prefs.getString(key);
  //   if (!Utils.textIsEmpty(value)) {
  //     result = (value.trim() == '1');
  //   }

  //   return result;
  // }

}
