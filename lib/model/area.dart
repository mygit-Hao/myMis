class Area {
  int areaId;
  String code;
  String shortName;

  Area({this.areaId, this.code, this.shortName});

  Area.fromJson(Map<String, dynamic> json) {
    areaId = json['AreaId'];
    code = json['Code'];
    shortName = json['ShortName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AreaId'] = this.areaId;
    data['Code'] = this.code;
    data['ShortName'] = this.shortName;
    return data;
  }
}
