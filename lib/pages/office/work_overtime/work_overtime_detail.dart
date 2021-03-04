import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/dept.dart';
import 'package:mis_app/model/overtime_detail.dart';
import 'package:mis_app/model/overtime.dart';
import 'package:mis_app/model/staff_info.dart';
import 'package:mis_app/pages/common/search_dept.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_overtime_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class WorkOverTimeDetailPage extends StatefulWidget {
  final Map arguments;
  const WorkOverTimeDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _WorkOverTimeDetailPageState createState() => _WorkOverTimeDetailPageState();
}

class _WorkOverTimeDetailPageState extends State<WorkOverTimeDetailPage> {
  // int _overTimeId = '';
  HeadData _headData;
  // List<Detail> _detailList = [];
  List<DropdownMenuItem> _areaItems = [];
  FLToastDefaults _flToastDefaults = FLToastDefaults();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _headData = new HeadData();

    _headData.overTimeId =
        this.widget.arguments == null ? 0 : this.widget.arguments['overtimeId'];
    _getDropDownList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, 'loading...');
    return Scaffold(
      appBar: AppBar(
        title: Text(_headData.overTimeId == 0 ? '加班单新增' : '加班单编辑'),
      ),
      body: FLToastProvider(
        defaults: _flToastDefaults,
        child: Container(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AbsorbPointer(
                absorbing: _headData.status > 0,
                child: Row(
                  children: <Widget>[
                    _areaSelect(),
                    _overtimeStatus(),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  _deptSearch(),
                  _applyData(),
                ],
              ),
              _addWorkOverTime(),
              _listView(),
              _headData.status < 10
                  ? _draftButtons()
                  : (_headData.status == 10 ? _submitButtons() : Text('')),
            ],
          ),
        ),
      ),
    );
  }

  ///地区选择
  Widget _areaSelect() {
    return Container(
      child: Expanded(
        child: Row(
          children: <Widget>[
            Text('项目：'),
            Expanded(
              child: DropdownButton(
                isExpanded: true,
                underline: Container(height: 0.0),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _headData.status < 10 ? Colors.blue : Colors.grey,
                ),
                items: _areaItems,
                value: _headData.areaId,
                onChanged: (value) async {
                  if (_headData.areaId != value) {
                    bool result = await DialogUtils.showConfirmDialog(
                        context, '更换地区将清空部门和添加的人员，是否继续？',
                        iconData: Icons.info, color: Colors.red);
                    if (result) {
                      setState(() {
                        _headData.deptId = 0;
                        _headData.deptName = '';
                        WorkOverTimeSData.curDeptId = 0;
                        _headData.applyDate = Utils.today;
                        WorkOverTimeSData.detailList.clear();
                        _headData.areaId = value;
                      });
                    }
                  }
                  setState(() {
                    _headData.areaId = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///状态
  Widget _overtimeStatus() {
    return Container(
      child: Expanded(
        child: Container(
          height: 28,
          margin: EdgeInsets.only(left: 30),
          child: Row(
            children: <Widget>[
              Text('状态：'),
              Expanded(
                child: customContainer(
                  child: Text(
                    _headData.statusName,
                    style: statusTextStyle(_headData.status),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///部门选择
  Widget _deptSearch() {
    return Expanded(
      child: Container(
        height: 28,
        child: InkWell(
          onTap: () {
            if (_headData.status >= 10) return;
            showSearch(
                    context: context,
                    delegate: SearchDeptDelegate(Prefs.keyHistorySelectDept,
                        areaId: _headData.areaId))
                .then((value) async {
              if (value == null || value == '') return;
              var data = jsonDecode(value);
              DeptModel deptModel = DeptModel.fromJson(data);
              if (_headData.deptId != deptModel.deptId) {
                if (WorkOverTimeSData.detailList.length == 0) {
                  setState(() {
                    WorkOverTimeSData.detailList.clear();
                    WorkOverTimeSData.curDeptId = deptModel.deptId;
                    _headData.deptId = deptModel.deptId;
                    _headData.deptName = deptModel.name;
                  });
                } else if (await DialogUtils.showConfirmDialog(
                    context, '更换部门将清除添加的人员，是否继续？')) {
                  setState(() {
                    WorkOverTimeSData.detailList.clear();
                    WorkOverTimeSData.curDeptId = deptModel.deptId;
                    _headData.deptId = deptModel.deptId;
                    _headData.deptName = deptModel.name;
                  });
                }
              }
            });
          },
          child: Row(
            children: <Widget>[
              Text('部门：'),
              Expanded(
                  child: customContainer(
                      child: customText(
                          value: _headData.deptName, color: Colors.black))),
              Icon(
                Icons.search,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  ///申请日期
  Widget _applyData() {
    var applydate = Utils.dateTimeToStr(_headData.applyDate);
    return Expanded(
        child: Container(
      height: 28,
      margin: EdgeInsets.only(left: 10),
      child: Row(
        children: <Widget>[
          Text('申请日期：'),
          Expanded(
            child: InkWell(
              // onTap: () {
              //   if (_headData.status >= 10) return;
              //   DialogUtils.showDatePickerDialog(context, _headData.applyDate,
              //       onValue: (val) {
              //     setState(() {
              //       _headData.applyDate = val;
              //     });
              //   });
              // },
              child: customContainer(
                  child: customText(
                      value: applydate, color: Colors.orange, fontSize: 16)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _addWorkOverTime() {
    return Transform.scale(
      scale: 0.9,
      child: Container(
        child: FlatButton(
            onPressed: () {
              if (_headData.status >= 10) return;
              if (_headData.deptId == 0) {
                toastBlackStyle('还未选择加班的部门！');
              } else {
                WorkOverTimeSData.isAdd = true;
                Navigator.pushNamed(context, workOverTimeAddPath).then((value) {
                  setState(() {});
                });
              }
            },
            color: Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Text(
              '添加人员',
              style: TextStyle(color: Colors.white),
            )),
      ),
    );
  }

  Widget _listView() {
    Widget redDivider = Divider(
      color: Colors.white,
      height: 1,
    );
    return Expanded(
      child: Container(
          child: ListView.separated(
        itemCount: WorkOverTimeSData.detailList.length,
        separatorBuilder: (context, index) {
          return redDivider;
        },
        itemBuilder: (context, index) {
          return _item(index);
        },
      )),
    );
  }

  Widget _item(int index) {
    OverTimeDetail item = WorkOverTimeSData.detailList[index];
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: [
        if (WorkOverTimeSData.status < 10)
          IconSlideAction(
            icon: Icons.delete,
            caption: '移除',
            color:
                WorkOverTimeSData.status < 10 ? Colors.red : Colors.grey[300],
            onTap: () {
              if (WorkOverTimeSData.status < 10) _removeItem(item);
            },
          )
      ],
      child: InkWell(
        onTap: () {
          WorkOverTimeSData.isAdd = false;
          WorkOverTimeSData.pressIndex = index;
          Navigator.pushNamed(context, workOverTimeAddPath).then((value) {
            setState(() {});
          });
        },
        child: customContainer(
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      customText(value: item.name, fontSize: 14),
                      customText(value: item.posi, fontSize: 14),
                      customText(value: item.typeName, fontSize: 14),
                      customText(value: item.reason, fontSize: 14),
                    ],
                  )),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    customText(
                        value: Utils.dateTimeToStrWithPattern(
                            item.beginDate, 'yyyy-MM-dd HH:mm'),
                        fontSize: 14),
                    customText(
                        value: Utils.dateTimeToStrWithPattern(
                            item.endDate, 'yyyy-MM-dd HH:mm'),
                        fontSize: 14),
                    Container(
                        padding: EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(5)),
                        child: customText(
                            value: '共${item.time}小时',
                            color: Colors.blue,
                            fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _removeItem(OverTimeDetail item) async {
    // bool result = await DialogUtils.showConfirmDialog(context, '是否移除该加班人员?');
    // if (result) {
    setState(() {
      WorkOverTimeSData.detailList.remove(item);
    });
    // }
  }

  Widget _draftButtons() {
    bool visible = _headData.overTimeId == 0 ? false : true;
    return Container(
      child: Row(
        children: <Widget>[
          if (visible) customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
          customButtom(Colors.green, '提交', _submit),
        ],
      ),
    );
  }

  Widget _submitButtons() {
    return Container(
      child: Row(
        children: <Widget>[
          customButtom(Colors.orange[300], '取消提交', _toDraft),
        ],
      ),
    );
  }

  //删除
  void _delete() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否删除该条记录?',
        iconData: Icons.info, color: Colors.red);
    if (result) _request('delete');
  }

  ///保存,修改
  void _save() {
    _request(_headData.overTimeId == 0 ? 'add' : 'update');
  }

  ///提交
  void _submit() {
    _request('submit');
  }

  //取消提交
  void _toDraft() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否取消提交?',
        iconData: Icons.info, color: Colors.red);
    if (result) _request('todraft');
  }

  ///获取地区下拉数据
  void _getDropDownList() {
    _areaItems.clear();
    WorkOverTimeSData.areaList.forEach((element) {
      _areaItems.add(
        DropdownMenuItem(
          value: element.areaId,
          child: customText(
              value: element.shortName,
              fontSize: 15.5,
              color: element.areaId == _headData.areaId
                  ? Colors.blue
                  : Colors.black),
        ),
      );
    });
  }

  ///获取详细数据
  void _initData() async {
    if (_headData.overTimeId == 0) {
      setState(() {
        _getBaseData();
        _headData.areaId = WorkOverTimeSData.userStaff[0].defaultAreaId;
      });
    } else {
      var dismiss = FLToast.loading();
      try {
        await WorkOverTimeService.getDetailData(_headData.overTimeId)
            .then((value) {
          if (value.errCode == 0) {
            _headData = value.headData;
            WorkOverTimeSData.status = _headData.status;
            WorkOverTimeSData.curDeptId = _headData.deptId;
            WorkOverTimeSData.detailList = value.detailList;
            if (WorkOverTimeSData.isCopy) _isCopy();
            setState(() {});
          } else {
            var msg = value.errMsg;
            DialogUtils.showAlertDialog(context, msg);
          }
        });
      } catch (e) {
        dismiss();
      } finally {
        dismiss();
      }
    }
  }

  void _isCopy() {
    _headData.status = 0;
    WorkOverTimeSData.status = 0;
    _headData.statusName = '草稿';
    _headData.applyDate = Utils.today;
    _headData.overTimeId = 0;
    WorkOverTimeSData.detailList.forEach((element) {
      if (element.beginDate.isBefore(DateTime.now())) {
        int year = DateTime.now().year;
        int month = DateTime.now().month;
        int day = DateTime.now().day;
        element.beginDate = DateTime(
            year, month, day, element.beginDate.hour, element.beginDate.minute);
        element.endDate = DateTime(
            year, month, day, element.endDate.hour, element.endDate.minute);
      }
    });
  }

  void _getBaseData() {
    StaffInfo userInfo = WorkOverTimeSData.userStaff[0];
    _headData.areaId = userInfo.defaultAreaId;
    _headData.deptId = userInfo.deptId;
    WorkOverTimeSData.status = _headData.status;
    WorkOverTimeSData.curDeptId = userInfo.deptId;
    _headData.deptName = WorkOverTimeSData.userStaff[0].deptName;
    WorkOverTimeSData.detailList.clear();
  }

  void _request(String action) async {
    setPageDataChanged(this.widget, true);
    try {
      // var dismiss = FLToast.loading(text: 'Loading...');
      await _progressDialog?.show();
      OverTimeDetaiModel responseData;
      List<OverTimeDetail> list = WorkOverTimeSData.detailList;
      switch (action) {
        case 'add':
          responseData = await WorkOverTimeService.requestService(
              'add', _headData, list, false);
          break;
        case 'update':
          responseData = await WorkOverTimeService.requestService(
              'update', _headData, list, false);
          break;
        case 'submit':
          responseData = _headData.overTimeId == 0
              ? await WorkOverTimeService.requestService(
                  'add', _headData, list, true)
              : await WorkOverTimeService.requestService(
                  'update', _headData, list, true);
          break;
        case 'delete':
          responseData = await WorkOverTimeService.deleteOrToDraft(
              'delete', _headData.overTimeId);
          break;
        case 'todraft':
          responseData = await WorkOverTimeService.deleteOrToDraft(
              'todraft', _headData.overTimeId);
          break;
        default:
      }
      int errCode = responseData.errCode;
      String errMsg = responseData.errMsg;
      if (errCode == 0) {
        // dismiss();
        await _progressDialog?.hide();
        if (action == 'add' || action == 'update') {
          toastBlackStyle('保存成功!');
        } else if (action == 'submit') {
          toastBlackStyle('提交成功!');
        } else if (action == 'delete') {
          toastBlackStyle('删除成功');
          Navigator.pop(context);
        } else if (action == 'todraft') {
          toastBlackStyle('取消成功!');
        }
        setState(() {
          _headData = responseData.headData;
          WorkOverTimeSData.status = _headData.status;
          WorkOverTimeSData.curDeptId = _headData.deptId;
          WorkOverTimeSData.detailList = responseData.detailList;
        });
      } else {
        // dismiss();
        await _progressDialog?.hide();
        DialogUtils.showAlertDialog(context, errMsg);
      }
    } catch (e) {
      // toastBlackStyle(e.toString());
    } finally {
      await _progressDialog?.hide();
    }
  }
}
