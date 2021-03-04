import 'dart:io';

import 'package:mis_app/utils/utils.dart';

class StaffQueryModel {
  StaffDetailModel staffDetail;
  List<EmploymentRecord> employmentRecord;
  List<Files> files;
  List<Performance> performance;

  StaffQueryModel(
      {this.staffDetail, this.employmentRecord, this.files, this.performance});

  StaffQueryModel.fromJson(Map<String, dynamic> json) {
    var dataList = json['Data'];
    if (dataList != null) {
      staffDetail = new StaffDetailModel();
      if (dataList.length > 0) {
        var jsonData = json['Data'][0];
        staffDetail = StaffDetailModel.fromJson(jsonData);
      }
    }
    if (json['EmploymentRecord'] != null) {
      employmentRecord = new List<EmploymentRecord>();
      json['EmploymentRecord'].forEach((v) {
        employmentRecord.add(new EmploymentRecord.fromJson(v));
      });
    }
    if (json['Files'] != null) {
      files = new List<Files>();
      json['Files'].forEach((v) {
        files.add(new Files.fromJson(v));
      });
    }
    if (json['Performance'] != null) {
      performance = new List<Performance>();
      json['Performance'].forEach((v) {
        performance.add(new Performance.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.staffDetail != null) {
      data['Data'][0] = this.staffDetail.toJson();
    }
    if (this.employmentRecord != null) {
      data['EmploymentRecord'] =
          this.employmentRecord.map((v) => v.toJson()).toList();
    }
    if (this.files != null) {
      data['Files'] = this.files.map((v) => v.toJson()).toList();
    }
    if (this.performance != null) {
      data['Performance'] = this.performance.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StaffDetailModel {
  int staffId;
  String code;
  String name;
  String deptName;
  String posi;
  int gender;
  String genderName;
  String areaName;
  int deptId;
  String phone;
  DateTime tryDate;
  String address;
  String nowAddress;
  String remarks;
  String marry;
  DateTime birthDate;
  String idNum;
  String province;
  String city;
  String nationality;
  String getJobWay;
  String bankName;
  String bankNum;
  String tel;
  DateTime workDate;
  String educationName;
  DateTime graduateDate;
  String lastSchool;
  String major;
  String card;
  String ecName;
  String ecRelation;
  String ecTel;
  String ecAddress;
  String title;
  String titleLevel;
  DateTime contractFrom;
  DateTime contractTo;
  DateTime idCardExpiryDate;
  bool idCardLongEffective;
  String duty;
  DateTime inDate;
  DateTime outDate;
  String outReason;
  int gradeNo;
  String auditGrade;

  StaffDetailModel(
      {this.staffId,
      this.code,
      this.name,
      this.deptName,
      this.posi,
      this.gender,
      this.genderName,
      this.areaName,
      this.deptId,
      this.phone,
      this.tryDate,
      this.address,
      this.nowAddress,
      this.remarks,
      this.marry,
      this.birthDate,
      this.idNum,
      this.province,
      this.city,
      this.nationality,
      this.getJobWay,
      this.bankName,
      this.bankNum,
      this.tel,
      this.workDate,
      this.educationName,
      this.graduateDate,
      this.lastSchool,
      this.major,
      this.card,
      this.ecName,
      this.ecRelation,
      this.ecTel,
      this.ecAddress,
      this.title,
      this.titleLevel,
      this.contractFrom,
      this.contractTo,
      this.idCardExpiryDate,
      this.idCardLongEffective,
      this.duty,
      this.inDate,
      this.outDate,
      this.outReason,
      this.gradeNo,
      this.auditGrade});

  StaffDetailModel.fromJson(Map<String, dynamic> json) {
    staffId = json['StaffId'];
    code = json['Code'];
    name = json['Name'];
    deptName = json['DeptName'];
    posi = json['Posi'];
    gender = json['Gender'];
    genderName = json['GenderName'];
    areaName = json['AreaName'];
    deptId = json['DeptId'];
    phone = json['Phone'];
    if (json['TryDate'] != null) tryDate = DateTime.parse(json['TryDate']);
    // tryDate = DateTime.parse(json['TryDate']);
    address = json['Address'];
    nowAddress = json['NowAddress'];
    remarks = json['Remarks'];
    marry = json['Marry'];
    if (json['BirthDate'] != null)
      birthDate = DateTime.parse(json['BirthDate']);
    idNum = json['IdNum'];
    province = json['Province'];
    city = json['City'];
    nationality = json['Nationality'];
    getJobWay = json['GetJobWay'];
    bankName = json['BankName'];
    bankNum = json['BankNum'];
    tel = json['Tel'];
    if (json['WorkDate'] != null) workDate = DateTime.parse(json['WorkDate']);
    educationName = json['EducationName'];
    if (json['GraduateDate'] != null)
      graduateDate = DateTime.parse(json['GraduateDate']);
    lastSchool = json['LastSchool'];
    major = json['Major'];
    card = json['Card'];
    ecName = json['EcName'];
    ecRelation = json['EcRelation'];
    ecTel = json['EcTel'];
    ecAddress = json['EcAddress'];
    title = json['Title'];
    titleLevel = json['TitleLevel'];
    contractFrom = DateTime.parse(json['ContractFrom']);
    contractTo = DateTime.parse(json['ContractTo']);
    if (json['IdCardExpiryDate'] != null)
      idCardExpiryDate = DateTime.parse(json['IdCardExpiryDate']);
    idCardLongEffective = json['IdCardLongEffective'];
    duty = json['Duty'];
    inDate = DateTime.parse(json['InDate']);
    if (json['OutDate'] != null) outDate = DateTime.parse(json['OutDate']);
    outReason = json['OutReason'];
    gradeNo = json['GradeNo'];
    auditGrade = json['AuditGrade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StaffId'] = this.staffId;
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    data['Gender'] = this.gender;
    data['GenderName'] = this.genderName;
    data['AreaName'] = this.areaName;
    data['DeptId'] = this.deptId;
    data['Phone'] = this.phone;
    data['TryDate'] = this.tryDate.toString();
    data['Address'] = this.address;
    data['NowAddress'] = this.nowAddress;
    data['Remarks'] = this.remarks;
    data['Marry'] = this.marry;
    data['BirthDate'] = this.birthDate.toString();
    data['IdNum'] = this.idNum;
    data['Province'] = this.province;
    data['City'] = this.city;
    data['Nationality'] = this.nationality;
    data['GetJobWay'] = this.getJobWay;
    data['BankName'] = this.bankName;
    data['BankNum'] = this.bankNum;
    data['Tel'] = this.tel;
    data['WorkDate'] = this.workDate.toString();
    data['EducationName'] = this.educationName;
    data['GraduateDate'] = this.graduateDate.toString();
    data['LastSchool'] = this.lastSchool;
    data['Major'] = this.major;
    data['Card'] = this.card;
    data['EcName'] = this.ecName;
    data['EcRelation'] = this.ecRelation;
    data['EcTel'] = this.ecTel;
    data['EcAddress'] = this.ecAddress;
    data['Title'] = this.title;
    data['TitleLevel'] = this.titleLevel;
    data['ContractFrom'] = this.contractFrom.toString();
    data['ContractTo'] = this.contractTo.toString();
    data['IdCardExpiryDate'] = this.idCardExpiryDate.toString();
    data['IdCardLongEffective'] = this.idCardLongEffective;
    data['Duty'] = this.duty;
    data['InDate'] = this.inDate.toString();
    data['OutDate'] = this.outDate.toString();
    data['OutReason'] = this.outReason;
    data['GradeNo'] = this.gradeNo;
    data['AuditGrade'] = this.auditGrade;
    return data;
  }
}

class EmploymentRecord {
  int itemNO;
  String fromTo;
  String company;
  String duty;
  String leaveReason;

  EmploymentRecord(
      {this.itemNO, this.fromTo, this.company, this.duty, this.leaveReason});

  EmploymentRecord.fromJson(Map<String, dynamic> json) {
    itemNO = json['ItemNO'];
    fromTo = json['FromTo'];
    company = json['Company'];
    duty = json['Duty'];
    leaveReason = json['LeaveReason'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ItemNO'] = this.itemNO;
    data['FromTo'] = this.fromTo;
    data['Company'] = this.company;
    data['Duty'] = this.duty;
    data['LeaveReason'] = this.leaveReason;
    return data;
  }
}

class Files {
  int fileId;
  String filePath;
  String fileName;
  String remarks;
  DateTime createDate;
  File file;
  String fileExt;
  String shortName;

  Files(
      {this.fileId,
      this.filePath,
      this.fileName,
      this.remarks,
      this.createDate});

  Files.fromJson(Map<String, dynamic> json) {
    fileId = json['FileId'];
    filePath = json['FilePath'];
    fileName = json['FileName'];
    remarks = json['Remarks'];
    createDate = DateTime.parse(json['CreateDate']);
    this.fileExt = Utils.getFileExt(filePath);
    this.shortName = Utils.getFileName(filePath);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileId'] = this.fileId;
    data['FilePath'] = this.filePath;
    data['FileName'] = this.fileName;
    data['Remarks'] = this.remarks;
    data['CreateDate'] = this.createDate.toString();
    return data;
  }
}

class Performance {
  int performanceId;
  String dimension;
  String norm;
  String illustrate;
  String goal;
  String standard;
  String userFullName;

  Performance(
      {this.performanceId,
      this.dimension,
      this.norm,
      this.illustrate,
      this.goal,
      this.standard,
      this.userFullName});

  Performance.fromJson(Map<String, dynamic> json) {
    performanceId = json['PerformanceId'];
    dimension = json['Dimension'];
    norm = json['Norm'];
    illustrate = json['Illustrate'];
    goal = json['Goal'];
    standard = json['Standard'];
    userFullName = json['UserFullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PerformanceId'] = this.performanceId;
    data['Dimension'] = this.dimension;
    data['Norm'] = this.norm;
    data['Illustrate'] = this.illustrate;
    data['Goal'] = this.goal;
    data['Standard'] = this.standard;
    data['UserFullName'] = this.userFullName;
    return data;
  }
}
