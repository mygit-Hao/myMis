import 'dart:convert';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/sevens_basedb.dart';
import 'package:mis_app/model/sevens_dept_deduct_list.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_group_page.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sevens_check_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SevenSDetailPage extends StatefulWidget {
  final Map arguments;
  const SevenSDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _SevenSDetailPageState createState() => _SevenSDetailPageState();
}

class _SevenSDetailPageState extends State<SevenSDetailPage> {
  final inputDecoration = InputDecoration(
      contentPadding: EdgeInsets.only(left: 10, right: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
      ));

  int _detailSpotId = 0;
  int _photoFileId;
  int _deptId;
  int _spotId;
  // String _deptValue;
  // String _spotValue;
  DateTime _limitData = DateTime.now().add(Duration(days: 7));
  String _imageUrl;
  // String _imagePath;
  File _imageFile;

  bool _offStageAddPhoto = false;
  bool _offStageClean = true;
  bool _isAbsorbing = false;
  // bool _offStageButton=false;

  List<Dept> _deptList = [];
  List<Spot> _spotList = [];

  DetailSpot _detailSpot;
  TextEditingController _detailSpotControll = new TextEditingController();
  TextEditingController _discribeControll = new TextEditingController();
  TextEditingController _deductControl = new TextEditingController(text: "1");

  FocusNode _detailSpotFN = new FocusNode();
  FocusNode _discribleFN = new FocusNode();
  FocusNode _deductFn = new FocusNode();

  final List<DropdownMenuItem> _depDropDowntItems = [];
  final List<DropdownMenuItem> _spotDropDownItems = [];

  ProgressDialog _progressDialog;
  @override
  void initState() {
    super.initState();
    if (this.widget.arguments == null) {
      _getDeptDropDown();
      // _deptId = _deptList[0].deptId;
      _getSpotDropDown();
      // _spotId = _spotList[0].spotId;
      _offStageClean = true;
    } else {
      var spotdate = this.widget.arguments;
      _detailSpot = DetailSpot.fromJson(spotdate);
      setState(() {
        (StaticData.status == 5) ? _isAbsorbing = false : _isAbsorbing = true;
        _detailSpotId = _detailSpot.detailSpotId;
        _deptId = _detailSpot.deptId;
        _getDeptDropDown();
        _getSpotDropDown();
        // _deptValue = _detailSpot.deptName;
        _spotId = _detailSpot.spotId;
        // _spotValue = _detailSpot.spotName;
        _detailSpotControll.text = _detailSpot.spotRemarks;
        _discribeControll.text = _detailSpot.remarks;
        _limitData = _detailSpot.rectifyDate;
        _deductControl.text = _detailSpot.deduct.toString();
        _photoFileId = _detailSpot.photoFileId;
        _imageUrl = Utils.getImageUrl(_photoFileId);
        _offStageAddPhoto = true;
        _offStageClean = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, "保存中...");
    return WillPopScope(
      onWillPop: _willPop,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          title: Text('缺陷详细'),
          actions: <Widget>[
            StaticData.status < 10
                ? InkWell(
                    onTap: () {
                      _scanner();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.crop_free),
                    ),
                  )
                : Container()
          ],
        ),
        body: SafeArea(
            child: Container(
          color: Colors.white,
          // padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Column(
            children: <Widget>[
              AbsorbPointer(
                absorbing: _isAbsorbing,
                child: Column(children: <Widget>[
                  _deptSelect(),
                  _spotSelect(),
                  _spotRemarks(),
                  _discript(),
                  Container(
                    child: _limitDataAndDeduct(),
                  ),
                ]),
              ),
              _addPhote(),
              _photo(),
              _buttoms(),
            ],
          ),
        )),
      ),
    );
  }

  void _scanner() async {
    var data = await BarcodeScanner.scan(
      options: ScanOptions(strings: scanOptionsStrings),
    );
    if (data.rawContent == '') return;
    int startIndex = data.rawContent.lastIndexOf(":");
    var type = data.rawContent.substring(0, startIndex);
    // var data = "7s / spot_id : 40";
    // int startIndex = data.lastIndexOf(":");
    // var type = data.substring(0, startIndex);
    if (type == '7s / spot_id ') {
      var spotId = data.rawContent.substring(startIndex + 1);
      _getDeptId(int.parse(spotId));
    } else {
      DialogUtils.showToast('该二维码不是7S 地点二维码', toastLength: Toast.LENGTH_LONG);
    }
  }

  void _getDeptId(int spotId) {
    var allSpotList = SevensBaseDBModel.baseDBModel.spotList;
    for (var element in allSpotList) {
      if (spotId == element.spotId) {
        var deptId = element.deptId;
        var result = _isSelectAreaGroup(deptId);
        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>" + result.toString());
        if (result) {
          setState(() {
            _deptId = deptId;
            _getSpotDropDown();
            _spotId = element.spotId;
          });
          return;
        }
      }
    }
    DialogUtils.showToast('该地点不属于所选择的区域');
  }

  //判断该扫描的地点是不是选择区域的部门和地点
  bool _isSelectAreaGroup(int deptId) {
    // _deptList.forEach((element) {
    //   if (deptId == element.deptId) return true;
    // });
    for (var element in _deptList) {
      if (deptId == element.deptId) {
        return true;
      }
    }
    return false;
  }

  //退出提示
  Future<bool> _willPop() async {
    bool willpop = true;
    if (_detailSpotId == 0) {
      willpop = await DialogUtils.showConfirmDialog(context, "正在新增编辑,是否退出?",
          iconData: Icons.info, color: Colors.blue);
    }
    return willpop;
  }

  //部门下拉列表
  Widget _deptSelect() {
    return _customContainer(
      child: Row(
        children: <Widget>[
          Text('部门：'),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(bottom: 2),
            child: DropdownButton(
              // isDense: true,
              isExpanded: true,
              underline: Container(
                color: Colors.blue,
                height: 0.0,
              ),
              hint: Text("请选择部门"),
              value: _deptId,
              icon: Icon(Icons.arrow_drop_down,
                  color: _isAbsorbing ? Colors.grey : Colors.blue),
              items: _depDropDowntItems,
              onChanged: (v) {
                setState(() {
                  // _deptValue = v;
                  // _getDpetId(_deptValue);
                  _deptId = v;
                  _getSpotDropDown();
                  _spotId = _spotList[0].spotId;
                  // _spotValue = _spotList[0].spotName;
                  // print(_spotId);
                });
              },
            ),
          )),
        ],
      ),
    );
  }

  //区域
  Widget _spotSelect() {
    return _customContainer(
      child: Row(
        children: <Widget>[
          Text('区域：'),
          Expanded(
              child: Container(
            margin: EdgeInsets.only(bottom: 2),
            child: DropdownButton(
              // isDense: true,
              isExpanded: true,
              underline: Container(
                color: Colors.blue,
                height: 0.0,
              ),
              value: _spotId,
              hint: Text("请选择区域"),
              icon: Icon(Icons.arrow_drop_down,
                  color: _isAbsorbing ? Colors.grey : Colors.blue),
              items: _spotDropDownItems,
              onChanged: (v) {
                setState(() {
                  // _spotValue = v;
                  // _getSpotId(_spotValue);
                  _spotId = v;
                });
              },
            ),
          )),
        ],
      ),
    );
  }

  //详细地点
  Widget _spotRemarks() {
    return _customContainer(
        child: Row(
      children: <Widget>[
        Text('详细地点：'),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: 4, bottom: 4),
            height: 35,
            child: TextField(
              autofocus: false,
              focusNode: _detailSpotFN,
              style: TextStyle(
                  color: _isAbsorbing ? Colors.black54 : Colors.black,
                  fontSize: 15.5),
              controller: _detailSpotControll,
              decoration: InputDecoration(
                hintText: "请输入详细地点(选填)",
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding: EdgeInsets.only(left: 2),
                border: OutlineInputBorder(borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ],
    ));
  }

  //描述
  Widget _discript() {
    return _customContainer(
      child: Row(
        children: <Widget>[
          // customText(value: '*', color: Colors.red),
          Text('缺陷描述：'),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: 4, bottom: 4),
              height: 45,
              child: TextField(
                autofocus: false,
                focusNode: _discribleFN,
                style: TextStyle(
                    color: _isAbsorbing ? Colors.black54 : Colors.black,
                    fontSize: 15.5),
                controller: _discribeControll,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "请选择或输入检查缺陷(必填)",
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: EdgeInsets.only(left: 2),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          Container(
            child: InkWell(
              onTap: () async {
                _nodeUnFocus();
                var result =
                    await Navigator.pushNamed(context, sevensTempletePath);
                if (result == null) return;
                if (_discribeControll.text == '') {
                  _discribeControll.text = result;
                } else {
                  _discribeControll.text =
                      _discribeControll.text + " , " + result.toString();
                }
              },
              child: Container(
                padding: EdgeInsets.only(left: 5),
                child: Icon(
                  Icons.search,
                  color: _isAbsorbing ? Colors.black54 : Colors.blue,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customContainer({Widget child}) {
    return Container(
      margin: EdgeInsets.only(top: 1),
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        // color: Colors.grey[100],
        border: Border(bottom: BorderSide(width: 0.2, color: Colors.grey[100])),
      ),
      child: child,
    );
  }

  //限期改善日期
  Widget _limitDataAndDeduct() {
    return _customContainer(
        child: Container(
      padding: EdgeInsets.only(top: 2, bottom: 6),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Text('限期改善日期:'),
          Expanded(
            flex: 3,
            child: InkWell(
              onTap: () {
                _nodeUnFocus();
                showDatePicker(
                        context: context,
                        initialDate: _limitData,
                        firstDate: defaultFirstDate,
                        lastDate: defaultLastDate)
                    .then((value) {
                  setState(() {
                    if (value == null) {
                      return;
                    }
                    _limitData = value;
                  });
                }).catchError((err) {
                  print(err);
                });
              },
              child: Container(
                margin: EdgeInsets.only(left: 2),
                padding: EdgeInsets.all(4),
                decoration: timePickDecoration,
                child: Text(
                  Utils.dateTimeToStrWithPattern(_limitData, 'yyyy-MM-dd'),
                  style: TextStyle(
                    fontSize: 16,
                    // color: _isAbsorbing ? Colors.black : Colors.orange,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 4, left: 10),
            child: Text('扣'),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(3),
              height: ScreenUtil().setHeight(65),
              child: TextField(
                focusNode: _deductFn,
                autofocus: false,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    // color: _isAbsorbing ? Colors.black : Colors.red,
                    color: Colors.red),
                controller: _deductControl,
                decoration: textFieldDecorationNoBorder(),
              ),
            ),
          ),
          Text('分'),
        ],
      ),
    ));
  }

  //添加相片
  Widget _addPhote() {
    return Offstage(
        offstage: _offStageAddPhoto,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              InkWell(
                onTap: () {
                  showModalBottomSheet(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      context: context,
                      builder: (context) {
                        return Container(
                          height: ScreenUtil().setHeight(200),
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  _nodeUnFocus();
                                  var file = await Utils.takePhote();
                                  if (file == null) return;
                                  setState(() {
                                    _imageFile = file;
                                    _offStageAddPhoto = true;
                                    _offStageClean = false;
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('拍照')),
                                    padding: EdgeInsets.all(10)),
                              ),
                              InkWell(
                                onTap: () async {
                                  _nodeUnFocus();
                                  var file =
                                      await Utils.takePhote(fromPhote: true);
                                  if (file == null) return;
                                  setState(() {
                                    _imageFile = file;
                                    _offStageAddPhoto = true;
                                    _offStageClean = false;
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('相册')),
                                    padding: EdgeInsets.all(10)),
                              ),
                              // FlatButton(
                              //   onPressed: () {},
                              //   child: Container(
                              //     color: Colors.blue,
                              //     child: Text('关闭'),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      });
                },
                child: Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ));
  }

  //相片显示
  Widget _photo() {
    //  var result= ServensCheckService.getthumb(_photoFileId,'getthumb');
    //  print(result);
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(top: 5, bottom: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Offstage(
                offstage: _offStageClean,
                child: Container(width: 30, child: null)),
            _imageUrl == null && _imageFile == null
                ? Center(child: Text('拍照或者选择相册'))
                : Expanded(
                    child: InkWell(
                      onTap: () {
                        _nodeUnFocus();
                        Navigator.of(context).push(
                            CustomRoute(ViewPhoto(_imageUrl, _imageFile)));
                      },
                      child: (_imageFile == null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.network(_imageUrl),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Image.file(_imageFile),
                            )),
                    ),
                  ),
            Offstage(
              offstage: _offStageClean,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _imageFile = null;
                    _offStageAddPhoto = false;
                    _offStageClean = true;
                  });
                },
                child: Icon(Icons.clear, color: Colors.red, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttoms() {
    return Offstage(
      offstage: _isAbsorbing,
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Flex(
          direction: Axis.horizontal,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 40, right: 25),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () async {
                    var result = await DialogUtils.showConfirmDialog(
                        context, "是否删除该项检查缺陷？",
                        iconData: Icons.warning, color: Colors.red);
                    if (result) {
                      delete(_detailSpotId);
                    }
                  },
                  color: Colors.red,
                  child: Text(
                    '删除',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 25, right: 40),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.blue,
                  child: Text(
                    '保存',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    _saveMethod();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _getDeptDropDown() {
    _depDropDowntItems.clear();
    var areaGroupId = StaticData.areaGroupId;
    var allDeptList = SevensBaseDBModel.baseDBModel.deptList;
    if (StaticData.isAllDept) {
      allDeptList.forEach((item) {
        if (StaticData.areaId == item.areaId) {
          _deptList.add(item);
          _depDropDowntItems.add(
            DropdownMenuItem(
              child: Container(
                margin: EdgeInsets.only(bottom: 3),
                child: Text(
                  item.deptName,
                  style: TextStyle(
                      color: _isAbsorbing ? Colors.black54 : Colors.black,
                      fontSize: 16),
                ),
              ),
              value: item.deptId,
            ),
          );
        }
      });
    } else {
      allDeptList.forEach(
        (item) {
          if (areaGroupId == item.areaGroupId) {
            _deptList.add(item);
            _depDropDowntItems.add(
              DropdownMenuItem(
                child: Container(
                  // margin: EdgeInsets.only(bottom: 2),
                  child: Text(
                    item.deptName,
                    style: TextStyle(
                        color: _isAbsorbing ? Colors.black54 : Colors.black,
                        fontSize: 16),
                  ),
                ),
                value: item.deptId,
              ),
            );
          }
        },
      );
    }
  }

  void _getSpotDropDown() {
    _spotDropDownItems.clear();
    _spotList.clear();
    var allSpotList = SevensBaseDBModel.baseDBModel.spotList;
    allSpotList.forEach((item) {
      if (_deptId == item.deptId) {
        _spotList.add(item);
        _spotDropDownItems.add(
          DropdownMenuItem(
            child: Container(
              // padding: EdgeInsets.only(bottom: 2),
              child: Text(
                item.spotName,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: _isAbsorbing ? Colors.black54 : Colors.black,
                    fontSize: 16),
              ),
            ),
            value: item.spotId,
          ),
        );
      }
    });
  }

  // void _getDpetId(String deptName) {
  //   _deptList.forEach((item) {
  //     if (deptName == item.deptName) {
  //       _deptId = item.deptId;
  //     }
  //   });
  // }

  // void _getSpotId(String spotName) {
  //   _spotList.forEach((item) {
  //     if (spotName == item.spotName) {
  //       _spotId = item.spotId;
  //     }
  //   });
  // }

  void delete(int detailCheckId) async {
    setPageDataChanged(this.widget, true);
    Map<dynamic, dynamic> result =
        await SevensCheckService.deleteDetailCheck(detailCheckId);
    print(jsonEncode(result));
    if (result['ErrCode'] == 0) {
      // DialogUtils.showConfirmDialog(context, "删除成功!");
      // Navigator.of(context).pop();
      Fluttertoast.showToast(msg: "删除成功！", gravity: ToastGravity.CENTER);
      Navigator.of(context).pop();
    } else {
      DialogUtils.showConfirmDialog(context, result['ErrMsg'].toString());
    }
  }

  void _saveMethod() async {
    if (_spotId == null) {
      DialogUtils.showToast('扣分区域不能为空！');
      return;
    } else if (_discribeControll.text == "") {
      DialogUtils.showToast("缺陷描述不能为空！");
      return;
    } else if (_deductControl.text == "") {
      DialogUtils.showToast("扣分不能为空！");
      return;
    }
    setPageDataChanged(this.widget, true);
    Map map = {
      // "checkId": StaticData.checkId,
      "deduct": _deductControl.text,
      "deptId": _deptId,
      "rectifyDate": _limitData.toString(),
      "remarks": _discribeControll.text,
      "spotId": _spotId,
      "spotRemarks": _detailSpotControll.text
    };
    RequestResult result;
    if (_detailSpotId == 0) {
      if (_imageFile == null) {
        DialogUtils.showToast("上传图片不能为空！");
        return;
      }
      await _progressDialog.show();
      map.addAll({"checkId": StaticData.checkId});
      result = await SevensCheckService.requestDetailData("add_detail", map,
          filePath: _imageFile.path);
      _progressDialog.hide();
      if (result.data['ErrCode'] != 0) {
        DialogUtils.showAlertDialog(context, result.data['ErrMsg']);
      } else {
        DialogUtils.showAlertDialog(context, "保存成功，可继续添加记录");
        setState(() {
          _detailSpotId = 0;
          _discribeControll.text = "";
          _detailSpotControll.text = "";
          _imageFile = null;
          _imageUrl = null;
          _offStageAddPhoto = false;
          _offStageClean = true;
        });
      }
    } else {
      await _progressDialog.show();
      map.addAll({"checkDetailSpotId": _detailSpotId});
      result = await SevensCheckService.requestDetailData("update_detail", map);
      _progressDialog.hide();
      if (result.data['ErrCode'] != 0) {
        DialogUtils.showAlertDialog(context, result.data['ErrMsg']);
      } else {
        DialogUtils.showToast("修改成功");
      }
    }
  }

  // int _setCompressQuality(int size) {
  //   int quality = 15;
  //   if (size < 1000000) {
  //     quality = 40;
  //   } else if (1000000 <= size && size <= 2000000) {
  //     quality = 15;
  //   } else if (size > 2000000) {
  //     quality = 10;
  //   }
  //   print(">>>>>>>>>>>>>>>>>>>>>>>压缩质量:$quality");
  //   return quality;
  // }

  //返回界面聚焦，不聚焦弹出键盘
  void _nodeUnFocus() {
    _detailSpotFN.unfocus();
    _discribleFN.unfocus();
    _deductFn.unfocus();
  }
}

class CustomRoute extends PageRouteBuilder {
  Widget widget;
  CustomRoute(this.widget)
      : super(
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (BuildContext context, Animation<double> animation1,
                Animation<double> animation2) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: animation1, curve: Curves.linear)),
                child: FadeTransition(
                    opacity: Tween(begin: 0.0, end: 2.0).animate(
                      CurvedAnimation(parent: animation1, curve: Curves.linear),
                    ),
                    child: child),
              );
            });
}
