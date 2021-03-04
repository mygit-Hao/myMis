import 'package:mis_app/model/week_plan_detail.dart';

class WeekPlanProjModel {
  List<WeekPlanProjData> projList;
  List<ChargeStaff> staffList;

  WeekPlanProjModel({this.projList, this.staffList});

  WeekPlanProjModel.fromJson(Map<String, dynamic> json) {
    if (json['DataList'] != null) {
      projList = new List<WeekPlanProjData>();
      json['DataList'].forEach((v) {
        var begin = v['PlanStartDate'];
        var end = v['PlanEndDate'];
        if (begin != null && end != null) {
          projList.add(new WeekPlanProjData.fromJson(v));
        } else {}
      });
    }
    if (json['StaffList'] != null) {
      staffList = new List<ChargeStaff>();
      json['StaffList'].forEach((v) {
        staffList.add(new ChargeStaff.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.projList != null) {
      data['DataList'] = this.projList.map((v) => v.toJson()).toList();
    }
    if (this.staffList != null) {
      data['StaffList'] = this.staffList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

// class WeekPlanProjData {
//   bool hasFiles;
//   String inviterStaffName;
//   DateTime planEndDate;
//   DateTime planStartDate;
//   String projNameStar;
//   String projNumStar;
//   String projObj;
//   int projStatus;
//   String projStatusName;
//   String staffName;
//   String statusRemarks;
//   int weekPlanObjEmployerId;
//   int weekPlanObjByProjId;

//   WeekPlanProjData(
//       {this.hasFiles,
//       this.inviterStaffName,
//       this.planEndDate,
//       this.planStartDate,
//       this.projNameStar,
//       this.projNumStar,
//       this.projObj,
//       this.projStatus,
//       this.projStatusName,
//       this.staffName,
//       this.statusRemarks,
//       this.weekPlanObjEmployerId,
//       this.weekPlanObjByProjId});

//   WeekPlanProjData.fromJson(Map<String, dynamic> json) {
//     hasFiles = json['HasFiles'];
//     inviterStaffName = json['InviterStaffName'];
//     if (json['PlanEndDate'] != null)
//       planEndDate = DateTime.parse(json['PlanEndDate']);
//     if (json['PlanStartDate'] != null)
//       planStartDate = DateTime.parse(json['PlanStartDate']);
//     projNameStar = json['ProjNameStar'];
//     projNumStar = json['ProjNumStar'];
//     projObj = json['ProjObj'];
//     projStatus = json['ProjStatus'];
//     projStatusName = json['ProjStatusName'];
//     staffName = json['StaffName'];
//     statusRemarks = json['StatusRemarks'];
//     weekPlanObjEmployerId = json['WeekPlanObjEmployerId'];
//     weekPlanObjByProjId = json['WeekPlanObjByProjId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['HasFiles'] = this.hasFiles;
//     data['InviterStaffName'] = this.inviterStaffName;
//     data['PlanEndDate'] = this.planEndDate.toIso8601String();
//     data['PlanStartDate'] = this.planStartDate.toIso8601String();
//     data['ProjNameStar'] = this.projNameStar;
//     data['ProjNumStar'] = this.projNumStar;
//     data['ProjObj'] = this.projObj;
//     data['ProjStatus'] = this.projStatus;
//     data['ProjStatusName'] = this.projStatusName;
//     data['StaffName'] = this.staffName;
//     data['StatusRemarks'] = this.statusRemarks;
//     data['WeekPlanObjEmployerId'] = this.weekPlanObjEmployerId;
//     data['WeekPlanObjListDetailId'] = this.weekPlanObjByProjId;
//     return data;
//   }
// }

class ChargeStaff {
  String areaName;
  String deptName;
  String staffCode;
  int staffId;
  String staffName;
  int weekPlanObjEmployerId;

  ChargeStaff(
      {this.areaName,
      this.deptName,
      this.staffCode,
      this.staffId,
      this.staffName,
      this.weekPlanObjEmployerId});

  ChargeStaff.fromJson(Map<String, dynamic> json) {
    areaName = json['AreaName'];
    deptName = json['DeptName'];
    staffCode = json['StaffCode'];
    staffId = json['StaffId'];
    staffName = json['StaffName'];
    weekPlanObjEmployerId = json['WeekPlanObjEmployerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AreaName'] = this.areaName;
    data['DeptName'] = this.deptName;
    data['StaffCode'] = this.staffCode;
    data['StaffId'] = this.staffId;
    data['StaffName'] = this.staffName;
    data['WeekPlanObjEmployerId'] = this.weekPlanObjEmployerId;
    return data;
  }
}
