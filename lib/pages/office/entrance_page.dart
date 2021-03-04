import 'dart:convert';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/entrance.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/utils.dart';

class EntrancePage extends StatefulWidget {
  @override
  _EntrancePageState createState() => _EntrancePageState();
}

class _EntrancePageState extends State<EntrancePage> {
  final _textStyle = TextStyle(color: Colors.black54);
  final _infoTextStyle = TextStyle(backgroundColor: Colors.blue[50]);

  bool _offStageScan = false;
  bool _offStageDetail = true;
  String _id;
  String _visitorName;
  String _visitorComp;
  String _reason;
  String _inDate;
  String _contactPerson;
  String _contactTel;
  List<MaterialData> _materialList;
  // String _visitorMaterial;
  TextEditingController _materialContr = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('接洽确认'),
        ),
        body: Container(
            width: ScreenUtil().setWidth(750),
            child: Column(
              children: <Widget>[
                _scanningCode(),
                _entranceDetail(context),
              ],
            )),
      ),
    );
  }

  Widget _scanningCode() {
    return Offstage(
        offstage: _offStageScan,
        child: Container(
          margin: EdgeInsets.only(top: ScreenUtil().setWidth(350)),
          child: Column(children: <Widget>[
            Text(
              '请扫描访客证二维码',
              style: TextStyle(fontSize: 20, color: Colors.black54),
            ),
            Container(height: 10),
            InkWell(
              onTap: () async {
                var scannerResult = await BarcodeScanner.scan(
                  options: ScanOptions(strings: scanOptionsStrings),
                );
                var kgsno = scannerResult.rawContent.toString();
                if (!Utils.textIsEmpty(kgsno)) {
                  _requestDetail(kgsno);
                }
              },
              child: Container(
                height: 60,
                width: 150,
                decoration: BoxDecoration(
                    color: Colors.blue, borderRadius: BorderRadius.circular(5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.crop_free,
                      size: 30,
                      color: Colors.white,
                    ),
                    customText(value: '扫一扫', fontSize: 20, color: Colors.white)
                  ],
                ),
              ),
            )
          ]),
        ));
  }

  Widget _entranceDetail(context) {
    return Offstage(
        offstage: _offStageDetail,
        child: Container(
          margin: EdgeInsets.only(top: 30),
          child: Column(children: <Widget>[
            Text(
              '接洽信息',
              style: TextStyle(color: Colors.blue, fontSize: 23),
            ),
            _visitorInfo(),
            _contactInfo(context),
            _bottoms(),
          ]),
        ));
  }

  Widget _visitorInfo() {
    return Container(
      padding: EdgeInsets.all(10),
      width: ScreenUtil().setWidth(750),
      margin: EdgeInsets.fromLTRB(10, 15, 10, 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(width: 1, color: Colors.blue)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '来访姓名 ', style: _textStyle),
                  TextSpan(
                    text: _visitorName,
                    style: _infoTextStyle,
                  )
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '来访单位 ', style: _textStyle),
                  TextSpan(text: _visitorComp, style: _infoTextStyle),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '理由 ', style: _textStyle),
                  TextSpan(text: _reason, style: _infoTextStyle),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '入厂时间 ', style: _textStyle),
                  TextSpan(text: _inDate, style: _infoTextStyle),
                ],
              ),
            )
          ]),
    );
  }

  Widget _contactInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: ScreenUtil().setWidth(750),
      margin: EdgeInsets.fromLTRB(10, 5, 10, 15),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(width: 1, color: Colors.blue)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '接洽人姓名 ', style: _textStyle),
                  TextSpan(text: _contactPerson, style: _infoTextStyle),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '接洽人手机号码 ', style: _textStyle),
                  TextSpan(text: _contactTel, style: _infoTextStyle),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: ScreenUtil().setSp(8)),
              child: Row(
                children: <Widget>[
                  Text('出厂携带物品 ', style: _textStyle),
                  Expanded(
                    child: Container(
                      height: 28,
                      child: TextField(
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          controller: _materialContr,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.blue[50],
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          )),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10))),
                              context: context,
                              builder: (context) {
                                return Container(
                                  height: ScreenUtil().setHeight(350),
                                  child: ListView.builder(
                                      itemCount: _materialList.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            _materialContr.text =
                                                _materialList[index].material;
                                          },
                                          child: Center(
                                            child: Container(
                                                margin: EdgeInsets.only(
                                                    top: ScreenUtil().setSp(25),
                                                    bottom:
                                                        ScreenUtil().setSp(25)),
                                                child: Text(
                                                  _materialList[index].material,
                                                  style: _textStyle,
                                                )),
                                          ),
                                        );
                                      }),
                                );
                              });
                        },
                        child: Icon(
                          Icons.search,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ))
                ],
              ),
            ),
          ]),
    );
  }

  Widget _bottoms() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      Expanded(
          child: Container(
              margin: EdgeInsets.only(
                left: ScreenUtil().setSp(60),
                right: ScreenUtil().setSp(30),
              ),
              child: FlatButton(
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                onPressed: () {
                  // Navigator.of(context).pop();
                  setState(() {
                    _offStageScan = false;
                    _offStageDetail = true;
                  });
                },
                child: Text('取消',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ))),
      Expanded(
          child: Container(
              margin: EdgeInsets.only(
                left: ScreenUtil().setSp(30),
                right: ScreenUtil().setSp(60),
              ),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                color: Colors.green,
                child: Text('确认接洽',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                onPressed: () {
                  _requestComfirm();
                },
              ))),
    ]);
  }

  void _requestDetail(String kgsno) async {
    Map<String, dynamic> map = {
      'action': 'get-entrance-visitor-v2',
      'kgsno': kgsno
    };
    await request(serviceUrl[entranceUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data);
      EntranceModel entranceModel = EntranceModel.fromJson(responseData);
      setState(() {
        if (entranceModel.hasData) {
          _offStageScan = true;
          _offStageDetail = false;
          _id = entranceModel.entryList[0].id;
          _visitorName = entranceModel.entryList[0].visitorName;
          _visitorComp = entranceModel.entryList[0].visitorComp;
          _reason = entranceModel.entryList[0].reason;
          _inDate = entranceModel.entryList[0].inDate;
          _contactPerson = entranceModel.entryList[0].contactPerson;
          _contactTel = entranceModel.entryList[0].contactTel;
          _materialContr.text = entranceModel.entryList[0].visitorMaterial;
          _materialList = entranceModel.materialList;
          // _visitorMaterial = entranceModel.entryList[0].visitorMaterial;
        } else {
          if (entranceModel.materialList == null) {
            Fluttertoast.showToast(msg: "扫码未成功", gravity: ToastGravity.CENTER);
          } else {
            Fluttertoast.showToast(msg: "没有接洽数据", gravity: ToastGravity.CENTER);
          }
        }
      });
    });
  }

  void _requestComfirm() async {
    Map<String, dynamic> map = {
      'action': 'finish-entrance-visitor',
      'id': _id,
      'material': _materialContr.text
    };
    await request(serviceUrl[entranceUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      if (responseData['ErrCode'] == 0) {
        Fluttertoast.showToast(msg: "接洽确认成功", gravity: ToastGravity.CENTER);
        setState(() {
          _offStageScan = false;
          _offStageDetail = true;
        });
      } else {
        var errMsg = responseData['ErrMsg'].toString();
        Fluttertoast.showToast(msg: errMsg, gravity: ToastGravity.CENTER);
      }
    });
  }
}
