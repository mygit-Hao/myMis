import 'package:mis_app/model/businessReport.dart';

class BusinessBaseDB {
  static int staffID = 0;
  static String staffName;
  static int areaId;
  static List<Area> areaList;
}

class BusinessModel {
  List<BusinessReportModel> list;
  List<Area> area;
  Null kind;
  List<UserStaff> userStaff;

  BusinessModel({this.list, this.area, this.kind, this.userStaff});

  BusinessModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list = new List<BusinessReportModel>();
      json['List'].forEach((v) {
        list.add(new BusinessReportModel.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      area = new List<Area>();
      json['Area'].forEach((v) {
        area.add(new Area.fromJson(v));
      });
    }
    kind = json['Kind'];
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
    data['Kind'] = this.kind;
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class DataList {
//   String onBusinessReportId;
//   String code;
//   String reporterName;
//   DateTime reportDate;
//   String reportTitle;
//   int isUsed;

//   DataList(
//       {this.onBusinessReportId,
//       this.code,
//       this.reporterName,
//       this.reportDate,
//       this.reportTitle,
//       this.isUsed});

//   DataList.fromJson(Map<String, dynamic> json) {
//     onBusinessReportId = json['OnBusinessReportId'];
//     code = json['Code'];
//     reporterName = json['ReporterName'];
//     reportDate = DateTime.parse(json['ReportDate']);
//     reportTitle = json['ReportTitle'];
//     isUsed = json['isUsed'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['OnBusinessReportId'] = this.onBusinessReportId;
//     data['Code'] = this.code;
//     data['ReporterName'] = this.reporterName;
//     data['ReportDate'] = this.reportDate.toString();
//     data['ReportTitle'] = this.reportTitle;
//     data['isUsed'] = this.isUsed;
//     return data;
//   }
// }

class Area {
  int areaId;
  String code;
  String shortName;

  Area({this.areaId, this.code, this.shortName});

  Area.fromJson(Map<String, dynamic> json) {
    areaId = json['AreaId'];
    code = json['Code'];
    shortName = json['ShortName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AreaId'] = this.areaId;
    data['Code'] = this.code;
    data['ShortName'] = this.shortName;
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
