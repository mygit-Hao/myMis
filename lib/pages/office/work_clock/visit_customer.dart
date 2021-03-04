import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/pages/office/work_clock/work_clock.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class VisitCustomerPage extends StatefulWidget {
  @override
  _VisitCustomerPageState createState() => _VisitCustomerPageState();
}

class _VisitCustomerPageState extends State<VisitCustomerPage> {
  final _textStyle =
      TextStyle(color: Color.fromARGB(190, 45, 45, 45), fontSize: 15);

  int _custId;
  int _customerKindId;
  String _customerName = '（未选定客户）';
  String _contactPerson = '';
  String _photeNum = '';
  String _remarks = '';
  String _reportData = '';
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _remarks = Prefs.getVisitReportStr(Prefs.keyVIsitReportStr) ?? '';
    var test = Prefs.getVisitReportList(Prefs.keyVisitReportList);
    _reportData = test == null ? '' : jsonEncode(test);
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text("拜访客户"),
      ),
      body: Container(
        color: Colors.grey[100],
        // padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            _custonInfo(),
            Text(
              '拜访报告',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, reportEditPath).then((value) {
                    var result =
                        Prefs.getVisitReportStr(Prefs.keyVIsitReportStr);
                    var selectList =
                        Prefs.getVisitReportList(Prefs.keyVisitReportList);
                    var reportData = jsonEncode(selectList);
                    setState(() {
                      _remarks = result;
                      _reportData = reportData;
                    });
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(6),
                  color: Colors.white,
                  width: ScreenUtil().setWidth(750),
                  margin: EdgeInsets.only(top: 4),
                  // decoration: BoxDecoration(
                  //   border: Border.all(color: Colors.blue, width: 1),
                  //   borderRadius: BorderRadius.circular(5),
                  // ),
                  child: Text(_remarks, style: _textStyle),
                ),
              ),
            ),
            _buttons(),
          ],
        ),
      ),
    );
  }

  ///客户相关信息
  Widget _custonInfo() {
    return Column(children: <Widget>[
      Container(
        // width: ScreenUtil().setWidth(750),
        padding: EdgeInsets.only(top: 8, bottom: 3),
        child: Text(
          "当前位置：" + ClockStaticData.address,
          style: TextStyle(color: Colors.blue, fontSize: 16),
        ),
      ),
      Container(
        color: Colors.white,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.only(top: 3, bottom: 6),
        // decoration: BoxDecoration(
        //     border: Border.all(color: Colors.blue, width: 1),
        //     borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              // padding: EdgeInsets.only(top: 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.business_center,
                    color: Colors.blue,
                    size: 16,
                  ),
                  Expanded(
                    child: Text(
                      " 客户：" + _customerName,
                      style: _textStyle,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      _selectCustomer();
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            _customerInfoRow(Icons.person, Colors.blue, ' 联系人：$_contactPerson'),
            _customerInfoRow(Icons.phone, Colors.orange, ' 电话：$_photeNum'),
          ],
        ),
      )
    ]);
  }

  Widget _customerInfoRow(IconData iconData, Color color, String str) {
    return Container(
      padding: EdgeInsets.only(top: 6),
      child: Row(
        children: <Widget>[
          Icon(iconData, color: color, size: 16),
          Expanded(
            child: Text(
              str,
              overflow: TextOverflow.ellipsis,
              style: _textStyle,
            ),
          )
        ],
      ),
    );
  }

  ///选择客服
  void _selectCustomer() {
    Navigator.pushNamed(context, customerSelectPath).then((value) {
      if (value == null) return;
      Map map = value;
      bool isNew = map['isNew'];
      _customerKindId = isNew ? 2 : 1;
      setState(() {
        _custId = map['CustId'];
        _customerName = map['Name'];
        _contactPerson = map['ContactPerson'];
        _photeNum = isNew ? map['ContactPersonTel'] : map['ContactTel'];
      });
    });
  }

  Widget _buttons() {
    return Container(
        // padding: EdgeInsets.only(left: 8, right: 8),
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Expanded(
        //   child: Container(
        //     margin: EdgeInsets.all(5),
        //     child: FlatButton(
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(5)),
        //       color: Colors.blue,
        //       onPressed: () {
        //         Navigator.pushNamed(context, reportEditPath).then((value) {
        //           var result =
        //               Prefs.getVisitReportStr(Prefs.keyVIsitReportStr);
        //           var selectList =
        //               Prefs.getVisitReportList(Prefs.keyVisitReportList);
        //           var reportData = jsonEncode(selectList);
        //           setState(() {
        //             _remarks = result;
        //             _reportData = reportData;
        //           });
        //         });
        //       },
        //       child: Text(
        //         "编写报告",
        //         style: TextStyle(color: Colors.white),
        //       ),
        //     ),
        //   ),
        // ),
        // Expanded(
        //   child: Container(
        //     margin: EdgeInsets.all(5),
        //     child: FlatButton(
        //       color: Colors.green,
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(5)),
        //       onPressed: () {
        //         _takePhoteAndClock();
        //       },
        //       child: Text(
        //         "送出打卡",
        //         style: TextStyle(color: Colors.white),
        //       ),
        //     ),
        //   ),
        // )
        customButtom(Colors.blue, '打卡', _takePhoteAndClock)
      ],
    ));
  }

  void _takePhoteAndClock() async {
    if (_customerName == '（未选定客户）') {
      toastBlackStyle("还未选择客户");
    } else if (_remarks == '') {
      toastBlackStyle("拜访报告不能为空");
    } else {
      var file = await Utils.takePhote();
      if (file != null) _requestVisitCustClock(file.path);
    }
  }

  ///拜访客户打卡
  void _requestVisitCustClock(filePath) async {
    try {
      _progressDialog.show();
      Map responseData;
      var file = await MultipartFile.fromFile(filePath, filename: filePath);
      Map<String, dynamic> map = {
        'action': 'clock-new',
        'clockkindid': 3,
        'longitude': ClockStaticData.longitude,
        'latitude': ClockStaticData.latitude,
        'address': ClockStaticData.address,
        'datakindid': _customerKindId,
        'relativeid': _custId,
        'relativeinfo': _customerName,
        'remarks': _remarks,
        'contentdata': _reportData,
        "FileUpload": file,
      };
      FormData formData = FormData.fromMap(map);
      await request(serviceUrl[workClockUrl], data: formData).then((value) {
        _progressDialog.hide();
        responseData = jsonDecode(value.data.toString());
        if (responseData['ErrCode'] == 0) {
          toastBlackStyle('打卡成功');
          Prefs.saveVisitReportStr(Prefs.keyVIsitReportStr, '');
          Prefs.saveVisitReportList(Prefs.keyVisitReportList, []);
          Navigator.pop(context);
        } else {
          var errMsg = responseData['ErrMsg'];
          DialogUtils.showAlertDialog(context, errMsg);
        }
      });
    } finally {}
  }
}
