import 'dart:convert';

import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/service/service_method.dart';

class GlobalService {
  static Future<Map<String, dynamic>> getUpdateInfo() async {
    Map<String, dynamic> result = Map();

    await httpRequest(serviceUrl[updateUrl], method: 'GET').then(
      (RequestResult value) async {
        if (value.success && (value.data != null)) {
          try {
            result = json.decode(value.data.toString());
          } catch (e) {
            print(e);
          }
        }
      },
    );

    return result;
  }
}
