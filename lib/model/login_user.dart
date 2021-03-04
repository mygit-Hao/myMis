import 'package:mis_app/model/dept.dart';
import 'package:mis_app/model/login_info.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/staff_info.dart';
import 'package:mis_app/utils/utils.dart';

class LoginUserModel {
  String userId;
  int oaAreaId;
  int _staffId;
  String userName;
  String fullName;
  String key;
  String devId;
  bool canViewAreaCust;
  bool canNewSalesOrder;
  bool needSignature;
  String tempToken;
  StaffInfo staffInfo;
  StaffModel _staff;
  DeptModel _dept;

  static const String _undefinedName = '(未指定)';

  LoginUserModel() {
    clearInfo();
  }

  LoginUserModel.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    userName = json['UserName'];
    fullName = json['FullName'];
  }

  StaffModel get staff {
    if (_staff == null) {
      _staff = StaffModel(
          staffId: staffId,
          deptId: deptId,
          name: staffName,
          deptName: deptName);
    }

    return _staff;
  }

  DeptModel get dept {
    if (_dept == null) {
      _dept = DeptModel(deptId: deptId, name: deptName);
    }

    return _dept;
  }

  void clearInfo() {
    userId = '';
    userName = '';
    fullName = '';
    tempToken = '';
    canViewAreaCust = false;
    canNewSalesOrder = false;
    needSignature = false;
  }

  String get staffName {
    String name;
    if (staffInfo != null) {
      name = staffInfo.staffName;
    }
    if (Utils.textIsEmptyOrWhiteSpace(name)) {
      name = _undefinedName;
    }

    return name;
  }

  int get deptId {
    int id;
    if (staffInfo != null) {
      id = staffInfo.deptId;
    }

    return id;
  }

  String get deptName {
    String name;
    if (staffInfo != null) {
      name = staffInfo.deptName;
    }

    if (Utils.textIsEmptyOrWhiteSpace(name)) {
      name = _undefinedName;
    }

    return name;
  }

  bool get canViewAllAttendance {
    if (staffInfo != null) {
      return staffInfo.canViewAllAttendance;
    }

    return false;
  }

  void setStaffId(String id) {
    String s = id ?? '';
    this._staffId = int.tryParse(s.trim()) ?? 0;
  }

  int get staffId {
    return _staffId;
  }

  /*
  UserModel.fromLoginInfo(LoginInfo info) {
    // String userStaffId = info.userDStaffId ?? '';

    userId = info.userId;
    userName = info.userName;
    // staffId = info.userDStaffId;
    // _staffId = int.tryParse(userStaffId.trim()) ?? 0;
    setStaffId(info.userDStaffId);
    fullName = info.userDStaffName;
  }
  */

  void setLoginInfo(LoginInfo info) {
    userId = info.userId;
    oaAreaId = info.oaAreaId;
    userName = info.userName;
    fullName = info.userDStaffName;
    canViewAreaCust = info.canViewAreaCust;
    canNewSalesOrder = info.canNewSalesOrder;
    needSignature = info.needSignature;
    tempToken = info.tempToken;

    setStaffId(info.userDStaffId);
    if ((info.staffInfo != null) && (info.staffInfo.length > 0)) {
      staffInfo = info.staffInfo[0];
    }

    // print('staffInfo: $staffInfo');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserId'] = this.userId;
    data['UserName'] = this.userName;
    data['FullName'] = this.fullName;

    return data;
  }

  @override
  String toString() {
    // return 'userId:$userId fullName:$fullName loginStatus:$loginStatus';
    return 'userId:$userId fullName:$fullName';
  }
}
