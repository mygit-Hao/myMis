import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/receivePhone.dart';

import 'base_db.dart';

class ReceiveBaseDB {
  static int staffID = 0;
  static String staffCode;
  static String staffName;
  static int deptId;
  static String deptName;
  static int areaId;
  static String posi;
  static List<Area> areaList;
  static List<Currency> currencyList;
  static List<ReceiveRoomBase> receiveRoom;
  static List<ReceivePerson> receivePerson;
}

class ReceiveBaseModel {
  List<Area> area;
  List<Currency> currency;
  List<UserStaff> userStaff;

  ReceiveBaseModel({this.area});

  ReceiveBaseModel.fromJson(Map<String, dynamic> json) {
    if (json['Area'] != null) {
      area = new List<Area>();
      json['Area'].forEach((v) {
        area.add(new Area.fromJson(v));
      });
    }
    if (json['Currency'] != null) {
      currency = new List<Currency>();
      json['Currency'].forEach((v) {
        currency.add(new Currency.fromJson(v));
      });
    }
    if (json['UserStaff'] != null) {
      userStaff = new List<UserStaff>();
      json['UserStaff'].forEach((v) {
        userStaff.add(new UserStaff.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.area != null) {
      data['List'] = this.area.map((v) => v.toJson()).toList();
    }
    if (this.currency != null) {
      data['Currency'] = this.currency.map((v) => v.toJson()).toList();
    }
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserStaff {
  int staffId;
  String staffCode;
  String staffName;
  String deptName;
  String posi;
  int iDefaultAreaId;
  int iDeptId;
  bool userIsPurchaser;
  bool canViewAllAttendance;

  UserStaff(
      {this.staffId,
      this.staffCode,
      this.staffName,
      this.deptName,
      this.posi,
      this.iDefaultAreaId,
      this.iDeptId,
      this.userIsPurchaser,
      this.canViewAllAttendance});

  UserStaff.fromJson(Map<String, dynamic> json) {
    staffId = json['StaffId'];
    staffCode = json['StaffCode'];
    staffName = json['StaffName'];
    deptName = json['DeptName'];
    posi = json['Posi'];
    iDefaultAreaId = json['i_DefaultAreaId'];
    iDeptId = json['i_DeptId'];
    userIsPurchaser = json['UserIsPurchaser'];
    canViewAllAttendance = json['CanViewAllAttendance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StaffId'] = this.staffId;
    data['StaffCode'] = this.staffCode;
    data['StaffName'] = this.staffName;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    data['i_DefaultAreaId'] = this.iDefaultAreaId;
    data['i_DeptId'] = this.iDeptId;
    data['UserIsPurchaser'] = this.userIsPurchaser;
    data['CanViewAllAttendance'] = this.canViewAllAttendance;
    return data;
  }
}
