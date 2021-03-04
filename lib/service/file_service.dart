import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/service/service_method.dart';

class FileService {
  static Future<bool> downloadAttachment(int fileId, String filePath) async {
    bool success = false;
    String url = serviceUrl[fileServiceUrl];

    Map<String, dynamic> queryParameters = {
      'action': 'getfile',
      'fileid': fileId,
    };

    await downloadFile(url, filePath, queryParameters: queryParameters).then(
      (RequestResult value) {
        success = true;
      },
    );

    return success;
  }
}
