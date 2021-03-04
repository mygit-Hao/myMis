import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/vehicle_request.dart';
import 'package:mis_app/model/vehicle_request_base_db.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/oa_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/box_container.dart';
import 'package:mis_app/widget/custom_button.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/single_line_info.dart';
import 'package:progress_dialog/progress_dialog.dart';

class VehicleRequestDetailPage extends StatefulWidget {
  final Map arguments;
  VehicleRequestDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _VehicleRequestDetailPageState createState() =>
      _VehicleRequestDetailPageState();
}

class _VehicleRequestDetailPageState extends State<VehicleRequestDetailPage> {
  VehicleRequestModel _request;
  List<RequestTypeModel> _requestTypeList = [];
  List<VehicleModel> _vehicleList = [];
  List<DriverModel> _driverList = [];
  List<DriverModel> _applicantList = [];
  List<DriverModel> _selectingDriverList = [];
  RequestTypeModel _selectedRequestType;
  VehicleModel _selectedVehicle;
  DriverModel _selectedDriver;
  int _selectedVehicleType;
  bool _selectingSourceIsApplicant;
  bool _modifying;
  bool _shifting;

  TextStyle _menuItemStyle = TextStyle(
    fontSize: fontSizeDetail,
    color: Colors.white,
  );
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _modifying = false;
    _shifting = false;

    _request = VehicleRequestModel();
    _requestTypeList = DataCache.requestTypeList;
    _setVehicleType(VehicleModel.vehicleTypePublic);
    _driverList = DataCache.driverList;
    _setDriverList();

    Map arguments = widget.arguments;
    if (arguments != null) {
      int requestId = arguments['vehicleRequestId'];
      _shifting = arguments['shifting'];

      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData(requestId);
      });
    }
  }

  void _loadData(int vehicleRequestId) async {
    if (vehicleRequestId == null) return;

    await _progressDialog?.show();
    try {
      _request = await OaService.getVehicleRequest(vehicleRequestId);
      _updateRequest();
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _updateRequest() {
    _selectedRequestType = _findVehicleRequestType(_request.requestType);
    _selectedVehicle = _findVehicle(_request.vehicleId);

    _initApplicantList();
    _setDriverList();

    _selectedDriver = _findDriver(_request.driverStaffId);

    _modifying = !_request.scheduled;
    setState(() {});
  }

  RequestTypeModel _findVehicleRequestType(String vehicleRequestTypeCode) {
    /*
    RequestTypeModel result;

    if (vehicleRequestTypeCode != null) {
      vehicleRequestTypeCode = vehicleRequestTypeCode.trim();

      for (RequestTypeModel item in _requestTypeList) {
        if (Utils.sameText(item.code, vehicleRequestTypeCode)) {
          result = item;
          break;
        }
      }
    }

    return result;
    */

    if (vehicleRequestTypeCode != null) {
      return _requestTypeList.firstWhere(
          (element) =>
              Utils.sameText(element.code, vehicleRequestTypeCode.trim()),
          orElse: () => null);
    }

    return null;
  }

  VehicleModel _findVehicle(int vehicleId) {
    if (vehicleId != null) {
      return _vehicleList.firstWhere(
          (element) => element.vehicleId == vehicleId,
          orElse: () => null);
    }

    return null;
  }

  DriverModel _findDriver(int staffId) {
    if (staffId != null) {
      return _selectingDriverList.firstWhere(
          (element) => element.staffId == staffId,
          orElse: () => null);
    }

    return null;
  }

  void _setDriverList() {
    bool selectingSourceIsApplicant = (_selectedRequestType != null) &&
        (_selectedRequestType.selectingSourceIsApplicant);

    if (selectingSourceIsApplicant != _selectingSourceIsApplicant) {
      _selectingDriverList =
          selectingSourceIsApplicant ? _applicantList : _driverList;
      _selectingSourceIsApplicant = selectingSourceIsApplicant;
      _selectedDriver = null;
    }
  }

  void _initApplicantList() {
    //把非专职司机列表清空，再把申请人加进
    _applicantList.clear();
    _addApplicant(_request.requestStaffId, _request.requestName);
    if ((_selectedRequestType != null) &&
        (_selectedRequestType.selectingSourceIsApplicant)) {
      //如果之前选择过非专职司机，把已设置的司机也加进列表
      _addApplicant(_request.driverStaffId, _request.driverName);
    }
  }

  DriverModel _addApplicant(int staffId, String staffName) {
    Iterable<DriverModel> list =
        _applicantList.where((element) => element.staffId == staffId);
    if (list.length > 0) {
      return list.toList()[0];
    }

    DriverModel driver = DriverModel(staffId: staffId, name: staffName);
    _applicantList.add(driver);

    return driver;
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(VehicleRequestModel.getTitle(_shifting)),
      ),
      body: SafeArea(
        child: _mainWidget,
      ),
    );
  }

  Widget get _mainWidget {
    return Container(
      child: Column(
        children: <Widget>[
          _infoWidget,
          _canModify ? _editingArea : IgnorePointer(child: _editingArea),
          _buttons,
        ],
      ),
    );
  }

  bool get _canSearchDriver {
    bool canChangeDriver = _canModify && _modifying;
    return canChangeDriver &&
        (_selectedRequestType != null) &&
        _selectedRequestType.canSearchDriver;
  }

  bool get _canModify {
    return _request.canModifySchedule && _modifying;
  }

  bool get _selectedSelfDriving {
    return _selectedRequestType != null && (_selectedRequestType.selfDriving);
  }

  Widget get _buttons {
    if (_request.scheduled) {
      if (_modifying) {
        return _modifyButtons;
      } else {
        return _scheduledButtons;
      }
    } else {
      if (!_shifting) {
        return _scheduleButtons;
      }
    }

    return Container();
  }

  Widget get _scheduleButtons {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomButton(
              title: '确定调度',
              onPressed: _confirmSchedule,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _scheduledButtons {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomButton(
              title: '修改调度',
              onPressed: _request.canModifySchedule ? _beginModify : null,
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: CustomButton(
              title: '取消调度',
              onPressed: _request.canModifySchedule && (!_shifting)
                  ? _cancelSchedule
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _beginModify() {
    setState(() {
      _modifying = true;
    });
  }

  void _cancelSchedule() async {
    if (await DialogUtils.showConfirmDialog(context, '确定要取消调度吗？',
        confirmTextColor: Colors.red)) {
      setPageDataChanged(this.widget, true);
      _request =
          await OaService.cancelVehicleRequest(_request.vehicleRequestId);
      _updateRequest();
    }
  }

  Widget get _modifyButtons {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: CustomButton(
              title: '取消',
              onPressed: () {
                setState(() {
                  _modifying = false;
                });
              },
            ),
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: CustomButton(
              title: '确定调度',
              onPressed: _confirmSchedule,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSchedule() async {
    if ((_request.vehicleRequestId <= 0) || (!_request.canModifySchedule))
      return;

    if (_selectedRequestType == null) {
      DialogUtils.showToast('请选择类别');
      return;
    }

    if (_selectedVehicle == null) {
      DialogUtils.showToast('请选择车辆');
      return;
    }

    if ((!_selectedSelfDriving) && (_selectedDriver == null)) {
      DialogUtils.showToast('请选择驾驶员');
      return;
    }

    _request.requestType = _selectedRequestType.code;
    _request.vehicleId = _selectedVehicle.vehicleId;
    _request.driverStaffId =
        _selectedDriver == null ? null : _selectedDriver.staffId;

    setPageDataChanged(this.widget, true);
    _request = await OaService.updateVehicleRequest(_request, _shifting);
    _updateRequest();
  }

  Widget get _editingArea {
    return Container(
      color: Theme.of(context).backgroundColor,
      margin: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Column(
        children: <Widget>[
          _requestTypeRow,
          _vehicleRow,
          _driverRow,
        ],
      ),
    );
  }

  Widget get _requestTypeRow {
    return Row(
      children: <Widget>[
        LabelText(
          '类别：',
          color: Colors.white,
        ),
        Expanded(
          child: DropdownButton<RequestTypeModel>(
            dropdownColor: Theme.of(context).backgroundColor,
            value: _selectedRequestType,
            items: _requestTypeList.map((RequestTypeModel item) {
              return DropdownMenuItem(
                child: Text(
                  item.name,
                  style: _menuItemStyle,
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (RequestTypeModel value) {
              _selectedRequestType = value;
              _setVehicleType(_selectedRequestType.vehicleType);
              _setDriverList();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  void _setVehicleType(int vehicleType) {
    if (_selectedVehicleType != vehicleType) {
      _vehicleList = DataCache.getVehicleList(vehicleType);
      _selectedVehicle = null;
      _selectedVehicleType = vehicleType;
    }
  }

  Widget get _vehicleRow {
    return Row(
      children: <Widget>[
        LabelText(
          '车辆：',
          color: Colors.white,
        ),
        Expanded(
          child: DropdownButton<VehicleModel>(
            dropdownColor: Theme.of(context).backgroundColor,
            value: _selectedVehicle,
            items: _vehicleList.map((VehicleModel item) {
              return DropdownMenuItem(
                child: Text(
                  item.name,
                  style: _menuItemStyle,
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (VehicleModel value) {
              setState(() {
                _selectedVehicle = value;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget get _driverRow {
    return Row(
      children: <Widget>[
        LabelText(
          '驾驶员：',
          color: Colors.white,
        ),
        Expanded(
          child: DropdownButton<DriverModel>(
            dropdownColor: Theme.of(context).backgroundColor,
            value: _selectedDriver,
            items: _selectingDriverList.map((DriverModel item) {
              return DropdownMenuItem(
                child: Text(
                  item.name,
                  style: _menuItemStyle,
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (DriverModel value) {
              setState(() {
                _selectedDriver = value;
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: _canSearchDriver
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor,
          ),
          onPressed: _canSearchDriver ? _searchDriver : null,
        ),
      ],
    );
  }

  void _searchDriver() async {
    if (!_canSearchDriver) return;
    var result = await showSearch(
      context: context,
      delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff),
    );

    if (result == null) return;

    StaffModel staff = StaffModel.fromJson(json.decode(result));
    DriverModel driver = _addApplicant(staff.staffId, staff.name);
    _selectedDriver = driver;

    setState(() {});
  }

  Widget get _infoWidget {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: BoxContainer(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(child: SingleLineInfo('部门：', _request.deptName)),
                Expanded(child: SingleLineInfo('申请人：', _request.requestName)),
              ],
            ),
            SingleLineInfo('随行人数：', '${_request.retinue}'),
            SingleLineInfo('随行人员：', '${_request.retinueList}'),
            SingleLineInfo('出发时间：',
                '${Utils.dateTimeToStrWithPattern(_request.startTime, formatPatternDateTime)}'),
            SingleLineInfo('返回时间：',
                '${Utils.dateTimeToStrWithPattern(_request.finishTime, formatPatternDateTime)}'),
            SingleLineInfo('所需时间：', '${_request.usingTime}'),
            Row(
              children: <Widget>[
                Expanded(child: SingleLineInfo('出发地点：', _request.origin)),
                Expanded(child: SingleLineInfo('目的地点：', _request.destination)),
              ],
            ),
            SingleLineInfo('途经地点：', '${_request.halfway}'),
            SingleLineInfo('事由：', '${_request.reason}'),
            Text(
              _request.statusName,
              style: TextStyle(
                color: _request.scheduled ? Colors.blue : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
