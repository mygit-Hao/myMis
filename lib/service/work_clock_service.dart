import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/history_clock.dart';
import 'package:mis_app/model/history_clock_detail.dart';
import 'package:mis_app/model/visit_customer_category.dart';
import 'package:mis_app/service/service_method.dart';
import '../model/visit_customer_category.dart';

class WorkClockService {
  static Future<CustomerVisitCateModel> getVisitCate() async {
    CustomerVisitCateModel customerVisitCateModel;
    Map map = {'action': 'getvisititems'};
    await request(serviceUrl[workClockUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.toString());
      customerVisitCateModel = CustomerVisitCateModel.fromJson(responseData);
    });
    return customerVisitCateModel;
  }

  ///判断是否在有效打卡范围内
  static Future<bool> isValidClockRange(kind, longitude, latitude) async {
    bool isValid = false;
    Map<String, dynamic> map = {
      'action': 'checkclockrange',
      'clockkindid': kind,
      'longitude': longitude,
      'latitude': latitude,
    };
    await request(serviceUrl[workClockUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      isValid = responseData['Result'];
    });
    return isValid;
  }

  ///上下班打卡
  static Future<Map> requestClock(
      kind, longitude, latitude, address, filePath) async {
    Map responseData;
    var file = await MultipartFile.fromFile(filePath, filename: filePath);
    Map<String, dynamic> map = {
      'action': 'clock-new',
      'clockkindid': kind,
      'longitude': longitude,
      'latitude': latitude,
      'address': address,
      "FileUpload": file,
    };

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workClockUrl], data: formData).then((value) {
      responseData = jsonDecode(value.data.toString());
    });
    return responseData;
  }

  //不在范围内打卡
  static Future<Map> requestOutofRangeClock(
      kind, longitude, latitude, address, photocount, reason, filePath) async {
    Map responseData;
    var file = await MultipartFile.fromFile(filePath, filename: filePath);
    Map<String, dynamic> map = {
      'action': 'clock-new',
      'clockkindid': kind,
      'longitude': longitude,
      'latitude': latitude,
      'address': address,
      'photocount': photocount,
      'reason': reason,
      "FileUpload": file,
    };

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workClockUrl], data: formData).then((value) {
      responseData = jsonDecode(value.data.toString());
    });
    return responseData;
  }

  static Future<Map> requestUploadPhotes(
      clockrecid, photocount, seqno, filePath) async {
    Map responseData;
    var file = await MultipartFile.fromFile(filePath, filename: filePath);
    Map<String, dynamic> map = {
      'action': 'upload-photos',
      'clockrecid': clockrecid,
      'photocount': photocount,
      'seqno': seqno,
      "FileUpload": file,
    };

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workClockUrl], data: formData).then((value) {
      responseData = jsonDecode(value.data.toString());
    });
    return responseData;
  }

  ///历史打卡记录
  static Future<List<HistoryClock>> getHistoryData(int option) async {
    List<HistoryClock> list = [];
    Map<String, dynamic> map = {'action': 'clockrec', 'option': option};

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workClockUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      responseData.forEach((item) {
        HistoryClock historyClock = HistoryClock.fromJson(item);
        list.add(historyClock);
      });
    });
    return list;
  }

  ///获取详细历史记录
  static Future<HistoryClockDetailModel> getHistoryDetail(
      int clockRecId) async {
    HistoryClockDetailModel historyClockDetailModel = HistoryClockDetailModel();
    Map<String, dynamic> map = {
      'action': 'clockrecdetail-new',
      'clockRecId': clockRecId
    };

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workClockUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      historyClockDetailModel = HistoryClockDetailModel.fromJson(responseData);
    });
    return historyClockDetailModel;
  }

  ///添加客服
  static Future<Map> addCustom(
      name, contactPerson, posi, tel, address, option) async {
    Map result = new Map();
    Map<String, dynamic> map = {
      'action': 'insertpotential',
      'name': name,
      'person': contactPerson,
      'posi': posi,
      'tel': tel,
      'address': address,
      'option': option
    };

    // FormData formData = FormData.fromMap(map);
    await request(serviceUrl[wxSalesUrl], queryParameters: map).then((value) {
      result = jsonDecode(value.data.toString());
    });
    return result;
  }

  ///获取客服数据
  static Future<List> getCustomerList(String action, String keyword,
      {String maxCode}) async {
    List list = List();
    Map<String, dynamic> map = {'action': action, 'keyword': keyword};

    if (action == 'getcustlist') {
      map.addAll({'maxCode': maxCode});
    }

    await request(serviceUrl[wxSalesUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data);
      responseData.forEach((item) {
        list.add(item);
      });
    });
    return list;
  }

  ///获取分类数据
  static Future<CustomerVisitCateModel> getVisitCategoryData() async {
    CustomerVisitCateModel visitCategoryModel = CustomerVisitCateModel();
    Map<String, dynamic> map = {'action': 'getvisititems'};
    await request(serviceUrl[wxSalesUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data);
      visitCategoryModel = CustomerVisitCateModel.fromJson(responseData);
    });
    return visitCategoryModel;
  }

  ///修改拜访报告
  static Future<Map> updateVisitReport(
      int clockrecid, String remarks, String contentdata) async {
    Map<String, dynamic> responseData;
    Map<String, dynamic> map = {
      'action': 'updateclockrecremarks',
      'clockrecid': clockrecid,
      'remarks': remarks,
      'contentdata': contentdata
    };
    // FormData formData = FormData.fromMap(map);
    await request(serviceUrl[workClockUrl], queryParameters: map).then((value) {
      responseData = jsonDecode(value.data.toString());
    });
    return responseData;
  }
}
