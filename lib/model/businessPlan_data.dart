class BusinesssPlanModel {
  int errCode;
  String errMsg;
  List<BusinessPlan> businessPlan;
  List<BusinessPlanEmp> businessPlanEmp;
  List<BusinessPlanLine> businessPlanLine;

  BusinesssPlanModel(
      {this.errCode,
      this.errMsg,
      this.businessPlan,
      this.businessPlanEmp,
      this.businessPlanLine});

  BusinesssPlanModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['BusinessPlan'] != null) {
      businessPlan = new List<BusinessPlan>();
      json['BusinessPlan'].forEach((v) {
        businessPlan.add(new BusinessPlan.fromJson(v));
      });
    }
    if (json['BusinessPlanEmp'] != null) {
      businessPlanEmp = new List<BusinessPlanEmp>();
      json['BusinessPlanEmp'].forEach((v) {
        businessPlanEmp.add(new BusinessPlanEmp.fromJson(v));
      });
    }
    if (json['BusinessPlanLine'] != null) {
      businessPlanLine = new List<BusinessPlanLine>();
      json['BusinessPlanLine'].forEach((v) {
        businessPlanLine.add(new BusinessPlanLine.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.businessPlan != null) {
      data['BusinessPlan'] = this.businessPlan.map((v) => v.toJson()).toList();
    }
    if (this.businessPlanEmp != null) {
      data['BusinessPlanEmp'] =
          this.businessPlanEmp.map((v) => v.toJson()).toList();
    }
    if (this.businessPlanLine != null) {
      data['BusinessPlanLine'] =
          this.businessPlanLine.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BusinessPlan {
  int businessPlanId;
  String planType;
  bool isTemp;
  String reason;
  DateTime applyDate;
  DateTime beginDate;
  DateTime endDate;
  String emps;
  int applyStaffId;
  String applyUser;
  String leaderUser;
  String proxyUser;
  double trafficCost;
  double livingCost;
  double accommodationsCost;
  double socialCost;
  double allCost;
  bool operable;
  int areaId;
  int status;
  String statusName;

  BusinessPlan(
      {this.businessPlanId = 0,
      this.planType,
      this.isTemp,
      this.reason,
      this.applyDate,
      this.beginDate,
      this.endDate,
      this.emps,
      this.applyStaffId,
      this.applyUser,
      this.leaderUser,
      this.proxyUser,
      this.trafficCost = 0.0,
      this.livingCost = 0.0,
      this.accommodationsCost = 0.0,
      this.socialCost = 0.0,
      this.allCost = 0.0,
      this.operable,
      this.areaId,
      this.status = 0,
      this.statusName = '草稿'});

  BusinessPlan.fromJson(Map<String, dynamic> json) {
    businessPlanId = json['BusinessPlanId'];
    planType = json['PlanType'];
    isTemp = json['IsTemp'];
    reason = json['Reason'];
    applyDate = DateTime.parse(json['ApplyDate']);
    beginDate = DateTime.parse(json['BeginDate']);
    endDate = DateTime.parse(json['EndDate']);
    emps = json['Emps'];
    applyStaffId = int.parse(json['ApplyStaffId']);
    applyUser = json['ApplyUser'];
    leaderUser = json['LeaderUser'];
    proxyUser = json['ProxyUser'];
    trafficCost = json['TrafficCost'];
    livingCost = json['LivingCost'];
    accommodationsCost = json['AccommodationsCost'];
    socialCost = json['SocialCost'];
    allCost = json['AllCost'];
    operable = json['Operable'];
    areaId = json['AreaId'];
    status = json['Status'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BusinessPlanId'] = this.businessPlanId;
    data['PlanType'] = this.planType;
    data['IsTemp'] = this.isTemp;
    data['Reason'] = this.reason;
    data['ApplyDate'] = this.applyDate.toIso8601String();
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    data['Emps'] = this.emps;
    data['ApplyStaffId'] = this.applyStaffId;
    data['ApplyUser'] = this.applyUser;
    data['LeaderUser'] = this.leaderUser;
    data['ProxyUser'] = this.proxyUser;
    data['TrafficCost'] = this.trafficCost;
    data['LivingCost'] = this.livingCost;
    data['AccommodationsCost'] = this.accommodationsCost;
    data['SocialCost'] = this.socialCost;
    data['AllCost'] = this.allCost;
    data['Operable'] = this.operable;
    data['AreaId'] = this.areaId;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    return data;
  }
}

class BusinessPlanEmp {
  // int tmpEmpId;
  int businessPlanEmpId;
  int businessPlanId;
  int staffId;
  String staffName;
  DateTime beginDate;
  DateTime endDate;
  // double days;

  BusinessPlanEmp({
    // this.tmpEmpId = 0,
    this.businessPlanEmpId = 0,
    this.businessPlanId = 0,
    this.staffId,
    this.staffName,
    this.beginDate,
    this.endDate,
    // this.days,
  });

  BusinessPlanEmp.fromJson(Map<String, dynamic> json) {
    businessPlanEmpId = int.parse(json['BusinessPlanEmpId']);
    // tmpEmpId = businessPlanEmpId;
    businessPlanId = int.parse(json['BusinessPlanId']);
    staffId = json['StaffId'];
    staffName = json['StaffName'];
    beginDate = DateTime.parse(json['BeginDate']);
    endDate = DateTime.parse(json['EndDate']);
    // days = json['Days'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BusinessPlanEmpId'] = this.businessPlanEmpId;
    data['BusinessPlanId'] = this.businessPlanId;
    data['StaffId'] = this.staffId;
    data['StaffName'] = this.staffName;
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    // data['Days'] = this.days;
    return data;
  }
}

class BusinessPlanLine {
  int businessPlanLineId;
  int businessPlanId;
  int businessPlanEmpId;
  DateTime beginDate;
  DateTime endDate;
  String plan;
  String address;
  String tel;
  String vehicleKind;

  BusinessPlanLine(
      {this.businessPlanLineId = 0,
      this.businessPlanId = 0,
      this.businessPlanEmpId = 0,
      this.beginDate,
      this.endDate,
      this.plan,
      this.address,
      this.tel,
      this.vehicleKind});

  BusinessPlanLine.fromJson(Map<String, dynamic> json) {
    businessPlanLineId = int.parse(json['BusinessPlanLineId']);
    businessPlanId = int.parse(json['BusinessPlanId']);
    businessPlanEmpId = int.parse(json['BusinessPlanEmpId'] ?? '0');
    if (json['BeginDate'] != null)
      beginDate = DateTime.parse(json['BeginDate']);
    if (json['EndDate'] != null) endDate = DateTime.parse(json['EndDate']);
    plan = json['Plan'];
    address = json['Address'];
    tel = json['Tel'];
    vehicleKind = json['VehicleKind'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BusinessPlanLineId'] = this.businessPlanLineId;
    data['BusinessPlanId'] = this.businessPlanId;
    data['BusinessPlanEmpId'] = this.businessPlanEmpId;
    data['BeginDate'] = this.beginDate.toIso8601String();
    data['EndDate'] = this.endDate.toIso8601String();
    data['Plan'] = this.plan;
    data['Address'] = this.address;
    data['Tel'] = this.tel;
    data['VehicleKind'] = this.vehicleKind;
    return data;
  }
}
