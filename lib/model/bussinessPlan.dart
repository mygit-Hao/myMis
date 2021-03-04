class BusinessPlanModel {
  String planId;
  String planDid;
  String applyDate;
  String planType;
  int staffId;
  String staffCode;
  String staffName;
  String posi;
  String deptName;
  String reason;
  String beginDate;
  String endDate;

  BusinessPlanModel(
      {this.planId,
      this.planDid,
      this.applyDate,
      this.planType,
      this.staffId,
      this.staffCode,
      this.staffName,
      this.posi,
      this.deptName,
      this.reason,
      this.beginDate,
      this.endDate});

  BusinessPlanModel.fromJson(Map<String, dynamic> json) {
    planId = json['PlanId'];
    planDid = json['PlanDid'];
    applyDate = json['ApplyDate'];
    planType = json['PlanType'];
    staffId = json['StaffId'];
    staffCode = json['StaffCode'];
    staffName = json['StaffName'];
    posi = json['Posi'];
    deptName = json['DeptName'];
    reason = json['Reason'];
    beginDate = json['BeginDate'];
    endDate = json['EndDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PlanId'] = this.planId;
    data['PlanDid'] = this.planDid;
    data['ApplyDate'] = this.applyDate;
    data['PlanType'] = this.planType;
    data['StaffId'] = this.staffId;
    data['StaffCode'] = this.staffCode;
    data['StaffName'] = this.staffName;
    data['Posi'] = this.posi;
    data['DeptName'] = this.deptName;
    data['Reason'] = this.reason;
    data['BeginDate'] = this.beginDate;
    data['EndDate'] = this.endDate;
    return data;
  }
}
