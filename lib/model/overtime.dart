import 'package:mis_app/model/staff_info.dart';
import 'area.dart';
import 'overtime_detail.dart';

class WorkOverTimeSData {
  // static String overtimeId;
  // static int maxid = 0;
  static List<Area> areaList;
  static List<Type> typeList;
  static List<StaffInfo> userStaff;

  static int curDeptId;
  static bool isAdd;
  static int pressIndex;
  static List<OverTimeDetail> detailList = [];
  static int deptId;
  static int status = 0;
  static bool isCopy = false;
}

class WorkOverTimeModel {
  List<OverTimeListData> overTimeList;
  List<Area> areaList;
  List<Type> typeList;
  List<StaffInfo> userStaff;

  WorkOverTimeModel(
      {this.overTimeList, this.areaList, this.typeList, this.userStaff});

  WorkOverTimeModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      overTimeList = new List<OverTimeListData>();
      json['List'].forEach((v) {
        overTimeList.add(new OverTimeListData.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      areaList = new List<Area>();
      json['Area'].forEach((v) {
        areaList.add(new Area.fromJson(v));
      });
    }
    if (json['Type'] != null) {
      typeList = new List<Type>();
      json['Type'].forEach((v) {
        typeList.add(new Type.fromJson(v));
      });
    }
    if (json['UserStaff'] != null) {
      userStaff = new List<StaffInfo>();
      json['UserStaff'].forEach((v) {
        userStaff.add(new StaffInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.overTimeList != null) {
      data['List'] = this.overTimeList.map((v) => v.toJson()).toList();
    }
    if (this.areaList != null) {
      data['Area'] = this.areaList.map((v) => v.toJson()).toList();
    }
    if (this.typeList != null) {
      data['Type'] = this.typeList.map((v) => v.toJson()).toList();
    }
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OverTimeListData {
  int overTimeId;
  String names;
  String applyDate;
  int status;
  String statusName;
  String approval;
  String wApproval;

  OverTimeListData(
      {this.overTimeId,
      this.names,
      this.applyDate,
      this.status,
      this.statusName,
      this.approval,
      this.wApproval});

  OverTimeListData.fromJson(Map<String, dynamic> json) {
    overTimeId = int.parse(json['OverTimeId']);
    names = json['Names'];
    applyDate = json['ApplyDate'];
    status = json['Status'];
    statusName = json['StatusName'];
    approval = json['Approval'];
    wApproval = json['WApproval'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OverTimeId'] = this.overTimeId;
    data['Names'] = this.names;
    data['ApplyDate'] = this.applyDate;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    data['Approval'] = this.approval;
    data['WApproval'] = this.wApproval;
    return data;
  }
}

class Type {
  String typeCode;
  String typeName;

  Type({this.typeCode, this.typeName});

  Type.fromJson(Map<String, dynamic> json) {
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
