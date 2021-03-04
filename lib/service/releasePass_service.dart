import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/release.dart';
import 'package:mis_app/model/releaseFile.dart';
import 'package:mis_app/model/releasePass.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/service/service_method.dart';

Future<List<ReleasePassModel>> releaseAction(String keyword) async {
  List<ReleasePassModel> dataList = [];
  bool first;

  if (ReleaseBaseDB.staffID == 0) {
    first = true;
  } else {
    first = false;
  }
  try {
    Map<String, dynamic> data = {
      "action": "getlist",
      "withbasedb": first,
      "keyword": keyword,
    };
    await request(serviceUrl[releaseUrl], queryParameters: data).then((val) {
      var resposeJson = jsonDecode(val.data.toString());
      ReleaseModel release = ReleaseModel.fromJson(resposeJson);
      dataList = release.list;
      if (ReleaseBaseDB.staffID == 0) {
        ReleaseBaseDB.areaList = release.area;
        List<UserStaff> userStaff = release.userStaff;
        ReleaseBaseDB.typeList = release.passType;
        ReleaseBaseDB.areaId = userStaff[0].iDefaultAreaId;
        ReleaseBaseDB.staffCode = userStaff[0].staffCode;
        ReleaseBaseDB.staffName = userStaff[0].staffName;
        ReleaseBaseDB.deptName = userStaff[0].deptName;
        ReleaseBaseDB.staffID = userStaff[0].staffId;
      }
    });
  } catch (e) {
    print(e);
    return dataList;
  }
  return dataList;
}

Future<ReleasePassWrapper> releaseDetail(String id) async {
  ReleasePassWrapper result;
  try {
    Map<String, dynamic> map = {
      "action": "getdetail",
      "id": id,
    };
    await request(serviceUrl[releaseUrl], queryParameters: map).then(
      (val) {
        var data = jsonDecode(val.data.toString());
        if (data != null) {
          // var list = data['ReleasePass'];
          // if (list.length > 0) {
          //   result = ReleasePassModel.fromJson(list[0]);
          // }
          result = ReleasePassWrapper.fromJson(data);
        }
      },
    );
  } catch (e) {
    print(e);
    return result;
  }
  return result;
}

Future<ReleasePassWrapper> releaseService(
    String action, ReleasePassModel headData, String option) async {
  ReleasePassWrapper result;
  // String data = json.encode(headData);
  try {
    Map<String, dynamic> map = {
      "action": action,
      "applydate": headData.applyDate,
      "staffid": headData.staffId,
      "group": headData.groupName,
      "reason": headData.reason,
      "type": headData.typeCode,
      "areaid": headData.areaId,
      'option': option ?? '',
      "id": headData.releasePassId ?? '',
    };

    await request(serviceUrl[releaseUrl], queryParameters: map).then(
      (val) {
        var data = jsonDecode(val.data.toString());
        if (data != null) {
          var list = data['ReleasePass'];
          if (list.length > 0) {
            result = ReleasePassWrapper.fromJson(data);
          }
        }
      },
    );
  } catch (e) {
    print(e);
    return result;
  }
  return result;
}

Future<Map> delete(String action, String id) async {
  Map result;
  Map<String, dynamic> map = {'action': action, 'id': id};
  await request(serviceUrl[releaseUrl], queryParameters: map).then((val) {
    result = jsonDecode(val.data.toString());
  });
  return result;
}

Future<ReleaseFileModel> upload(String releasePassId, String filePath) async {
  ReleaseFileModel releaseFileModel = ReleaseFileModel();
  Map<String, dynamic> map = {
    'action': 'uploadattachment',
    'id': releasePassId,
    "FileUpload": await MultipartFile.fromFile(filePath, filename: filePath),
  };
  FormData formData = new FormData.fromMap(map);
  await request(serviceUrl[releaseUrl], data: formData).then((value) {
    var responseData = jsonDecode(value.data.toString());
    releaseFileModel = ReleaseFileModel.fromJson(responseData);
  });
  return releaseFileModel;
}

Future<RequestResult> uploadPhoto(String releasePassId, String filePath) async {
  RequestResult result = RequestResult();
  Map<String, dynamic> map = {
    'action': 'uploadphoto',
    'releasePassId': releasePassId,
    "FileUpload": await MultipartFile.fromFile(filePath, filename: filePath),
  };
  FormData formData = new FormData.fromMap(map);
  result = await request(serviceUrl[releaseUrl], data: formData);
  return result;
}

Future<ReleaseFileWrapper> attachementDelete(
    String releaseId, String releaseFileid) async {
  ReleaseFileWrapper releaseFileWrapper = ReleaseFileWrapper();
  Map<String, dynamic> result = {};
  Map<String, dynamic> map = {
    'action': 'deleteattachment',
    'releasepassid': releaseId,
    'releasepassfileid': releaseFileid
  };
  await request(serviceUrl[releaseUrl], queryParameters: map).then((value) {
    result = jsonDecode(value.data.toString());
    releaseFileWrapper = ReleaseFileWrapper.fromJson(result);
  });
  return releaseFileWrapper;
}
