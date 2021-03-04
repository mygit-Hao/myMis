import 'package:mis_app/utils/utils.dart';

class OverTimeDetaiModel {
  int errCode;
  String errMsg;
  // List<Data> data;
  HeadData headData;
  List<OverTimeDetail> detailList = [];

  OverTimeDetaiModel(
      {this.errCode, this.errMsg, this.headData, this.detailList});

  OverTimeDetaiModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['Data'] != null) {
      // data = new List<Data>();
      // json['Data'].forEach((v) {
      //   data.add(new Data.fromJson(v));
      // });
      var jsonData = json['Data'][0];
      headData = HeadData.fromJson(jsonData);
    }
    if (json['Detail'] != null) {
      detailList = new List<OverTimeDetail>();
      json['Detail'].forEach((v) {
        detailList.add(new OverTimeDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.headData != null) {
      // data['Data'] = this.data.map((v) => v.toJson()).toList();
      data['Data'][0] = this.headData.toJson();
    }
    if (this.detailList != null) {
      data['Detail'] = this.detailList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class HeadData {
  String code;
  int overTimeId;
  int areaId;
  int deptId;
  String deptName;
  DateTime applyDate;
  int status = 0;
  String statusName = '';

  HeadData(
      {this.code,
      this.overTimeId = 0,
      this.areaId,
      this.deptId,
      this.deptName = '',
      this.applyDate,
      this.status = 0,
      this.statusName = '草稿'}) {
    if (this.applyDate == null) this.applyDate = Utils.today;
  }

  HeadData.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    overTimeId = int.parse(json['OverTimeId']);
    areaId = json['AreaId'];
    deptId = int.parse(json['DeptId']);
    deptName = json['DeptName'];
    applyDate = DateTime.parse(json['ApplyDate']);
    status = json['Status'];
    statusName = json['StatusName'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['OverTimeId'] = this.overTimeId;
    data['AreaId'] = this.areaId;
    data['DeptId'] = this.deptId.toString();
    data['DeptName'] = this.deptName;
    data['ApplyDate'] = this.applyDate.toIso8601String();
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class OverTimeDetail {
  // int overTimeId;
  // int overTimeDId;
  String overTimeId;
  String overTimeDId;
  String code;
  int staffId;
  String name;
  int deptId;
  String deptName;
  String posi;
  DateTime beginDate;
  DateTime endDate;
  double time;
  String reason;
  String type;
  String typeName;
  int did;

  OverTimeDetail(
      {this.overTimeId,
      this.overTimeDId,
      this.code,
      this.staffId,
      this.name,
      this.deptId,
      this.deptName,
      this.posi,
      this.beginDate,
      this.endDate,
      this.time,
      this.reason,
      this.type,
      this.typeName,
      this.did});

  OverTimeDetail.fromJson(Map<String, dynamic> json) {
    // overTimeId = int.parse(json['OverTimeId']);
    // overTimeDId = int.parse(json['OverTimeDId']);
    overTimeId = json['OverTimeId'];
    overTimeDId = json['OverTimeDId'];
    code = json['Code'];
    staffId = json['StaffId'];
    name = json['Name'];
    deptId = json['DeptId'];
    deptName = json['DeptName'];
    posi = json['Posi'];
    beginDate = DateTime.parse(json['BeginDate']);
    endDate = DateTime.parse(json['EndDate']);
    time = json['Time'];
    reason = json['Reason'];
    type = json['Type'];
    typeName = json['TypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OverTimeId'] = this.overTimeId;
    data['OverTimeDId'] = this.overTimeDId;
    data['Code'] = this.code;
    data['StaffId'] = this.staffId;
    data['Name'] = this.name;
    data['DeptId'] = this.deptId;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    data['Time'] = this.time;
    data['Reason'] = this.reason;
    data['Type'] = this.type;
    data['TypeName'] = this.typeName;
    return data;
  }
}
