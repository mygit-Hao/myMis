import 'dart:io';

import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/pages/office/work_clock/work_clock.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OutOfRangeClockPage extends StatefulWidget {
  @override
  _OutOfRangeClockPageState createState() => _OutOfRangeClockPageState();
}

class _OutOfRangeClockPageState extends State<OutOfRangeClockPage> {
  // bool _isFirst = true;
  FLToastDefaults _toastDefaults = FLToastDefaults();
  List<File> _imageList = [];
  ProgressDialog _progressDialog;
  File _imgfile;
  // List<IconData> _exampIconList = [
  //   ConstValues.icon_person,
  //   ConstValues.icon_environ
  // ];
  // List<String> _exampleList = ["自拍照", "环境照"];
  TextEditingController _reasonController = new TextEditingController();
  // List<GlobalKey> _globalKeyList = [];

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '正在上传...');
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        // Fluttertoast.showToast(msg: "需上传一张自拍照和环境照");
        Utils.closeInput(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('范围外打卡'),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.all(10),
                child: InkWell(
                  onTap: () {
                    _addPhote();
                  },
                  child: Icon(Icons.camera),
                ))
          ],
        ),
        body: FLToastProvider(
          defaults: _toastDefaults,
          child: Container(
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _location(),
                  _customext('原因:'),
                  _reason(),
                  _customext('照片:'),
                  _photes(),
                  _customext('样版:'),
                  _example(),
                  Row(
                    children: [customButtom(Colors.blue, '打卡', _request)],
                  )
                  // _buttonFinish()
                ],
              )),
        ),
      ),
    );
  }

  ///当前位置
  Widget _location() {
    return Container(
      width: ScreenUtil().setWidth(750),
      padding: EdgeInsets.all(5),
      color: Colors.blue[50],
      child: Text(
        "当前位置：" + ClockStaticData.address,
        style: TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }

  //原因
  Widget _reason() {
    return Container(
        // margin: EdgeInsets.only(top:8),
        child: Row(
      children: <Widget>[
        Container(
            padding: EdgeInsets.all(10),
            color: Colors.white,
            width: ScreenUtil().setWidth(750),
            height: ScreenUtil().setHeight(300),
            child: TextField(
              style: TextStyle(
                  fontSize: 16, color: Color.fromRGBO(45, 45, 45, 45)),
              maxLines: 10,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: '不在有效范围内打卡,需填写原因'),
              controller: _reasonController,
            )),
      ],
    ));
  }

  Widget _customext(String text, {Color color}) {
    return Container(
      // width: ScreenUtil().setWidth(750),
      padding: EdgeInsets.fromLTRB(5, 5, 0, 2),
      child: Text(
        text,
        style: TextStyle(color: color ?? Colors.black),
      ),
    );
  }

  Widget _photes() {
    return Expanded(
      child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          width: ScreenUtil().setWidth(750),
          height: ScreenUtil().setHeight(650),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 5, crossAxisSpacing: 5, crossAxisCount: 3),
              itemCount: _imageList.length + 1,
              itemBuilder: (context, index) {
                return _itemPhote(index);
              })),
    );
  }

  ///单个照片
  Widget _itemPhote(int index) {
    return (index != _imageList.length)
        ? Stack(fit: StackFit.expand, children: [
            InkWell(
                onTap: () async {
                  // 截取图片生成一张新的图片
                  // RenderRepaintBoundary boundary =
                  //     _globalKeyList[index].currentContext.findRenderObject();
                  // ui.Image image = await boundary.toImage(pixelRatio: 10.0);
                  // ByteData byteData =
                  //     await image.toByteData(format: ui.ImageByteFormat.png);
                  // Uint8List pngBytes = byteData.buffer.asUint8List();
                  // _imageList[index] =
                  //     await File(_imageList[index].path).writeAsBytes(pngBytes);
                  Utils.closeInput(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ViewPhoto(null, _imageList[index]);
                  }));
                },
                child: Image.file(
                  _imageList[index],
                  fit: BoxFit.cover,
                )),
            Positioned(
              top: 0,
              right: 0,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      _imageList.removeAt(index);
                    });
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.white,
                  )),
            )
          ])
        : Container(
            color: Colors.grey[50],
            child: InkWell(
              onTap: () {
                _addPhote();
              },
              // child: _imageList.length == 0
              //     ? _backIcon(ConstValues.icon_person, "自拍照")
              //     : (_imageList.length == 1
              //         ? _backIcon(ConstValues.icon_environ, "环境照")
              //         : Icon(Icons.add, color: Colors.grey[400], size: 40)),
              child: Icon(Icons.add, color: Colors.grey[400], size: 40),
            ),
          );
  }

  //样例
  Widget _example() {
    return Expanded(
      // child: customWebView(serviceUrl[clockModelUrl]),
      child: InAppWebView(
        initialUrl: serviceUrl[clockModelUrl],
        initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(supportZoom: true),
            android: AndroidInAppWebViewOptions(
              builtInZoomControls: true,
              loadWithOverviewMode: false,
            )),
        onWebViewCreated: (InAppWebViewController controller) {
          // ctrl = controller;
        },
      ),
    );
  }

  ///添加照片
  void _addPhote() async {
    if (_imageList.length == 0) {
      await Fluttertoast.showToast(
          msg: "请上传一张自拍照",
          gravity: ToastGravity.CENTER,
          // textColor: Colors.red,
          fontSize: 16.0,
          toastLength: Toast.LENGTH_LONG);
    } else {
      await Fluttertoast.showToast(
          msg: "请上传一张环境照",
          gravity: ToastGravity.CENTER,
          // textColor: Colors.red,
          fontSize: 16.0,
          toastLength: Toast.LENGTH_LONG);
    }

    var imageFile = await Utils.takePhote();
    if (imageFile != null) {
      _imgfile = imageFile;
      // _globalKeyList.add(GlobalKey(debugLabel: _imgfile.path));
      _imageList.add(_imgfile);
      setState(() {});
    }
  }

  ///照片上传到服务器
  void _request() async {
    if (_reasonController.text == '') {
      toastBlackStyle('不在有效范围内打卡，需要填写原因!');
    } else if (_imageList.length < 2) {
      toastBlackStyle('不在有效范围内打卡，需上传两张及其以上照片!');
    } else {
      // var dismiss = FLToast.loading(text: 'Loading...');
      Utils.closeInput(context);
      await _progressDialog.show();
      Map responseData = await WorkClockService.requestOutofRangeClock(
          ClockStaticData.clockKind,
          ClockStaticData.longitude,
          ClockStaticData.latitude,
          ClockStaticData.address,
          _imageList.length,
          _reasonController.text,
          _imageList[0].path);
      if (responseData['ErrCode'] == 0) {
        var clockrecid = responseData['ExtraData'];
        for (int i = 1; i < _imageList.length; i++) {
          //循环上传后面的图片
          var result = await WorkClockService.requestUploadPhotes(
              clockrecid, _imageList.length, i + 1, _imageList[i].path);
          if (result['ErrCode'] != 0) {
            // dismiss();
            await _progressDialog.hide();
            var msg = result['ErrMsg'];
            DialogUtils.showAlertDialog(context, msg);
            return;
          } else {
            if (i == _imageList.length - 1) {
              // dismiss();
              await _progressDialog.hide();
              toastBlackStyle("打卡成功");
              Navigator.pop(context);
            }
          }
        }
      } else {
        // dismiss();
        await _progressDialog.hide();
        DialogUtils.showAlertDialog(context, responseData['ErrMsg']);
      }
    }
  }
}
