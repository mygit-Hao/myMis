import 'package:mis_app/model/releasePass.dart';

import 'area.dart';

class ReleaseBaseDB {
  static int staffID = 0;
  static String staffCode;
  static String staffName;
  static String deptName;
  static int areaId;
  static List<Area> areaList;
  static List<PassType> typeList;
}

class ReleaseModel {
  List<ReleasePassModel> list;
  List<Area> area;
  List<PassType> passType;
  List<UserStaff> userStaff;

  ReleaseModel({this.list, this.area, this.passType, this.userStaff});

  ReleaseModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list = new List<ReleasePassModel>();
      json['List'].forEach((v) {
        list.add(new ReleasePassModel.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      area = new List<Area>();
      json['Area'].forEach((v) {
        area.add(new Area.fromJson(v));
      });
    }
    if (json['PassType'] != null) {
      passType = new List<PassType>();
      json['PassType'].forEach((v) {
        passType.add(new PassType.fromJson(v));
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
    if (this.list != null) {
      data['List'] = this.list.map((v) => v.toJson()).toList();
    }
    if (this.area != null) {
      data['Area'] = this.area.map((v) => v.toJson()).toList();
    }
    if (this.passType != null) {
      data['PassType'] = this.passType.map((v) => v.toJson()).toList();
    }
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PassType {
  String typeCode;
  String typeName;

  PassType({this.typeCode, this.typeName});

  PassType.fromJson(Map<String, dynamic> json) {
    typeCode = json['TypeCode'];
    typeName = json['TypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TypeCode'] = this.typeCode;
    data['TypeName'] = this.typeName;
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
