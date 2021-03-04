import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/overtime.dart';
import 'package:mis_app/model/overtime_detail.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/staff_info.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/base_container.dart';
import 'package:mis_app/widget/date_time_view.dart';

class WorkOverTimeAddPage extends StatefulWidget {
  @override
  _WorkOverTimeAddPageState createState() => _WorkOverTimeAddPageState();
}

class _WorkOverTimeAddPageState extends State<WorkOverTimeAddPage> {
  // bool _isNew;
  OverTimeDetail _detail;
  List<DropdownMenuItem> _typeDropDownItems = [];
  TextEditingController _timeController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    int index = WorkOverTimeSData.pressIndex;
    if (WorkOverTimeSData.isAdd) {
      ///添加加班人员
      _getDefualtStaffData();
    } else {
      _detail = WorkOverTimeSData.detailList[index];
      _timeController.text = _detail.time.toString();
      _reasonController.text = _detail.reason;
    }
    _initDropDownButton();
  }

  void _initDropDownButton() {
    WorkOverTimeSData.typeList.forEach((element) {
      _typeDropDownItems.add(DropdownMenuItem(
        child: customText(
            value: element.typeName, fontSize: 15.5, color: Colors.blue[600]),
        value: element.typeCode,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      parentContext: context,
      child: Scaffold(
        appBar: AppBar(title: Text(WorkOverTimeSData.isAdd ? '人员添加' : '人员编辑')),
        body: AbsorbPointer(
          absorbing: WorkOverTimeSData.status < 10 ? false : true,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      _staffcode(),
                      _customerWidget('姓名', _detail.name,
                          flex: 3, marginleft: true),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      _customerWidget('部门', _detail.deptName, flex: 2),
                      _customerWidget('职务', _detail.posi,
                          flex: 2, marginleft: true),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      // Expanded(
                      //   flex: 3,
                      //   child: InkWell(
                      //       onTap: () {
                      //         _dateAndTimePick(_detail.beginDate, 'begin');
                      //       },
                      //       child: _customerWidget('开始', beginDate)),
                      // ),
                      Text('开始: '),
                      DateTimeView(
                        value: _detail?.beginDate,
                        onDateTap: () {
                          DialogUtils.showDatePickerDialog(
                              context, _detail.beginDate,
                              onValue: (DateTime val) {
                            _detail.beginDate =
                                _detail.beginDate.replaceDate(val);
                            if (_detail.beginDate.isAfter(_detail.endDate)) {
                              _detail.endDate = _detail.endDate
                                  .replaceDate(_detail.beginDate);
                            }
                            setState(() {});
                          });
                        },
                        onTimeTap: () {
                          DialogUtils.showTimePickerDialog(
                              context, _detail.beginDate,
                              initialTime: _detail.beginDate.time,
                              onValue: (TimeOfDay val) {
                            setState(() {
                              _detail.beginDate =
                                  _detail.beginDate.replaceTime(val);
                            });
                          });
                        },
                      ),
                      _type(),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: <Widget>[
                      // Expanded(
                      //   flex: 3,
                      //   child: InkWell(
                      //       onTap: () {
                      //         _dateAndTimePick(_detail.endDate, 'end');
                      //       },
                      //       child: _customerWidget('结束', endDate, flex: 3)),
                      // ),
                      Text('结束: '),
                      DateTimeView(
                        value: _detail?.endDate,
                        onDateTap: () {
                          DialogUtils.showDatePickerDialog(
                              context, _detail.endDate,
                              onValue: (DateTime val) {
                            setState(() {
                              _detail.endDate =
                                  _detail.endDate.replaceDate(val);
                            });
                          });
                        },
                        onTimeTap: () {
                          DialogUtils.showTimePickerDialog(
                              context, _detail.endDate,
                              initialTime: _detail.endDate.time,
                              onValue: (TimeOfDay val) {
                            setState(() {
                              _detail.endDate =
                                  _detail.endDate.replaceTime(val);
                            });
                          });
                        },
                      ),
                      Expanded(
                        flex: 2,
                        child: _hours(),
                      )
                    ],
                  ),
                ),
                _reason(),
                WorkOverTimeSData.status == 0 ? _confirmBt() : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _staffcode() {
    return Expanded(
      flex: 3,
      child: Container(
        height: 28,
        child: Row(
          children: <Widget>[
            Text('工号：'),
            Expanded(
                child: customOutLineContainer(
                    child:
                        customText(value: _detail.code, color: Colors.black))),
            InkWell(
              onTap: () {
                _selectStaff();
              },
              child: Container(
                margin: EdgeInsets.only(left: 5),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _customerWidget(String name, String value,
      {int flex, bool marginleft}) {
    return Expanded(
        flex: flex ?? 1,
        child: Container(
          height: 28,
          margin: EdgeInsets.only(left: marginleft == true ? 15 : 1),
          child: Row(
            children: <Widget>[
              Text('$name：'),
              Expanded(
                  child: customOutLineContainer(
                      child: customText(value: value, color: Colors.black))),
            ],
          ),
        ));
  }

  Widget _type() {
    return Expanded(
      flex: 2,
      child: Container(
        margin: EdgeInsets.only(left: 10),
        child: Row(
          children: <Widget>[
            Text('类型：'),
            Expanded(
              child: DropdownButton(
                  isDense: true,
                  isExpanded: true,
                  underline: Container(height: 0),
                  value: _detail.type,
                  items: _typeDropDownItems,
                  onChanged: (val) {
                    setState(() {
                      _detail.type = val;
                      _detail.typeName = _getItemName(val);
                    });
                  }),
            )
          ],
        ),
      ),
    );
  }

  String _getItemName(String type) {
    String typeName = '';
    WorkOverTimeSData.typeList.forEach((element) {
      if (type == element.typeCode) {
        typeName = element.typeName;
      }
    });
    return typeName;
  }

  Widget _hours() {
    // Duration diff = _detail.endDate.difference(_detail.beginDate);
    // String hours = (diff.inMinutes / 60).toStringAsFixed(1);
    // _timeController.text = hours;

    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Text('共 '),
          Expanded(
              child: Container(
                  height: 28,
                  child: TextField(
                    style: TextStyle(color: Colors.blue[600]),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                    ],
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: _timeController,
                  ))),
          Text(' 小时'),
          // InkWell(
          //   onTap: () {
          //     DialogUtils.showToast('加班时间默认为开始结束时间差，可修改');
          //   },
          //   child: Icon(Icons.help, color: Colors.blue),
          // )
        ],
      ),
    );
  }

  Widget _reason() {
    return Container(
      margin: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Text('原因:   '),
          Expanded(
              child: Container(
                  height: 28,
                  child: TextField(
                    style: TextStyle(fontSize: 15.5),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8), hintText: '请输入加班原因'),
                    controller: _reasonController,
                  ))),
        ],
      ),
    );
  }

  Widget _confirmBt() {
    return Container(
      child: Row(
        children: <Widget>[
          customButtom(Colors.blue, '确定', _confirm),
        ],
      ),
    );
  }

  void _confirm() {
    if (_timeController.text == '') {
      toastBlackStyle('加班时长不能为空!');
    } else if (_reasonController.text == '') {
      toastBlackStyle('加班原因不能为空!');
    } else if (_detail.beginDate.isAtSameMomentAs(_detail.endDate)) {
      toastBlackStyle('起始时间不能与结束时间相同！');
    } else if (_detail.beginDate.difference(_detail.endDate) >=
        Duration(hours: 24)) {
      toastBlackStyle('加班时间差不能超过24小时!');
    } else if (_detail.beginDate.isAfter(_detail.endDate)) {
      toastBlackStyle('起始时间不能大于结束数间!');
    } else {
      _detail.time = double.parse(_timeController.text);
      _detail.reason = _reasonController.text;
      if (WorkOverTimeSData.isAdd) {
        WorkOverTimeSData.detailList.add(_detail);
      }
      Navigator.pop(context);
    }
  }

  void _selectStaff() async {
    var result = await showSearch(
      context: context,
      delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff,
          deptId: _detail.deptId),
    );
    if (result == '' || result == null) return;
    StaffModel staff = StaffModel.fromJson(json.decode(result));

    setState(() {
      _detail.staffId = staff.staffId;
      _detail.code = staff.code;
      _detail.posi = staff.posi;
      _detail.name = staff.name;
      _detail.deptName = staff.deptName;
    });
  }

  // void _dateAndTimePick(DateTime date, String type) async {
  //   // var date = _detail.beginDate;
  //   var time = TimeOfDay.fromDateTime(date);
  //   var datePick = await showDatePicker(
  //       context: context,
  //       initialDate: date,
  //       firstDate: defaultFirstDate,
  //       lastDate: defaultLastDate);
  //   if (datePick == null) return;
  //   var timePick = await showTimePicker(context: context, initialTime: time);
  //   if (timePick == null) return;
  //   var result = DateTime(datePick.year, datePick.month, datePick.day,
  //       timePick.hour, timePick.minute);
  //   setState(() {
  //     type == 'begin' ? _detail.beginDate = result : _detail.endDate = result;
  //     print(datePick.toString());
  //     print(timePick.toString());
  //   });
  // }

  ///获取默认值
  void _getDefualtStaffData() {
    DateTime now = DateTime.now();
    _detail = new OverTimeDetail();
    StaffInfo staffInfo = WorkOverTimeSData.userStaff[0];
    if (WorkOverTimeSData.curDeptId == staffInfo.deptId) {
      _detail.staffId = staffInfo.staffId;
      _detail.code = staffInfo.staffCode;
      _detail.name = staffInfo.staffName;
      _detail.deptId = staffInfo.deptId;
      _detail.deptName = staffInfo.deptName;
      _detail.posi = staffInfo.posi;
      // _detail.overTimeId = ;
    } else {
      _detail.deptId = WorkOverTimeSData.curDeptId;
    }
    _detail.beginDate = now;
    _detail.endDate = now;
    _detail.type = WorkOverTimeSData.typeList[0].typeCode;
    _detail.typeName = WorkOverTimeSData.typeList[0].typeName;
  }
}
