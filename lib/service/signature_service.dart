import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/signature_data.dart';
import 'package:mis_app/service/service_method.dart';

class SignatureService {
  static Future<bool> getSignature() async {
    bool success = false;
    //把action加在formData不生效，所以加在url中
    // String url = '${serviceUrl[fileServicePath]}?action=getsignature';
    String url = serviceUrl[fileServiceUrl];

    Map<String, dynamic> queryParameters = {'action': 'getsignature'};

    await downloadFile(url, Global.signatureFilePath,
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        success = true;
      },
    );

    return success;
  }

  static Future<RequestResult> uploadSignature() async {
    RequestResult result = RequestResult();
    String url = serviceUrl[fileServiceUrl];

    FormData formData = FormData.fromMap({
      "action": "uploadsignature",
      "FileUpload":
          await MultipartFile.fromFile(Global.signatureFilePath, filename: ""),
    });

    await request(url, data: formData).then(
      (RequestResult value) {
        try {
          var responseData = json.decode(value.data.toString());
          result.success = true;
          result.data = SignatureData.fromJson(responseData);
        } catch (e) {
          result.msg = e.toString();
        }
      },
    );

    return result;
  }
}
