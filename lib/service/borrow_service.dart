import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/borrow.dart';
import 'package:mis_app/model/borrow_detail.dart';
import 'package:mis_app/service/service_method.dart';

class BorrowService {
  static Future<BorrowModel> getList(String keyword, int maxid) async {
    BorrowModel borrowModel = BorrowModel();
    Map<String, dynamic> map = {
      'action': 'getList',
      'keyword': keyword,
      'maxid': maxid,
      'withbasedb': BorrowSData.area.length == 0 ? true : false,
    };
    await request(serviceUrl[borrowUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      borrowModel = BorrowModel.fromJson(responseData);
    });
    return borrowModel;
  }

  static Future<Map> delete(int id) async {
    Map<String, dynamic> result = {};
    Map<String, dynamic> map = {
      'action': 'delete',
      'id': id,
    };
    await request(serviceUrl[borrowUrl], queryParameters: map).then((value) {
      result = json.decode(value.data.toString());
    });
    return result;
  }

  static Future<BorrowDetaiModel> toDraft(int id) async {
    BorrowDetaiModel result = BorrowDetaiModel();
    Map<String, dynamic> map = {
      'action': 'todraft',
      'id': id,
    };
    await request(serviceUrl[borrowUrl], queryParameters: map).then((value) {
      var responseData = json.decode(value.data.toString());
      result = BorrowDetaiModel.fromJson(responseData);
    });
    return result;
  }

  static Future<BorrowDetaiModel> getDetail(int id) async {
    BorrowDetaiModel borrowDtl = BorrowDetaiModel();
    Map<String, dynamic> parameters = {'action': 'getDetail', 'id': id};
    await request(serviceUrl[borrowUrl], queryParameters: parameters)
        .then((value) {
      var responseData = jsonDecode(value.data.toString());
      borrowDtl = BorrowDetaiModel.fromJson(responseData);
    });
    return borrowDtl;
  }

  static Future<BorrowDetaiModel> borrowRequest(
      String action, BorrowData borrowData, bool isSubmit) async {
    BorrowDetaiModel detaiModel = BorrowDetaiModel();
    if (action == 'submit') {
      action = (borrowData.borrowId == null) ? 'add' : 'submit';
    }
    Map<String, dynamic> parameter = {
      'action': action,
      'id': borrowData.borrowId,
      'applydate': borrowData.applyDate.toIso8601String(),
      'staffid': borrowData.staffId,
      'repaymentdate': borrowData.repaymentDate.toIso8601String(),
      'payment': borrowData.payment,
      'reason': borrowData.reason,
      'receipt': borrowData.receipt,
      'bankname': borrowData.bankName,
      'bankcode': borrowData.bankCode,
      'currency': borrowData.currency,
      'amount': borrowData.amount,
      'areaid': borrowData.areaId,
      'option': isSubmit ? 'submit' : '',
    };
    FormData formData = FormData.fromMap(parameter);
    await request(serviceUrl[borrowUrl], data: formData).then((value) {
      var responseData = jsonDecode(value.data.toString());
      detaiModel = BorrowDetaiModel.fromJson(responseData);
    });
    return detaiModel;
  }

  static Future<Map<String, dynamic>> upload(int id, String filePath) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    Map<String, dynamic> map = {
      'action': 'uploadattachment',
      'id': id,
      "FileUpload": await MultipartFile.fromFile(filePath, filename: filePath),
    };
    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[borrowUrl], data: formData).then((value) {
      result = jsonDecode(value.data.toString());
    });
    return result;
  }

  static Future<Map<String, dynamic>> deleteAttach(
      int id, String fileId) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    Map<String, dynamic> map = {
      'action': 'deleteattachment',
      'id': id,
      "borrowfileid": fileId,
    };
    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[borrowUrl], data: formData).then((value) {
      result = jsonDecode(value.data.toString());
    });
    return result;
  }
}
