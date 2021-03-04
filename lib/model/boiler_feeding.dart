class BoilerFeedingModel {
  int meterRecordId;
  int fuelDeviceId;
  int fuelId;
  double readQty;
  DateTime readTime;
  String remarks;
  String areaName;
  String fuelDeviceName;
  String fuelName;
  String uom;

  BoilerFeedingModel(
      {this.meterRecordId,
      this.fuelDeviceId,
      this.fuelId,
      this.readQty,
      this.readTime,
      this.remarks = '',
      this.areaName = '',
      this.fuelDeviceName = '',
      this.fuelName = '',
      this.uom = ''});

  BoilerFeedingModel.fromJson(Map<String, dynamic> json) {
    meterRecordId = json['MeterRecordId'];
    fuelDeviceId = json['FuelDeviceId'];
    fuelId = json['FuelId'];
    readQty = json['ReadQty'];
    readTime = DateTime.parse(json['ReadTime']);
    remarks = json['Remarks'];
    areaName = json['AreaName'];
    fuelDeviceName = json['FuelDeviceName'];
    fuelName = json['FuelName'];
    uom = json['Uom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MeterRecordId'] = this.meterRecordId;
    data['FuelDeviceId'] = this.fuelDeviceId;
    data['FuelId'] = this.fuelId;
    data['ReadQty'] = this.readQty;
    data['ReadTime'] = this.readTime.toIso8601String();
    data['Remarks'] = this.remarks;
    data['AreaName'] = this.areaName;
    data['FuelDeviceName'] = this.fuelDeviceName;
    data['FuelName'] = this.fuelName;
    data['Uom'] = this.uom;
    return data;
  }
}

class BFStcData {
  static int recoardId;
  static bool isUpdate = false;
  static List<FlueCategoryModel> categoryList = List<FlueCategoryModel>();
}

class BoilerFeedingDtlModel {
  int meterRecordId;
  int areaId;
  int fuelDeviceId;
  int fuelId;
  double readQty;
  DateTime readTime;
  String remarks;
  String uom;

  BoilerFeedingDtlModel(
      {this.meterRecordId,
      this.areaId,
      this.fuelDeviceId,
      this.fuelId,
      this.readQty,
      this.readTime,
      this.remarks,
      this.uom = ''});

  BoilerFeedingDtlModel.fromJson(Map<String, dynamic> json) {
    meterRecordId = json['MeterRecordId'];
    areaId = int.parse(json['AreaId']);
    fuelDeviceId = json['FuelDeviceId'];
    fuelId = json['FuelId'];
    readQty = json['ReadQty'];
    readTime = DateTime.parse(json['ReadTime']);
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MeterRecordId'] = this.meterRecordId;
    data['AreaId'] = this.areaId;
    data['FuelDeviceId'] = this.fuelDeviceId;
    data['FuelId'] = this.fuelId;
    data['ReadQty'] = this.readQty;
    data['ReadTime'] = this.readTime;
    data['Remarks'] = this.remarks;
    return data;
  }
}

class FlueCategoryModel {
  int deviceId;
  int areaId;
  String name;
  int typeId;
  int defaultFuelId;
  List<AvailableFuels> availableFuelList;

  FlueCategoryModel(
      {this.deviceId,
      this.areaId,
      this.name,
      this.typeId,
      this.defaultFuelId,
      this.availableFuelList});

  FlueCategoryModel.fromJson(Map<String, dynamic> json) {
    deviceId = json['DeviceId'];
    areaId = json['AreaId'];
    name = json['Name'];
    typeId = json['TypeId'];
    defaultFuelId = json['DefaultFuelId'];
    if (json['AvailableFuels'] != null) {
      availableFuelList = new List<AvailableFuels>();
      json['AvailableFuels'].forEach((v) {
        availableFuelList.add(new AvailableFuels.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DeviceId'] = this.deviceId;
    data['AreaId'] = this.areaId;
    data['Name'] = this.name;
    data['TypeId'] = this.typeId;
    data['DefaultFuelId'] = this.defaultFuelId;
    if (this.availableFuelList != null) {
      data['AvailableFuels'] =
          this.availableFuelList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvailableFuels {
  int fuelId;
  String name;
  String uom;

  AvailableFuels({this.fuelId, this.name, this.uom});

  AvailableFuels.fromJson(Map<String, dynamic> json) {
    fuelId = json['FuelId'];
    name = json['Name'];
    uom = json['Uom'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FuelId'] = this.fuelId;
    data['Name'] = this.name;
    data['Uom'] = this.uom;
    return data;
  }
}
