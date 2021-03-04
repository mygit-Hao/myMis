import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/vehicle_request.dart';
import 'package:mis_app/model/vehicle_request_base_db.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class OaService {
  static Future<RequestResult> deleteVehicleRequest(
      int vehicleRequestId) async {
    RequestResult result = RequestResult(success: false);

    Map<String, dynamic> queryParameters = {
      'action': 'delete',
      'id': vehicleRequestId
    };

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          if (responseData['ErrCode'] == 0) {
            result.success = true;
          } else {
            result.msg = responseData['ErrMsg'];
          }
        }
      },
    );

    return result;
  }

  static Future<VehicleRequestModel> vehicleRequestToDraft(
      int vehicleRequestId) async {
    VehicleRequestModel result;

    Map<String, dynamic> queryParameters = {
      'action': 'to-draft',
      'id': vehicleRequestId,
    };

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          if (responseData['ErrCode'] != 0) {
            DialogUtils.showToast(responseData['ErrMsg']);
          } else {
            if ((responseData['Data'] != null) &&
                (responseData['Data'].length > 0)) {
              result = VehicleRequestModel.fromJson(responseData['Data'][0]);
            }
          }
        }
      },
    );

    return result;
  }

  static Future<VehicleRequestModel> updateUserVehicleRequest(
      VehicleRequestModel vehicleRequest,
      {bool toSubmit = false}) async {
    VehicleRequestModel result;

    Map<String, dynamic> map = {
      'action': 'update-user-request',
      'data': json.encode(vehicleRequest),
      'option': toSubmit ? 'submit' : '',
    };

    FormData formData = FormData.fromMap(map);

    await request(serviceUrl[vehicleRequestUrl], data: formData).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          if (responseData['ErrCode'] != 0) {
            DialogUtils.showToast(responseData['ErrMsg']);
          } else {
            if ((responseData['Data'] != null) &&
                (responseData['Data'].length > 0)) {
              result = VehicleRequestModel.fromJson(responseData['Data'][0]);
            }
          }
        }
      },
    );

    return result;
  }

  static Future<List<VehicleRequestModel>> getVehicleUserRequestList(
      String keyword,
      {int maxId = 0}) async {
    List<VehicleRequestModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'get-user-request-list',
      'keyword': keyword,
      'maxid': maxId
    };

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new VehicleRequestModel.fromJson(v));
        });
      },
    );

    return list;
  }

  static Future<VehicleRequestModel> cancelVehicleRequest(
      int vehicleRequestId) async {
    VehicleRequestModel result;

    Map<String, dynamic> queryParameters;
    queryParameters = {'action': 'cancel', 'id': vehicleRequestId};

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        if (responseData != null) {
          if (responseData['Success']) {
            if (responseData['Data'].length > 0) {
              result = VehicleRequestModel.fromJson(responseData['Data'][0]);
            }
          } else {
            DialogUtils.showToast("操作未成功:  ${responseData['Msg']}");
          }
        }
      },
    );

    return result;
  }

  static Future<VehicleRequestModel> updateVehicleRequest(
      VehicleRequestModel vehicleRequest, bool shifting) async {
    VehicleRequestModel result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'update',
      'id': vehicleRequest.vehicleRequestId,
      'requesttype': vehicleRequest.requestType,
      'vehicleid': vehicleRequest.vehicleId,
      'staffid': vehicleRequest.driverStaffId ?? 0,
      'shifting': Utils.boolToString(shifting)
    };

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        // if ((responseData != null) && (responseData['Data'].length > 0)) {
        //   result = VehicleRequestModel.fromJson(responseData['Data'][0]);
        // }
        if (responseData != null) {
          if (responseData['Success']) {
            if (responseData['Data'].length > 0) {
              result = VehicleRequestModel.fromJson(responseData['Data'][0]);
            }
          } else {
            DialogUtils.showToast("操作未成功:  ${responseData['Msg']}");
          }
        }
      },
    );

    return result;
  }

  static Future<VehicleRequestModel> getVehicleRequest(
      int vehicleRequestId) async {
    VehicleRequestModel result;

    Map<String, dynamic> queryParameters;
    queryParameters = {
      'action': 'get-detail-v2',
      'id': vehicleRequestId,
    };

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        if (responseData == null) return;

        if ((responseData['Data'] != null) &&
            (responseData['Data'].length > 0)) {
          result = VehicleRequestModel.fromJson(responseData['Data'][0]);
        }
      },
    );

    return result;
  }

  static Future<List<VehicleRequestModel>> getVehicleRequestList(
      bool shifting) async {
    List<VehicleRequestModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'getlist',
      'withbasedb': 'false',
      'shifting': Utils.boolToString(shifting)
    };

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          var dataList = responseData['List'];
          dataList.forEach((v) {
            list.add(VehicleRequestModel.fromJson(v));
          });
        }
      },
    );

    return list;
  }

  static Future<VehicleRequestBaseDbWrapper> getVehicleRequestBaseDb() async {
    VehicleRequestBaseDbWrapper result;

    Map<String, dynamic> queryParameters = {'action': 'getbasedb'};

    await request(serviceUrl[vehicleRequestUrl],
            queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        if (responseData != null) {
          result = VehicleRequestBaseDbWrapper.fromJson(responseData);
        }
      },
    );

    return result;
  }
}
