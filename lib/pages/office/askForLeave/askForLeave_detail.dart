import 'dart:convert';
import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/askForLeave.dart';
import 'package:mis_app/model/askForLeaveDetail.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/askForLeave_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/base_container.dart';
import 'package:progress_dialog/progress_dialog.dart';

class AskForLeaveDetailPage extends StatefulWidget {
  @override
  _AskForLeaveDetailPageState createState() => _AskForLeaveDetailPageState();
}

class _AskForLeaveDetailPageState extends State<AskForLeaveDetailPage> {
  TextStyle _textStyle = TextStyle(fontSize: 15.5);
  final _padding = EdgeInsets.only(top: 6, bottom: 6);
  AskForLeaveData _headData = AskForLeaveData();
  bool _needAttanchement = false;
  bool _needOverTime = false;
  List<OverTimeSelectModel> _overTimeList = [];
  List<AskForLeaveAttachments> _attachementList = [];
  List<DropdownMenuItem> _areaDropDownList = [];
  List<DropdownMenuItem> _typeDropDownList = [];
  TextEditingController _contactControl = TextEditingController();
  TextEditingController _dayControl = TextEditingController();
  TextEditingController _hoursControl = TextEditingController();
  TextEditingController _reasonControl = TextEditingController();
  GlobalKey _formKey = new GlobalKey<FormState>();
  ProgressDialog _progressDialog;
  ArrangeData _arrangeData = new ArrangeData();

  @override
  void initState() {
    super.initState();

    if (AskForLeaveSData.askForLeaveId != 0) {
      _getDetailData();
    } else {
      _getDefaltData();
    }

    _getAreaItems();
    _getTypeItems();
  }

  void _getDefaltData() {
    _headData.areaId = AskForLeaveSData.userStaff[0].defaultAreaId;
    _headData.staffId = AskForLeaveSData.userStaff[0].staffId;
    _headData.staffCode = AskForLeaveSData.userStaff[0].staffCode;
    _headData.staffName = AskForLeaveSData.userStaff[0].staffName;
    _headData.deptName = AskForLeaveSData.userStaff[0].deptName;
    _headData.applyDate = Utils.today;
    _headData.beginDate = DateTime.now();
    _headData.endDate = DateTime.now();
    _arrangeData = AskForLeaveSData.arrangeData;
  }

  void _getArrange(bool changed) async {
    int id = _headData.staffId;
    _arrangeData = await AskForLeaveService.getArrange(id);
    print('每日工作时数' + _arrangeData.hours.toString());
    if (_hoursControl.text != '' && changed) {
      double hours = double.parse(_hoursControl.text);
      _arrangeData.hours = _arrangeData.hours == 0 ? 8 : _arrangeData.hours;
      _dayControl.text = (hours / _arrangeData.hours).toStringAsFixed(3);
    }
    setState(() {});
  }

  void _getAreaItems() {
    _areaDropDownList.clear();
    AskForLeaveSData.areaList.forEach((element) {
      _areaDropDownList.add(DropdownMenuItem(
        child: customText(
            value: element.shortName,
            fontSize: 16,
            color: _headData.areaId == element.areaId
                ? Colors.blue
                : Colors.black),
        value: element.areaId,
      ));
    });
  }

  void _getTypeItems() {
    _typeDropDownList.clear();
    AskForLeaveSData.kindList.forEach((element) {
      _typeDropDownList.add(DropdownMenuItem(
          value: element.ncTypeCode,
          child: customText(
              value: element.ncTypeName,
              fontSize: 16,
              color: element.ncTypeCode == _headData.typeCode
                  ? Colors.blue
                  : Colors.black)));
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return BaseContainer(
      parentContext: context,
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title:
                Text(AskForLeaveSData.askForLeaveId == 0 ? '请假单新增' : '请假单编辑'),
          ),
          body: WillPopScope(
            onWillPop: () async {
              if ((_headData.askForLeaveId == null)) {
                if (!(await DialogUtils.showConfirmDialog(context, '确定要退出吗？',
                    confirmText: '退出', confirmTextColor: Colors.red))) {
                  return false;
                }
              }
              return true;
            },
            child: FLToastProvider(
              child: Form(
                key: _formKey,
                // autovalidate: true,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      AbsorbPointer(
                        absorbing: _headData.status >= 10 ? true : false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: _padding,
                              child: Row(
                                children: <Widget>[
                                  _area(),
                                  _status(),
                                ],
                              ),
                            ),
                            _applyDateAndStaff(),
                            Container(padding: _padding, child: _staffInfo()),
                            if (_arrangeData != null) _workHours(),
                            _begin(),
                            _end(),
                            _reason(),
                            Container(
                              padding: _padding,
                              child: Row(
                                children: <Widget>[
                                  // _applyData(),
                                  _contact(),
                                ],
                              ),
                            ),
                            Container(
                              child: Flex(
                                direction: Axis.horizontal,
                                children: <Widget>[
                                  _type(),
                                  _tiaoxiuOrAttachement(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      _needOverTime
                          ? _listView()
                          : (_needAttanchement
                              ? _attachementWidget()
                              : Expanded(child: Container())),
                      _headData.status < 10
                          ? _draftStatusButtons()
                          : (_headData.status == 10
                              ? _submitStatusButton()
                              : Container())
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _area() {
    return Expanded(
      child: Row(
        children: <Widget>[
          Text('项目：'),
          DropdownButton(
              isDense: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: _headData.status < 10 ? Colors.blue : Colors.grey,
              ),
              underline: Container(),
              items: _areaDropDownList,
              value: _headData.areaId,
              onChanged: (value) {
                setState(() {
                  _headData.areaId = value;
                  _getAreaItems();
                });
              })
        ],
      ),
    );
  }

  Widget _status() {
    return Expanded(
        child: Row(
      children: <Widget>[
        Text('状态：'),
        Expanded(
            child: Text(
          _headData.statusName ?? '',
          style: statusTextStyle(_headData.status),
        )),
      ],
    ));
  }

  Widget _applyDateAndStaff() {
    return Container(
      padding: _padding,
      child: Row(
        children: <Widget>[
          _applyData(),
          Expanded(
              child: Row(
            children: <Widget>[
              Text('工号：'),
              customText(value: _headData.staffCode, color: Colors.black),
              InkWell(
                onTap: () async {
                  Utils.closeInput(context);
                  String result = await showSearch(
                      context: context,
                      delegate:
                          SearchStaffDelegate(Prefs.keyHistorySelectStaff));
                  if (result == null || result == '') return;
                  StaffModel staffModel =
                      StaffModel.fromJson(jsonDecode(result));
                  if (_headData.staffId != staffModel.staffId) {
                    _headData.staffCode = staffModel.code;
                    _headData.staffId = staffModel.staffId;
                    _headData.staffName = staffModel.name;
                    _headData.deptName = staffModel.deptName;
                    _contactControl.text = staffModel.phone;
                    _overTimeList.clear();
                    _getArrange(true);
                  }
                },
                child: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
              )
            ],
          )),
        ],
      ),
    );
  }

  Widget _staffInfo() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Text('姓名：'),
              customText(value: _headData.staffName, color: Colors.black),
            ],
          )),
          Expanded(
              child: Row(
            children: <Widget>[
              Text('部门：'),
              customText(value: _headData.deptName, color: Colors.black),
            ],
          )),
        ],
      ),
    );
  }

  Widget _applyData() {
    String applydata = Utils.dateTimeToStr(_headData.applyDate);
    return Expanded(
        child: Row(
      children: <Widget>[
        Text('申请日期：'),
        InkWell(
          // onTap: () {
          //   DialogUtils.showDatePickerDialog(
          //     context,
          //     _headData.applyDate,
          //     onValue: (val) {
          //       if (val == null) return;
          //       setState(() {
          //         _headData.applyDate = val;
          //       });
          //     },
          //   );
          // },
          child: customText(
            value: applydata,
            fontSize: 16,
            // color: Colors.orange,
            // backgroundColor: Colors.orange[50],
          ),
        ),
      ],
    ));
  }

  Widget _customtextField(TextEditingController _controller) {
    return Container(
      height: 30,
      child: TextField(
        maxLines: 1,
        textAlign: TextAlign.center,
        style: _textStyle,
        controller: _controller,
        // inputFormatters: [WhitelistingTextInputFormatter(RegExp("[0-9.]"))],
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
        keyboardType: TextInputType.number,
        decoration: textFieldDecorationNoBorder(),
        onChanged: (v) {
          if (_arrangeData.hours == null) return;
          if (_controller == _hoursControl) {
            double hours =
                _hoursControl.text != '' ? double.parse(_hoursControl.text) : 0;
            _dayControl.text = (hours / _arrangeData.hours).toStringAsFixed(3);
          } else if (_controller == _dayControl) {
            double day = double.parse(_dayControl.text);
            _hoursControl.text = (day * _arrangeData.hours).toStringAsFixed(1);
          }
        },
      ),
    );
  }

  InputDecoration _customDecoratin(String label) {
    return InputDecoration(
      contentPadding: EdgeInsets.all(1),
      labelText: label + ':',
      hintText: '请输入' + label ?? '',
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _begin() {
    String beginDate =
        Utils.dateTimeToStr(_headData.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                Text('开始：'),
                InkWell(
                  onTap: () {
                    _dateAndTimePick(_headData.beginDate, 'begin');
                  },
                  child: customText(
                    value: beginDate,
                    color: Colors.blue,
                    // fontWeight: FontWeight.w600
                    backgroundColor: Color(0x80DFEEFC),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Text('共 '),
                Expanded(child: _customtextField(_dayControl)),
                Text(' 天    ')
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _end() {
    String endDate =
        Utils.dateTimeToStr(_headData.endDate, pattern: 'yyyy-MM-dd HH:mm');
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                Text('结束：'),
                InkWell(
                    onTap: () {
                      _dateAndTimePick(_headData.endDate, 'end');
                    },
                    child: customText(
                      value: endDate,
                      color: Colors.blue,
                      // fontWeight: FontWeight.w600
                      backgroundColor: Color(0x80DFEEFC),
                    )),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Text('共 '),
                Expanded(child: _customtextField(_hoursControl)),
                Text(' 小时')
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _workHours() {
    return _arrangeData.hours != null
        ? Container(
            child: customText(
                value: '工作时数：(${_arrangeData.hours}h/天)', fontSize: 10),
          )
        : Container();
  }

  void _dateAndTimePick(DateTime date, String type) async {
    // var date = _detail.beginDate;
    var time = TimeOfDay.fromDateTime(date);
    var datePick = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: defaultFirstDate,
        lastDate: defaultLastDate);
    if (datePick == null) return;
    var timePick = await showTimePicker(context: context, initialTime: time);
    if (timePick == null) return;
    var result = DateTime(datePick.year, datePick.month, datePick.day,
        timePick.hour, timePick.minute);
    setState(() {
      type == 'begin'
          ? _headData.beginDate = result
          : _headData.endDate = result;
      // Duration diff = _headData.endDate.difference(_headData.beginDate);
      // String hours = (diff.inMinutes / 60).toStringAsFixed(1);
      // _hoursControl.text = hours;
      // _dayControl.text = (diff.inMinutes / 60 / 8).toStringAsFixed(3);
    });
  }

  Widget _reason() {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          // Text('原因：'),
          Expanded(
            child: Container(
              // height: 30,
              child: TextFormField(
                // autovalidate: true,
                maxLines: 1,
                style: _textStyle,
                controller: _reasonControl,
                decoration: _customDecoratin('请假原因'),
                validator: (v) {
                  return v.length > 0 ? null : '请输入请假原因';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contact() {
    var format = MaskTextInputFormatter(mask: '### #### #### ####');
    return Expanded(
      child: Row(
        children: <Widget>[
          // Text('电话：'),
          Expanded(
              child: Container(
            // height: 30,
            child: TextFormField(
              style: _textStyle,
              controller: _contactControl,
              keyboardType: TextInputType.phone,
              inputFormatters: [format],
              decoration: _customDecoratin('联系电话'),
              validator: (v) {
                return v.trim().length > 7 ? null : '电话号码不能少于7位';
              },
            ),
          ))
        ],
      ),
    );
  }

  Widget _type() {
    return Expanded(
      flex: 2,
      child: Row(
        children: <Widget>[
          Text('类型：'),
          Expanded(
              child: Container(
            padding: EdgeInsets.all(1),
            decoration: containerDeroation(),
            child: DropdownButton(
                onTap: () {
                  Utils.closeInput(context);
                },
                isDense: true,
                underline: Container(),
                hint: customText(value: '请选择'),
                value: _headData.typeCode,
                items: _typeDropDownList,
                onChanged: (value) {
                  _headData.typeCode = value;
                  AskForLeaveKind askForLeaveKind = _getTypeItem(value);
                  setState(() {
                    _needAttanchement = askForLeaveKind.needAttachment;
                    _needOverTime = askForLeaveKind.needOverTime;
                    // _getTypeItems();
                  });
                }),
          ))
        ],
      ),
    );
  }

  AskForLeaveKind _getTypeItem(String typeCode) {
    AskForLeaveKind askForLeaveKind;
    AskForLeaveSData.kindList.forEach((element) {
      if (typeCode == element.ncTypeCode) {
        askForLeaveKind = element;
      }
    });
    return askForLeaveKind;
  }

  Widget _tiaoxiuOrAttachement() {
    double hours = _getTotalTimeOfTiaoxiu();
    return Expanded(
      flex: 3,
      child: _needOverTime
          ? Container(
              margin: EdgeInsets.only(left: 10),
              child: Row(
                children: <Widget>[
                  Text('共调休:'),
                  customText(
                      value: ' $hours ',
                      color: Colors.blue,
                      backgroundColor: Colors.blue[50]),
                  Text('小时'),
                  customButtom(Colors.blue, '调休', _overtimetx),
                ],
              ),
            )
          : (_needAttanchement
              ? Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Icon(
                        Icons.attachment,
                        color: Colors.blue,
                        size: 30,
                      ),
                    ),
                  ],
                )
              : Container()),
    );
  }

  double _getTotalTimeOfTiaoxiu() {
    double time = 0.0;
    _overTimeList.forEach((element) {
      time += element.usedHours;
    });
    return time;
  }

  void _overtimetx() {
    Utils.closeInput(context);
    AskForLeaveSData.staffId = _headData.staffId;
    Navigator.pushNamed(context, overTimeSelectPath,
        arguments: {'list': _overTimeList}).then((value) {
      OverTimeSelectModel overTimeSelectModel = value;
      overTimeSelectModel.totalUsedHours = overTimeSelectModel.usedHours;
      overTimeSelectModel.usedHours = 0;
      setState(() {
        if (value != null) {
          _overTimeList.add(value);
        }
      });
    });
  }

  Widget _listView() {
    Divider divider = Divider(
      height: 0.2,
      color: Colors.grey,
    );
    return Expanded(
        child: Container(
      child: ListView.separated(
          itemBuilder: (context, index) {
            return Slidable(
              actionPane: SlidableDrawerDismissal(),
              child: _overtimeItem(index),
              secondaryActions: <Widget>[
                IconSlideAction(
                  onTap: () {
                    // setState(() {
                    //   _overTimeList.remove(_overTimeList[index]);
                    // });
                    _remove(_overTimeList[index]);
                  },
                  caption: '移除',
                  color: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                )
              ],
            );
          },
          separatorBuilder: (context, index) {
            return divider;
          },
          itemCount: _overTimeList.length),
    ));
  }

  //保存后才能上传附件、
  ///上传附件如过是新增自动保存
  ///如果有为空的内容
  Widget _attachementWidget() {
    return Expanded(
      child: Card(
        elevation: 0.0,
        color: Colors.grey[100],
        margin: EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.all(5),
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemCount: _attachementList.length + 1,
              itemBuilder: (context, index) {
                return _itemPhote(index);
              }),
        ),
      ),
    );
  }

  ///单个照片
  Widget _itemPhote(int index) {
    // String imageUrl = Utils.getImageUrl(_attachementList[index].fileId);
    return (index < _attachementList.length)
        ? Stack(fit: StackFit.expand, children: [
            InkWell(
                onTap: () {
                  Utils.closeInput(context);
                  _attachementList[index].fileType == 'Photo'
                      ? Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                          return ViewPhoto(
                              Utils.getImageUrl(_attachementList[index].fileId),
                              _attachementList[index].file);
                        }))
                      : Utils.viewAttachment(context, _attachementList[index]);
                },
                child: _attachementList[index].fileType == 'Photo'
                    ? Image.network(
                        Utils.getImageUrl(_attachementList[index].fileId),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 40,
                            ),
                            customText(
                                value: _attachementList[index].shortName),
                          ],
                        ),
                      )),
            _headData.status < 10
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                        onTap: () {
                          _deleteAttachement(index);
                          setState(() {});
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        )),
                  )
                : Container()
          ])
        : Container(
            color: Colors.grey[200],
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
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  _addAttachement('camera');
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('拍照')),
                                    padding: EdgeInsets.only(bottom: 8)),
                              ),
                              InkWell(
                                onTap: () async {
                                  _addAttachement('photo');
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('相册')),
                                    padding: EdgeInsets.all(8)),
                              ),
                              InkWell(
                                onTap: () async {
                                  _addAttachement('PDF');
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('PDF文件')),
                                    padding: EdgeInsets.only(top: 8)),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Icon(Icons.add, color: Colors.grey[400], size: 40),
            ),
          );
  }

  ///添加照片
  void _addAttachement(String type) async {
    bool isSaved = true;
    Utils.closeInput(context);
    if (AskForLeaveSData.askForLeaveId == 0) isSaved = await _save();
    if (isSaved == null || isSaved == false) return;
    switch (type) {
      case 'camera':
        var imageFile = await Utils.takePhote();
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'photo':
        var imageFile = await Utils.takePhote(fromPhote: true);
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'PDF':
        var fileList = await Utils.selectFile();
        if (fileList != null) {
          fileList.forEach((element) {
            _uploadFile(element.path);
          });
        }
        break;
      default:
    }
  }

  ///添加附件
  // void _addFile() async {
  //   bool isSaved = true;
  //   Utils.closeInput(context);
  //   if (AskForLeaveStaticData.askForLeaveId == '') isSaved = await _save();
  //   if (isSaved == null || isSaved == false) return;
  //   var fileList = await Utils.selectFile();
  //   if (fileList != null) {
  //     fileList.forEach((element) async {
  //       _uploadFile(element.path);
  //     });
  //   }
  // }

  void _uploadFile(filePath) async {
    await _progressDialog?.show();
    try {
      await AskForLeaveService.upload(filePath).then((value) async {
        if (value.errCode == 0) {
          await _progressDialog?.hide();
          toastBlackStyle('上传成功!');
          // _updateUi(value);
          setState(() {
            _attachementList = value.attachmentList;
          });
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg,
              iconData: Icons.info, color: Colors.red);
        }
      });
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _deleteAttachement(int index) async {
    bool result = await DialogUtils.showConfirmDialog(context, '是否删除该附件？',
        iconData: Icons.info, color: Colors.red);
    if (result == true) {
      String fileId = _attachementList[index].askForLeaveFileId;
      await AskForLeaveService.attachementDelete(fileId).then((value) {
        if (value.errCode == 0) {
          _attachementList.removeAt(index);
          toastBlackStyle('删除成功!');
          _updateUi(value);
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg);
        }
      });
    }
  }

  Widget _overtimeItem(int index) {
    OverTimeSelectModel item = _overTimeList[index];
    String beginDate =
        Utils.dateTimeToStr(item.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String endDate =
        Utils.dateTimeToStr(item.endDate, pattern: 'yyyy-MM-dd HH:mm');
    return Container(
      color: Colors.grey[100],
      padding: EdgeInsets.all(8),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 11,
            child: Column(
              children: <Widget>[
                // customText(value: '单号: ' + item.code),
                _beginRow(beginDate, item),
                _endRow(endDate, item),
                _reasonAndhours(item),
              ],
            ),
          ),
          // if (_headData.status < 10) _remove(item)
        ],
      ),
    );
  }

  Widget _beginRow(String beginDate, OverTimeSelectModel item) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(
            flex: 3,
            child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customText(value: '开始: ', fontSize: 14.5),
                customText(value: beginDate, color: Colors.blue, fontSize: 14.5
                    // backgroudColor: Color.fromARGB(15, 33, 137, 255),
                    )
              ],
            )),
        Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                customText(value: '共 ', fontSize: 14.5),
                customText(value: item.hours.toString()),
                customText(value: ' 小时', fontSize: 14.5),
              ],
            )),
      ],
    );
  }

  Widget _endRow(String endDate, OverTimeSelectModel item) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Row(
                children: <Widget>[
                  customText(value: '结束: ', fontSize: 14.5),
                  customText(value: endDate, color: Colors.blue, fontSize: 14.5
                      // backgroudColor: Color.fromARGB(15, 33, 137, 255),
                      )
                ],
              )),
          Expanded(
              flex: 2,
              child: Row(
                children: <Widget>[
                  customText(value: '已使用 ', fontSize: 14.5),
                  Text(
                    item.totalUsedHours.toString() ?? '0.0',
                    style: TextStyle(
                        color: Colors.orange,
                        backgroundColor: Colors.orange[50]),
                  ),
                  customText(value: ' 小时', fontSize: 14.5)
                ],
              )),
        ],
      ),
    );
  }

  Widget _reasonAndhours(OverTimeSelectModel item) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
              flex: 3, child: customText(value: item.reason, fontSize: 14.5)),
          Expanded(
              flex: 2,
              child: InkWell(
                onTap: () async {
                  double value = await DialogUtils.showNumberDialog(context,
                      title: '调试时数', defaultValue: item.usedHours);
                  if (value != null) {
                    setState(() {
                      item.usedHours = value;
                    });
                  }
                },
                child: Row(
                  children: <Widget>[
                    customText(value: '调休 ', fontSize: 14.5),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1))),
                      child: customText(
                          value: item.usedHours.toString(), color: Colors.red),
                    ),
                    customText(value: '小时 ', fontSize: 14.5),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _remove(OverTimeSelectModel item) async {
    // var result = await DialogUtils.showConfirmDialog(context, '是否移除该调休加班单?',
    //     iconData: Icons.info, color: Colors.red);
    // if (result == true) {
    setState(() {
      _overTimeList.remove(item);
    });
    // }
  }

  Widget _draftStatusButtons() {
    return Container(
      child: Row(
        children: <Widget>[
          if (AskForLeaveSData.askForLeaveId != 0)
            customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
          customButtom(Colors.green, '提交', _submit)
        ],
      ),
    );
  }

  Widget _submitStatusButton() {
    return Container(
      child: Row(
        children: <Widget>[customButtom(Colors.amber, '取消提交', _toDraft)],
      ),
    );
  }

  void _delete() async {
    setPageDataChanged(this.widget, true);
    bool isDelete = await DialogUtils.showConfirmDialog(context, '是否删除该条请假单？',
        iconData: Icons.info, color: Colors.red);
    if (isDelete) {
      var id = AskForLeaveSData.askForLeaveId;
      await AskForLeaveService.toDraftOrDelete('delete', id).then((value) {
        if (value.errCode == 0) {
          toastBlackStyle('删除成功!');
          Navigator.pop(context);
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg);
        }
      });
    }
  }

  void _toDraft() async {
    setPageDataChanged(this.widget, true);
    var id = AskForLeaveSData.askForLeaveId;
    await AskForLeaveService.toDraftOrDelete('toDraft', id).then((value) {
      if (value.errCode == 0) {
        _updateUi(value);
        toastBlackStyle('取消成功!');
      } else {
        DialogUtils.showAlertDialog(context, value.errMsg);
      }
    });
  }

  Future<bool> _save() async {
    if (!(_formKey.currentState as FormState).validate()) return false;
    setPageDataChanged(this.widget, true);
    bool result = false;
    if (!_needOverTime) _overTimeList.clear();
    if (!_needAttanchement) _attachementList.clear();
    if (_getFormData()) {
      String action = AskForLeaveSData.askForLeaveId == 0 ? 'add' : 'update';
      await AskForLeaveService.requstsaveOrSubmit(
              action, _headData, _overTimeList)
          .then((value) {
        if (value.errCode == 0) {
          _updateUi(value);
          toastBlackStyle('保存成功!');
          result = true;
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg);
          result = false;
        }
      });
    }
    return result;
  }

  void _submit() async {
    setPageDataChanged(this.widget, true);
    if (_getFormData()) {
      try {
        await _progressDialog?.show();
        String action = AskForLeaveSData.askForLeaveId == 0 ? 'add' : 'update';
        await AskForLeaveService.requstsaveOrSubmit(
                action, _headData, _overTimeList,
                submit: 'submit')
            .then((value) async {
          await _progressDialog?.hide();
          if (value.errCode == 0) {
            _updateUi(value);
            toastBlackStyle('提交成功!');
          } else {
            DialogUtils.showAlertDialog(context, value.errMsg);
          }
        });
      } finally {
        await _progressDialog?.hide();
      }
    }
  }

  bool _getFormData() {
    String begin =
        Utils.dateTimeToStr(_headData.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String end =
        Utils.dateTimeToStr(_headData.endDate, pattern: 'yyyy-MM-dd HH:mm');
    if (_dayControl.text == '') {
      toastBlackStyle('请假天数不能为空！');
      return false;
    } else if (_hoursControl.text == '') {
      toastBlackStyle('请假时数不能为空！');
      return false;
    } else if (_reasonControl.text == '') {
      toastBlackStyle('原因不能为空！');
      return false;
    } else if (_contactControl.text == '') {
      toastBlackStyle('联系电话不能为空！');
      return false;
    } else if (_headData.endDate.isBefore(_headData.beginDate)) {
      toastBlackStyle('结束时间需大于开始时间');
      return false;
    } else if (begin == end) {
      toastBlackStyle('开始结束时间不能相等');
      return false;
    } else if (_headData.typeCode == null) {
      toastBlackStyle('请选择请假类型!');
      return false;
    } else if (_needOverTime && _overTimeList.length == 0) {
      toastBlackStyle('当前请假类型需要加班单调休!');
      return false;
    }
    _headData.days = double.parse(_dayControl.text);
    _headData.hours = double.parse(_hoursControl.text);
    _headData.reason = _reasonControl.text;
    _headData.contact = _contactControl.text;
    return true;
  }

  void _getDetailData() async {
    await _progressDialog?.show();
    try {
      var id = AskForLeaveSData.askForLeaveId;
      AskForLeaveDetailModel detailmodel =
          await AskForLeaveService.getDetailData(id);
      _updateUi(detailmodel);
      _getArrange(false);
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _updateUi(AskForLeaveDetailModel detailmodel) {
    setState(() {
      _headData = detailmodel.headDate;
      _overTimeList = detailmodel.overTimeList;
      _contactControl.text = _headData.contact;
      _dayControl.text = _headData.days.toString();
      _hoursControl.text = _headData.hours.toString();
      _reasonControl.text = _headData.reason;
      _overTimeList = detailmodel.overTimeList;
      _attachementList = detailmodel.attachmentList;
      AskForLeaveSData.askForLeaveId = _headData.askForLeaveId;
      AskForLeaveKind askForLeaveKind = _getTypeItem(_headData.typeCode);

      _needAttanchement = askForLeaveKind.needAttachment;
      _needOverTime = askForLeaveKind.needOverTime;
    });
  }
}
