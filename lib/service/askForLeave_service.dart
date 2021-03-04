import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/askForLeave.dart';
import 'package:mis_app/model/askForLeaveDetail.dart';
import 'package:mis_app/service/service_method.dart';

class AskForLeaveService {
  static Future<AskForLeaveModel> getAskForLeaveList(
      String keyword, bool withbaseDb, int maxid) async {
    AskForLeaveModel askForLeaveModel = new AskForLeaveModel();
    Map<String, dynamic> map = {
      'action': 'getList',
      'keyword': keyword ?? '',
      'maxid': maxid,
      'withbasedb': withbaseDb,
    };

    await request(serviceUrl[askForLeaveUrl], queryParameters: map)
        .then((value) {
      var responseData = jsonDecode(value.data.toString());
      askForLeaveModel = AskForLeaveModel.fromJson(responseData);
    });
    return askForLeaveModel;
  }

  static Future<AskForLeaveDetailModel> getDetailData(int id) async {
    AskForLeaveDetailModel askForLeaveDetailModel =
        new AskForLeaveDetailModel();
    Map<String, dynamic> map = {
      'action': 'getDetail',
      'id': id.toString(),
    };
    await request(serviceUrl[askForLeaveUrl], queryParameters: map)
        .then((value) {
      var response = jsonDecode(value.data.toString());
      askForLeaveDetailModel = AskForLeaveDetailModel.fromJson(response);
    });

    return askForLeaveDetailModel;
  }

  static Future<List<OverTimeSelectModel>> getOverTimeList(int staffId) async {
    List<OverTimeSelectModel> selectList = [];
    Map<String, dynamic> map = {'action': 'getovertime', 'staffID': staffId};
    await request(serviceUrl[askForLeaveUrl], queryParameters: map)
        .then((value) {
      List responsedata = jsonDecode(value.data.toString());
      responsedata.forEach((item) {
        OverTimeSelectModel overTimeSelectModel =
            OverTimeSelectModel.fromJson(item);
        selectList.add(overTimeSelectModel);
      });
    });
    return selectList;
  }

  static Future<AskForLeaveDetailModel> requstsaveOrSubmit(String action,
      AskForLeaveData headData, List<OverTimeSelectModel> overTimeList,
      {String submit}) async {
    AskForLeaveDetailModel detailModel = new AskForLeaveDetailModel();
    String data = jsonEncode(headData);
    String detail = jsonEncode(overTimeList);
    Map<String, dynamic> map = {
      'action': action,
      'data': data,
      'detail': detail,
      'option': submit ?? ''
    };
    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[askForLeaveUrl], data: formData).then((value) {
      var responseDate = jsonDecode(value.data.toString());
      detailModel = AskForLeaveDetailModel.fromJson(responseDate);
    });
    return detailModel;
  }

  static Future<AskForLeaveDetailModel> toDraftOrDelete(
      String action, int id) async {
    AskForLeaveDetailModel detailModel = new AskForLeaveDetailModel();

    Map<String, dynamic> map = {'action': action, 'id': id};
    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[askForLeaveUrl], data: formData).then((value) {
      var responseDate = jsonDecode(value.data.toString());
      detailModel = AskForLeaveDetailModel.fromJson(responseDate);
    });
    return detailModel;
  }

  static Future<AskForLeaveDetailModel> upload(String filePath) async {
    AskForLeaveDetailModel askForLeaveDetailModel = AskForLeaveDetailModel();
    Map<String, dynamic> map = {
      'action': 'uploadattachment',
      'id': AskForLeaveSData.askForLeaveId,
      "FileUpload": await MultipartFile.fromFile(filePath, filename: filePath),
    };
    FormData formData = new FormData.fromMap(map);
    await request(serviceUrl[askForLeaveUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      askForLeaveDetailModel = AskForLeaveDetailModel.fromJson(responseData);
    });
    return askForLeaveDetailModel;
  }

  static Future<AskForLeaveDetailModel> attachementDelete(
      String askForleaveFileid) async {
    AskForLeaveDetailModel askForLeaveDetailModel = AskForLeaveDetailModel();
    Map<String, dynamic> result = {};
    Map<String, dynamic> map = {
      'action': 'deleteattachment',
      'id': AskForLeaveSData.askForLeaveId,
      'askForLeaveFileId': askForleaveFileid
    };
    await request(serviceUrl[askForLeaveUrl], queryParameters: map)
        .then((value) {
      result = jsonDecode(value.data.toString());
      askForLeaveDetailModel = AskForLeaveDetailModel.fromJson(result);
    });
    return askForLeaveDetailModel;
  }

  static Future<ArrangeData> getArrange(int staffId) async {
    ArrangeData arrangeData = ArrangeData();
    Map<String, dynamic> map = {
      'action': 'getArrange',
      'staffId': staffId,
    };
    await request(serviceUrl[askForLeaveUrl], queryParameters: map)
        .then((value) {
      var result = jsonDecode(value.data.toString());
      if (result['Data'].length != 0) {
        var data = result['Data'][0];
        arrangeData = ArrangeData.fromJson(data);
      }
    });
    return arrangeData;
  }
}
