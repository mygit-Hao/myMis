class StaffModel {
  int staffId;
  int deptId;
  String code;
  String name;
  String deptName;
  String posi;
  int gender;
  String genderName;
  String areaName;
  String phone;
  DateTime inDate;
  DateTime contractFrom;
  DateTime contractTo;

  StaffModel(
      {this.staffId,
      this.deptId,
      this.code,
      this.name,
      this.deptName,
      this.posi,
      this.gender,
      this.genderName,
      this.areaName,
      this.phone,
      this.inDate,
      this.contractFrom,
      this.contractTo});

  StaffModel.fromJson(Map<String, dynamic> json) {
    staffId = json['StaffId'];
    deptId = json['DeptId'];
    code = json['Code'];
    name = json['Name'];
    deptName = json['DeptName'];
    posi = json['Posi'];
    gender = json['Gender'];
    genderName = json['GenderName'];
    areaName = json['AreaName'];
    phone = json['Phone'] ?? '';
    inDate = DateTime.parse(json['InDate']);
    contractFrom = DateTime.parse(json['ContractFrom']);
    contractTo=DateTime.parse(json['ContractTo']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StaffId'] = this.staffId;
    data['DeptId'] = this.deptId;
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    data['Gender'] = this.gender;
    data['GenderName'] = this.genderName;
    data['AreaName'] = this.areaName;
    data['Phone'] = this.phone;
    data['InDate']=this.inDate.toString();
    data['ContractFrom']=this.contractFrom.toString();
    data['ContractTo']=this.contractTo.toString();
    return data;
  }
}
