import 'dart:io';

import 'package:mis_app/utils/utils.dart';

class AskForLeaveDetailModel {
  int errCode;
  String errMsg;
  // List<AskForLeaveData> headDate;
  AskForLeaveData headDate;
  List<OverTimeSelectModel> overTimeList;
  List<AskForLeaveAttachments> attachmentList;

  AskForLeaveDetailModel(
      {this.errCode,
      this.errMsg,
      this.headDate,
      this.overTimeList,
      this.attachmentList});

  AskForLeaveDetailModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['Data'] != null) {
      // headDate = new List<AskForLeaveData>();
      // json['Data'].forEach((v) {
      //   headDate.add(new AskForLeaveData.fromJson(v));
      // });
      headDate = new AskForLeaveData();
      var data = json['Data'][0];
      headDate = AskForLeaveData.fromJson(data);
    }
    if (json['OverTimeList'] != null) {
      overTimeList = new List<OverTimeSelectModel>();
      json['OverTimeList'].forEach((v) {
        overTimeList.add(new OverTimeSelectModel.fromJson(v));
      });
    }
    if (json['Attachments'] != null) {
      attachmentList = new List<AskForLeaveAttachments>();
      json['Attachments'].forEach((v) {
        attachmentList.add(new AskForLeaveAttachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.headDate != null) {
      // data['Data'] = this.headDate.map((v) => v.toJson()).toList();
      data['Data'][0] = this.headDate;
    }
    if (this.overTimeList != null) {
      data['OverTimeList'] = this.overTimeList.map((v) => v.toJson()).toList();
    }
    if (this.attachmentList != null) {
      data['Attachments'] = this.attachmentList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AskForLeaveData {
  int askForLeaveId;
  String code;
  DateTime applyDate;
  String staffName;
  String staffCode;
  String deptName;
  DateTime beginDate;
  DateTime endDate;
  double days;
  double hours;
  String reason;
  String contact;
  String typeCode;
  String typeName;
  int staffId;
  int areaId;
  String approval;
  String wApproval;
  int status;
  String statusName;

  AskForLeaveData(
      {this.askForLeaveId,
      this.code,
      this.applyDate,
      this.staffName,
      this.staffCode,
      this.deptName,
      this.beginDate,
      this.endDate,
      this.days,
      this.hours,
      this.reason,
      this.contact,
      this.typeCode,
      this.typeName,
      this.staffId,
      this.areaId,
      this.approval,
      this.wApproval,
      this.status = 0,
      this.statusName = '草稿'});

  AskForLeaveData.fromJson(Map<String, dynamic> json) {
    askForLeaveId = int.parse(json['AskForLeaveId']);
    code = json['Code'];
    applyDate = DateTime.parse(json['ApplyDate']);
    staffName = json['StaffName'];
    staffCode = json['StaffCode'];
    deptName = json['DeptName'];
    beginDate = DateTime.parse(json['BeginDate']);
    endDate = DateTime.parse(json['EndDate']);
    days = json['Days'];
    hours = json['Hours'];
    reason = json['Reason'];
    contact = json['Contact'];
    typeCode = json['TypeCode'];
    typeName = json['TypeName'];
    staffId = json['StaffId'];
    areaId = json['AreaId'];
    approval = json['Approval'];
    wApproval = json['WApproval'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AskForLeaveId'] = this.askForLeaveId;
    data['Code'] = this.code;
    data['ApplyDate'] = this.applyDate.toIso8601String();
    data['StaffName'] = this.staffName;
    data['StaffCode'] = this.staffCode;
    data['DeptName'] = this.deptName;
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    data['Days'] = this.days;
    data['Hours'] = this.hours;
    data['Reason'] = this.reason;
    data['Contact'] = this.contact;
    data['TypeCode'] = this.typeCode;
    data['TypeName'] = this.typeName;
    data['StaffId'] = this.staffId;
    data['AreaId'] = this.areaId;
    data['Approval'] = this.approval;
    data['WApproval'] = this.wApproval;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class OverTimeSelectModel {
  int askForLeaveId;
  String askForLeaveOverTimeDid;
  String overTimeDid;
  int staffId;
  String code;
  DateTime beginDate;
  DateTime endDate;
  String reason;
  double hours;
  double totalUsedHours;
  double usedHours;

  OverTimeSelectModel(
      {this.askForLeaveId,
      this.askForLeaveOverTimeDid,
      this.overTimeDid,
      this.staffId,
      this.code,
      this.beginDate,
      this.endDate,
      this.reason,
      this.hours = 0.0,
      this.totalUsedHours = 0.0,
      this.usedHours = 0.0});

  OverTimeSelectModel.fromJson(Map<String, dynamic> json) {
    askForLeaveId = int.parse(json['AskForLeaveId'] ?? "0");
    askForLeaveOverTimeDid = json['AskForLeaveOverTimeDid'];
    overTimeDid = json['OverTimeDid'];
    staffId = json['StaffId'];
    code = json['Code'];
    beginDate = DateTime.parse(json['BeginDate']);
    endDate = DateTime.parse(json['EndDate']);
    reason = json['Reason'];
    hours = json['Hours'] ?? 0.0;
    totalUsedHours = json['TotalUsedHours'] ?? 0.0;
    usedHours = json['UsedHours'] ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AskForLeaveId'] = this.askForLeaveId;
    data['AskForLeaveOverTimeDid'] = this.askForLeaveOverTimeDid;
    data['OverTimeDid'] = this.overTimeDid;
    data['StaffId'] = this.staffId;
    data['Code'] = this.code;
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    data['Reason'] = this.reason;
    data['Hours'] = this.hours;
    data['TotalUsedHours'] = this.totalUsedHours;
    data['UsedHours'] = this.usedHours;
    return data;
  }
}

class AskForLeaveAttachments {
  String askForLeaveFileId;
  int fileId;
  String fileName;
  String remarks;
  String fileType;
  File file;
  String fileExt;
  String shortName;

  AskForLeaveAttachments(
      {this.askForLeaveFileId,
      this.fileId,
      this.fileName,
      this.remarks,
      this.fileType});

  AskForLeaveAttachments.fromJson(Map<String, dynamic> json) {
    askForLeaveFileId = json['AskForLeaveFileId'];
    fileId = json['FileId'];
    fileName = json['FileName'];
    remarks = json['Remarks'];
    fileType = json['FileType'];
    this.fileExt = Utils.getFileExt(fileName);
    this.shortName = Utils.getFileName(fileName);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AskForLeaveFileId'] = this.askForLeaveFileId;
    data['FileId'] = this.fileId;
    data['FileName'] = this.fileName;
    data['Remarks'] = this.remarks;
    data['FileType'] = this.fileType;
    return data;
  }
}
