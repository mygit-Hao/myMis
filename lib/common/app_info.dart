import 'package:package_info/package_info.dart';

class AppInfo {
  // static const String _versionTag = 'mis_';

  static String _appVersion;
  static String _appBuildNumber;
  static String _appName;

  static Future<void> getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    // String appName = packageInfo.appName;
    // String packageName = packageInfo.packageName;

    _appVersion = packageInfo.version;
    _appBuildNumber = packageInfo.buildNumber;
    _appName = packageInfo.appName;
  }

  /*
  static set appVersion(String version) {
    _appVersion = _versionTag + version;
  }
  */

  static String get appVersion {
    return _appVersion;
  }

  static String get appBuildNumber {
    return _appBuildNumber;
  }

  static String get appFullVersion {
    return '$_appVersion.$_appBuildNumber';
  }

  static String get appName {
    return _appName;
  }
}
