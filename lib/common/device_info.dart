import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:mis_app/utils/utils.dart';

class DeviceInfo {
  static String _devId;
  static String _devCpu;

  static String get devId {
    return _devId;
  }

  static String get devCpu {
    return _devCpu;
  }

  static Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = new DeviceInfoPlugin();
    String devInfoStr;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      _devCpu = androidInfo.supportedAbis.toString();

      // print(_readAndroidBuildData(androidInfo).toString());
      devInfoStr = List.from([
        androidInfo.board,
        androidInfo.brand,
        androidInfo.supportedAbis.toString(),
        androidInfo.device,
        androidInfo.androidId,
        androidInfo.id,
        androidInfo.model,
        androidInfo.tags,
        androidInfo.type
      ]).join('-');
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      _devCpu = iosInfo.utsname.machine;

      // print(_readIosDeviceInfo(iosInfo).toString());
      // devInfoStr = iosInfo.name +
      //     iosInfo.systemName +
      //     iosInfo.systemVersion +
      //     iosInfo.model +
      //     iosInfo.localizedModel +
      //     iosInfo.identifierForVendor +
      //     iosInfo.utsname.sysname +
      //     iosInfo.utsname.nodename +
      //     iosInfo.utsname.release +
      //     iosInfo.utsname.version +
      //     iosInfo.utsname.machine;

      devInfoStr = List.from([
        iosInfo.name,
        iosInfo.systemName,
        iosInfo.systemVersion,
        iosInfo.model,
        iosInfo.localizedModel,
        iosInfo.identifierForVendor,
        iosInfo.utsname.sysname,
        iosInfo.utsname.nodename,
        iosInfo.utsname.release,
        iosInfo.utsname.version,
        iosInfo.utsname.machine
      ]).join('-');
    }

    _devId = Utils.getMd5(devInfoStr);
    // print('DevInfoStr: ' + devInfoStr);
    // print('DevId md5 16:' + Utils.getMd5_16(devInfoStr));
    // print('DevId: ' + Global.devId);
    // print('CPU: ' + Global.devCpu);
  }

  /*
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }
  */
}
