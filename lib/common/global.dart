import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mis_app/common/app_info.dart';
import 'package:mis_app/common/biometrics.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/device_info.dart';
import 'package:mis_app/common/jpush_helper.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/utils/xupdate_util.dart';
import 'package:path_provider/path_provider.dart';

class Global {
  static const String authentication_failed = 'Authentication failed';
  // static const String signature_updated = "SIGNATURE_UPDATED";

  static const int passcodeLength = 6;
  static const double stockQtyWarning = 10.0;
  static const int lockAppAfterInactive = 90;

  static const String jpushAppKey = '51d07a1bc871e0b48b5b1aa2';
  static const String jpushChannel = 'theChannel';

  static const String amapServiceIOSKey = 'fa40639f218bfd4d171a285f57118cb1';
  static const String amapServiceAndroidKey =
      '7232ffe666f70276356b4a460843de29';

  //static int areaId;
  static int layoutResourceKind;

  static const int layoutResourceKindDefault = 0;
  static const int layoutResourceKind1 = 1;

  static String _documentsDir;
  static String _signatureFilePath;
  static String _cacheFilesPath;
  static List<MobileFunction> _ownedFunctions = List<MobileFunction>();
  static BuildContext mainContext;

  static bool get islayoutResourceKind1 {
    return layoutResourceKind == layoutResourceKind1;
  }

  static void updateOwnedFunctions(List<MobileFunction> functions) {
    if (functions == null) return;

    clearOwnedFunctions();
    // _ownedFunctions.addAll(functions);
    functions.forEach((element1) {
      MobileFunction function = allFunctions.firstWhere(
          (element2) => element2.mobileFunctionId == element1.mobileFunctionId,
          orElse: () => null);
      if (function != null) _ownedFunctions.add(function);
    });
  }

  static void clearOwnedFunctions() {
    _ownedFunctions.clear();
  }

  static bool hasRight(MobileFunction function) {
    return _ownedFunctions.any((MobileFunction item) =>
        item.mobileFunctionId == function.mobileFunctionId);
  }

  static bool hasRightForRoute(String routeName) {
    var function = _ownedFunctions.firstWhere((element) {
      if (Utils.sameText(element.routeName, routeName)) return true;

      if ((element.childRoutes != null) && (element.childRoutes.length > 0)) {
        if (element.childRoutes.contains(routeName)) return true;
      }

      return false;
    }, orElse: () => null);

    if (function == null) return false;

    return hasRight(function);
  }

  static List<MobileFunction> getOwnedFunctions(
      List<MobileFunction> fullFunctionList) {
    List<MobileFunction> newList = List();
    fullFunctionList.forEach((MobileFunction item) {
      if (Global.hasRight(item)) {
        newList.add(item);
      }
    });

    return newList;
  }

  static String get signatureFilePath {
    return _signatureFilePath;
  }

  static String get documentsDir {
    return _documentsDir;
  }

  static Map<String, Object> getUserLoginParams(
      String userName, String password) {
    Map<String, Object> params = {
      'action': 'login',
      'username': userName,
      'password': UserProvide.getMd5Password(password),
      'devid': DeviceInfo.devId,
      'version': AppInfo.appVersion,
      'cpu': DeviceInfo.devCpu,
      'areaId': UserProvide.currentLoginedAreaId,
      'push-rid': JPushHelper.registrationId,
    };

    return params;
  }

  static Map<String, Object> getCurrentUserLoginParams() {
    Map<String, Object> params = {
      'action': 'login',
      'username': UserProvide.currentUserName,
      // 'password': _userMd5Password,
      'password': UserProvide.currentUserMd5Password,
      'devid': DeviceInfo.devId,
      'version': AppInfo.appVersion,
      'cpu': DeviceInfo.devCpu,
      'areaId': UserProvide.currentLoginedAreaId,
      'push-rid': JPushHelper.registrationId,
    };

    return params;
  }

  //初始化全局信息
  static Future init() async {
    initAllFunctions();

    await _initCacheFilesDir();

    await _initPaths();
    await Prefs.initPrefs();

    await DeviceInfo.getDeviceInfo();
    await AppInfo.getAppInfo();
    await Biometrics.checkBiometricsInfo();

    XUpdateUtil.initXUpdate();
    // ApprovalService.initApprovaledDaysItems();
  }

  static Future<void> _initCacheFilesDir() async {
    _cacheFilesPath = (await getTemporaryDirectory()).path;
    _cacheFilesPath = '$_cacheFilesPath/files';
    Directory cacheDir = Directory(_cacheFilesPath);
    try {
      bool exists = await cacheDir.exists();
      // print('cacheDir existed: $exists');

      if (!exists) {
        await cacheDir.create();
      }
    } catch (e) {
      print(e);
    }
  }

  static String getFileCachePath(int fileId, String fileExt) {
    String filePath = '$_cacheFilesPath/$fileId';
    if (!Utils.textIsEmptyOrWhiteSpace(fileExt)) {
      filePath = '$filePath.$fileExt';
    }

    return filePath;
  }

  static Future<void> _initPaths() async {
    _documentsDir = (await getApplicationDocumentsDirectory()).path;
    // _signatureFilePath = (await getApplicationDocumentsDirectory()).path;
    // _signatureFilePath = '$_signatureFilePath/signature.png';
    _signatureFilePath = '$_documentsDir/signature.png';
    // print('signatureFilePath: $_signatureFilePath');

    // File file = File(_signatureFilePath);
    // //如果签名文件存在，就删除
    // if (await file.exists()) {
    //   file.delete();
    // }
  }

  static String getUuidKey(String uuid) {
    return Utils.getServerKey([
      UserProvide.currentUser.userId,
      UserProvide.currentUser.tempToken,
      uuid
    ]);
  }
}
