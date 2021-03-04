import 'dart:convert';

import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/staffQuery.dart';
import 'package:mis_app/service/service_method.dart';

class StaffService {
  static Future<StaffQueryModel> requestStaffData(int staffId) async {
    StaffQueryModel model = StaffQueryModel();
    Map<String, dynamic> map = {
      'action': 'staff-detail',
      'staff-id': staffId,
    };
    await request(serviceUrl[hrmsUrl], queryParameters: map).then((value) {
      var result = jsonDecode(value.data.toString());
      model = StaffQueryModel.fromJson(result);
    });
    return model;
  }

  // static Future<StaffQueryModel> requestUpdateData(
  //     StaffDetailModel staffDetailModel) async {
  //   StaffQueryModel model = StaffQueryModel();
  //   String data = jsonEncode(staffDetailModel);
  //   Map<String, dynamic> map = {
  //     'action': 'staff-update',
  //     'data': data,
  //   };
  //   FormData formData = FormData.fromMap(map);
  //   await request(serviceUrl[hrmsUrl], data: formData).then((value) {
  //     var result = jsonDecode(value.data.toString());
  //     model = StaffQueryModel.fromJson(result);
  //   });
  //   return model;
  // }
}
