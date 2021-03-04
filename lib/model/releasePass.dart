import 'dart:io';

import 'package:mis_app/model/releaseFile.dart';
import 'package:mis_app/utils/utils.dart';

class ReleasePassWrapper {
  int errCode;
  String errMsg;
  ReleasePassModel releasePass;
  List<ReleasePhotos> photos;
  List<Attachments> attachments;

  ReleasePassWrapper(
      {this.errCode, this.errMsg, this.releasePass, this.attachments});

  ReleasePassWrapper.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['ReleasePass'] != null) {
      var jsonData = json['ReleasePass'][0];
      releasePass = ReleasePassModel.fromJson(jsonData);
    }

    if (json['Photos'] != null) {
      photos = new List<ReleasePhotos>();
      json['Photos'].forEach((v) {
        photos.add(new ReleasePhotos.fromJson(v));
      });
    }
    if (json['Attachments'] != null) {
      attachments = new List<Attachments>();
      json['Attachments'].forEach((v) {
        attachments.add(new Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.releasePass != null) {
      data['ReleasePass'][0] = this.releasePass.toJson();
    }
    if (this.attachments != null) {
      data['Attachments'] = this.attachments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReleasePassModel {
  String releasePassId;
  String code;
  DateTime applyDate;
  String name;
  int staffId;
  String staffCode;
  String deptName;
  String groupName;
  String reason;
  String typeCode;
  String passType;
  int areaId;
  String approval;
  String wApproval;
  int status = 0;
  String statusName;

  ReleasePassModel(
      {this.releasePassId,
      this.code,
      this.applyDate,
      this.name,
      this.staffId,
      this.staffCode,
      this.deptName,
      this.groupName,
      this.reason,
      this.typeCode,
      this.passType,
      this.areaId,
      this.approval,
      this.wApproval,
      this.status,
      this.statusName});

  ReleasePassModel.fromJson(Map<String, dynamic> json) {
    releasePassId = json['ReleasePassId'];
    code = json['Code'];
    applyDate = DateTime.parse(json['ApplyDate']);
    name = json['Name'];
    staffId = json['StaffId'];
    staffCode = json['StaffCode'];
    deptName = json['DeptName'];
    groupName = json['GroupName'];
    reason = json['Reason'];
    typeCode = json['TypeCode'];
    passType = json['PassType'];
    areaId = json['AreaId'];
    approval = json['Approval'];
    wApproval = json['WApproval'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReleasePassId'] = this.releasePassId;
    data['Code'] = this.code;
    data['ApplyDate'] = this.applyDate.toString();
    data['Name'] = this.name;
    data['StaffId'] = this.staffId;
    data['StaffCode'] = this.staffCode;
    data['DeptName'] = this.deptName;
    data['GroupName'] = this.groupName;
    data['Reason'] = this.reason;
    data['TypeCode'] = this.typeCode;
    data['PassType'] = this.passType;
    data['AreaId'] = this.areaId;
    data['Approval'] = this.approval;
    data['WApproval'] = this.wApproval;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class Attachments {
  String releasePassFileId;
  int fileId;
  String fileName;
  String remarks;
  String fileType;
  File file;
  String fileExt;
  String shortName;

  Attachments(
      {this.releasePassFileId,
      this.fileId,
      this.fileName,
      this.remarks,
      this.fileType});

  Attachments.fromJson(Map<String, dynamic> json) {
    releasePassFileId = json['ReleasePassFileId'];
    fileId = json['FileId'];
    fileName = json['FileName'];
    remarks = json['Remarks'];
    fileType = json['FileType'];
    this.fileExt = Utils.getFileExt(fileName);
    this.shortName = Utils.getFileName(fileName);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReleasePassFileId'] = this.releasePassFileId;
    data['FileId'] = this.fileId;
    data['FileName'] = this.fileName;
    data['Remarks'] = this.remarks;
    data['FileType'] = this.fileType;
    return data;
  }
}
