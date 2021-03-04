import 'area.dart';

class BuCardBaseDB {
  static int staffID = 0;
  static String staffCode;
  static String staffName;
  static int deptId;
  static String deptName;
  static int areaId;
  static String posi;
  static List<Area> areaList;
  static List<Kind> kindList;
}

class BuCardModel {
  List<BuCardList> list;
  List<Area> area;
  List<Kind> kind;
  List<UserStaff> userStaff;

  BuCardModel({this.list, this.area, this.kind, this.userStaff});

  BuCardModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list = new List<BuCardList>();
      json['List'].forEach((v) {
        list.add(new BuCardList.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      area = new List<Area>();
      json['Area'].forEach((v) {
        area.add(new Area.fromJson(v));
      });
    }
    if (json['Kind'] != null) {
      kind = new List<Kind>();
      json['Kind'].forEach((v) {
        kind.add(new Kind.fromJson(v));
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
    if (this.kind != null) {
      data['Kind'] = this.kind.map((v) => v.toJson()).toList();
    }
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BuCardList {
  String buCardId;
  String code;
  DateTime applyDate;
  DateTime noCardDate;
  String deptName;
  String staffNames;
  int deptId;
  int kindId;
  String kindName;
  String reason;
  int areaId;
  String approval;
  String wApproval;
  int status;
  String statusName;

  BuCardList(
      {this.buCardId,
      this.code,
      this.applyDate,
      this.noCardDate,
      this.deptName,
      this.staffNames,
      this.deptId,
      this.kindId,
      this.kindName,
      this.reason,
      this.areaId,
      this.approval,
      this.wApproval,
      this.status,
      this.statusName});

  BuCardList.fromJson(Map<String, dynamic> json) {
    buCardId = json['BuCardId'];
    code = json['Code'];
    applyDate = DateTime.parse(json['ApplyDate']);
    noCardDate = DateTime.parse(json['NoCardDate']);
    deptName = json['DeptName'];
    staffNames = json['StaffNames'];
    deptId = json['DeptId'];
    kindId = json['KindId'];
    kindName = json['KindName'];
    reason = json['Reason'];
    areaId = json['AreaId'];
    approval = json['Approval'];
    wApproval = json['WApproval'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BuCardId'] = this.buCardId;
    data['Code'] = this.code;
    data['ApplyDate'] = this.applyDate.toString();
    data['NoCardDate'] = this.noCardDate.toString();
    data['DeptName'] = this.deptName;
    data['StaffNames'] = this.staffNames;
    data['DeptId'] = this.deptId;
    data['KindId'] = this.kindId;
    data['KindName'] = this.kindName;
    data['Reason'] = this.reason;
    data['AreaId'] = this.areaId;
    data['Approval'] = this.approval;
    data['WApproval'] = this.wApproval;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class Kind {
  int kindId;
  String kindName;

  Kind({this.kindId, this.kindName});

  Kind.fromJson(Map<String, dynamic> json) {
    kindId = json['KindId'];
    kindName = json['KindName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['KindId'] = this.kindId;
    data['KindName'] = this.kindName;
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
