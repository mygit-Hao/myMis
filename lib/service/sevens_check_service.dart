import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/sevens_basedb.dart';
import 'package:mis_app/service/service_method.dart';

class SevensCheckService {
  static Future<SevensBaseDBModel> getCheckBaseData() async {
    SevensBaseDBModel baseDBModel;
    Map<String, dynamic> queryParameters = {
      'action': 'basedb',
    };
    await request(serviceUrl[sevensCheckUrl], queryParameters: queryParameters)
        .then((val) {
      String responseStr = val.data.toString();
      var responseData = jsonDecode(responseStr);
      baseDBModel = SevensBaseDBModel.fromJson(responseData);
    });
    return baseDBModel;
  }

  static Future<List<Map>> getCheckData(String keyword, int id) async {
    List<Map> list = [];
    Map<String, dynamic> queryParameters = {
      'action': 'get_list',
      'keyword': keyword,
      'maxid': id
    };
    await request(serviceUrl[sevensCheckUrl], queryParameters: queryParameters)
        .then((val) {
      var responseData = json.decode(val.data.toString());
      list = (responseData['List'] as List).cast();
    });
    return list;
  }

  static Future<Map> getRequstResult(int checkId, String action) async {
    Map delResult;
    Map<String, dynamic> deleteParmeters = {
      'action': action,
      'id': checkId,
    };
    await request(serviceUrl[sevensCheckUrl], queryParameters: deleteParmeters)
        .then((v) {
      delResult = json.decode(v.data.toString());
    });
    return delResult;
  }

  static Future<Map> getRequstResult1(String dataJson, String detailUserjson,
      String action, bool confirm) async {
    Map delResult;
    Map<String, dynamic> deleteParmeters = {
      'data': dataJson,
      'detail_user': detailUserjson,
      'action': action,
      'option': confirm ? 'confirm' : '',
    };
    await request(serviceUrl[sevensCheckUrl], queryParameters: deleteParmeters)
        .then((v) {
      delResult = json.decode(v.data.toString());
    });
    return delResult;
  }

  static Future<Map> getRequstResult3(
      int deptId, int checkId, String action) async {
    Map delResult;
    Map<String, dynamic> deleteParmeters = {
      'action': action,
      'id': checkId,
      'deptid': deptId,
    };
    await request(serviceUrl[sevensCheckUrl], queryParameters: deleteParmeters)
        .then((v) {
      delResult = json.decode(v.data.toString());
    });
    return delResult;
  }

  static Future<RequestResult> requestDetailData(action, Map map,
      {String filePath}) async {
    RequestResult result = RequestResult();
    var jsonData = json.encode(map);
    String url = serviceUrl[sevensCheckUrl];
    var requestMap = action == "add_detail"
        ? {
            "action": action,
            "data": jsonData,
            "FileUpload":
                await MultipartFile.fromFile(filePath, filename: filePath),
          }
        : {
            "action": action,
            "data": jsonData,
          };

    FormData formData = FormData.fromMap(requestMap);

    await request(url, data: formData).then(
      (RequestResult value) {
        try {
          var responseData = json.decode(value.data.toString());
          result.success = true;
          //  result.data = responseData[''];
          result.data = responseData;
        } catch (e) {
          result.msg = e.toString();
        }
      },
    );

    return result;
  }

  static Future<Map> deleteDetailCheck(int detailCheckId) async {
    Map resultMap;
    var map = {"action": "delete_detail", "detail_spot_id": detailCheckId};
    await request(serviceUrl[sevensCheckUrl], queryParameters: map)
        .then((value) => resultMap = jsonDecode(value.data.toString()));
    return resultMap;
  }
}
