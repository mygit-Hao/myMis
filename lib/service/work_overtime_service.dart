import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/overtime_detail.dart';
import 'package:mis_app/model/overtime.dart';
import 'package:mis_app/service/service_method.dart';

class WorkOverTimeService {
  ///获取加班单列表
  static Future<WorkOverTimeModel> query(String keyword, int maxid) async {
    WorkOverTimeModel workOverTimeModel = new WorkOverTimeModel();
    bool withBaseDb = WorkOverTimeSData.areaList == null ? true : false;
    Map<String, dynamic> map = {
      'action': 'getlist',
      'keyword': keyword,
      'withbasedb': withBaseDb,
      'maxid': maxid
    };
    await request(serviceUrl[workOverTime], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      workOverTimeModel = WorkOverTimeModel.fromJson(responseData);
    });
    return workOverTimeModel;
  }

  static Future<OverTimeDetaiModel> getDetailData(int id) async {
    OverTimeDetaiModel overTimeDetaiModel;
    Map<String, dynamic> map = {
      'action': 'getdetail',
      'id': id,
    };
    await request(serviceUrl[workOverTime], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      overTimeDetaiModel = OverTimeDetaiModel.fromJson(responseData);
    });
    return overTimeDetaiModel;
  }

  static Future<OverTimeDetaiModel> requestService(String action,
      HeadData headData, List<OverTimeDetail> detail, bool submit) async {
    OverTimeDetaiModel overTimeDetaiModel = OverTimeDetaiModel();
    String data = json.encode(headData);
    String detaildata = json.encode(detail);
    Map<String, dynamic> map = {
      'action': action,
      'data': data,
      'detail': detaildata,
      'option': submit ? 'submit' : ''
    };

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workOverTime], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      overTimeDetaiModel = OverTimeDetaiModel.fromJson(responseData);
    });
    return overTimeDetaiModel;
  }

  static Future<OverTimeDetaiModel> deleteOrToDraft(
      String action, int id) async {
    OverTimeDetaiModel overTimeDetaiModel = OverTimeDetaiModel();
    Map<String, dynamic> map = {'action': action, 'id': id};
    await request(serviceUrl[workOverTime], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      overTimeDetaiModel = OverTimeDetaiModel.fromJson(responseData);
    });
    return overTimeDetaiModel;
  }
}
