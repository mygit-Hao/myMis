import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/app_info.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/jpush_helper.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/login_info.dart';
import 'package:mis_app/model/login_user.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/utils/utils.dart';

class UserProvide with ChangeNotifier {
  static LoginUserModel _currentUser = LoginUserModel();
  static String _userMd5Password;
  static String _appTitle;
  static List<MobileFunction> _officeFunctions = List<MobileFunction>();
  static List<Map<String, dynamic>> _officeGroupFunctions = List();
  static List<Map<String, dynamic>> _salesGroupFunctions = List();
  static List<MobileFunction> _lifeFunctions = List<MobileFunction>();
  static List<MobileFunction> _homeFunctions = List<MobileFunction>();
  static List<MobileFunction> _salesFunctions = List<MobileFunction>();
  static int _areaId;
  static List<Area> _areaList;
  static List<Area> _oaAreaList;
  static int _countOfUnread = 0;
  /*
  static bool _appLocked = false;

  static bool get appLocked {
    return _appLocked;
  }

  void setAppLocked(bool value) {
    if (value != _appLocked) {
      _appLocked = value;
      notifyListeners();
    }
  }
  */

  static int get countOfUnread {
    return _countOfUnread;
  }

  static void setAreaList(List<Area> list) {
    _areaList = list;
  }

  static List<Area> get areaList {
    return _areaList;
  }

  static void setOaAreaList(List<Area> list) {
    _oaAreaList = list;
  }

  static List<Area> get oaAreaList {
    return _oaAreaList;
  }

  static Area findArea(int areaId) {
    return _areaList.firstWhere((element) => element.areaId == areaId,
        orElse: () => null);
  }

  static Area findOaArea(int areaId) {
    return _oaAreaList.firstWhere((element) => element.areaId == areaId,
        orElse: () => null);
  }

  static LoginUserModel get currentUser {
    return _currentUser;
  }

  static int get oaAreaId {
    return _currentUser.oaAreaId;
  }

  String get appTitle {
    if (Utils.textIsEmptyOrWhiteSpace(_appTitle)) {
      updateAppTitle();
    }
    return _appTitle;
  }

  void updateCountOfUnread(int count) {
    JPushHelper.setBadge(count);

    if (count != _countOfUnread) {
      _countOfUnread = count;
      notifyListeners();
    }
  }

  static void setCountOfUnread(int count) {
    if (count != _countOfUnread) {
      _countOfUnread = count;
    }
  }

  void updateOfficeGroupFunctions() {
    _officeGroupFunctions.clear();

    List<MobileFunction> recentFunctions = Prefs.recentFunctionIds
        .map((e) => findFunction(allOfficeFunctions, e))
        .toList();
    recentFunctions = Global.getOwnedFunctions(recentFunctions);
    if (recentFunctions.length > 0) {
      _officeGroupFunctions.add({
        'name': '最近使用',
        'tag': 1,
        'functions': recentFunctions,
      });
    }

    allOfficeGroupFunctions.forEach((Map<String, dynamic> element) {
      List<MobileFunction> allFunctions = element['functions'];
      /*
      List<MobileFunction> functions = List();
      allFunctions.forEach((MobileFunction item) {
        if (Global.hasRight(item)) {
          functions.add(item);
        }
      });
      */
      List<MobileFunction> functions = Global.getOwnedFunctions(allFunctions);
      if (functions.length > 0) {
        _officeGroupFunctions.add({
          'name': element['name'],
          'tag': 0,
          'functions': functions,
        });
      }
    });
  }

  void _updateSalesGroupFunctions() {
    _salesGroupFunctions.clear();

    allSalesGroupFunctions.forEach((Map<String, dynamic> element) {
      List<MobileFunction> allFunctions = element['functions'];
      List<MobileFunction> functions = Global.getOwnedFunctions(allFunctions);
      if (functions.length > 0) {
        _salesGroupFunctions.add({
          'name': element['name'],
          'functions': functions,
        });
      }
    });
  }

  void updateFunctions() {
    _officeFunctions.clear();
    _lifeFunctions.clear();
    _homeFunctions.clear();
    _salesFunctions.clear();

    /*
    allOfficeFunctions.forEach((MobileFunction item) {
      if (Global.hasRight(item)) {
        _officeFunctions.add(item);
      }
    });

    allLifeFunctions.forEach((MobileFunction item) {
      if (Global.hasRight(item)) {
        _lifeFunctions.add(item);
      }
    });

    allHomeFunctions.forEach((MobileFunction item) {
      if (Global.hasRight(item)) {
        _homeFunctions.add(item);
      }
    });

    allSalesFunctions.forEach((MobileFunction item) {
      if (Global.hasRight(item)) {
        _salesFunctions.add(item);
      }
    });
    */

    updateOfficeGroupFunctions();
    _updateSalesGroupFunctions();

    _officeFunctions = Global.getOwnedFunctions(allOfficeFunctions);
    _lifeFunctions = Global.getOwnedFunctions(allLifeFunctions);
    _homeFunctions = Global.getOwnedFunctions(allHomeFunctions);
    _salesFunctions = Global.getOwnedFunctions(allSalesFunctions);

    notifyListeners();
  }

  static List<MobileFunction> get homeFunctions {
    return _homeFunctions;
  }

  static List<MobileFunction> get officeFunctions {
    return _officeFunctions;
  }

  static List<Map<String, dynamic>> get officeGroupFunctions {
    return _officeGroupFunctions;
  }

  static List<Map<String, dynamic>> get salesGroupFunctions {
    return _salesGroupFunctions;
  }

  static List<MobileFunction> get lifeFunctions {
    return _lifeFunctions;
  }

  static List<MobileFunction> get salesFunctions {
    return _salesFunctions;
  }

  bool setAreaId(int areaId) {
    if (_areaId == areaId) {
      return false;
    }

    _areaId = areaId;
    return true;
  }

  static int get currentAreaIndex {
    int result = -1;

    if (areaList != null) {
      for (var i = 0; i < areaList.length; i++) {
        Area item = areaList[i];
        if (item.areaId == _areaId) {
          result = i;
          break;
        }
      }
    }

    return result;
  }

  static String get currentUserAreaName {
    String areaName = '';

    if (areaList != null) {
      for (Area item in areaList) {
        if (item.areaId == _areaId) {
          areaName = item.shortName;
          break;
        }
      }
    }

    return areaName;
  }

  void updateUserInfo(LoginInfo info, [String password]) {
    // _currentUser.userId = info.userId;
    // _currentUser.userName = info.userName;
    // _currentUser.fullName = info.userDStaffName;
    // _currentUser.setStaffId(info.userDStaffId);
    // _currentUser.setLoginInfo(info);
    setUserInfo(info, password);

    Global.updateOwnedFunctions(info.mobileFunctions);
    updateFunctions();

    updateAppTitle();

    notifyListeners();
  }

  static void setUserInfo(LoginInfo info, [String password]) async {
    if (info.success) {
      Global.layoutResourceKind = info.layoutResourceKind;
      _currentUser.setLoginInfo(info);
      setAreaList(info.areaList);
      setOaAreaList(info.oaAreaList);
      UserProvide().setAreaId(info.loginedAreaId);
      // JPushHelper.setTag(_currentUser.userId);
      DataCache.clearCache();
      LoginStatusProvide().setLoginStatus(
          info.success ? LoginStatus.onLine : LoginStatus.logout);

      if (password != null) {
        updateUserMd5Password(getMd5Password(password));
      }
    }
  }

  void updateRecentFunctions(int functionId) {
    if (Prefs.updateRecentFunctions(functionId)) {
      updateOfficeGroupFunctions();
      notifyListeners();
    }
  }

  static void updateAppTitle() {
    String title = AppInfo.appName;
    if ((areaList != null) && (areaList.length > 0)) {
      String areaName = UserProvide.currentUserAreaName;
      if (!Utils.textIsEmptyOrWhiteSpace(areaName)) {
        title = '$title - $areaName';
      }
    }
    _appTitle = title;
  }

  void updatePasscode(String passcode) {
    Prefs.savePasscode(passcode);

    notifyListeners();
  }

  static String getMd5Password(String password) {
    return Utils.getMd5_16(password);
  }

  void logout({bool keepSetting = false}) {
    // _currentUser.userId = "";
    // _currentUser.userName = "";
    // _currentUser.fullName = "";
    // String oldUserId = _currentUser.userId;
    _currentUser.clearInfo();
    _userMd5Password = "";
    _areaId = 0;
    _countOfUnread = 0;

    Global.clearOwnedFunctions();
    // JPushHelper.deleteTag(oldUserId);

    LoginStatusProvide().setLoginStatus(LoginStatus.logout);

    if (!keepSetting) {
      Prefs.clearUserLogin();
    }

    updateFunctions();

    notifyListeners();
  }

  static String get currentUserId {
    return _currentUser.userId;
  }

  static String get userQrCode {
    return 'mis_user: ${_currentUser.userId}';
  }

  static String get currentUserName {
    return _currentUser.userName;
  }

  static int get currentLoginedAreaId {
    return _areaId;
  }

  static void updateUserMd5Password(String md5Password) {
    _userMd5Password = md5Password;
  }

  static void setCurrentUser(
      String userId, String userName, String md5Password) {
    _currentUser.userId = userId;
    _currentUser.userName = (userName ?? '').trim();
    _userMd5Password = md5Password;
  }

  static String get userToken {
    String token = _currentUser.userId.padRight(10, ' ');
    token = '${token.substring(0, 10)}$_userMd5Password';

    return token;
  }

  static String get displayUserName {
    String displayName = "(未登录)";
    if (userNameIsValid) {
      displayName =
          "${_currentUser.fullName ?? ''} (${Utils.toUpperCaseFirstOne(_currentUser.userName ?? '')})";
    }

    return displayName;
  }

  static bool get userNameIsValid {
    return (_currentUser != null) &&
        (!Utils.textIsEmpty(_currentUser.userName));
  }

  void updateCurrentUserInfo(LoginInfo info) {
    /*
    _currentUser.userId = info.userId;
    _currentUser.userName = info.userName;
    _currentUser.fullName = info.userDStaffName;

    LoginStatusProvide()
        .setLoginStatus(info.success ? LoginStatus.onLine : LoginStatus.logout);

    notifyListeners();
    */
    updateUserInfo(info);
  }

  void refreshCurrentUserInfo() {
    notifyListeners();
  }

  static String get currentUserMd5Password {
    return _userMd5Password;
  }
}
