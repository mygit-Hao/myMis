import 'package:mis_app/model/businessPlan_data.dart';

class BusinessSData {
  static List<PlanType> typeList = [];
  static List<VehicleKind> vehicleKindList = [];
  // static bool isAddstaff = true;
  static List<BusinessPlanEmp> empList = [];
  static List<BusinessPlanLine> businessPlanLine = [];
  static int status = 0;
  static int planId = 0;
  static int curEmpId = 0;
  static DateTime data = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 0, 0, 0, 0, 0);
  static DateTime beginData = data;
  static DateTime endData = data;
}

class BusinessPlanListModel {
  List<BusinessPlanData> businesslist;
  List<PlanType> planType;
  List<VehicleKind> vehicleKind;

  BusinessPlanListModel({this.businesslist, this.planType, this.vehicleKind});

  BusinessPlanListModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      businesslist = new List<BusinessPlanData>();
      json['List'].forEach((v) {
        businesslist.add(new BusinessPlanData.fromJson(v));
      });
    }
    if (json['PlanType'] != null) {
      planType = new List<PlanType>();
      json['PlanType'].forEach((v) {
        planType.add(new PlanType.fromJson(v));
      });
    }
    if (json['VehicleKind'] != null) {
      vehicleKind = new List<VehicleKind>();
      json['VehicleKind'].forEach((v) {
        vehicleKind.add(new VehicleKind.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.businesslist != null) {
      data['List'] = this.businesslist.map((v) => v.toJson()).toList();
    }
    if (this.planType != null) {
      data['PlanType'] = this.planType.map((v) => v.toJson()).toList();
    }
    if (this.vehicleKind != null) {
      data['VehicleKind'] = this.vehicleKind.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BusinessPlanData {
  int businessPlanId;
  String planType;
  bool isTemp;
  String reason;
  DateTime beginDate;
  DateTime endDate;
  String emps;
  String applyStaffId;
  String applyUser;
  String leaderUser;
  String proxyUser;
  bool operable;
  int status;
  String statusName;

  BusinessPlanData(
      {this.businessPlanId,
      this.planType,
      this.isTemp,
      this.reason,
      this.beginDate,
      this.endDate,
      this.emps,
      this.applyStaffId,
      this.applyUser,
      this.leaderUser,
      this.proxyUser,
      this.operable,
      this.status,
      this.statusName});

  BusinessPlanData.fromJson(Map<String, dynamic> json) {
    businessPlanId = json['BusinessPlanId'];
    planType = json['PlanType'];
    isTemp = json['IsTemp'];
    reason = json['Reason'];
    beginDate = DateTime.parse(json['BeginDate']);
    endDate = DateTime.parse(json['EndDate']);
    emps = json['Emps'];
    applyStaffId = json['ApplyStaffId'];
    applyUser = json['ApplyUser'];
    leaderUser = json['LeaderUser'];
    proxyUser = json['ProxyUser'];
    operable = json['Operable'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BusinessPlanId'] = this.businessPlanId;
    data['PlanType'] = this.planType;
    data['IsTemp'] = this.isTemp;
    data['Reason'] = this.reason;
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    data['Emps'] = this.emps;
    data['ApplyStaffId'] = this.applyStaffId;
    data['ApplyUser'] = this.applyUser;
    data['LeaderUser'] = this.leaderUser;
    data['ProxyUser'] = this.proxyUser;
    data['Operable'] = this.operable;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class PlanType {
  int planTypeId;
  String code;
  String name;

  PlanType({this.planTypeId, this.code, this.name});

  PlanType.fromJson(Map<String, dynamic> json) {
    planTypeId = json['PlanTypeId'];
    code = json['Code'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PlanTypeId'] = this.planTypeId;
    data['Code'] = this.code;
    data['Name'] = this.name;
    return data;
  }
}

class VehicleKind {
  int vehicleKindID;
  String name;

  VehicleKind({this.vehicleKindID, this.name});

  VehicleKind.fromJson(Map<String, dynamic> json) {
    vehicleKindID = json['VehicleKindID'];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['VehicleKindID'] = this.vehicleKindID;
    data['Name'] = this.name;
    return data;
  }
}
