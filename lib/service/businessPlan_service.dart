import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/businessPlan_data.dart';
import 'package:mis_app/model/businessPlan_list.dart';
import 'package:mis_app/service/service_method.dart';

class BusinessPlanService {
  static Future<BusinessPlanListModel> getList(
      String keyword, int maxid) async {
    BusinessPlanListModel businessPlanModel = new BusinessPlanListModel();
    bool withBaseDB = BusinessSData.typeList.length == 0 ? true : false;
    Map<String, dynamic> parameters = {
      'action': 'getList',
      'keyword': keyword,
      'withbasedb': withBaseDB,
      'maxid': maxid
    };

    FormData formData = FormData.fromMap(parameters);
    await request(serviceUrl[businessPlanUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      businessPlanModel = BusinessPlanListModel.fromJson(responseData);
    });
    return businessPlanModel;
  }

  static Future<Map> delete(int id) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    Map<String, dynamic> parameters = {'action': 'delete', 'planid': id};
    await request(serviceUrl[businessPlanUrl], queryParameters: parameters)
        .then((value) {
      result = jsonDecode(value.data.toString());
    });
    return result;
  }

  static Future<BusinesssPlanModel> getDetailData(int id) async {
    BusinesssPlanModel model = BusinesssPlanModel();
    Map<String, dynamic> parameters = {'action': 'getdetail', 'id': id};
    await request(serviceUrl[businessPlanUrl], queryParameters: parameters)
        .then((value) {
      var result = json.decode(value.data.toString());
      model = BusinesssPlanModel.fromJson(result);
    });
    return model;
  }

  static Future<BusinesssPlanModel> requestData(
    String action,
    bool submit,
    BusinessPlan plan,
  ) async {
    BusinesssPlanModel model = BusinesssPlanModel();
    List<BusinessPlanEmp> emp = BusinessSData.empList;
    List<BusinessPlanLine> line = BusinessSData.businessPlanLine;
    Map<String, dynamic> map = {
      'action': action,
      'plan': jsonEncode(plan),
      'planEmpList': jsonEncode(emp),
      'planLineList': jsonEncode(line),
      'option': submit ? 'submit' : ''
    };
    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[businessPlanUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      model = BusinesssPlanModel.fromJson(responseData);
    });
    return model;
  }

  static Future<BusinesssPlanModel> todraft(int id) async {
    BusinesssPlanModel model = BusinesssPlanModel();
    Map<String, dynamic> parameters = {'action': 'todraft', 'planid': id};
    await request(serviceUrl[businessPlanUrl], queryParameters: parameters)
        .then((value) {
      var responseData = jsonDecode(value.data.toString());
      model = BusinesssPlanModel.fromJson(responseData);
    });
    return model;
  }
}
