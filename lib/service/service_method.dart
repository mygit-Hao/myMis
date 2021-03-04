import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/device_info.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/config/config.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/login_info.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

const String _token1Key = 'token1';
const String _token2Key = 'token2';
const String _areaKey = 'AreaId';
const int _connectTimeout = 30000;
const int _receiveTimeout = 30000;
const String _spaceEncoded = '%20';

Future<bool> get isOnline async {
  var connectivityResult = await (Connectivity().checkConnectivity());

  return connectivityResult != ConnectivityResult.none;
}

Map<String, String> getRequestHeader() {
  return {
    _token1Key: UserProvide.userToken,
    _token2Key: DeviceInfo.devId,
  };
}

String getUrlToken() {
  String token =
      '$_token1Key=${UserProvide.userToken}&$_token2Key=${DeviceInfo.devId}';
  return token.replaceAll(' ', _spaceEncoded);
}

Future<RequestResult> httpRequest(String url,
    {dynamic data,
    Map<String, dynamic> queryParameters,
    String method = 'POST'}) async {
  String errMsg = "";
  RequestResult result = RequestResult();

  if (!await isOnline) {
    result.msg = '当前网络不可用';
    DialogUtils.showToast(result.msg);
    return result;
  }

  try {
    Response response;
    Dio dio = _getDio;

    // if (formData == null) {
    //   response = await dio.post(url);
    // } else {
    //   response = await dio.post(
    //     url,
    //     data: formData,
    //   );
    // }

    if (Utils.sameText(method, 'GET')) {
      response = await dio.get(url, queryParameters: queryParameters);
    } else {
      response = await dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
      );
    }

    if (response.statusCode == 200) {
      // return response.data;
      result.success = true;
      result.data = response.data;
    } else {
      throw Exception('后端接口出现异常，请检测代码和服务器情况......');
    }
  } catch (e) {
    // return print('ERROR:======>$e');
    print('ERROR:======>$e');
    if (e is DioError) {
      errMsg = e.error is SocketException ? '连接服务器时出现错误' : e.message;
    } else {
      errMsg = e.toString();
    }

    result.msg = errMsg;
  }

  if ((!result.success) && (!Utils.textIsEmpty(errMsg))) {
    DialogUtils.showToast(errMsg, toastLength: Toast.LENGTH_LONG);
  }

  return result;
}

Future<RequestResult> request(String url,
    {dynamic data, Map<String, dynamic> queryParameters}) async {
  const String defaultErrMsg = '服务器响应异常，请稍候再试';

  String errMsg = "";
  RequestResult result = RequestResult();

  if (!await isOnline) {
    DialogUtils.showToast('当前网络不可用');
    return result;
  }

  try {
    Response response;
    Dio dio = _getDio;

    if (queryParameters == null) {
      queryParameters = {};
    }

    // queryParameters[_TOKEN1] = Global.token1;
    queryParameters[_token1Key] = UserProvide.userToken;
    queryParameters[_token2Key] = DeviceInfo.devId;

    // bool hasAreaKey = queryParameters.keys
    //     .any((element) => Utils.sameText(element, _areaKey));
    bool hasAreaKey = Utils.containsText(queryParameters.keys, _areaKey);
    if ((!hasAreaKey) && (data != null)) {
      try {
        for (var item in data.fields) {
          if ((item is MapEntry) && (Utils.sameText(item.key, _areaKey))) {
            hasAreaKey = true;
            break;
          }
        }
      } catch (e) {
        print('ERROR:======>$e');
      }
    }

    // if (queryParameters[_areaKey] == null)
    if (!hasAreaKey) {
      queryParameters[_areaKey] = UserProvide.currentLoginedAreaId.toString();
    }

    response = await dio.post(
      url,
      data: data,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      dynamic responseData = response.data;
      if (responseData == Global.authentication_failed) {
        if (UserProvide.userNameIsValid) {
          Map<String, dynamic> loginParams = Global.getCurrentUserLoginParams();

          response = await dio.post(serviceUrl[loginUrl],
              queryParameters: loginParams);
          if (response.statusCode == 200) {
            responseData = response.data;
            if ((responseData != null) &&
                (responseData != Global.authentication_failed)) {
              try {
                responseData = json.decode(responseData);
              } catch (e) {
                print('ERROR:======>$e');
                responseData = null;
              }

              if (responseData != null) {
                LoginInfo info = LoginInfo.fromJson(responseData);

                if (info.success) {
                  response = await dio.post(
                    url,
                    data: data,
                    queryParameters: queryParameters,
                  );

                  if (response.statusCode == 200) {
                    // return response.data;
                    result.success = true;
                    result.data = response.data;
                  }
                }
              }
            }
          }
        } else {
          errMsg = defaultErrMsg;
        }
      } else {
        result.success = true;
        result.data = response.data;
      }

      // return response.data;
    } else {
      // throw Exception('后端接口出现异常，请检测代码和服务器情况......');
      throw Exception(defaultErrMsg);
    }
  } catch (e) {
    // return print('ERROR:======>$e');
    print('ERROR:======>$e');
    // errMsg = e.toString();
    // errMsg = '服务器响应异常：$e';
    // 如果调试模式下，才显示具体错误
    errMsg = isTest ? '$defaultErrMsg：$e' : defaultErrMsg;
  }

  if ((!result.success) && (!Utils.textIsEmpty(errMsg))) {
    DialogUtils.showToast(errMsg, toastLength: Toast.LENGTH_LONG);
  }

  return result;
}

Future<RequestResult> downloadFile(String url, dynamic savePath,
    {dynamic data, Map<String, dynamic> queryParameters}) async {
  String errMsg = "";
  RequestResult result = RequestResult();

  if (!await isOnline) {
    DialogUtils.showToast('当前网络不可用');
    return result;
  }

  try {
    Response response;
    Dio dio = _getDio;

    //把token放里data不生效，所以加在headers
    // dio.options.headers.addAll({
    //   _TOKEN1: Global.token1,
    //   _TOKEN2: DeviceInfo.devId,
    // });

    if (queryParameters == null) {
      queryParameters = {};
    }

    // queryParameters[_TOKEN1] = Global.token1;
    queryParameters[_token1Key] = UserProvide.userToken;
    queryParameters[_token2Key] = DeviceInfo.devId;

    response = await dio.download(
      url,
      savePath,
      data: data,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      dynamic responseData = response.data;
      if (responseData == Global.authentication_failed) {
        Map<String, dynamic> loginParams = Global.getCurrentUserLoginParams();
        response =
            await dio.post(serviceUrl[userUrl], queryParameters: loginParams);
        if (response.statusCode == 200) {
          responseData = json.decode(response.data);

          LoginInfo info = LoginInfo.fromJson(responseData);

          if (info.success) {
            response = await dio.download(
              url,
              savePath,
              data: data,
              queryParameters: queryParameters,
            );

            if (response.statusCode == 200) {
              // return response.data;
              result.success = true;
              result.data = response.data;
            }
          }
        }
      } else {
        result.success = true;
        result.data = response.data;
      }

      // return response.data;
    } else {
      throw Exception('后端接口出现异常，请检测代码和服务器情况......');
    }
  } catch (e) {
    // return print('ERROR:======>$e');
    print('ERROR:======>$e');
    errMsg = e.toString();
  }

  if ((!result.success) && (!Utils.textIsEmpty(errMsg))) {
    DialogUtils.showToast(errMsg, toastLength: Toast.LENGTH_LONG);
  }

  return result;
}

Dio get _getDio {
  Dio dio = Dio();
  //设置连接超时时间
  dio.options.connectTimeout = _connectTimeout;
  //设置数据接收超时时间
  dio.options.receiveTimeout = _receiveTimeout;
  dio.options.contentType = 'application/x-www-form-urlencoded';

  return dio;
}

/*
Future getHomePageContent() async {
  try {
    print('开始获取首页数据......');
    Response response;
    Dio dio = Dio();
    dio.options.contentType = 'application/x-www-form-urlencoded';
    var formData = {'lon': '115.02932', 'lat': '35.76189'};
    response = await dio.post(serviceUrl['homePageContext'], data: formData);

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('后端接口出现异常，请检测代码和服务器情况......');
    }
  } catch (e) {
    return print('ERROR:======>$e');
  }
}

Future getHomePageBelowContent() async {
  try {
    print('开始获取下拉列表数据......');
    Response response;
    Dio dio = Dio();
    dio.options.contentType = 'application/x-www-form-urlencoded';
    int page = 1;
    response = await dio.post(serviceUrl['homePageBelowContent'], data: page);
    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('后端接口出现异常，请检测代码和服务器情况......');
    }
  } catch (e) {
    return print('ERROR:======>$e');
  }
}
*/
