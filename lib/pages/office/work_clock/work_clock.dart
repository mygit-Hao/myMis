import 'dart:async';
import 'dart:io';

import 'package:amap_location_fluttify/amap_location_fluttify.dart';
import 'package:amap_map_fluttify/amap_map_fluttify.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';

class WorkOclockPage extends StatefulWidget {
  @override
  _WorkOclockPageState createState() => _WorkOclockPageState();
}

class _WorkOclockPageState extends State<WorkOclockPage> {
  // double _latitude = 0.0;
  // double _longitude = 0.0;
  Timer _timer;
  DateTime _dateTime = DateTime.now();
  File _imageFile;

  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _initkey();
    _getLocation();
  }

  @override
  void dispose() {
    // _stopListenAndTimer();
    // AmapLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '正在上传...');
    if (_timer == null) {
      _updateTime();
    }
    return WillPopScope(
        onWillPop: _stopListenAndTimer,
        child: Scaffold(
          appBar: AppBar(
            title: Text("打卡"),
            actions: <Widget>[
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return WebViewPage(
                      arguments: {
                        'title': '打卡',
                        'url': serviceUrl[clockHelpUrl]
                      },
                    );
                  }));
                },
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Icon(Icons.help_outline),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, historyClockListPath);
                },
                child: Container(
                    padding: EdgeInsets.all(10), child: Icon(Icons.history)),
              )
            ],
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                // Text("test"),
                Expanded(
                  child: _amapView(),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  // color: Colors.white,
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '当前位置：',
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: ClockStaticData.address,
                        style: TextStyle(color: Colors.blue),
                      )
                    ]),
                    // "当前位置：" + ClockStaticData.address,
                    // style: TextStyle(color: Colors.blue),
                    // overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: Text(
                    Utils.dateTimeToStrWithPattern(_dateTime, "HH:mm"),
                    style: TextStyle(fontSize: 27),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                          child: FlatButton(
                        // color: Colors.blue,
                        onPressed: () {
                          // _stopListenAndTimer();
                          ClockStaticData.clockKind = 1;
                          _requestClock(1);
                        },
                        child: Text(
                          "上班",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                      Expanded(
                          child: FlatButton(
                        // color: Colors.green,
                        onPressed: () {
                          // _stopListenAndTimer();
                          Navigator.pushNamed(context, visitCustomerPath);
                        },
                        child: Text(
                          "拜访客户",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )),
                      Expanded(
                        child: FlatButton(
                          // color: Colors.blue,
                          onPressed: () {
                            ClockStaticData.clockKind = 2;
                            _requestClock(2);
                            // _workClock();
                          },
                          child: Text(
                            "下班",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _amapView() {
    return AmapView(
      mapType: MapType.Standard,
      maskDelay: const Duration(milliseconds: 500),
      showZoomControl: true,
      showCompass: true,
      showScaleControl: true,
      zoomGesturesEnabled: true,
      rotateGestureEnabled: true,
      zoomLevel: 17,
      // centerCoordinate: LatLng(39, 116),
      onMapCreated: (controller) async {
        var permission = await _requestPermission();
        if (permission) {
          await controller.showMyLocation(MyLocationOption(
              show: true, myLocationType: MyLocationType.Follow));
        }
      },
    );
  }

  Future<bool> _requestPermission() async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
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

  ///获取权限、监听位置改变
  void _getLocation() async {
    try {
      bool permission = await _requestPermission();
      if (permission) {
        await for (final lacation in AmapLocation.instance.listenLocation()) {
          setState(() {
            ClockStaticData.address = lacation.poiName ?? '';
            ClockStaticData.latitude = lacation.latLng.latitude;
            ClockStaticData.longitude = lacation.latLng.longitude;
            print('正在监听位置————————————————————');
          });
        }
      }
    } catch (e) {
      print(e.toString());
      toastBlackStyle(e.toString());
    }
  }

  ///停止定位、关闭计时器
  Future<bool> _stopListenAndTimer() async {
    if (await _requestPermission()) {
      await AmapLocation.instance.stopLocation();
      _timer.cancel();
    }
    return true;
  }

  ///计时器、每10秒刷新一下时间
  void _updateTime() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      setState(() {
        print(t.toString());
        _dateTime = DateTime.now();
        print(_dateTime.toString());
      });
    });
  }

  void _requestClock(int clockKind) async {
    //判断打卡是否在有效范围
    bool isValid = await WorkClockService.isValidClockRange(
        clockKind, ClockStaticData.longitude, ClockStaticData.latitude);
    if (isValid) {
      ///拍照压缩
      await Fluttertoast.showToast(
          msg: "请上传一张自拍照",
          gravity: ToastGravity.CENTER,
          fontSize: 16.0,
          toastLength: Toast.LENGTH_LONG);
      var imageFile = await Utils.takePhote();
      if (imageFile != null) {
        _imageFile = imageFile;
        //访问服务器打卡
        await _progressDialog.show();
        Map responseData;
        try {
          responseData = await WorkClockService.requestClock(
              clockKind,
              ClockStaticData.longitude,
              ClockStaticData.latitude,
              ClockStaticData.address,
              _imageFile.path);
        } finally {
          await _progressDialog.hide();
        }
        var errCode = responseData['ErrCode'];
        if (errCode == 0) {
          toastBlackStyle('打卡成功');
          // Navigator.pushNamed(context, historyClockListPath);
        } else {
          var errMsg = responseData['ErrMsg'].toString();
          DialogUtils.showAlertDialog(context, "打卡失败" + errMsg);
        }
      }
    } else {
      Navigator.pushNamed(context, outOfRangeClockPath);
    }
  }
}

class ClockStaticData {
  static int clockKind;
  static String address = '';
  static double longitude = 0.0;
  static double latitude = 0.0;
  static int clockId;
}
