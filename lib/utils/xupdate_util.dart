import 'dart:io';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:mis_app/config/service_url.dart';

class XUpdateUtil {
  static String _updateUrl = serviceUrl[updateUrl];

  ///初始化
  static void initXUpdate() {
    if (Platform.isAndroid) {
      FlutterXUpdate.init(

              ///是否输出日志
              debug: true,

              ///是否使用post请求
              isPost: false,

              ///post请求是否是上传json
              isPostJson: false,

              ///是否开启自动模式
              isWifiOnly: false,

              ///是否开启自动模式
              isAutoMode: false,

              ///需要设置的公共参数
              supportSilentInstall: false,

              ///在下载过程中，如果点击了取消的话，是否弹出切换下载方式的重试提示弹窗
              enableRetry: false)
          .then(
        (value) {
          print("初始化成功: $value");
          // 为防止签名提醒与升级提示同时出现（签名提示需旋转屏幕，与升级提示冲突），改在登录后再检查版本升级
          // checkUpdate();
        },
      ).catchError(
        (error) {
          print(error);
        },
      );

      FlutterXUpdate.setUpdateHandler(
        onUpdateError: (Map<String, dynamic> message) async {
          print(message);
          //下载失败
          /*
          if (message["code"] == 4000) {
            FlutterXUpdate.showRetryUpdateTipDialog(
                retryContent: "Github被墙无法继续下载，是否考虑切换蒲公英下载？",
                retryUrl: "https://www.pgyer.com/flutter_learn");
          }
          */
        },
      );
    } else {
      print("ios暂不支持XUpdate更新");
    }
  }

  static void checkUpdate() {
    FlutterXUpdate.checkUpdate(url: _updateUrl);
  }

  static bool isNewVersion(String currentVersion, String targetVersion) {
    const String versionSplitter = '.';
    bool isNew = false;

    List<String> currentVersionList = currentVersion.split(versionSplitter);
    List<String> targetVersionList = targetVersion.split(versionSplitter);

    for (var i = 0; i < targetVersionList.length; i++) {
      int ver1 = int.tryParse(targetVersionList[i]) ?? 0;
      int ver2 = 0;
      if (currentVersionList.length > i) {
        ver2 = int.tryParse(currentVersionList[i]) ?? 0;
      }

      if (ver1 > ver2) {
        isNew = true;
        break;
      } else if (ver1 < ver2) {
        break;
      }
    }

    return isNew;
  }
}
