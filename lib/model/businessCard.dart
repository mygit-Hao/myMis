import 'package:mis_app/model/businessClockRecords.dart';

class BusinessCardModel {
  PlaneLine planeLine;
  List<ClockRecords> clockRecords;

  BusinessCardModel({this.planeLine, this.clockRecords});

  BusinessCardModel.fromJson(Map<String, dynamic> json) {
    if (json['PlaneLine'] != null) {
      // planeLine = new List<PlaneLine>();
      // json['PlaneLine'].forEach((v) {
      //   planeLine.add(new PlaneLine.fromJson(v));
      // });
      var dataList = json['PlaneLine'];
      if (dataList != null) {
        planeLine = new PlaneLine();
        if (dataList.length > 0) {
          var data = dataList[0];
          planeLine.businessPlanLineId = data['BusinessPlanLineId'];
          planeLine.businessPlanLineDid = data['BusinessPlanLineDid'];
          planeLine.reason = data['Reason'];
          planeLine.plan = data['Plan'];
        }
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
    if (this.planeLine != null) {
      // data['PlaneLine'] = this.planeLine.map((v) => v.toJson()).toList();
      data['BusinessPlanLineId'] = this.planeLine.businessPlanLineId;
      data['BusinessPlanLineDid'] = this.planeLine.businessPlanLineDid;
      data['Reason'] = this.planeLine.reason;
      data['Plan'] = this.planeLine.plan;
    }
    if (this.clockRecords != null) {
      data['ClockRecords'] = this.clockRecords.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PlaneLine {
  String businessPlanLineId;
  String businessPlanLineDid;
  String reason;
  String plan;

  PlaneLine(
      {this.businessPlanLineId,
      this.businessPlanLineDid,
      this.reason,
      this.plan});

  PlaneLine.fromJson(Map<String, dynamic> json) {
    businessPlanLineId = json['BusinessPlanLineId'];
    businessPlanLineDid = json['BusinessPlanLineDid'];
    reason = json['Reason'];
    plan = json['Plan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BusinessPlanLineId'] = this.businessPlanLineId;
    data['BusinessPlanLineDid'] = this.businessPlanLineDid;
    data['Reason'] = this.reason;
    data['Plan'] = this.plan;
    return data;
  }
}
