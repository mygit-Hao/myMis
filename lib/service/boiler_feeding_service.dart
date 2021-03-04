import 'dart:convert';

import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/boiler_feeding.dart';
import 'package:mis_app/service/service_method.dart';

class BoilerFeedingService {
  // static int maxId = 0;
  static Future getList(String keyword, int maxid) async {
    List<BoilerFeedingModel> list = [];
    Map<String, dynamic> map = {
      'action': 'getmeterrecordlist',
      'keyword': keyword,
      'maxid': maxid
    };

    await request(serviceUrl[boilerFeedingUrl], queryParameters: map)
        .then((value) {
      var responseData = jsonDecode(value.data.toString());
      responseData.forEach((val) {
        BoilerFeedingModel item = BoilerFeedingModel.fromJson(val);
        list.add(item);
      });
    });
    // (list.length > 0) ? maxId = list[list.length - 1].meterRecordId : maxId = 0;

    return list;
  }

  static Future<Map<String, dynamic>> delete(int id) async {
    Map<String, dynamic> result;
    Map<String, dynamic> map = {
      'action': 'deletemeterrecord',
      'recordId': id,
    };
    var response =
        await request(serviceUrl[boilerFeedingUrl], queryParameters: map);
    result = jsonDecode(response.data.toString());
    return result;
  }

  static Future<BoilerFeedingDtlModel> getDetailData(int recordId) async {
    BoilerFeedingDtlModel model = BoilerFeedingDtlModel();
    Map<String, dynamic> map = {
      'action': 'getmeterrecorddetail',
      'recordId': recordId
    };
    await request(serviceUrl[boilerFeedingUrl], queryParameters: map)
        .then((value) {
      var responseData = value.data;
      var data = jsonDecode(responseData);
      model = BoilerFeedingDtlModel.fromJson(data[0]);
    });
    return model;
  }

  static Future<Map> getScanData(String scanCode) async {
    Map<String, dynamic> result = Map<String, dynamic>();
    Map<String, dynamic> map = {
      'action': 'getfueldevicebycode',
      'code': scanCode
    };
    await request(serviceUrl[boilerFeedingUrl], queryParameters: map)
        .then((value) {
      var responseData = value.data;
      result = jsonDecode(responseData);
    });
    return result;
  }

  static Future<Map> save(BoilerFeedingDtlModel detail) async {
    Map<String, dynamic> responseData = Map();
    Map<String, dynamic> map = {
      'action':
          BFStcData.recoardId == 0 ? 'insertmeterrecord' : 'updatemeterrecord',
      'areaId': detail.areaId,
      'fuelDeviceId': detail.fuelDeviceId,
      'fuelId': detail.fuelId,
      'qty': detail.readQty,
      // 'uom': detail.uom,
      'readTime': detail.readTime,
      'remarks': detail.remarks
    };
    if (BFStcData.recoardId != 0) {
      map.addAll({'recordId': BFStcData.recoardId});
    }
    await request(serviceUrl[boilerFeedingUrl], queryParameters: map)
        .then((value) {
      responseData = jsonDecode(value.data);
    });
    return responseData;
  }

  static Future<List<FlueCategoryModel>> getBaseDb() async {
    List<FlueCategoryModel> list = [];
    Map<String, dynamic> map = {'action': 'getfueldevices'};
    await request(serviceUrl[boilerFeedingUrl], queryParameters: map)
        .then((value) {
      List responseData = jsonDecode(value.data);
      responseData.forEach((element) {
        list.add(FlueCategoryModel.fromJson(element));
      });
    });
    return list;
  }
}
