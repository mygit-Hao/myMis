class DeptModel {
  int deptId;
  String code;
  String name;
  String areaName;

  DeptModel({this.deptId, this.code, this.name, this.areaName});

  DeptModel.fromJson(Map<String, dynamic> json) {
    deptId = json['DeptId'];
    code = json['Code'];
    name = json['Name'];
    areaName = json['AreaName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DeptId'] = this.deptId;
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['AreaName'] = this.areaName;
    return data;
  }
}
