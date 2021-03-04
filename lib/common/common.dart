import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mis_app/common/app_info.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/download_result.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/model/notification.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/file_service.dart';
import 'package:mis_app/service/general_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/utils/xupdate_util.dart';
import 'package:open_file/open_file.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provide/provide.dart';
import 'package:url_launcher/url_launcher.dart';

enum LoginStatus {
  logout,
  offLine,
  onLine,
}

final List<MobileFunction> allFunctions = [];

/*
void initScreenUtil(BuildContext context) {
  // ScreenUtil.init(context, width: screenWidth, height: screenHeight);
  ScreenUtil.init(context,
      designSize: Size(screenWidth, screenHeight), allowFontScaling: false);
}
*/

ProgressDialog getProgressDialog(BuildContext context,
    {String message = loadingMessage, bool isDismissible = true}) {
  ProgressDialog progressDialog =
      ProgressDialog(context, isDismissible: isDismissible);

  progressDialog.style(
    message: message,
    progressWidget: Center(
      child: CircularProgressIndicator(),
    ),
  );

  return progressDialog;
}

Image getFileIcon(String fileExt) {
  int fileType = _getFileType(fileExt);

  switch (fileType) {
    case fileTypePhoto:
      return ConstValues.imagePhoto;
    case fileTypePdf:
      return ConstValues.imagePdf;
    case fileTypeWord:
      return ConstValues.imageWord;
    case fileTypeExcel:
      return ConstValues.imageExcel;
    case fileTypePpt:
      return ConstValues.imagePpt;
    case fileTypeRar:
      return ConstValues.imageRar;
    case fileTypeZip:
      return ConstValues.imageZip;
    case fileTypeAudio:
      return ConstValues.imageAudio;
    case fileTypeVideo:
      return ConstValues.imageVideo;
    default:
      return ConstValues.imageFile;
  }
}

int _getFileType(String fileExt) {
  if (Utils.sameText(fileExt, 'bmp') ||
      Utils.sameText(fileExt, 'wmf') ||
      Utils.sameText(fileExt, 'emf') ||
      Utils.sameText(fileExt, 'gif') ||
      Utils.sameText(fileExt, 'jpg') ||
      Utils.sameText(fileExt, 'jpeg') ||
      Utils.sameText(fileExt, 'tif') ||
      Utils.sameText(fileExt, 'psd') ||
      Utils.sameText(fileExt, 'pcx') ||
      Utils.sameText(fileExt, 'ttf') ||
      Utils.sameText(fileExt, 'png') ||
      Utils.sameText(fileExt, 'ico')) {
    return fileTypePhoto;
  }

  if (Utils.sameText(fileExt, 'pdf')) {
    return fileTypePdf;
  }

  if (Utils.sameText(fileExt, 'doc') || Utils.sameText(fileExt, 'docx')) {
    return fileTypeWord;
  }

  if (Utils.sameText(fileExt, 'xls') || Utils.sameText(fileExt, 'xlsx')) {
    return fileTypeExcel;
  }

  if (Utils.sameText(fileExt, 'ppt') || Utils.sameText(fileExt, 'pptx')) {
    return fileTypePpt;
  }

  if (Utils.sameText(fileExt, 'rar')) {
    return fileTypeRar;
  }

  if (Utils.sameText(fileExt, 'zip')) {
    return fileTypeZip;
  }

  if (Utils.sameText(fileExt, 'wav') ||
      Utils.sameText(fileExt, 'wma') ||
      Utils.sameText(fileExt, 'mp3')) {
    return fileTypeAudio;
  }

  if (Utils.sameText(fileExt, 'avi') ||
      Utils.sameText(fileExt, 'mp4') ||
      Utils.sameText(fileExt, 'wmv') ||
      Utils.sameText(fileExt, 'mpg') ||
      Utils.sameText(fileExt, 'mpeg') ||
      Utils.sameText(fileExt, 'mkv')) {
    return fileTypeVideo;
  }

  return fileTypeUnknown;
}

Future<DownloadResultModel> downloadAttachmentWithFileExt(
    int fileId, String fileExt,
    {bool usingCache = true}) async {
  DownloadResultModel result = DownloadResultModel(
      storageFilePath: Global.getFileCachePath(fileId, fileExt));

  bool needDownload = true;

  if (usingCache) {
    bool fileHasData = await Utils.filePathHasData(result.storageFilePath);
    if (fileHasData) {
      // print('文件已存在，不需下载：${result.storageFilePath}');
      needDownload = false;
      result.success = true;
    }
  }

  if (needDownload) {
    if (await FileService.downloadAttachment(fileId, result.storageFilePath)) {
      result.success = true;
    }
  }

  return result;
}

void viewFile(BuildContext context,
    {String storageFilePath, String filePath, String title}) async {
  // File file = File(storageFilePath);
  // bool existed = await file.exists();
  // if (!existed) {
  //   DialogUtils.showToast('文件打开失败，可能已被移动或者删除');
  // }

  bool hasData = await Utils.filePathHasData(storageFilePath);
  if (!hasData) {
    print('文件打开失败：$storageFilePath');
    DialogUtils.showToast('文件打开失败，可能已被移动或者删除');
    return;
  }

  Utils.clearImageCache();

  OpenFile.open(storageFilePath);

  // int fileType = _getFileType(Utils.getFileExt(storageFilePath));
  // Map<String, String> arguments = {
  //   'storageFilePath': storageFilePath,
  //   'filePath': filePath,
  //   'title': title,
  // };

  // switch (fileType) {
  //   case fileTypePhoto:
  //     Navigator.pushNamed(
  //       context,
  //       viewPhotoPath,
  //       arguments: arguments,
  //     );
  //     break;
  //   case fileTypePdf:
  //     Navigator.pushNamed(
  //       context,
  //       viewPdfPath,
  //       arguments: arguments,
  //     );
  //     break;
  //   case fileTypeVideo:
  //     Navigator.pushNamed(
  //       context,
  //       fileViewPath,
  //       arguments: arguments,
  //     );
  //     break;
  //   case fileTypeAudio:
  //     Navigator.pushNamed(
  //       context,
  //       fileViewPath,
  //       arguments: arguments,
  //     );
  //     break;
  //   case fileTypeWord:
  //     Navigator.pushNamed(
  //       context,
  //       fileViewPath,
  //       arguments: arguments,
  //     );
  //     break;
  //   default:
  //     DialogUtils.showToast('暂不支持该类型的查看');
  //     break;
  // }
}

Icon get phoneIcon {
  return Icon(
    Icons.phone,
    color: Colors.lightGreenAccent,
    size: defaultIconSize,
  );
}

void callPhone(String phones) {
  if (Utils.textIsEmptyOrWhiteSpace(phones)) return;

  List<String> list = Utils.getPhoneNumbers(phones);
  if (list.length > 0) {
    launch('tel:${list[0]}');
  }
}

MobileFunction findFunction(List<MobileFunction> list, int functionId) {
  return list.firstWhere(
    (element) => element.mobileFunctionId == functionId,
    orElse: () => null,
  );
}

MobileFunction findFunctionInAll(String name) {
  initAllFunctions();

  MobileFunction result;

  if (!Utils.textIsEmptyOrWhiteSpace(name)) {
    name = name.trim();

    result = allFunctions.firstWhere(
        (element) => Utils.sameText(element.name, name),
        orElse: () => null);
  }

  return result;
}

void initAllFunctions() {
  if (allFunctions.length > 0) return;

  allFunctions
    ..addAll(allHomeFunctions)
    ..addAll(allSalesFunctions)
    ..addAll(allOfficeFunctions)
    ..addAll(allLifeFunctions);
}

void callFunction(BuildContext context, MobileFunction function) {
  // print('点击了功能: ' + function.functionName);

  // 如果在办公功能中，更新最近列表
  if (allOfficeFunctions.any(
      (element) => element.mobileFunctionId == function.mobileFunctionId)) {
    Provide.value<UserProvide>(context)
        .updateRecentFunctions(function.mobileFunctionId);
  }

  /*
  switch (function.mobileFunctionId) {
    case functionIdAttendance:
      Navigator.pushNamed(context, attendancePath);
      break;
    case functionIdApproval:
      Navigator.pushNamed(context, approvalPath);
      break;
    case functionIdSales:
      Navigator.pushNamed(context, salesPath);
      break;
    case functionIdCust:
      Navigator.pushNamed(context, custPath);
      break;
    case functionIdSalesCart:
      Navigator.pushNamed(context, salesCartPath);
      break;
    case functionIdSevenS:
      Navigator.pushNamed(context, sevensPath);
      break;
    case functionIdEntrance:
      Navigator.pushNamed(context, entrancePath);
      break;
    case functionIdOvertime:
      Navigator.pushNamed(context, workOverTimePath);
      break;
    case functionIdPriceSearch:
      Navigator.pushNamed(context, searchPricePath);
      break;
    case functionIdSearchInventory:
      Navigator.pushNamed(context, searchInventoryPath);
      break;
    case functionIdSalesOrder:
      Navigator.pushNamed(context, salesOrderPath);
      break;
    case functionIdworkClock:
      Utils.requestPermissionAndNavigator(context, workClockPath);
      break;
    case functionIdSalesSummary:
      Navigator.pushNamed(context, salesSummaryPath);
      break;
    case functionIdArreage:
      Navigator.pushNamed(context, arrearagePath);
      break;
    case functionIdSampleDelivery:
      Navigator.pushNamed(context, sampleDeliveryPath);
      break;
    case functionIdBusinessReport:
      Navigator.pushNamed(context, businessPath);
      break;
    case functionIdReleaseAskForLeave:
      Navigator.pushNamed(context, askForLeavePath);
      break;
    case functionIdReleasePassRequest:
      Navigator.pushNamed(context, releasePassPath);
      break;
    case functionIdSalesBonusQuery:
      Navigator.pushNamed(context, salesBonusQueryPath);
      break;
    case functionIdboilerFeeding:
      Navigator.pushNamed(context, boilerFeedingPath);
      break;
    case functionIdbottomMaterialLogin:
      Navigator.pushNamed(context, bottomMaterialLoginPath);
      break;
    case functionIdMealBooking:
      Navigator.pushNamed(context, mealBookingPath);
      break;
    case functionIdVehicleRequest:
      Navigator.pushNamed(context, vehicleRequestPath);
      break;
    case functionIdVehicleRequestShift:
      Navigator.pushNamed(context, vehicleRequestPath,
          arguments: {'shifting': true});
      break;
    case functionIdVehicleUserRequest:
      Navigator.pushNamed(context, vehicleUserRequestPath);
      break;
    case functionIdSupplementCard:
      Navigator.pushNamed(context, buCardPath);
      break;
    case functionIdBorrow:
      Navigator.pushNamed(context, borrowPath);
      break;
    case functionIdBusinessPlan:
      Navigator.pushNamed(context, businessPlanListPath);
      break;
    case functionIdReceive:
      Navigator.pushNamed(context, receivePath);
      break;
    case functionIdReleasePass:
      Navigator.pushNamed(context, releasePassCamPath);
      break;
    case functionIdEquipment:
      Navigator.pushNamed(context, deviceDataPath);
      break;
    default:
      print('暂未实现此功能');
      break;
  }
  */
  if (!Utils.textIsEmptyOrWhiteSpace(function.routeName)) {
    if (function.needPermission) {
      Utils.requestPermissionAndNavigator(context, function.routeName);
    } else {
      Navigator.pushNamed(context, function.routeName,
          arguments: function.routeArguments);
    }
  } else {
    print('暂未实现此功能');
  }
}

Color getcustGradeColorByCust(CustModel cust) {
  /*
  if (cust.trade ?? false) {
    switch (cust.grade) {
      case 2:
        return Color(0xFFFF9800);
      case 3:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  return Colors.grey;
  */

  return getcustGradeColor(cust.grade, trade: cust.trade ?? false);
}

Color getcustGradeColor(int grade, {bool trade = true}) {
  if (trade) {
    switch (grade) {
      case 2:
        return Color(0xFFFF9800);
      case 3:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  return Colors.grey;
}

Image logoImage(double height, double width) {
  return Image(
    image: AssetImage('assets/images/logo.png'),
    height: height,
    width: width,
  );
}

void openNotificationFunction(
    BuildContext context, NotificationModel notification) {
  /*
  if (!notification.canOpen) return;

  String routeName;
  Object arguments;
  if (!Utils.textIsEmptyOrWhiteSpace(notification.routeArguments)) {
    arguments = json.decode(notification.routeArguments);
  }

  MobileFunction function = findFunctionInAll(notification.routeName);

  if (function != null) {
    if (Global.hasRight(function)) {
      routeName = function.routeName;
    } else {
      return;
    }
  } else {
    if (routes[notification.routeName] != null) {
      routeName = notification.routeName;
    }
  }

  Navigator.pushNamed(context, routeName, arguments: arguments);
  */
  openFunctionByRoute(
      context, notification.routeName, notification.routeArguments);
}

void openFunctionByRoute(
    BuildContext context, String routeName, String routeArguments) {
  if (Utils.textIsEmptyOrWhiteSpace(routeName)) return;

  MobileFunction function = findFunctionInAll(routeName);

  if (function != null) {
    if (Global.hasRight(function)) {
      routeName = function.routeName;
    } else {
      return;
    }
  } else {
    if (routes[routeName] != null) {
      routeName = routeName;
    }
  }

  Object arguments;
  if (!Utils.textIsEmptyOrWhiteSpace(routeArguments)) {
    arguments = json.decode(routeArguments);
  }

  Navigator.pushNamed(context, routeName, arguments: arguments);
}

void checkAppVersion(BuildContext context, bool needMessage) async {
  bool hasNewVersion = false;

  Map<String, dynamic> result = await GlobalService.getUpdateInfo();
  String versionName =
      (result['iOSVersionName'] ?? result['VersionName']) ?? '';
  dynamic versionCode =
      (result['iOSVersionCode'] ?? result['VersionCode']) ?? 0;
  String fullVersion = '$versionName.$versionCode';
  String updateUrl = result['iOSUpdateUrl'];

  if (!Utils.textIsEmptyOrWhiteSpace(fullVersion) ||
      !Utils.textIsEmptyOrWhiteSpace(updateUrl)) {
    String modifyContent =
        result['iOSModifyContent'] ?? result['ModifyContent'];
    String appFullVersion = AppInfo.appFullVersion;

    // if (fullVersion.compareTo(appFullVersion) > 0)
    if (XUpdateUtil.isNewVersion(appFullVersion, fullVersion)) {
      hasNewVersion = true;

      if (Platform.isIOS) {
        String messageContent = Utils.textIsEmptyOrWhiteSpace(modifyContent)
            ? ''
            : '\n更新内容：$modifyContent';
        if (await DialogUtils.showConfirmDialog(
            context, '发现有新版本 ($fullVersion)!$messageContent\n\n确定要升级吗？',
            confirmTextColor: Colors.orangeAccent, confirmText: '升级')) {
          if (await canLaunch(updateUrl)) {
            await launch(updateUrl);
          }
        }
      } else if (Platform.isAndroid) {
        XUpdateUtil.checkUpdate();
      }
    }
  }

  if ((!hasNewVersion) && needMessage) {
    DialogUtils.showToast('没有更新版本');
  }
}

/// 关闭应用
Future<void> pop() async {
  await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  // 由于iOS调用SystemNavigator.pop可能并不能真正关闭应用，所以使用另一方式关闭应用
  exit(0);
}

/*
ScanDataModel parseScanData(String rawContent) {
  ScanDataModel result = ScanDataModel();
  if (!Utils.textIsEmptyOrWhiteSpace(rawContent)) {
    List<String> list = rawContent.split(':');
    list = list.map((e) => e.trim()).toList();
    if (list.length >= 2) {
      result.type = list[0];
      result.data = list[1];
    }
  }

  return result;
}
*/
