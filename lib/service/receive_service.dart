import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/receive.dart';
import 'package:mis_app/model/receiveBase.dart';
import 'package:mis_app/model/receivePhone.dart';
import 'package:mis_app/model/receiveWrapper.dart';
import 'package:mis_app/service/service_method.dart';

Future<List<ReceiveList>> receiveAction(String keyword) async {
  List<ReceiveList> dataList = [];

  if (ReceiveBaseDB.staffID == 0) {
    try {
      Map<String, dynamic> data = {
        "action": "basedb",
      };
      await request(serviceUrl[generalUrl], queryParameters: data).then((val) {
        var resposeJson = jsonDecode(val.data.toString());
        ReceiveBaseModel release = ReceiveBaseModel.fromJson(resposeJson);
        ReceiveBaseDB.areaList = release.area;
        ReceiveBaseDB.currencyList = release.currency;
        List<UserStaff> userStaff = release.userStaff;
        ReceiveBaseDB.areaId = userStaff[0].iDefaultAreaId;
        ReceiveBaseDB.staffCode = userStaff[0].staffCode;
        ReceiveBaseDB.staffName = userStaff[0].staffName;
        ReceiveBaseDB.staffID = userStaff[0].staffId;
        ReceiveBaseDB.deptName = userStaff[0].deptName;
        ReceiveBaseDB.deptId = userStaff[0].iDeptId;
        ReceiveBaseDB.posi = userStaff[0].posi;
      });
    } catch (e) {
      print(e);
    }

    try {
      Map<String, dynamic> data = {
        "action": "basedb",
      };
      await request(serviceUrl[receiveUrl], queryParameters: data).then((val) {
        var resposeJson = jsonDecode(val.data.toString());
        ReceivePhoneModel release = ReceivePhoneModel.fromJson(resposeJson);
        ReceiveBaseDB.receiveRoom = release.roomlist;
        ReceiveBaseDB.receivePerson = release.personlist;
      });
    } catch (e) {
      print(e);
    }
  }

  try {
    Map<String, dynamic> data = {
      "action": "get_list",
      "keyword": keyword,
    };
    await request(serviceUrl[receiveUrl], queryParameters: data).then((val) {
      var resposeJson = jsonDecode(val.data.toString());
      ReceiveModel receiveModel = ReceiveModel.fromJson(resposeJson);
      dataList = receiveModel.list;
    });
  } catch (e) {
    print(e);
    return dataList;
  }
  return dataList;
}

Future receiveDetail(String id) async {
  var resposeJson;
  try {
    Map<String, dynamic> map = {
      "action": "get_detail",
      "id": id,
    };
    await request(serviceUrl[receiveUrl], queryParameters: map).then(
      (val) {
        resposeJson = jsonDecode(val.data.toString());
      },
    );
  } catch (e) {
    print(e);
    return resposeJson;
  }
  return resposeJson;
}

Future<ReceiveWrapper> requestData(
  String action,
  bool submit,
  ReceiveList receiveList,
  List<ReceiveDetail> detail,
  List<ReceiveRoom> room,
) async {
  ReceiveWrapper receiveWrapper = ReceiveWrapper();
  List<ReceiveDetail> detailList = detail;
  List<ReceiveRoom> roomList = room;
  Map<String, dynamic> map = {
    'action': action,
    'data': jsonEncode(receiveList),
    'detail': jsonEncode(detailList),
    'rooms': jsonEncode(roomList),
    'option': submit ? 'submit' : ''
  };
  FormData formData = FormData.fromMap(map);
  await request(serviceUrl[receiveUrl], data: formData).then((value) {
    var responseData = jsonDecode(value.data.toString());
    receiveWrapper = ReceiveWrapper.fromJson(responseData);
  });
  return receiveWrapper;
}

Future<ReceiveWrapper> todraft(String id) async {
  ReceiveWrapper receiveWrapper = ReceiveWrapper();
  Map<String, dynamic> parameters = {'action': 'todraft', 'id': id};
  await request(serviceUrl[receiveUrl], queryParameters: parameters)
      .then((value) {
    var responseData = jsonDecode(value.data.toString());
    receiveWrapper = ReceiveWrapper.fromJson(responseData);
  });
  return receiveWrapper;
}

Future<Map> delete(String id) async {
  Map<String, dynamic> result = Map<String, dynamic>();
  Map<String, dynamic> parameters = {'action': 'delete', 'id': id};
  await request(serviceUrl[receiveUrl], queryParameters: parameters)
      .then((value) {
    result = jsonDecode(value.data.toString());
  });
  return result;
}

Future<ReceiveWrapper> upload(String receiveId, String filePath) async {
  ReceiveWrapper releaseFileModel = ReceiveWrapper();
  Map<String, dynamic> map = {
    'action': 'uploadattachment',
    'id': receiveId,
    "FileUpload": await MultipartFile.fromFile(filePath, filename: filePath),
  };
  FormData formData = new FormData.fromMap(map);
  await request(serviceUrl[receiveUrl], data: formData).then((value) {
    var responseData = jsonDecode(value.data.toString());
    releaseFileModel = ReceiveWrapper.fromJson(responseData);
  });
  return releaseFileModel;
}

Future<ReceiveWrapper> attachementDelete(
    String receiveId, String receiveFileid) async {
  ReceiveWrapper releaseFileWrapper = ReceiveWrapper();
  Map<String, dynamic> result = {};
  Map<String, dynamic> map = {
    'action': 'deleteattachment',
    'id': receiveId,
    'receivefileid': receiveFileid
  };
  await request(serviceUrl[receiveUrl], queryParameters: map).then((value) {
    result = jsonDecode(value.data.toString());
    releaseFileWrapper = ReceiveWrapper.fromJson(result);
  });
  return releaseFileWrapper;
}
