import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/askForLeaveDetail.dart';
import 'package:mis_app/model/staff_info.dart';

class AskForLeaveSData {
  static List<Area> areaList;
  static List<AskForLeaveKind> kindList;
  static List<StaffInfo> userStaff;
  static ArrangeData arrangeData;

  // static int maxId = 0;
  static int askForLeaveId = 0;
  static int staffId;
}

class AskForLeaveModel {
  List<AskForLeaveData> askForLeavelist;
  List<Area> areaList;
  List<AskForLeaveKind> kindList;
  List<StaffInfo> userStaff;

  AskForLeaveModel(
      {this.askForLeavelist, this.areaList, this.kindList, this.userStaff});

  AskForLeaveModel.fromJson(Map<String, dynamic> json) {
    if (json != null) {
      askForLeavelist = new List<AskForLeaveData>();
      json['List'].forEach((v) {
        askForLeavelist.add(new AskForLeaveData.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      areaList = new List<Area>();
      json['Area'].forEach((v) {
        areaList.add(new Area.fromJson(v));
      });
    }
    if (json['Kind'] != null) {
      kindList = new List<AskForLeaveKind>();
      json['Kind'].forEach((v) {
        kindList.add(new AskForLeaveKind.fromJson(v));
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
    if (this.askForLeavelist != null) {
      data['List'] = this.askForLeavelist.map((v) => v.toJson()).toList();
    }
    if (this.areaList != null) {
      data['Area'] = this.areaList.map((v) => v.toJson()).toList();
    }
    if (this.kindList != null) {
      data['Kind'] = this.kindList.map((v) => v.toJson()).toList();
    }
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AskForLeaveKind {
  String ncTypeCode;
  String ncTypeName;
  bool needAttachment;
  bool needOverTime;

  AskForLeaveKind(
      {this.ncTypeCode,
      this.ncTypeName,
      this.needAttachment,
      this.needOverTime});

  AskForLeaveKind.fromJson(Map<String, dynamic> json) {
    ncTypeCode = json['nc_TypeCode'];
    ncTypeName = json['nc_TypeName'];
    needAttachment = json['NeedAttachment'];
    needOverTime = json['NeedOverTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nc_TypeCode'] = this.ncTypeCode;
    data['nc_TypeName'] = this.ncTypeName;
    data['NeedAttachment'] = this.needAttachment;
    data['NeedOverTime'] = this.needOverTime;
    return data;
  }
}

class ArrangeData {
  double hours;
  DateTime dt1;
  DateTime dt2;
  DateTime dt3;
  DateTime dt4;
  DateTime dt5;
  DateTime dt6;

  ArrangeData({
    this.hours,
    this.dt1,
    this.dt2,
    this.dt3,
    this.dt4,
    this.dt5,
    this.dt6,
  });

  ArrangeData.fromJson(Map<String, dynamic> json) {
    hours = json['H_Type'];
    if (json['dt1'] != null) {
      dt1 = DateTime.parse(json['dt1']);
    }
    if (json['dt2'] != null) {
      dt2 = DateTime.parse(json['dt2']);
    }
    if (json['dt3'] != null) {
      dt3 = DateTime.parse(json['dt3']);
    }
    if (json['dt4'] != null) {
      dt4 = DateTime.parse(json['dt4']);
    }
    if (json['dt5'] != null) {
      dt5 = DateTime.parse(json['dt5']);
    }
    if (json['dt6'] != null) {
      dt6 = DateTime.parse(json['dt6']);
    }
  }

  ArrangeData.toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['H_type'] = this.hours;
    if (this.dt1 != null) {
      data['dt1'] = this.dt1.toIso8601String();
    }
    if (this.dt2 != null) {
      data['dt2'] = this.dt2.toIso8601String();
    }
    if (this.dt3 != null) {
      data['dt3'] = this.dt3.toIso8601String();
    }
    if (this.dt4 != null) {
      data['dt4'] = this.dt4.toIso8601String();
    }
    if (this.dt5 != null) {
      data['dt5'] = this.dt5.toIso8601String();
    }
    if (this.dt6 != null) {
      data['dt6'] = this.dt6.toIso8601String();
    }
  }
}
