import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/week_plan_basedb.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/model/week_plan_proj.dart';
import 'package:mis_app/service/service_method.dart';

class WeekPlanService {
  static Future<WeekPlanProjModel> getList(int staffId, int option) async {
    WeekPlanProjModel model = WeekPlanProjModel();
    Map<String, dynamic> map = {
      'action': 'list',
      'staffid': staffId,
      'option': option
    };
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var result = jsonDecode(value.data.toString());
      model = WeekPlanProjModel.fromJson(result);
    });
    return model;
  }

  static Future<WeekPlanDtlModel> requestData(String action, int projId) async {
    WeekPlanDtlModel model = WeekPlanDtlModel();
    Map<String, dynamic> map = {
      'action': action,
      'proj-id': projId,
    };
    FormData data = FormData.fromMap(map);
    await request(serviceUrl[weekPlanUrl], data: data).then((value) {
      var result = jsonDecode(value.data.toString());
      model = WeekPlanDtlModel.fromJson(result);
    });
    return model;
  }

  static Future<WeekPlanStatusModel> getbaseDb() async {
    WeekPlanStatusModel model = WeekPlanStatusModel();
    Map<String, dynamic> map = {'action': 'basedb'};
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      model = WeekPlanStatusModel.fromJson(responseData);
    });
    return model;
  }

  static Future<WeekPlanDtlModel> updateDetail(
      WeekPlanProjData projData) async {
    WeekPlanDtlModel dtlModel = WeekPlanDtlModel();
    Map<String, dynamic> map = {
      'action': 'update-proj',
      'data': jsonEncode(projData),
      // 'data': jsonEncode(planDtlModel.toJson()),
    };
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      dtlModel = WeekPlanDtlModel.fromJson(responseData);
    });
    return dtlModel;
  }

  static Future<WeekPlanDtlModel> addPartner(
      int projId, List<int> partners) async {
    WeekPlanDtlModel result = WeekPlanDtlModel();
    var json = jsonEncode(partners);
    Map<String, dynamic> map = {
      'action': 'add-partners',
      'proj-id': projId,
      'partners': json
    };
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      result = WeekPlanDtlModel.fromJson(responseData);
    });
    return result;
  }

  static Future<WeekPlanDtlModel> deletePartner(int projId, int staffId) async {
    WeekPlanDtlModel result = WeekPlanDtlModel();
    Map<String, dynamic> map = {
      'action': 'delete-partner',
      'proj-id': projId,
      'staff-id': staffId
    };
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      result = WeekPlanDtlModel.fromJson(responseData);
    });
    return result;
  }

  static Future<WeekPlanDtlModel> updateProgress(Week week) async {
    WeekPlanDtlModel model = WeekPlanDtlModel();
    var jsonWeek = jsonEncode(week);
    Map<String, dynamic> map = {'action': 'update-weeks', 'data': jsonWeek};
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      model = WeekPlanDtlModel.fromJson(responseData);
    });
    return model;
  }

  static Future<WeekPlanDtlModel> deleteProgress(int weekId) async {
    WeekPlanDtlModel dtlModel = WeekPlanDtlModel();
    Map<String, dynamic> map = {
      'action': 'delete-weeks',
      'week-id': weekId,
    };
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      dtlModel = WeekPlanDtlModel.fromJson(responseData);
    });
    return dtlModel;
  }

  static Future<WeekPlanDtlModel> uploadWeekFile(int projId, String filePath,
      {int weekId}) async {
    WeekPlanDtlModel model = WeekPlanDtlModel();
    Map<String, dynamic> map = {
      'action': 'upload-file',
      'proj-id': projId,
      'week-id': weekId,
      "FileUpload": await MultipartFile.fromFile(filePath, filename: filePath),
    };
    FormData formData = new FormData.fromMap(map);
    await request(serviceUrl[weekPlanUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      model = WeekPlanDtlModel.fromJson(responseData);
    });
    return model;
  }

  static Future<WeekPlanDtlModel> deleteWeekFile(int weekPlanObjFilId) async {
    WeekPlanDtlModel model = WeekPlanDtlModel();
    Map<String, dynamic> result = {};
    Map<String, dynamic> map = {
      'action': 'delete-file',
      'week-file-id': weekPlanObjFilId
    };
    await request(serviceUrl[weekPlanUrl], queryParameters: map).then((value) {
      result = jsonDecode(value.data.toString());
      model = WeekPlanDtlModel.fromJson(result);
    });
    return model;
  }
}
