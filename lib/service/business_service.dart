import 'package:flutter/material.dart';
import 'package:mis_app/model/business.dart';
import 'package:mis_app/model/businessReport.dart';
import 'package:mis_app/model/businessReportWrapper.dart';
import 'package:mis_app/service/service_method.dart';
import 'dart:async';
import '../config/service_url.dart';
import 'dart:convert';

Future<List<BusinessReportModel>> businessAction(String keyword) async {
  List<BusinessReportModel> dataList = [];
  bool first;

  if (BusinessBaseDB.staffID == 0) {
    first = true;
  } else {
    first = false;
  }
  try {
    Map<String, dynamic> data = {
      "action": "getlist",
      "withbasedb": first,
      "keyword": keyword,
    };
    await request(serviceUrl[businessUrl], queryParameters: data).then((val) {
      var resposeJson = jsonDecode(val.data.toString());
      BusinessModel business = BusinessModel.fromJson(resposeJson);
      dataList = business.list;
      if (BusinessBaseDB.staffID == 0) {
        BusinessBaseDB.areaList = business.area;
        List<UserStaff> userStaff = business.userStaff;
        BusinessBaseDB.areaId = userStaff[0].iDefaultAreaId;
        BusinessBaseDB.staffName = userStaff[0].staffName;
        BusinessBaseDB.staffID = userStaff[0].staffId;
      }
    });
  } catch (e) {
    print(e);
    return dataList;
  }
  return dataList;
}

Future businessCard(
    String planId, int staffId, String summary, String cardTitle) async {
  var resposeJson;
  try {
    Map<String, dynamic> data = {
      "action": "getPlanData",
      "planid": planId,
      "staffid": staffId,
    };
    await request(serviceUrl[businessUrl], queryParameters: data).then(
      (val) {
        resposeJson = jsonDecode(val.data.toString());
      },
    );
  } catch (e) {
    print(e);
  }
  return resposeJson;
}

Future<BusinessReportWrapper> businessSave(
    {BuildContext context,
    String action,
    BusinessReportModel dataBusiness}) async {
  BusinessReportWrapper resposeJson;
  Map jsonData = {
    "OnBusinessReportId": dataBusiness.onBusinessReportId,
    "PlanId": dataBusiness.planId,
    "PlanDid": dataBusiness.planDid,
    "ReporterId": dataBusiness.reporterId,
    "ReportDate": dataBusiness.reportDate.toString(),
    "ReportTitle": dataBusiness.reportTitle,
    "Summary": dataBusiness.summary,
    "Solution": dataBusiness.solution,
    "NextPlan": dataBusiness.nextPlan,
    "Thoughts": dataBusiness.thoughts,
    "AreaId": dataBusiness.areaId,
  };
  try {
    Map<String, dynamic> map = {
      "action": action,
      "data": json.encode(jsonData),
    };
    await request(serviceUrl[businessUrl], queryParameters: map).then(
      (val) {
        var data = jsonDecode(val.data.toString());
        resposeJson = BusinessReportWrapper.fromJson(data);
      },
    );
  } catch (e) {
    print(e);
  }
  return resposeJson;
}

Future businessDel(BuildContext context, String businessReportyId) async {
  var resposeJson;
  try {
    Map<String, dynamic> data = {
      "action": "delete",
      "id": businessReportyId,
    };
    await request(serviceUrl[businessUrl], queryParameters: data).then(
      (val) {
        resposeJson = jsonDecode(val.data.toString());
      },
    );
  } catch (e) {
    print(e);
    return resposeJson;
  }
  return resposeJson;
}

Future businessDetail(String id) async {
  var resposeJson;
  try {
    Map<String, dynamic> map = {
      "action": "getdetail",
      "id": id,
    };
    await request(serviceUrl[businessUrl], queryParameters: map).then(
      (val) {
        resposeJson = jsonDecode(val.data.toString());
      },
    );
  } catch (e) {
    print(e);
    return resposeJson;
  }
  return resposeJson;
}

Future getBusinessPlan(int id) async {
  var resposeJson;
  try {
    Map<String, dynamic> data = {
      "action": "getBusinessPlan",
      "staffid": id,
    };
    await request(serviceUrl[businessUrl], queryParameters: data).then((val) {
      resposeJson = jsonDecode(val.data.toString());
    });
  } catch (e) {
    print(e);
    return resposeJson;
  }
  return resposeJson;
}
