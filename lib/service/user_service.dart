import 'dart:convert';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/login_info.dart';
import 'package:mis_app/model/notification.dart';
import 'package:mis_app/model/notification_category.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/user.dart';
import 'package:mis_app/model/user_status.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/utils.dart';

class UserService {
  static Future<RequestResult> scanUuid(String uuid) async {
    RequestResult result = RequestResult();
    Map<String, dynamic> queryParameters = {
      'action': 'scan-uuid',
      'uuid': uuid,
      'uuid-key': Global.getUuidKey(uuid),
    };
    await request(serviceUrl[userUrl], queryParameters: queryParameters)
        .then((val) {
      var responseData = jsonDecode(val.data.toString());
      if (responseData == null) return;

      result.msg = responseData['ErrMsg'];
      if (responseData['ErrCode'] == 0) {
        result.success = true;
      }
    });
    return result;
  }

  static Future<RequestResult> getUuidInfo(String uuid) async {
    RequestResult result = RequestResult();
    Map<String, dynamic> queryParameters = {
      'action': 'uuid-info',
      'uuid': uuid,
      'uuid-key': Global.getUuidKey(uuid),
    };
    await request(serviceUrl[userUrl], queryParameters: queryParameters)
        .then((val) {
      var responseData = jsonDecode(val.data.toString());
      if (responseData == null) return;

      result.success = true;
      result.data = {
        'valid': responseData['Valid'],
        'userName': responseData['UserName'],
        'hostName': responseData['HostName'],
        'msg': responseData['Msg'],
      };
    });
    return result;
  }

  static Future<NotificationModel> getNotificationDetail(
      int notificationDetailId) async {
    NotificationModel result;
    Map<String, dynamic> queryParameters = {
      'action': 'notification-detail',
      'id': notificationDetailId
    };
    await request(serviceUrl[userUrl], queryParameters: queryParameters)
        .then((val) {
      var responseData = jsonDecode(val.data.toString());
      if (responseData == null) return;

      result = NotificationModel.fromJson(responseData);
    });
    return result;
  }

  static Future<bool> updateNotificationListReadStatus(
      List<NotificationModel> list, List<int> notificationDetailIds,
      {bool reset = false}) async {
    RequestResult result =
        await updateNotificationsReadStatus(notificationDetailIds, reset);
    if ((result.data != null) && (result.data.length > 0)) {
      result.data.forEach((v) {
        int notificationDetailId = v['NotificationDetailId'];
        var item = list.firstWhere(
            (element) => element.notificationDetailId == notificationDetailId,
            orElse: () => null);
        if (item != null) {
          var readDate = v['ReadDate'];
          if (readDate != item.readDate) {
            item.readDate =
                (readDate == null) ? readDate : DateTime.parse(readDate);
          }
        }
      });

      return true;
    }

    return false;
  }

  static Future<RequestResult> updateNotificationsReadStatus(
      List<int> notificationDetailIds, bool reset) async {
    RequestResult result = RequestResult();

    if ((notificationDetailIds != null) && (notificationDetailIds.length > 0)) {
      Map<String, dynamic> queryParameters = {
        'action': 'update-notification-read-status',
        'ids': json.encode(notificationDetailIds),
        'option': reset ? 'reset' : ''
      };

      await request(serviceUrl[userUrl], queryParameters: queryParameters).then(
        (RequestResult value) {
          var responseData = json.decode(value.data.toString());

          if (responseData != null) {
            result.msg = responseData['ErrMsg'];
            if (responseData['ErrCode'] == 0) {
              result.success = true;
            }
            result.data = responseData['Data'];
          }
        },
      );
    }

    return result;
  }

  static Future<List<NotificationModel>> getNotificationList(int categoryId,
      {int maxId = 0}) async {
    List<NotificationModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'notification-list',
      'categoryId': categoryId,
      'maxid': maxId,
    };

    await request(serviceUrl[userUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          responseData.forEach((v) {
            list.add(NotificationModel.fromJson(v));
          });
        }
      },
    );

    return list;
  }

  static Future<UserStatusModel> getStatus() async {
    UserStatusModel result;

    Map<String, dynamic> queryParameters = {'action': 'status'};

    await request(serviceUrl[userUrl], queryParameters: queryParameters)
        .then((val) {
      try {
        var responseData = jsonDecode(val.data.toString());

        if (responseData != null) {
          result = UserStatusModel.fromJson(responseData);
        }
      } catch (e) {
        print(e);
      }
    });

    return result;
  }

  static Future<List<NotificationCategoryModel>>
      getNotificationSummary() async {
    List<NotificationCategoryModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'notification-summary',
    };

    await request(serviceUrl[userUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData != null) {
          responseData.forEach((v) {
            list.add(NotificationCategoryModel.fromJson(v));
          });
        }
      },
    );

    return list;
  }

  static Future<RequestResult> logout() async {
    Map<String, dynamic> queryParameters = {'action': 'logout'};

    RequestResult result = RequestResult();

    await request(serviceUrl[loginUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        try {
          result.success = true;
        } catch (e) {
          result.msg = value.data;
        }
      },
    );

    return result;
  }

  static Future<BaseDbModel> getBaseDb() async {
    BaseDbModel baseDBModel;
    Map<String, dynamic> queryParameters = {'action': 'basedb'};
    await request(serviceUrl[generalUrl], queryParameters: queryParameters)
        .then((val) {
      var responseData = jsonDecode(val.data.toString());
      if (responseData == null) return;

      baseDBModel = BaseDbModel.fromJson(responseData);
    });
    return baseDBModel;
  }

  static Future<List<UserModel>> search(String keyword) async {
    List<UserModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'search',
      'keyword': keyword,
    };

    await request(serviceUrl[userUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(UserModel.fromJson(v));
        });

        // print(list);
      },
    );

    return list;
  }

  static Future<RequestResult> changePassword(
      String oldPassword, String newPassword) async {
    String md5OldPassword = Utils.getMd5_16(oldPassword);
    String md5NewPassword = Utils.getMd5_16(newPassword);

    Map<String, dynamic> queryParameters = {
      'action': 'changepwd',
      'oldpwd': md5OldPassword,
      'newpwd': md5NewPassword,
    };

    RequestResult result = RequestResult();

    await request(serviceUrl[userUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        try {
          var responseData = json.decode(value.data.toString());
          if (responseData == null) return;

          result.success = responseData['Succeed'];
          result.msg = responseData['Info'];
          if (result.success) {
            UserProvide.updateUserMd5Password(md5NewPassword);
          }
        } catch (e) {
          result.msg = value.data;
        }
      },
    );

    return result;
  }

  static Future<LoginInfo> login(String userName, String password) async {
    Map<String, dynamic> queryParameters =
        Global.getUserLoginParams(userName, password);

    return _login(queryParameters, password);

    /*
    LoginInfo info = LoginInfo();

    await httpRequest(serviceUrl[loginPath], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        info = LoginInfo.fromJson(responseData);
      },
    );

    return info;
    */
  }

  static Future<LoginInfo> currentUserLogin() async {
    Map<String, dynamic> queryParameters = Global.getCurrentUserLoginParams();

    return _login(queryParameters);

    /*
    LoginInfo info = LoginInfo();

    await httpRequest(serviceUrl[loginPath], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        info = LoginInfo.fromJson(responseData);
      },
    );

    return info;
    */
  }

  static Future<LoginInfo> _login(Map<String, dynamic> queryParameters,
      [String password]) async {
    LoginInfo info = LoginInfo();

    // 登录前先把销售人员列表清空（不同项目，销售人员不同）
    DataCache.clearSalesmanList();

    await httpRequest(serviceUrl[loginUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) async {
        var responseData;
        if (!Utils.textIsEmptyOrWhiteSpace(value.msg)) {
          info.info = value.msg;
        }
        try {
          if (value.data != null) {
            responseData = json.decode(value.data.toString());
          }
        } catch (e) {
          print('ERROR:======>$e');
          info.info = e.toString();
        }
        if (responseData == null) return info;

        info = LoginInfo.fromJson(responseData);
        UserProvide.setUserInfo(info, password);
        // UserProvide.setAreaList(info.areaList);
        // UserProvide.setOaAreaList(info.oaAreaList);
        if (info.success) {
          DataCache.initGeneralBaseDb();

          UserStatusModel result = await getStatus();
          if (result != null) {
            UserProvide.setCountOfUnread(result.countOfUnreadNotification);
          }
        }
      },
    );

    return info;
  }
}
