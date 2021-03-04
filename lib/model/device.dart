class DevTypeModel {
  String code;
  String deviceName;

  DevTypeModel({this.code, this.deviceName});

  DevTypeModel.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    deviceName = json['DeviceName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['DeviceName'] = this.deviceName;
    return data;
  }
}

class DevData {
  int comDataId;
  String deviceNo;
  double value10;
  DateTime createDate;
  String areaName;
  String deviceTypeName;
  String comServiceIp;
  String comPort;
  String comLocation;
  String deviceLocation;

  DevData(
      {this.comDataId,
      this.deviceNo,
      this.value10,
      this.createDate,
      this.areaName,
      this.deviceTypeName,
      this.comServiceIp,
      this.comPort,
      this.comLocation,
      this.deviceLocation});

  DevData.fromJson(Map<String, dynamic> json) {
    comDataId = json['ComDataId'];
    deviceNo = json['DeviceNo'];
    value10 = json['Value10'];
    createDate = DateTime.parse(json['CreateDate']);
    areaName = json['AreaName'];
    deviceTypeName = json['DeviceTypeName'];
    comServiceIp = json['ComServiceIp'];
    comPort = json['ComPort'];
    comLocation = json['ComLocation'];
    deviceLocation = json['DeviceLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ComDataId'] = this.comDataId;
    data['DeviceNo'] = this.deviceNo;
    data['Value10'] = this.value10;
    data['CreateDate'] = this.createDate.toIso8601String();
    data['AreaName'] = this.areaName;
    data['DeviceTypeName'] = this.deviceTypeName;
    data['ComServiceIp'] = this.comServiceIp;
    data['ComPort'] = this.comPort;
    data['ComLocation'] = this.comLocation;
    data['DeviceLocation'] = this.deviceLocation;
    return data;
  }
}
