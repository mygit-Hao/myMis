import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/buCard.dart';
import 'package:mis_app/model/buCardWrapper.dart';
import 'package:mis_app/service/service_method.dart';

Future<List<BuCardList>> buCardAction(String keyword) async {
  List<BuCardList> dataList = [];
  bool first;

  if (BuCardBaseDB.staffID == 0) {
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
    await request(serviceUrl[buCardUrl], queryParameters: data).then((val) {
      var resposeJson = jsonDecode(val.data.toString());
      BuCardModel release = BuCardModel.fromJson(resposeJson);
      dataList = release.list;
      if (BuCardBaseDB.staffID == 0) {
        BuCardBaseDB.areaList = release.area;
        BuCardBaseDB.kindList = release.kind;
        List<UserStaff> userStaff = release.userStaff;
        BuCardBaseDB.areaId = userStaff[0].iDefaultAreaId;
        BuCardBaseDB.staffCode = userStaff[0].staffCode;
        BuCardBaseDB.staffName = userStaff[0].staffName;
        BuCardBaseDB.staffID = userStaff[0].staffId;
        BuCardBaseDB.deptName = userStaff[0].deptName;
        BuCardBaseDB.deptId = userStaff[0].iDeptId;
        BuCardBaseDB.posi = userStaff[0].posi;
      }
    });
  } catch (e) {
    print(e);
    return dataList;
  }
  return dataList;
}

Future<BuCardWrapper> buCardDetail(String id) async {
  BuCardWrapper result;
  try {
    Map<String, dynamic> map = {
      "action": "getdetail",
      "id": id,
    };
    await request(serviceUrl[buCardUrl], queryParameters: map).then(
      (val) {
        var data = jsonDecode(val.data.toString());
        if (data != null) {
          result = BuCardWrapper.fromJson(data);
        }
      },
    );
  } catch (e) {
    print(e);
    return result;
  }
  return result;
}

Future<BuCardWrapper> buCardService(String action, BuCardList headData,
    List<Detail> detailList, String option) async {
  BuCardWrapper result;
  String data = jsonEncode(headData);
  String detail = jsonEncode(detailList);
  try {
    Map<String, dynamic> map = {
      "action": action,
      "data": data,
      "detail": detail,
      'option': option ?? '',
    };

    FormData formData = FormData.fromMap(map);
    await request(serviceUrl[buCardUrl], data: formData).then(
      (val) {
        var data = jsonDecode(val.data.toString());
        result = BuCardWrapper.fromJson(data);
      },
    );
  } catch (e) {
    print(e);
    return result;
  }
  return result;
}

Future<BuCardWrapper> toDraftOrDelete(String action, String id) async {
  BuCardWrapper detailModel;

  Map<String, dynamic> map = {'action': action, 'id': id};
  FormData formData = FormData.fromMap(map);
  await request(serviceUrl[buCardUrl], data: formData).then((val) {
    var data = jsonDecode(val.data.toString());
    detailModel = BuCardWrapper.fromJson(data);
  });
  return detailModel;
}
