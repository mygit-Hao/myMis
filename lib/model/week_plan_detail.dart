import 'dart:io';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/utils.dart';

class WeekPlanDtlModel {
  int errCode;
  String errMsg;
  WeekPlanProjData projData = WeekPlanProjData();
  // List<WeekPlanProjData> data;
  List<Week> weeks = [];
  List<Files> files = [];
  List<Partner> partners = [];
  int weekId;

  WeekPlanDtlModel(
      {this.errCode,
      this.errMsg,
      this.projData,
      this.weeks,
      this.files,
      this.partners});

  WeekPlanDtlModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    weekId = json['WeekId'];
    if (json['Data'] != null) {
      // data = new List<WeekPlanProjData>();
      projData = WeekPlanProjData();
      json['Data'].forEach((v) {
        // data.add(new WeekPlanProjData.fromJson(v));
        projData = WeekPlanProjData.fromJson(v);
      });
    }
    if (json['Weeks'] != null) {
      weeks = new List<Week>();
      json['Weeks'].forEach((v) {
        weeks.add(new Week.fromJson(v));
      });
    }
    if (json['Files'] != null) {
      files = new List<Files>();
      json['Files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    if (json['Partners'] != null) {
      partners = new List<Partner>();
      json['Partners'].forEach((v) {
        partners.add(new Partner.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.projData != null) {
      // data['Data'] = this.data.map((v) => v.toJson()).toList();

      // List<WeekPlanProjData> list = [];
      // list.add(this.projData);
      // data['Data'] = list;

      data['Data'] = this.projData;
    }
    if (this.weeks != null) {
      data['Weeks'] = this.weeks.map((v) => v.toJson()).toList();
    }
    if (this.files != null) {
      data['Files'] = this.files.map((v) => v.toJson()).toList();
    }
    if (this.partners != null) {
      data['Partners'] = this.partners.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class WeekPlanProjData {
  int projId = 0;
  int weekPlanObjEmployerId;
  int staffId;
  String staffName;
  int projNum;
  String projName;
  DateTime planStartDate;
  DateTime planEndDate;
  String projObj;
  String statusRemarks;
  int projStatus;
  String projStatusName;
  String projNameStar;
  String projNameStarTree;
  String projNumStar;
  int staffNameCount;
  bool hasFiles;
  String inviterStaffName;
  bool planned;
  int progress;
  String location;
  bool readOnly;
  bool canFollow = true;
  bool isTCD = false;
  String tCD1;
  String tCD2;
  String tCD3;
  String tCD4;
  String tCD5;
  String tCD6;

  WeekPlanProjData(
      {this.projId = 0,
      this.weekPlanObjEmployerId = 0,
      this.staffId = 0,
      this.staffName = '',
      this.projNum = 0,
      this.projName = '',
      this.planStartDate,
      this.planEndDate,
      this.projObj = '',
      this.statusRemarks = '',
      this.projStatus = 10,
      this.projStatusName = '进行中',
      this.projNameStar = '',
      this.projNameStarTree = '',
      this.projNumStar = '',
      this.staffNameCount = 0,
      this.hasFiles = false,
      this.inviterStaffName = '',
      this.planned = true,
      this.progress = 0,
      this.location = '',
      this.isTCD = false,
      this.readOnly = false,
      this.tCD1 = '',
      this.tCD2 = '',
      this.tCD3 = '',
      this.tCD4 = '',
      this.tCD5 = '',
      this.tCD6 = ''});

  WeekPlanProjData.fromJson(Map<String, dynamic> json) {
    projId = json['WeekPlanObjByProjId'] ?? 0;
    weekPlanObjEmployerId = json['WeekPlanObjEmployerId'];
    staffId = json['StaffId'];
    staffName = json['StaffName'];
    projNum = json['ProjNum'];
    projName = json['ProjName'];
    if (json['PlanStartDate'] != null)
      planStartDate = DateTime.parse(json['PlanStartDate']);
    if (json['PlanEndDate'] != null)
      planEndDate = DateTime.parse(json['PlanEndDate']);
    projObj = json['ProjObj'];
    statusRemarks = json['StatusRemarks'];
    projStatus = json['ProjStatus'];
    projStatusName = json['ProjStatusName'];
    projNameStar = json['ProjNameStar'] ?? '';
    projNameStarTree = json['ProjNameStarTree'] ?? '';
    projNumStar = json['ProjNumStar'] ?? '';
    staffNameCount = json['StaffNameCount'] ?? 0;
    hasFiles = json['HasFiles'];
    inviterStaffName = json['InviterStaffName'];
    planned = json['Planned'];
    progress = json['Progress'] ?? 0;
    location = json['Location'] ?? '';
    readOnly = json['ReadOnly'] ?? true;
    canFollow = json['CanFollow'] ?? true;
    tCD1 = json['TCD1'] ?? '';
    tCD2 = json['TCD2'] ?? '';
    tCD3 = json['TCD3'] ?? '';
    tCD4 = json['TCD4'] ?? '';
    tCD5 = json['TCD5'] ?? '';
    tCD6 = json['TCD6'] ?? "";
    isTCD = tCD1 == '' ? false : true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WeekPlanObjByProjId'] = this.projId;
    data['WeekPlanObjEmployerId'] = this.weekPlanObjEmployerId;
    data['StaffId'] = this.staffId;
    data['StaffName'] = this.staffName;
    data['ProjNum'] = this.projNum;
    data['ProjName'] = this.projName;
    data['PlanStartDate'] = this.planStartDate.toIso8601String();
    data['PlanEndDate'] = this.planEndDate.toIso8601String();
    data['ProjObj'] = this.projObj;
    data['StatusRemarks'] = this.statusRemarks;
    data['ProjStatus'] = this.projStatus;
    data['ProjStatusName'] = this.projStatusName;
    data['ProjNameStar'] = this.projNameStar;
    data['ProjNameStarTree'] = this.projNameStarTree;
    data['ProjNumStar'] = this.projNumStar;
    data['StaffNameCount'] = this.staffNameCount;
    data['HasFiles'] = this.hasFiles;
    data['InviterStaffName'] = this.inviterStaffName;
    data['Planned'] = this.planned;
    data['Progress'] = this.progress;
    data['Location'] = this.location;
    data['TCD1'] = this.tCD1;
    data['TCD2'] = this.tCD2;
    data['TCD3'] = this.tCD3;
    data['TCD4'] = this.tCD4;
    data['TCD5'] = this.tCD5;
    data['TCD6'] = this.tCD6;
    return data;
  }
}

class Week {
  int weekId;
  int weekPlanObjEmployerId;
  int weekPlanObjByProjId;
  int week;
  String weekObj;
  String weekResult;
  int staffId;
  String staffName;
  int fromStaffId;
  String fromStaffName;
  String weekFrom;
  String weekTo;
  int newWeek;
  int year;
  String comment;
  DateTime lastModifydate;
  bool weekObjReadOnly;
  bool weekResultReadOnly;
  bool commentReadOnly;
  bool privacy;
  bool isExpanded;
  bool hasFiles;
  bool readOnly;

  Week(
      {this.weekId = 0,
      this.weekPlanObjEmployerId,
      this.weekPlanObjByProjId,
      this.week,
      this.weekObj = '',
      this.weekResult = '',
      this.staffId = 0,
      this.staffName = '',
      this.fromStaffId = 0,
      this.fromStaffName = '',
      this.weekFrom = '',
      this.weekTo = '',
      this.newWeek,
      this.year,
      this.comment = '',
      this.lastModifydate,
      this.weekObjReadOnly = false,
      this.weekResultReadOnly = false,
      this.commentReadOnly = false,
      this.isExpanded = false,
      this.hasFiles = false,
      this.privacy = false});

  Week.fromJson(Map<String, dynamic> json) {
    weekId = json['WeekPlanObjByWeekId'];
    weekPlanObjEmployerId = json['WeekPlanObjEmployerId'];
    weekPlanObjByProjId = json['WeekPlanObjByProjId'];
    week = json['Week'];
    weekObj = json['WeekObj'];
    weekResult = json['WeekResult'];
    staffId = json['StaffId'];
    staffName = json['StaffName'];
    fromStaffId = json['FromStaffId'];
    fromStaffName = json['FromStaffName'];
    weekFrom = json['WeekFrom'];
    weekTo = json['WeekTo'];
    newWeek = json['NewWeek'];
    year = json['Year'];
    comment = json['Comment'] ?? '';
    this.weekObjReadOnly = json['WeekObjReadOnly'] ?? false;
    this.weekResultReadOnly = json['WeekResultReadOnly'] ?? false;
    this.commentReadOnly = json['CommentReadOnly'] ?? false;
    privacy = json['Privacy'] ?? false;
    lastModifydate = DateTime.parse(json['LastModifyDate']);
    hasFiles = json['HasFiles'] ?? false;
    isExpanded = isExp(week);
    readOnly = (staffId == UserProvide.currentUser.staffId) ? false : true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WeekPlanObjByWeekId'] = this.weekId ?? 0;
    data['WeekPlanObjEmployerId'] = this.weekPlanObjEmployerId ?? 0;
    data['WeekPlanObjByProjId'] = this.weekPlanObjByProjId ?? 0;
    data['Week'] = this.week;
    data['WeekObj'] = this.weekObj ?? '';
    data['WeekResult'] = this.weekResult ?? '';
    // data['StaffId'] = this.staffId ?? 0;
    // data['StaffName'] = this.staffName ?? '';
    // data['FromStaffId'] = this.fromStaffId ?? 0;
    // data['FromStaffName'] = this.fromStaffName ?? '';
    data['WeekFrom'] = this.weekFrom;
    data['WeekTo'] = this.weekTo;
    // data['NewWeek'] = this.newWeek ?? 0;
    data['Year'] = this.year ?? 0;
    data['Comment'] = this.comment;
    // data['ReadOnly'] = this.weekObjReadOnly ?? false;
    // if (this.lastModifydate != null)
    //   data['LastModifydate'] = this.lastModifydate.toIso8601String();
    return data;
  }
}

class Files {
  int weekPlanObjFilId;
  int weekId;
  // String weekId;
  int weekPlanObjEmployerId;
  Null staffId;
  int fileId;
  String filePath;
  String createDate;
  String remarks;
  int fileType;
  String userFullName;
  bool canDelete;
  File file;
  String fileExt;
  String shortName;
  String fileName;

  Files(
      {this.weekPlanObjFilId,
      this.weekId,
      this.weekPlanObjEmployerId,
      this.staffId,
      this.fileId,
      this.filePath,
      this.createDate,
      this.remarks,
      this.fileType,
      this.userFullName,
      this.fileExt,
      this.shortName,
      this.fileName});

  Files.fromJson(Map<String, dynamic> json) {
    weekPlanObjFilId = int.parse(json['WeekPlanObjFileId'] ?? '0');
    weekPlanObjEmployerId = int.parse(json['WeekPlanObjEmployerId'] ?? '0');
    // weekId = int.parse(json['WeekPlanObjByWeekId'] ?? "0");
    weekId = json['WeekPlanObjByWeekId'] ?? 0;
    staffId = json['StaffId'];
    fileId = json['FileId'];
    filePath = json['FilePath'];
    createDate = json['CreateDate'];
    remarks = json['Remarks'];
    fileType = json['FileType'];
    userFullName = json['UserFullName'];
    canDelete = json['CanDelete'];
    this.fileExt = Utils.getFileExt(filePath);
    this.shortName = Utils.getFileName(filePath);
    this.fileName = filePath;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WeekPlanObjFilId'] = this.weekPlanObjFilId;
    data['WeekPlanObjEmployerId'] = this.weekPlanObjEmployerId;
    data['StaffId'] = this.staffId;
    data['FileId'] = this.fileId;
    data['FilePath'] = this.filePath;
    data['CreateDate'] = this.createDate;
    data['Remarks'] = this.remarks;
    data['FileType'] = this.fileType;
    data['UserFullName'] = this.userFullName;
    return data;
  }
}

class Partner {
  int weekPlanObjByPartnerId;
  int weekPlanObjEmployerId;
  int weekPlanObjByProjId;
  int staffId;
  String staffName;
  bool isDefault;
  String staffCode;
  String deptName;

  Partner(
      {this.weekPlanObjByPartnerId,
      this.weekPlanObjEmployerId,
      this.weekPlanObjByProjId,
      this.staffId,
      this.staffName = '',
      this.isDefault,
      this.staffCode,
      this.deptName});

  Partner.fromJson(Map<String, dynamic> json) {
    weekPlanObjByPartnerId = json['WeekPlanObjByPartnerId'];
    weekPlanObjEmployerId = json['WeekPlanObjEmployerId'];
    weekPlanObjByProjId = json['WeekPlanObjByProjId'];
    staffId = json['StaffId'];
    staffName = json['StaffName'];
    isDefault = json['IsDefault'];
    staffCode = json['StaffCode'];
    deptName = json['DeptName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['WeekPlanObjByPartnerId'] = this.weekPlanObjByPartnerId;
    data['WeekPlanObjEmployerId'] = this.weekPlanObjEmployerId;
    data['WeekPlanObjByProjId'] = this.weekPlanObjByProjId;
    data['StaffId'] = this.staffId;
    data['StaffName'] = this.staffName;
    data['IsDefault'] = this.isDefault;
    data['StaffCode'] = this.staffCode;
    data['DeptName'] = this.deptName;
    return data;
  }
}

bool isExp(int week) {
  DateTime date = DateTime.now();
  DateTime startOfYear = new DateTime(date.year, 1, 1, 0, 0);
  int firstMonday = startOfYear.weekday;
  //第一周的天数
  int daysInFirstWeek = 8 - firstMonday;
  int diff = date.difference(startOfYear).inDays + 1;
  int weeks = ((diff - daysInFirstWeek) / 7).ceil();
  //加上第一周
  weeks += 1;
  weeks = date.year * 100 + weeks;
  bool isExpanded = (week > (weeks - 5));
  return isExpanded;
}
