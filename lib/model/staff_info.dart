class StaffInfo {
  int staffId;
  String staffCode;
  String staffName;
  String deptName;
  String posi;
  int defaultAreaId;
  int deptId;
  bool userIsPurchaser;
  bool canViewAllAttendance;

  StaffInfo(
      {this.staffId,
      this.staffCode,
      this.staffName,
      this.deptName,
      this.posi,
      this.defaultAreaId,
      this.deptId,
      this.userIsPurchaser,
      this.canViewAllAttendance});

  StaffInfo.fromJson(Map<String, dynamic> json) {
    staffId = json['StaffId'] ?? 0;
    staffCode = json['StaffCode'] ?? '';
    staffName = json['StaffName'] ?? '';
    deptName = json['DeptName'] ?? '';
    posi = json['Posi'] ?? '';
    defaultAreaId = json['i_DefaultAreaId'] ?? 0;
    deptId = json['i_DeptId'] ?? 0;
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
    data['i_DefaultAreaId'] = this.defaultAreaId;
    data['i_DeptId'] = this.deptId;
    data['UserIsPurchaser'] = this.userIsPurchaser;
    data['CanViewAllAttendance'] = this.canViewAllAttendance;
    return data;
  }
}
