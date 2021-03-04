import 'package:mis_app/model/businessClockRecords.dart';
import 'package:mis_app/model/businessReport.dart';

class BusinessReportWrapper {
  int errCode;
  String errMsg;
  BusinessReportModel businessReportModel;
  List<ClockRecords> clockRecords;

  BusinessReportWrapper(
      {this.errCode, this.errMsg, this.businessReportModel, this.clockRecords});

  BusinessReportWrapper.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    var dataList = json['Data'];
    if (dataList != null) {
      // list = new List<BusinessReportModel>();
      // json['Data'].forEach((v) {
      //   list.add(new BusinessReportModel.fromJson(v));
      // });
      businessReportModel = new BusinessReportModel();
      if (dataList.length > 0) {
        var data = dataList[0];
        businessReportModel.onBusinessReportId = data['OnBusinessReportId'];
        businessReportModel.code = data['Code'];
        businessReportModel.planId = data['PlanId'];
        businessReportModel.planDid = data['PlanDid'];
        businessReportModel.reporterId = data['ReporterId'];
        businessReportModel.reporterName = data['ReporterName'];
        businessReportModel.reportDate = DateTime.parse(data['ReportDate']);
        businessReportModel.reportTitle = data['ReportTitle'];
        businessReportModel.summary = data['Summary'];
        businessReportModel.solution = data['Solution'];
        businessReportModel.nextPlan = data['NextPlan'];
        businessReportModel.thoughts = data['Thoughts'];
        businessReportModel.isUsed = data['isUsed'];
        businessReportModel.areaId = data['AreaId'];
        businessReportModel.areaName = data['AreaName'];
      }
    }
    if (json['ClockRecords'] != null) {
      clockRecords = new List<ClockRecords>();
      json['ClockRecords'].forEach((v) {
        clockRecords.add(new ClockRecords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.businessReportModel != null) {
      // data['Data'] = this.list.map((v) => v.toJson()).toList();
      data['OnBusinessReportId'] = this.businessReportModel.onBusinessReportId;
      data['Code'] = this.businessReportModel.code;
      data['PlanId'] = this.businessReportModel.planId;
      data['PlanDid'] = this.businessReportModel.planDid;
      data['ReporterId'] = this.businessReportModel.reporterId;
      data['ReporterName'] = this.businessReportModel.reporterName;
      data['ReportDate'] = this.businessReportModel.reportDate.toString();
      data['ReportTitle'] = this.businessReportModel.reportTitle;
      data['Summary'] = this.businessReportModel.summary;
      data['Solution'] = this.businessReportModel.solution;
      data['NextPlan'] = this.businessReportModel.nextPlan;
      data['Thoughts'] = this.businessReportModel.thoughts;
      data['isUsed'] = this.businessReportModel.isUsed;
      data['AreaId'] = this.businessReportModel.areaId;
      data['AreaName'] = this.businessReportModel.areaName;
    }
    if (this.clockRecords != null) {
      data['ClockRecords'] = this.clockRecords.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
