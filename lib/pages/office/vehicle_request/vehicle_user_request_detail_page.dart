import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/dept.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/vehicle_request.dart';
import 'package:mis_app/model/vehicle_request_base_db.dart';
import 'package:mis_app/pages/common/search_dept.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/hrms_service.dart';
import 'package:mis_app/service/oa_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/critical_button.dart';
import 'package:mis_app/widget/custom_outline_button.dart';
import 'package:mis_app/widget/date_time_view.dart';
import 'package:mis_app/widget/dense_text_field.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/remarks_text_field.dart';
import 'package:mis_app/widget/underline_container.dart';
import 'package:progress_dialog/progress_dialog.dart';

class VehicleUserRequestDetailPage extends StatefulWidget {
  final Map arguments;
  VehicleUserRequestDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _VehicleUserRequestDetailPageState createState() =>
      _VehicleUserRequestDetailPageState();
}

class _VehicleUserRequestDetailPageState
    extends State<VehicleUserRequestDetailPage> {
  int _vehicleRequestId;
  List<Area> _areaList = [];
  Area _selectedArea;
  CarTypeModel _selectedCarType;
  DeptModel _selectedDept;
  StaffModel _selectedRequestStaff;
  List<StaffModel> _staffList = [StaffModel(staffId: -1, name: '(请选择)')];
  VehicleRequestModel _request;
  TextStyle _textStyle = TextStyle(
    fontSize: fontSizeDetail,
  );
  TextEditingController _retinueController = TextEditingController();
  TextEditingController _retinueListController = TextEditingController();
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _originalController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();
  TextEditingController _halfwayController = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _areaList = UserProvide.oaAreaList;

    Map arguments = widget.arguments;
    if (arguments != null) {
      _vehicleRequestId = arguments['vehicleRequestId'];
    }

    if ((_vehicleRequestId != null) && (_vehicleRequestId > 0)) {
      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData();
      });
    } else {
      _initNewRequest();
    }
  }

  void _initNewRequest() {
    DateTime startTime = Utils.today.replaceTime(TimeOfDay(hour: 8, minute: 0));
    VehicleRequestModel request = VehicleRequestModel(
        startTime: startTime,
        finishTime: startTime,
        retinue: 1,
        areaId: UserProvide.oaAreaId,
        deptId: UserProvide.currentUser.deptId);
    _updateRequest(request);
    _initStaffList(deptId: UserProvide.currentUser.staff.deptId);
  }

  void _initStaffList({int deptId}) async {
    List<StaffModel> list;
    if (deptId != null) {
      list = await HrmsService.getStaffList(
        '',
        deptId: deptId,
        includeBranch: true,
      );
    }

    _staffList.clear();
    _addToStaffList(_selectedRequestStaff);
    _addToStaffList(UserProvide.currentUser.staff);

    if (list != null) {
      for (StaffModel item in list) {
        _addToStaffList(item);
      }
    }

    if (_selectedRequestStaff == null) {
      _selectedRequestStaff = UserProvide.currentUser.staff;
    }

    setState(() {});
  }

  void _loadData() async {
    if (_vehicleRequestId == null) return;

    await _progressDialog?.show();
    try {
      VehicleRequestModel request =
          await OaService.getVehicleRequest(_vehicleRequestId);
      _updateRequest(request);
      if (_request != null) {
        _selectedRequestStaff = StaffModel(
            staffId: _request.requestStaffId, name: _request.requestName);
        _initStaffList();
      }
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _updateRequest(VehicleRequestModel request) {
    if (request == null) return;

    _request = request;

    _selectedArea = UserProvide.findOaArea(_request.areaId);
    if ((_selectedDept == null) || (_selectedDept.deptId != _request.deptId)) {
      _selectedDept = _request.isNew
          ? UserProvide.currentUser.dept
          : DeptModel(deptId: _request.deptId, name: _request.deptName);
    }

    _selectedCarType = DataCache.findCarType(_request.carType);

    _retinueController.text = '${_request.retinue}';
    _retinueListController.text = _request.retinueList;
    _reasonController.text = _request.reason;
    _originalController.text = _request.origin;
    _destinationController.text = _request.destination;
    _halfwayController.text = _request.halfway;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return WillPopScope(
      onWillPop: () async {
        if ((_request != null) && (_request.isNew)) {
          if (!(await DialogUtils.showConfirmDialog(context, '确定要退出吗？',
              confirmText: '退出', confirmTextColor: Colors.red))) {
            return false;
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('用车申请'),
        ),
        body: SafeArea(
          child: _mainWidget,
        ),
      ),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        Expanded(
          child: (_request != null) && (_request.userCanModify)
              ? _editingArea
              : IgnorePointer(child: _editingArea),
        ),
        if ((_request != null) && (_request.userCanOperate)) _buttons,
      ],
    );
  }

  Widget get _editingArea {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: _areaWidget),
                Expanded(
                  child: Text(
                    _request == null ? '' : _request.statusName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSizeDetail,
                      color: (_request != null) && _request.scheduled
                          ? Colors.blue
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _carTypeWidget),
                Expanded(child: _deptWidget),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(child: _requestStaffWidget),
                Expanded(child: _retinueWidget),
              ],
            ),
            _retinueListWidget,
            _timeWidget,
            _locationWidget,
            SizedBox(height: 4.0),
            _reasonWidget,
          ],
        ),
      ),
    );
  }

  Widget get _buttons {
    bool userCanModify = (_request != null) && (_request.userCanModify);
    bool userCanDelete =
        (_request != null) && (_request.userCanModify) && (!_request.isNew);
    bool sumitted = (_request != null) && _request.sumitted;

    return Container(
      // color: Theme.of(context).backgroundColor,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: ButtonBar(
        // mainAxisAlignment: MainAxisAlignment.end,
        // alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (userCanDelete)
            CriticalButton(
              title: '删除',
              icon: Icons.delete,
              onPressed: _delete,
            ),
          if (userCanModify)
            CustomOutlineButton(
              label: '保存',
              icon: Icons.save,
              onPressed: () {
                _saveData(false);
              },
            ),
          // SizedBox(width: 8.0),
          CustomOutlineButton(
            label: sumitted ? '取消提交' : '提交',
            icon: Icons.check_circle_outline,
            onPressed: () {
              if (sumitted) {
                _toDraft();
              } else {
                _saveData(true);
              }
            },
          ),
        ],
      ),
    );
  }

  void _delete() async {
    if (await DialogUtils.showConfirmDialog(context, '确定要删除当前申请吗？',
        confirmText: '删除', confirmTextColor: Colors.red)) {
      RequestResult result =
          await OaService.deleteVehicleRequest(_vehicleRequestId);
      if (result.success) {
        setPageDataChanged(this.widget, true);
        DialogUtils.showToast('申请已删除');
        Navigator.of(context).pop();
      } else {
        DialogUtils.showToast(result.msg);
      }
    }
  }

  void _toDraft() async {
    if (await DialogUtils.showConfirmDialog(context, '确定要取消提交吗？',
        confirmTextColor: Colors.red)) {
      setPageDataChanged(this.widget, true);
      VehicleRequestModel result =
          await OaService.vehicleRequestToDraft(_request.vehicleRequestId);
      _updateRequest(result);
    }
  }

  void _saveData(bool toSubmit) {
    if (!_checkTimeValid(_request.startTime, _request.finishTime)) {
      return;
    }

    if (_selectedArea == null) {
      DialogUtils.showToast('请选择项目');
      return;
    }

    if (_selectedDept == null) {
      DialogUtils.showToast('请选择部门');
      return;
    }

    if (_selectedRequestStaff == null) {
      DialogUtils.showToast('请选择申请人');
      return;
    }

    if (_selectedCarType == null) {
      DialogUtils.showToast('请选择车辆类型');
      return;
    }

    int retinue = int.tryParse(_retinueController.text);
    if (retinue != null) {
      _request.retinue = retinue;
    }

    _request.areaId = _selectedArea.areaId;
    _request.deptId = _selectedDept.deptId;
    _request.requestStaffId = _selectedRequestStaff.staffId;
    _request.carType = _selectedCarType.carType;
    _request.retinueList = _retinueListController.text;
    _request.origin = _originalController.text;
    _request.destination = _destinationController.text;
    _request.halfway = _halfwayController.text;
    _request.reason = _reasonController.text;

    if (_request.retinue < 1) {
      DialogUtils.showToast('请输入随行人数');
      return;
    }

    if ((_request.retinue > 1) &&
        (Utils.textIsEmptyOrWhiteSpace(_request.retinueList))) {
      DialogUtils.showToast('请输入随行人员');
      return;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_request.origin)) {
      DialogUtils.showToast('请输入出发地点');
      return;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_request.destination)) {
      DialogUtils.showToast('请输入目的地');
      return;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_request.reason)) {
      DialogUtils.showToast('请输入事由');
      return;
    }

    _save(toSubmit);
  }

  void _save(bool toSubmit) async {
    setPageDataChanged(this.widget, true);
    VehicleRequestModel result =
        await OaService.updateUserVehicleRequest(_request, toSubmit: toSubmit);
    if (result != null) {
      DialogUtils.showToast(toSubmit ? '申请已提交' : '申请已保存');
    }
    _updateRequest(result);
  }

  Widget get _reasonWidget {
    return RemarksTextField(
      hintText: '请输入事由',
      controller: _reasonController,
    );
  }

  Widget get _locationWidget {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  LabelText('出发地点：'),
                  Expanded(
                    child: DenseTextField(
                      style: _textStyle,
                      controller: _originalController,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  LabelText('目的地：'),
                  Expanded(
                    child: DenseTextField(
                      style: _textStyle,
                      controller: _destinationController,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            LabelText('途经：'),
            Expanded(
              child: DenseTextField(
                style: _textStyle,
                controller: _halfwayController,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget get _timeWidget {
    return Row(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  LabelText('出发时间：'),
                  DateTimeView(
                    value: _request?.startTime,
                    onDateTap: () {
                      DialogUtils.showDatePickerDialog(
                          context, _request.startTime, onValue: (DateTime val) {
                        _request.startTime =
                            _request.startTime.replaceDate(val);
                        if (_request.startTime.isAfter(_request.finishTime)) {
                          _request.finishTime = _request.finishTime
                              .replaceDate(_request.startTime);
                        }

                        setState(() {});
                      });
                    },
                    onTimeTap: () {
                      DialogUtils.showTimePickerDialog(
                          context, _request.startTime,
                          initialTime: _request.startTime.time,
                          onValue: (TimeOfDay val) {
                        setState(() {
                          _request.startTime =
                              _request.startTime.replaceTime(val);
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
              child: Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  LabelText('返回时间：'),
                  DateTimeView(
                    value: _request?.finishTime,
                    onDateTap: () {
                      DialogUtils.showDatePickerDialog(
                          context, _request.finishTime,
                          onValue: (DateTime val) {
                        setState(() {
                          _request.finishTime =
                              _request.finishTime.replaceDate(val);
                        });
                      });
                    },
                    onTimeTap: () {
                      DialogUtils.showTimePickerDialog(
                          context, _request.finishTime,
                          initialTime: _request.finishTime.time,
                          onValue: (TimeOfDay val) {
                        setState(() {
                          _request.finishTime =
                              _request.finishTime.replaceTime(val);
                        });
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                LabelText(
                  '时间总计：',
                  fontSize: fontSizeDetail,
                ),
                // SizedBox(height: 4.0),
                Text(
                  _request?.usingTime ?? '',
                  style: TextStyle(
                    fontSize: fontSizeDetail,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _checkTimeValid(DateTime startTime, DateTime finishTime) {
    DateTime now = DateTime.now();
    if (startTime.isBefore(now) || finishTime.isBefore(now)) {
      DialogUtils.showToast('时间不能早于现在');
      return false;
    }

    if (!finishTime.isAfter(startTime)) {
      DialogUtils.showToast('返回时间必须晚于出发时间');
      return false;
    }

    return true;
  }

  Widget get _requestStaffWidget {
    return Row(
      children: <Widget>[
        LabelText('申请人：'),
        Expanded(
          child: DropdownButton<StaffModel>(
            value: _selectedRequestStaff,
            items: _staffList.map((StaffModel item) {
              return DropdownMenuItem(
                child: Text(
                  item.name,
                  style: _textStyle,
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (StaffModel value) {
              setState(() {
                _selectedRequestStaff = value;
              });
            },
          ),
        ),
        /*
        Expanded(
          child: UnderlineContainer(
            child: Text(
              _selectedRequestStaff == null ? '' : _selectedRequestStaff.name,
              style: TextStyle(decoration: TextDecoration.underline),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: _selectRequestStaff,
        ),
        */
      ],
    );
  }

  StaffModel _addToStaffList(StaffModel staff) {
    if (staff == null) return null;

    Iterable<StaffModel> list =
        _staffList.where((element) => element.staffId == staff.staffId);
    if (list.length > 0) {
      return list.toList()[0];
    }

    _staffList.add(staff);

    return staff;
  }

  Widget get _retinueWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          LabelText('随行人数：'),
          Expanded(
            child: DenseTextField(
              style: _textStyle,
              inputFormatters: [integerInputFormatter],
              keyboardType: TextInputType.number,
              controller: _retinueController,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _retinueListWidget {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        LabelText('人员姓名：'),
        Expanded(
          child: DenseTextField(
            style: _textStyle,
            controller: _retinueListController,
          ),
        ),
      ],
    );
  }

  Widget get _deptWidget {
    return Row(
      children: <Widget>[
        LabelText('部门：'),
        Expanded(
          child: UnderlineContainer(
            child: Text(
              _selectedDept == null ? '' : _selectedDept.name,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: _selectDept,
        ),
      ],
    );
  }

  void _selectDept() {
    showSearch(
      context: context,
      delegate: SearchDeptDelegate(Prefs.keyHistorySelectDept),
    ).then((value) {
      if (value == null) return;
      var data = json.decode(value);
      _selectedDept = DeptModel.fromJson(data);
      _initStaffList(deptId: _selectedDept.deptId);
      setState(() {});
    });
  }

  Widget get _carTypeWidget {
    return Row(
      children: <Widget>[
        LabelText('车辆类型：'),
        Expanded(
          child: DropdownButton<CarTypeModel>(
            value: _selectedCarType,
            items: DataCache.carTypeList.map((CarTypeModel item) {
              return DropdownMenuItem(
                child: Text(
                  item.carType,
                  style: _textStyle,
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (CarTypeModel value) {
              setState(() {
                _selectedCarType = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget get _areaWidget {
    return Row(
      children: <Widget>[
        LabelText('项目：'),
        Expanded(
          child: DropdownButton<Area>(
            value: _selectedArea,
            items: _areaList.map((Area item) {
              return DropdownMenuItem(
                child: Text(
                  item.shortName,
                  style: _textStyle,
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (Area value) {
              setState(() {
                _selectedArea = value;
              });
            },
          ),
        ),
      ],
    );
  }
}
