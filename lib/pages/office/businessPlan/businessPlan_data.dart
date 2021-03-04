import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/businessPlan_data.dart';
import 'package:mis_app/model/businessPlan_list.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/staff_info.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/businessPlan_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class BusinessPlanDataPage extends StatefulWidget {
  final int businessId;
  const BusinessPlanDataPage({Key key, this.businessId}) : super(key: key);

  @override
  _BusinessPlanDataPageState createState() => _BusinessPlanDataPageState();
}

class _BusinessPlanDataPageState extends State<BusinessPlanDataPage> {
  final _rowMargin = EdgeInsets.only(top: 7, bottom: 6);
  BusinessPlan _headData = BusinessPlan();
  List<DropdownMenuItem> _areaItems = [];
  List<DropdownMenuItem> _typeItems = [];
  TextEditingController _reaonContrl = TextEditingController();
  TextEditingController _trafCostCtrl = TextEditingController();
  TextEditingController _lifeCostCtrl = TextEditingController();
  TextEditingController _sleepCostCtrl = TextEditingController();
  TextEditingController _socialCostCtrl = TextEditingController();
  ProgressDialog _progressDialog;
  // List<BusinessPlanEmp> _empList = [];
  // List<BusinessPlanLine> _businessPlanLine = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (this.widget.businessId != null) {
        _headData.businessPlanId = this.widget.businessId;
        _request('getDetail');
      } else {
        StaffInfo basedb = BaseDbModel.baseDbModel.userStaffList[0];
        setState(() {
          _headData.businessPlanId = 0;
          BusinessSData.planId = 0;
          _headData.areaId = basedb.defaultAreaId;
          _headData.applyStaffId = basedb.staffId;
          _headData.applyUser = basedb.staffName;
          _headData.applyDate = Utils.today;
          DateTime data = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 0, 0, 0, 0, 0);
          _headData.beginDate = data;
          _headData.endDate = data;
          BusinessSData.empList = [];
          BusinessSData.businessPlanLine = [];
          _getTypeItems();
          _getAreaItems();
        });
      }
    });
  }

  void _getTypeItems() {
    _typeItems.clear();
    BusinessSData.typeList.forEach((e) {
      _typeItems.add(DropdownMenuItem(
        child: customText(
            value: e.name,
            color: _headData.planType == e.name ? Colors.blue : Colors.black),
        value: e.name,
      ));
    });
  }

  void _getAreaItems() {
    _areaItems.clear();
    BaseDbModel.baseDbModel.areaList.forEach((element) {
      _areaItems.add(DropdownMenuItem(
        child: customText(
            value: element.shortName,
            color: _headData.areaId == element.areaId
                ? Colors.blue
                : Colors.black),
        value: element.areaId,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return WillPopScope(
      onWillPop: () async {
        if ((_request != null) && (_headData.businessPlanId == 0)) {
          if (!(await DialogUtils.showConfirmDialog(context, '确定要退出吗？',
              confirmText: '退出', confirmTextColor: Colors.red))) {
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.blueAccent,
          title: Text(_headData.businessPlanId == 0 ? '出差计划新增' : '出差计划编辑'),
        ),
        body: Container(
          color: Colors.grey[200],
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          // margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AbsorbPointer(
                                absorbing: _headData.status < 10 ? false : true,
                                child: Column(
                                  children: <Widget>[
                                    _areaAanApplyData(),
                                    _typeAndApplyMan(),
                                    _leaderAndPosiMan(),
                                    Container(
                                      margin: _rowMargin,
                                      child: Row(children: <Widget>[
                                        _staffSelWidget(
                                            '职务代理人', _headData.proxyUser)
                                      ]),
                                    ),
                                    _begin(),
                                  ],
                                ),
                              ),
                              _end(),
                              Text('出差原因：', style: TextStyle(fontSize: 15)),
                              _reason(),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                          padding: EdgeInsets.all(8),
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              _addStaff(),
                              _listView(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              _headData.status < 10
                  ? _draftStatueButtons()
                  : _submitStatusButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _areaAanApplyData() {
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Expanded(
                  child: Row(
                children: <Widget>[
                  Text('项目：'),
                  DropdownButton(
                      isDense: true,
                      items: _areaItems,
                      underline: Container(),
                      value: _headData.areaId,
                      onChanged: (v) {
                        setState(() {
                          _headData.areaId = v;
                          _getAreaItems();
                        });
                      }),
                ],
              )),
              Expanded(
                  child: Row(
                children: <Widget>[
                  Text('状态：'),
                  Text(
                    _headData.statusName,
                    style: statusNameTextStyle(_headData.statusName),
                  )
                ],
              )),
            ],
          )),
        ],
      ),
    );
  }

  Widget _typeAndApplyMan() {
    String applydata = Utils.dateTimeToStr(_headData.applyDate);
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Text('出差类型：'),
              DropdownButton(
                  isDense: true,
                  underline: Container(),
                  value: _headData.planType,
                  hint: customText(value: '请选择'),
                  items: _typeItems,
                  onChanged: (v) {
                    setState(() {
                      _headData.planType = v;
                      _getTypeItems();
                    });
                  }),
            ],
          )),
          Expanded(
              child: Row(
            children: <Widget>[
              Text('申请日期：'),
              InkWell(
                child: Container(
                    // padding: EdgeInsets.all(2),
                    // decoration: timePickDecoration,
                    child: customText(value: applydata, color: Colors.orange)),
                // onTap: () async {
                //   DialogUtils.showDatePickerDialog(context, _headData.applyDate,
                //       onValue: (v) {
                //     if (v == null) return;
                //     setState(() {
                //       _headData.applyDate = v;
                //     });
                //   });
                // },
              )
            ],
          )),
        ],
      ),
    );
  }

  Widget _leaderAndPosiMan() {
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          _staffSelWidget('申请人', _headData.applyUser,
              staffid: _headData.applyStaffId),
          _staffSelWidget('领队人', _headData.leaderUser),
        ],
      ),
    );
  }

  Widget _staffSelWidget(String title, String name, {int staffid}) {
    return Expanded(
        child: InkWell(
      onTap: () async {
        String result = await showSearch(
            context: context,
            delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff));
        if (result == '' || result == null) return;
        StaffModel staff = StaffModel.fromJson(jsonDecode(result));
        setState(() {
          if (title == '申请人') {
            staffid = staff.staffId;
            _headData.applyUser = staff.name;
          } else if (title == '领队人') {
            _headData.leaderUser = staff.name;
          } else if (title == '职务代理人') {
            _headData.proxyUser = staff.name;
          }
        });
      },
      child: Container(
        // decoration: timePickDecoration,
        // padding: EdgeInsets.only(top: 3, bottom: 3),
        margin: EdgeInsets.only(right: 8),
        child: Row(
          children: <Widget>[
            Text(title + "："),
            Expanded(
              child: Container(
                // padding: EdgeInsets.only(top: 3, bottom: 3),
                // decoration: BoxDecoration(
                //   color: Colors.grey[100],
                //   border: Border.all(width: 0.5, color: Color(0xffd4e0ef)),
                //   borderRadius: BorderRadius.circular(5),
                // ),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(name ?? '')),
                    if (_headData.status < 10)
                      Container(
                        padding: EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(3)),
                        child: Icon(
                          Icons.search,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget _begin() {
    String beginDate =
        Utils.dateTimeToStr(_headData.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    Duration difference = _headData.endDate != null
        ? _headData.endDate.difference(_headData.beginDate)
        : Duration(days: 0);
    String day = (difference.inMinutes / (24 * 60)).toStringAsFixed(2);
    return Container(
      margin: _rowMargin,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 6,
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
              flex: 5,
              child: Container(
                  child: customText(
                      value: '共 ' + day + ' 天', color: Colors.black)))
        ],
      ),
    );
  }

  Widget _end() {
    String endDate =
        Utils.dateTimeToStr(_headData.endDate, pattern: 'yyyy-MM-dd HH:mm');
    // String cost = '预计总费用￥:' + _headData.allCost.toString() + '元';
    return Container(
      margin: _rowMargin,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Row(
              children: <Widget>[
                Text('结束：'),
                InkWell(
                    onTap: () {
                      if (_headData.status < 10)
                        _dateAndTimePick(_headData.endDate, 'end');
                    },
                    child: customText(
                      value: endDate,
                      color: Colors.blue,
                      backgroundColor: Color(0x80DFEEFC),
                    )),
              ],
            ),
          ),
          Expanded(
              flex: 5,
              child: InkWell(
                onTap: () {
                  _showBottonSheet();
                },
                child: Wrap(
                  children: <Widget>[
                    customText(value: '预计总费用:', color: Colors.black),
                    Container(
                      padding: EdgeInsets.all(1),
                      decoration: timePickDecoration,
                      child: customText(
                          value: _headData.allCost.toString(),
                          backgroundColor: Colors.grey[100],
                          color: Colors.orange),
                    ),
                    customText(value: '元', color: Colors.black)
                  ],
                ),
              ))
        ],
      ),
    );
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
      BusinessSData.beginData = _headData.beginDate;
      BusinessSData.endData = _headData.endDate;
      print(datePick.toString());
      print(timePick.toString());
    });
  }

  void _showBottonSheet() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Row(
                      children: <Widget>[
                        _customTextField('交通费 ', _trafCostCtrl),
                      ],
                    )),
                    Expanded(
                        child: Row(
                      children: <Widget>[
                        _customTextField('生活费 ', _lifeCostCtrl),
                      ],
                    ))
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Row(
                        children: <Widget>[
                          _customTextField('住宿费 ', _sleepCostCtrl),
                        ],
                      )),
                      Expanded(
                          child: Row(
                        children: <Widget>[
                          _customTextField('交际费 ', _socialCostCtrl),
                        ],
                      ))
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    customButtom(Colors.blue, '关闭', () {
                      Navigator.pop(context);
                    }, radius: 20)
                  ],
                )
              ],
            ),
          );
        }).then((value) {
      setState(() {
        _headData.trafficCost = getCost(_trafCostCtrl);
        _headData.livingCost = getCost(_lifeCostCtrl);
        _headData.accommodationsCost = getCost(_sleepCostCtrl);
        _headData.socialCost = getCost(_socialCostCtrl);
        _headData.allCost = getCost(_trafCostCtrl) +
            _headData.livingCost +
            _headData.accommodationsCost +
            _headData.socialCost;
      });
    });
  }

  double getCost(TextEditingController _ctrl) {
    double cost = 0;
    if (_ctrl.text == '') {
      cost = 0;
    } else {
      cost = double.parse(_ctrl.text);
    }
    return cost;
  }

  Widget _customTextField(String titel, TextEditingController ctrl) {
    return Expanded(
        child: Container(
      margin: EdgeInsets.all(5),
      child: Row(
        children: <Widget>[
          Text(titel),
          Expanded(
            child: Container(
              height: 30,
              child: TextField(
                readOnly: _headData.status < 10 ? false : true,
                controller: ctrl,
                style: TextStyle(fontSize: 15),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                ],
                keyboardType: TextInputType.number,
                decoration: outLineDecoration(15),
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _reason() {
    return Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(width: 0.2, color: Color(0xffd4e0ef)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                        controller: _reaonContrl,
                        onChanged: (v) {
                          setState(() {});
                        },
                        maxLines: 3,
                        style: TextStyle(fontSize: 15.5),
                        decoration: InputDecoration(
                            // labelText: '出差原因',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(1),
                            hintText: '请输入出差原因',
                            hintStyle: TextStyle(fontSize: 15)))),
                if (_reaonContrl.text != '' && _headData.status < 10)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _reaonContrl.text = '';
                        _reaonContrl.clear(); //清除textfield的值
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                      child: Icon(
                        Icons.cancel,
                        color: Colors.grey,
                        size: 17,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ));
  }

//添加人员
  Widget _addStaff() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, border: Border(bottom: BorderSide(width: 0.2))),
      child: Row(
        children: <Widget>[
          Expanded(child: Text('人员列表')),
          if (_headData.status < 10)
            InkWell(
              onTap: () {
                Utils.closeInput(context);
                BusinessSData.status = _headData.status;

                navigatePage(context, businessPlanDetailPath).then((value) {
                  if (_headData.beginDate.isAfter(BusinessSData.beginData))
                    _headData.beginDate = BusinessSData.beginData;
                  if (_headData.endDate.isBefore(BusinessSData.endData))
                    _headData.endDate = BusinessSData.endData;

                  setState(() {});
                });
              },
              child: Row(
                children: <Widget>[
                  Container(
                    // decoration: BoxDecoration(
                    //     color: Colors.blue, borderRadius: BorderRadius.circular(3)),
                    padding: EdgeInsets.all(3),
                    // margin: EdgeInsets.only(bottom: 1),
                    child: Icon(
                      Icons.person_add,
                      color: Colors.blue,
                      // size: 30,
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _listView() {
    Divider divider = Divider(height: 0.2);
    return Container(
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Slidable(
                actionPane: SlidableBehindActionPane(),
                secondaryActions: <Widget>[
                  if (_headData.status < 10)
                    IconSlideAction(
                      onTap: () {
                        //循环移除该人员的计划
                        // int empid =
                        //     BusinessSData.empList[index].businessPlanEmpId;
                        // BusinessSData.businessPlanLine.forEach((element) {
                        //   if (element.businessPlanEmpId == empid) {
                        //     BusinessSData.businessPlanLine.remove(element);
                        //   }
                        // });
                        setState(() {
                          BusinessSData.empList.removeAt(index);
                        });
                      },
                      caption: '移除',
                      color: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline,
                    )
                ],
                child: _item(index));
          },
          separatorBuilder: (context, index) {
            return divider;
          },
          itemCount: BusinessSData.empList.length),
    );
  }

  Widget _item(int index) {
    BusinessPlanEmp item = BusinessSData.empList[index];
    String begin =
        Utils.dateTimeToStr(item.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String end = Utils.dateTimeToStr(item.endDate, pattern: 'yyyy-MM-dd HH:mm');
    int i = 0;
    return InkWell(
      onTap: () async {
        BusinessSData.status = _headData.status;
        navigatePage(context, businessPlanDetailPath,
                arguments: item.businessPlanEmpId)
            .then((value) {
          if (_headData.beginDate.isAfter(BusinessSData.beginData))
            _headData.beginDate = BusinessSData.beginData;
          if (_headData.endDate.isBefore(BusinessSData.endData))
            _headData.endDate = BusinessSData.endData;
          setState(() {});
        });
      },
      child: Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                padding: EdgeInsets.only(right: 10),
                child: customText(
                  value: item.staffName,
                  fontSize: 14,
                  color: Colors.blue,
                )),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.blue,
                          size: 18,
                        ),
                      ),
                      customText(
                        value: begin,
                        fontSize: 14,
                      ),
                      customText(value: ' - ', color: Colors.blue),
                      customText(
                        value: end,
                        fontSize: 14,
                      ),
                    ],
                  ),
                  Wrap(
                      children: BusinessSData.businessPlanLine.map((e) {
                    if (e.businessPlanEmpId == item.businessPlanEmpId) {
                      i++;
                      return i <= 3
                          ? customText(
                              value: (' ' + i.toString() + '、' + e.plan),
                              fontSize: 14,
                            )
                          : customText(value: '...');
                    } else {
                      return Container();
                    }
                  }).toList())
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _draftStatueButtons() {
    return Container(
      child: Row(
        children: <Widget>[
          if (_headData.businessPlanId != 0)
            customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
          customButtom(Colors.green, '提交', _submit),
        ],
      ),
    );
  }

  Widget _submitStatusButtons() {
    return Container(
      child: Row(
        children: <Widget>[customButtom(Colors.amber, '取消提交', _toDraft)],
      ),
    );
  }

  void _delete() async {
    if (await DialogUtils.showConfirmDialog(context, '是否删除该条出差计划单？',
        iconData: Icons.info, color: Colors.red)) {
      setPageDataChanged(this.widget, true);
      await BusinessPlanService.delete(_headData.businessPlanId).then((value) {
        if (value['ErrCode'] == 0) {
          DialogUtils.showToast('删除成功');
          Navigator.pop(context);
        } else {
          DialogUtils.showConfirmDialog(context, value['ErrMsg']);
        }
      });
    }
  }

  void _save() {
    if (!checkData()) return;
    setPageDataChanged(this.widget, true);
    _request('save');
  }

  void _submit() {
    if (!checkData()) return;
    setPageDataChanged(this.widget, true);
    _request('submit');
  }

  void _toDraft() {
    _request('todraft');
  }

  void _request(String action) async {
    Utils.closeInput(context);
    try {
      await _progressDialog?.show();
      BusinesssPlanModel model = BusinesssPlanModel();
      switch (action) {
        case 'getDetail':
          model =
              await BusinessPlanService.getDetailData(_headData.businessPlanId);
          break;
        case 'save':
          String action = _headData.businessPlanId == 0 ? 'add' : 'update';
          model =
              await BusinessPlanService.requestData(action, false, _headData);
          break;
        case 'submit':
          String action = _headData.businessPlanId == 0 ? 'add' : 'update';
          model =
              await BusinessPlanService.requestData(action, true, _headData);
          break;
        case 'todraft':
          model = await BusinessPlanService.todraft(_headData.businessPlanId);
          break;
        default:
      }

      if (model.errCode == 0) {
        switch (action) {
          case 'save':
            DialogUtils.showToast('保存成功');
            break;
          case 'submit':
            DialogUtils.showToast('提交成功');
            break;
          case 'todraft':
            DialogUtils.showToast('取消成功');
            break;
          default:
        }
        setState(() {
          _headData = model.businessPlan[0];
          BusinessSData.planId = _headData.businessPlanId;
          _reaonContrl.text = _headData.reason;
          _trafCostCtrl.text = _headData.trafficCost.toString();
          _lifeCostCtrl.text = _headData.livingCost.toString();
          _sleepCostCtrl.text = _headData.accommodationsCost.toString();
          _socialCostCtrl.text = _headData.socialCost.toString();
          BusinessSData.empList = model.businessPlanEmp;
          BusinessSData.businessPlanLine = model.businessPlanLine;
          BusinessSData.beginData = _headData.beginDate;
          BusinessSData.endData = _headData.endDate;
          _getTypeItems();
          _getAreaItems();
        });
      } else {
        DialogUtils.showConfirmDialog(context, model.errMsg);
      }
    } finally {
      _progressDialog?.hide();
    }
  }

  bool checkData() {
    bool hasData = false;
    String begin =
        Utils.dateTimeToStr(_headData.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String end =
        Utils.dateTimeToStr(_headData.endDate, pattern: 'yyyy-MM-dd HH:mm');
    _headData.reason = _reaonContrl.text;
    if (_headData.planType == null) {
      DialogUtils.showToast('出差类型不能为空!');
    } else if (_headData.applyUser == null) {
      DialogUtils.showToast('申请人不能为空!');
    } else if (_headData.leaderUser == null) {
      DialogUtils.showToast('领队人不能为空!');
    } else if (begin == end) {
      DialogUtils.showToast('开始时间不能与结束时间相等!');
    } else if (_headData.beginDate.isAfter(_headData.endDate)) {
      DialogUtils.showToast('结束时间不能小于开始时间!');
    } else if (_headData.proxyUser == null) {
      DialogUtils.showToast('职务代理人不能为空!');
    } else if (_reaonContrl.text == '') {
      DialogUtils.showToast('出差原因不能为空!');
    } else if (BusinessSData.empList.length == 0) {
      DialogUtils.showToast('出差人员不能为空!');
    } else {
      hasData = true;
    }
    return hasData;
  }
}
