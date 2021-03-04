class GroupCheckModel {
  List<GroupCheckData> data;
  List<DetailDept> detailDept;
  List<DetailUser> detailUser;
  int errCode;
  String errMsg;

  GroupCheckModel(
      {this.data, this.detailDept, this.detailUser, this.errCode, this.errMsg});

  GroupCheckModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = new List<GroupCheckData>();
      json['Data'].forEach((v) {
        data.add(new GroupCheckData.fromJson(v));
      });
    }
    if (json['DetailDept'] != null) {
      detailDept = new List<DetailDept>();
      json['DetailDept'].forEach((v) {
        detailDept.add(new DetailDept.fromJson(v));
      });
    }
    if (json['DetailUser'] != null) {
      detailUser = new List<DetailUser>();
      json['DetailUser'].forEach((v) {
        detailUser.add(new DetailUser.fromJson(v));
      });
    }
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data.map((v) => v.toJson()).toList();
    }
    if (this.detailDept != null) {
      data['DetailDept'] = this.detailDept.map((v) => v.toJson()).toList();
    }
    if (this.detailUser != null) {
      data['DetailUser'] = this.detailUser.map((v) => v.toJson()).toList();
    }
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    return data;
  }
}

class GroupCheckData {
  int areaGroupId;
  String areaGroupName;
  int areaId;
  String areaName;
  DateTime checkDate;
  // String checkDate;
  int checkId;
  String checkUserChnName;
  String groupName;
  int status;
  String statusName;

  GroupCheckData(
      {this.areaGroupId,
      this.areaGroupName,
      this.areaId,
      this.areaName,
      this.checkDate,
      this.checkId,
      this.checkUserChnName,
      this.groupName,
      this.status,
      this.statusName});

  GroupCheckData.fromJson(Map<String, dynamic> json) {
    areaGroupId = json['AreaGroupId'];
    areaGroupName = json['AreaGroupName'];
    areaId = json['AreaId'];
    areaName = json['AreaName'];
    checkDate = DateTime.parse(json['CheckDate']);
    checkId = json['CheckId'];
    checkUserChnName = json['CheckUserChnName'];
    groupName = json['GroupName'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AreaGroupId'] = this.areaGroupId;
    data['AreaGroupName'] = this.areaGroupName;
    data['AreaId'] = this.areaId;
    data['AreaName'] = this.areaName;
    data['CheckDate'] = this.checkDate.toIso8601String();
    data['CheckId'] = this.checkId;
    data['CheckUserChnName'] = this.checkUserChnName;
    data['GroupName'] = this.groupName;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class DetailDept {
  int countOfDefect;
  int deptId;
  String deptName;
  double sumOfDeduct;

  DetailDept(
      {this.countOfDefect, this.deptId, this.deptName, this.sumOfDeduct});

  DetailDept.fromJson(Map<String, dynamic> json) {
    countOfDefect = json['CountOfDefect'];
    deptId = json['DeptId'];
    deptName = json['DeptName'];
    sumOfDeduct = json['SumOfDeduct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CountOfDefect'] = this.countOfDefect;
    data['DeptId'] = this.deptId;
    data['DeptName'] = this.deptName;
    data['SumOfDeduct'] = this.sumOfDeduct;
    return data;
  }
}

class DetailUser {
  int checkDetailUserId;
  String userChnName;
  String userId;

  DetailUser({/*this.checkDetailUserId,*/ this.userChnName, this.userId});

  DetailUser.fromJson(Map<String, dynamic> json) {
    // checkDetailUserId = json['CheckDetailUserId'];
    userChnName = json['UserChnName'];
    userId = json['UserId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    // data['CheckDetailUserId'] = this.checkDetailUserId;
    data['UserChnName'] = this.userChnName;
    data['UserId'] = this.userId;
    return data;
  }
}
