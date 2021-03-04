class BusinessReportModel {
  String onBusinessReportId;
  String code;
  String planId;
  String planDid;
  String reporterId;
  String reporterName;
  DateTime reportDate;
  String reportTitle;
  String summary;
  String solution;
  String nextPlan;
  String thoughts;
  int isUsed;
  int areaId;
  String areaName;

  BusinessReportModel(
      {this.onBusinessReportId,
      this.code,
      this.planId,
      this.planDid,
      this.reporterId,
      this.reporterName,
      this.reportDate,
      this.reportTitle,
      this.summary,
      this.solution,
      this.nextPlan,
      this.thoughts,
      this.isUsed,
      this.areaId,
      this.areaName});

  BusinessReportModel.fromJson(Map<String, dynamic> json) {
    onBusinessReportId = json['OnBusinessReportId'];
    code = json['Code'];
    planId = json['PlanId'];
    planDid = json['PlanDid'];
    reporterId = json['ReporterId'];
    reporterName = json['ReporterName'];
    reportDate = DateTime.parse(json['ReportDate']);
    reportTitle = json['ReportTitle'];
    summary = json['Summary'];
    solution = json['Solution'];
    nextPlan = json['NextPlan'];
    thoughts = json['Thoughts'];
    isUsed = json['isUsed'];
    areaId = json['AreaId'];
    areaName = json['AreaName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['OnBusinessReportId'] = this.onBusinessReportId;
    data['Code'] = this.code;
    data['PlanId'] = this.planId;
    data['PlanDid'] = this.planDid;
    data['ReporterId'] = this.reporterId;
    data['ReporterName'] = this.reporterName;
    data['ReportDate'] = this.reportDate.toString();
    data['ReportTitle'] = this.reportTitle;
    data['Summary'] = this.summary;
    data['Solution'] = this.solution;
    data['NextPlan'] = this.nextPlan;
    data['Thoughts'] = this.thoughts;
    data['isUsed'] = this.isUsed;
    data['AreaId'] = this.areaId;
    data['AreaName'] = this.areaName;
    return data;
  }
}