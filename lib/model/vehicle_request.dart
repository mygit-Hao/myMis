import 'package:mis_app/model/vehicle_request_base_db.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/utils.dart';

class VehicleRequestListWrapper {
  List<VehicleRequestModel> list;
  List<RequestTypeModel> requestType;
  List<VehicleModel> vehicle;
  List<DriverModel> driver;

  VehicleRequestListWrapper(
      {this.list, this.requestType, this.vehicle, this.driver});

  VehicleRequestListWrapper.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list = new List<VehicleRequestModel>();
      json['List'].forEach((v) {
        list.add(new VehicleRequestModel.fromJson(v));
      });
    }
    if (json['RequestType'] != null) {
      requestType = new List<RequestTypeModel>();
      json['RequestType'].forEach((v) {
        requestType.add(new RequestTypeModel.fromJson(v));
      });
    }
    if (json['Vehicle'] != null) {
      vehicle = new List<VehicleModel>();
      json['Vehicle'].forEach((v) {
        vehicle.add(new VehicleModel.fromJson(v));
      });
    }
    if (json['Driver'] != null) {
      driver = new List<DriverModel>();
      json['Driver'].forEach((v) {
        driver.add(new DriverModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.list != null) {
      data['List'] = this.list.map((v) => v.toJson()).toList();
    }
    if (this.requestType != null) {
      data['RequestType'] = this.requestType.map((v) => v.toJson()).toList();
    }
    if (this.vehicle != null) {
      data['Vehicle'] = this.vehicle.map((v) => v.toJson()).toList();
    }
    if (this.driver != null) {
      data['Driver'] = this.driver.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VehicleRequestModel {
  static const int _statusDraft = 0;
  static const int _statusSubmit = 10;
  static const String _statusDraftName = '草稿';

  int seqNo;
  int vehicleRequestId;
  int areaId;
  int deptId;
  int status;
  DateTime startTime;
  DateTime finishTime;
  String requestName;
  String deptName;
  int retinue;
  String origin;
  String destination;
  String reason;
  bool selfDriving;
  String driverName;
  String vehicleName;
  String statusName;
  int usingDays;
  double usingHours;
  bool scheduled;
  bool canModifySchedule;
  String retinueList;
  String halfway;
  String requestType;
  String carType;
  int vehicleId;
  int driverStaffId;
  int requestStaffId;
  String createUserId;

  static String getTitle(bool shifting) {
    return shifting ? "出车变更" : "车辆调度";
  }

  bool get isNew {
    return (this.vehicleRequestId == null) || (this.vehicleRequestId <= 0);
  }

  bool get owned {
    return isNew ||
        (Utils.sameText(this.createUserId, UserProvide.currentUserId,
            ignoreWhiteSpace: true));
  }

  bool get userCanModify {
    return (this.status == _statusDraft) && owned;
  }

  bool get userCanOperate {
    return this.status <= _statusSubmit && owned;
  }

  bool get sumitted {
    return this.status >= _statusSubmit;
  }

  String get usingTime {
    /*
    if (this.usingDays <= 0) {
      return '${Utils.getNumberStr(this.usingHours)}小时';
    }

    return '${this.usingDays}天${Utils.getNumberStr(this.usingHours)}小时';
    */

    if (this.startTime.isAfter(this.finishTime)) return '';

    Duration duration = this.finishTime.difference(this.startTime);
    int days = duration.inDays;
    double hours = (duration.inMinutes - days * 60 * 24) / 60;

    String result = '';

    if (days > 0) {
      result = '$days天';
    }

    if ((hours > 0) || (days == 0)) {
      result = result + '${Utils.getNumberStr(hours)}小时';
    }

    return result;
  }

  VehicleRequestModel(
      {this.seqNo = 0,
      this.vehicleRequestId = 0,
      this.areaId = 0,
      this.deptId = 0,
      this.status = 0,
      this.startTime,
      this.finishTime,
      this.requestName = '',
      this.deptName = '',
      this.retinue = 0,
      this.origin = '',
      this.destination = '',
      this.reason = '',
      this.selfDriving = false,
      this.driverName,
      this.vehicleName,
      this.statusName = _statusDraftName,
      this.usingDays = 0,
      this.usingHours = 0,
      this.scheduled = false,
      this.canModifySchedule = false,
      this.retinueList = '',
      this.halfway = '',
      this.requestType,
      this.carType,
      this.vehicleId = 0,
      this.driverStaffId = 0,
      this.requestStaffId,
      this.createUserId});

  VehicleRequestModel.fromJson(Map<String, dynamic> json) {
    seqNo = json['i_SeqNo'];
    vehicleRequestId = int.parse(json['i_VehicleRequestID']);
    areaId = json['i_AreaId'];
    deptId = json['i_DeptID'];
    status = json['i_Status'];
    startTime = DateTime.parse(json['dt_Start']);
    finishTime = DateTime.parse(json['dt_Finish']);
    requestName = json['nc_RequestName'];
    deptName = json['nc_DeptName'];
    retinue = json['i_Retinue'];
    origin = json['nc_Origin'];
    destination = json['nc_Destination'];
    reason = json['nc_Reason'];
    selfDriving = json['b_SelfDriving'] ?? false;
    driverName = json['nc_DriverName'];
    vehicleName = json['nc_VehicleName'];
    statusName = json['nc_StatusName'];
    usingDays = json['i_UsingDays'] ?? 0;
    usingHours = json['n_UsingHours'] ?? 0;
    scheduled = json['b_Scheduled'] ?? false;
    canModifySchedule = json['b_CanModifySchedule'] ?? false;
    retinueList = json['nc_RetinueList'];
    halfway = json['nc_Halfway'];
    requestType = json['nc_RequestType'];
    carType = json['nc_CarType'];
    vehicleId = json['i_VehicleID'];
    driverStaffId = json['i_DriverStaffID'];
    requestStaffId = json['i_RequestStaffId'];
    createUserId = json['CreateUserId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['i_SeqNo'] = this.seqNo;
    data['i_VehicleRequestID'] = this.vehicleRequestId;
    data['i_AreaId'] = this.areaId;
    data['i_DeptID'] = this.deptId;
    data['i_Status'] = this.status;
    data['dt_Start'] = this.startTime.toIso8601String();
    data['dt_Finish'] = this.finishTime.toIso8601String();
    data['nc_RequestName'] = this.requestName;
    data['nc_DeptName'] = this.deptName;
    data['i_Retinue'] = this.retinue;
    data['nc_Origin'] = this.origin;
    data['nc_Destination'] = this.destination;
    data['nc_Reason'] = this.reason;
    data['b_SelfDriving'] = this.selfDriving;
    data['nc_DriverName'] = this.driverName;
    data['nc_VehicleName'] = this.vehicleName;
    data['nc_StatusName'] = this.statusName;
    data['i_UsingDays'] = this.usingDays;
    data['n_UsingHours'] = this.usingHours;
    data['b_Scheduled'] = this.scheduled;
    data['b_CanModifySchedule'] = this.canModifySchedule;
    data['nc_RetinueList'] = this.retinueList;
    data['nc_Halfway'] = this.halfway;
    data['nc_RequestType'] = this.requestType;
    data['nc_CarType'] = this.carType;
    data['i_VehicleID'] = this.vehicleId;
    data['i_DriverStaffID'] = this.driverStaffId;
    data['i_RequestStaffId'] = this.requestStaffId;
    data['CreateUserId'] = this.createUserId;

    //为了在服务端能正常反序列
    data['eqNo'] = this.seqNo;
    data['VehicleRequestID'] = this.vehicleRequestId;
    data['AreaId'] = this.areaId;
    data['DeptId'] = this.deptId;
    data['Status'] = this.status;
    data['Start'] = this.startTime.toIso8601String();
    data['Finish'] = this.finishTime.toIso8601String();
    data['RequestName'] = this.requestName;
    data['DeptName'] = this.deptName;
    data['Retinue'] = this.retinue;
    data['Origin'] = this.origin;
    data['Destination'] = this.destination;
    data['Reason'] = this.reason;
    data['SelfDriving'] = this.selfDriving;
    data['DriverName'] = this.driverName;
    data['VehicleName'] = this.vehicleName;
    data['StatusName'] = this.statusName;
    data['UsingDays'] = this.usingDays;
    data['UsingHours'] = this.usingHours;
    data['Scheduled'] = this.scheduled;
    data['CanModifySchedule'] = this.canModifySchedule;
    data['RetinueList'] = this.retinueList;
    data['Halfway'] = this.halfway;
    data['RequestType'] = this.requestType;
    data['CarType'] = this.carType;
    data['VehicleID'] = this.vehicleId;
    data['DriverStaffID'] = this.driverStaffId;
    data['RequestStaffId'] = this.requestStaffId;
    return data;
  }
}
