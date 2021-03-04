import 'dart:convert';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:permission_handler/permission_handler.dart';

class BottomMaterialLoginPage extends StatefulWidget {
  @override
  _BottomMaterialLoginPageState createState() =>
      _BottomMaterialLoginPageState();
}

class _BottomMaterialLoginPageState extends State<BottomMaterialLoginPage> {
  String _scanCode;
  String _address;
  double _longitude;
  double _latitude;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initkey();
      _getLocation();
    });
  }

  @override
  void dispose() {
    _stopListenLocation();
    super.dispose();
  }

  void _initkey() async {
    await AmapService.init(
      iosKey: Global.amapServiceIOSKey,
      androidKey: Global.amapServiceAndroidKey,
    );

    ///关闭log
    await enableFluttifyLog(false);
    WidgetsFlutterBinding.ensureInitialized();
  }

  ///获取权限
  Future<bool> _requestPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  ///获取位置
  void _getLocation() async {
    if (await _requestPermission()) {
      await for (final location in AmapLocation.instance.listenLocation()) {
        if (mounted)
          setState(() {
            _address = location.address;
            _longitude = location.latLng.longitude;
            _latitude = location.latLng.latitude;
            print('监听中_______________');
          });
      }
    }
  }

  void _stopListenLocation() async {
    if (await _requestPermission()) {
      await AmapLocation.instance.stopLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('底料登录验证'),
      ),
      body: Container(
        width: ScreenUtil().setWidth(750),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                padding: EdgeInsets.all(10),
                child: customText(value: '请扫描二维码登录验证', fontSize: 20)),
            InkWell(
              onTap: () async {
                var result = await BarcodeScanner.scan(
                  options: ScanOptions(strings: scanOptionsStrings),
                );
                _scanCode = result.rawContent;
                if (_scanCode != '') {
                  _loginRequest();
                }
              },
              child: Container(
                height: 60,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.crop_free,
                      size: 30,
                    ),
                    customText(value: '扫一扫', fontSize: 20)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _loginRequest() async {
    Map<String, dynamic> map = {
      'action': 'logincheck',
      'code': _scanCode,
      'longitude': _longitude,
      'latitude': _latitude,
      'address': _address
    };
    print(jsonEncode(map));
    await request(serviceUrl[bottomMaterialLoginUrl], queryParameters: map)
        .then((value) {
      var responseData = jsonDecode(value.data.toString());
      print(responseData);
      if (responseData['ErrCode'] == 0) {
        DialogUtils.showToast('验证成功');
      } else {
        DialogUtils.showToast(responseData['ErrMsg']);
      }
    });
  }
}
