import 'package:mis_app/utils/utils.dart';

class VehicleRequestBaseDbWrapper {
  List<RequestTypeModel> requestTypeList;
  List<VehicleModel> vehicleList;
  List<DriverModel> driverList;
  List<CarTypeModel> carTypeList;

  VehicleRequestBaseDbWrapper(
      {this.requestTypeList, this.vehicleList, this.driverList});

  VehicleRequestBaseDbWrapper.fromJson(Map<String, dynamic> json) {
    if (json['RequestType'] != null) {
      requestTypeList = new List<RequestTypeModel>();
      json['RequestType'].forEach((v) {
        requestTypeList.add(new RequestTypeModel.fromJson(v));
      });
    }
    if (json['Vehicle'] != null) {
      vehicleList = new List<VehicleModel>();
      json['Vehicle'].forEach((v) {
        vehicleList.add(new VehicleModel.fromJson(v));
      });
    }
    if (json['Driver'] != null) {
      driverList = new List<DriverModel>();
      json['Driver'].forEach((v) {
        driverList.add(new DriverModel.fromJson(v));
      });
    }
    if (json['CarType'] != null) {
      carTypeList = new List<CarTypeModel>();
      json['CarType'].forEach((v) {
        carTypeList.add(new CarTypeModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.requestTypeList != null) {
      data['RequestType'] =
          this.requestTypeList.map((v) => v.toJson()).toList();
    }
    if (this.vehicleList != null) {
      data['Vehicle'] = this.vehicleList.map((v) => v.toJson()).toList();
    }
    if (this.driverList != null) {
      data['Driver'] = this.driverList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RequestTypeModel {
  static const String selectingSourceExperts = "Experts";
  static const String selectingSourceApplicant = "Applicant";

  int requestTypeId;
  String code;
  String name;
  String property;
  bool selfDriving;
  String selectingSource;
  bool canSearchDriver;
  int vehicleType;

  bool get selectingSourceIsApplicant {
    return Utils.sameText(selectingSource, selectingSourceApplicant);
  }

  RequestTypeModel(
      {this.requestTypeId,
      this.code,
      this.name,
      this.property,
      this.selfDriving,
      this.selectingSource,
      this.canSearchDriver,
      this.vehicleType});

  RequestTypeModel.fromJson(Map<String, dynamic> json) {
    requestTypeId = json['i_RequestTypeId'];
    code = json['nc_Code'];
    name = json['nc_Name'];
    property = json['nc_Property'];
    selfDriving = json['b_SelfDriving'];
    selectingSource = json['nc_SelectingList'];
    canSearchDriver = json['b_CanSearchDriver'];
    vehicleType = json['i_VehicleType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['i_RequestTypeId'] = this.requestTypeId;
    data['nc_Code'] = this.code;
    data['nc_Name'] = this.name;
    data['nc_Property'] = this.property;
    data['b_SelfDriving'] = this.selfDriving;
    data['nc_SelectingList'] = this.selectingSource;
    data['b_CanSearchDriver'] = this.canSearchDriver;
    data['i_VehicleType'] = this.vehicleType;
    return data;
  }
}

class VehicleModel {
  static const int vehicleTypePublic = 1;
  static const int vehicleTypePrivate = 2;

  int vehicleId;
  String name;
  int vehicleType;

  VehicleModel({this.vehicleId, this.name, this.vehicleType});

  VehicleModel.fromJson(Map<String, dynamic> json) {
    vehicleId = json['i_VehicleId'];
    name = json['nc_Name'];
    vehicleType = json['i_VehicleType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['i_VehicleId'] = this.vehicleId;
    data['nc_Name'] = this.name;
    data['i_VehicleType'] = this.vehicleType;
    return data;
  }
}

class DriverModel {
  int staffId;
  String code;
  String name;
  String tel;

  DriverModel({this.staffId, this.code, this.name, this.tel});

  DriverModel.fromJson(Map<String, dynamic> json) {
    staffId = json['i_StaffId'];
    code = json['nc_Code'];
    name = json['nc_Name'];
    tel = json['nc_Tel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['i_StaffId'] = this.staffId;
    data['nc_Code'] = this.code;
    data['nc_Name'] = this.name;
    data['nc_Tel'] = this.tel;
    return data;
  }
}

class CarTypeModel {
  String carType;

  CarTypeModel({this.carType});

  CarTypeModel.fromJson(Map<String, dynamic> json) {
    carType = json['nc_CarType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nc_CarType'] = this.carType;
    return data;
  }
}
