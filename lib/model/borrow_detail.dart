import 'dart:io';

import 'package:mis_app/utils/utils.dart';

class BorrowDetaiModel {
  int errCode;
  String errMsg;
  List<BorrowData> detaildata;
  List<BorrowAttach> attachments;

  BorrowDetaiModel({this.detaildata, this.attachments});

  BorrowDetaiModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['Data'] != null) {
      detaildata = new List<BorrowData>();
      json['Data'].forEach((v) {
        detaildata.add(new BorrowData.fromJson(v));
      });
    }
    if (json['Attachments'] != null) {
      attachments = new List<BorrowAttach>();
      json['Attachments'].forEach((v) {
        attachments.add(new BorrowAttach.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.detaildata != null) {
      data['ErrCode'] = this.errCode;
      data['errMsg'] = this.errMsg;
      data['Data'] = this.detaildata.map((v) => v.toJson()).toList();
    }
    if (this.attachments != null) {
      data['Attachments'] = this.attachments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BorrowData {
  int borrowId;
  String code;
  DateTime applyDate;
  String name;
  int staffId;
  String staffCode;
  String deptName;
  String posi;
  String reason;
  String currency;
  double amount;
  DateTime repaymentDate;
  String payment;
  String receipt;
  String bankName;
  String bankCode;
  int areaId;
  String approval;
  String wApproval;
  int status;
  String statusName;

  BorrowData(
      {this.borrowId,
      this.code,
      this.applyDate,
      this.name = '',
      this.staffId,
      this.staffCode = '',
      this.deptName = '',
      this.posi = '',
      this.reason = '',
      this.currency = '',
      this.amount = 0.0,
      this.repaymentDate,
      this.payment,
      this.receipt = '',
      this.bankName = '',
      this.bankCode = '',
      this.areaId,
      this.approval = '',
      this.wApproval = '',
      this.status = 0,
      this.statusName = '草稿'});

  BorrowData.fromJson(Map<String, dynamic> json) {
    borrowId = int.parse(json['BorrowId']);
    code = json['Code'];
    applyDate = DateTime.parse(json['ApplyDate']);
    name = json['Name'];
    staffId = json['StaffId'];
    staffCode = json['StaffCode'];
    deptName = json['DeptName'];
    posi = json['Posi'];
    reason = json['Reason'];
    currency = json['Currency'];
    amount = json['Amount'];
    if (json['RepaymentDate'] != null)
      repaymentDate = DateTime.parse(json['RepaymentDate']);
    payment = json['Payment'];
    receipt = json['Receipt'];
    bankName = json['BankName'];
    bankCode = json['BankCode'];
    areaId = json['AreaId'];
    approval = json['Approval'];
    wApproval = json['WApproval'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BorrowId'] = this.borrowId.toString();
    data['Code'] = this.code;
    data['ApplyDate'] = this.applyDate.toIso8601String();
    data['Name'] = this.name;
    data['StaffId'] = this.staffId;
    data['StaffCode'] = this.staffCode;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    data['Reason'] = this.reason;
    data['Currency'] = this.currency;
    data['Amount'] = this.amount;
    data['RepaymentDate'] = this.repaymentDate.toIso8601String();
    data['Payment'] = this.payment;
    data['Receipt'] = this.receipt;
    data['BankName'] = this.bankName;
    data['BankCode'] = this.bankCode;
    data['AreaId'] = this.areaId;
    data['Approval'] = this.approval;
    data['WApproval'] = this.wApproval;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class BorrowAttach {
  String borrowFileId;
  int fileId;
  String fileName;
  String remarks;
  String fileType;
  File file;
  String fileExt;
  String shortName;

  BorrowAttach(
      {this.borrowFileId,
      this.fileId,
      this.fileName,
      this.remarks,
      this.fileType});

  BorrowAttach.fromJson(Map<String, dynamic> json) {
    borrowFileId = json['BorrowFileId'];
    fileId = json['FileId'];
    fileName = json['FileName'];
    remarks = json['Remarks'];
    fileType = json['FileType'];
    this.fileExt = Utils.getFileExt(fileName);
    this.shortName = Utils.getFileName(fileName);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BorrowFileId'] = this.borrowFileId;
    data['FileId'] = this.fileId;
    data['FileName'] = this.fileName;
    data['Remarks'] = this.remarks;
    data['FileType'] = this.fileType;
    return data;
  }
}
