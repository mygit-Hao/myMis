import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/notification.dart';
import 'package:mis_app/routers/routes.dart';

class JPushHelper {
  static final JPush jpush = new JPush();
  static bool _inited = false;
  static String _registrationId;

  static get inited {
    return _inited;
  }

  static get registrationId {
    return _registrationId;
  }

  static Future<void> initPlatformState(BuildContext context) async {
    // String platformVersion;

    if (_inited) return;

    try {
      jpush.addEventHandler(
          onReceiveNotification: (Map<String, dynamic> message) async {
        print("flutter onReceiveNotification: $message");

        setBadge(Prefs.badge + 1);
      }, onOpenNotification: (Map<String, dynamic> message) async {
        print("flutter onOpenNotification: $message");
        _viewNotification(context, message);
      }, onReceiveMessage: (Map<String, dynamic> message) async {
        print("flutter onReceiveMessage: $message");
      }, onReceiveNotificationAuthorization:
              (Map<String, dynamic> message) async {
        print("flutter onReceiveNotificationAuthorization: $message");
      });
    } on PlatformException {
      // platformVersion = 'Failed to get platform version.';
    }

    jpush.setup(
      appKey: Global.jpushAppKey, //你自己应用的 AppKey
      channel: Global.jpushChannel,
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(
        new NotificationSettingsIOS(sound: true, alert: true, badge: true));

    // Platform messages may fail, so we use a try/catch PlatformException.
    jpush.getRegistrationID().then((rid) {
      _registrationId = rid;
      print("flutter get registration id : $rid");
    }).catchError((err) {
      print(err);
    });

    _inited = true;
  }

  static void setBadge(int badge) {
    Prefs.setBadge(badge);
    JPush jpush = new JPush();
    jpush.setBadge(badge).then((map) {
      print(map);
    });
  }

  static void _viewNotification(
      BuildContext context, Map<String, dynamic> message) {
    // var str = json.encode(message);
    // print(str);

    dynamic extrasValue;
    String title;
    String content;
    var extras = message['extras'];
    if (Platform.isIOS) {
      // extras = extras['cn.jpush.IOS.EXTRA'];
      extrasValue = extras;
      var alert = message['aps']['alert'];
      if (alert != null) {
        title = alert['subtitle'];
        content = alert['body'];
      }
    } else if (Platform.isAndroid) {
      extras = extras['cn.jpush.android.EXTRA'];
      extrasValue = json.decode(extras);
      title = message['title'];
      content = message['alert'];
    }

    if (extrasValue != null) {
      int notificationDetailId =
          int.tryParse(extrasValue['notificationDetailId']);
      DateTime createDate;
      if (extrasValue['createDate'] != null) {
        createDate = DateTime.parse(extrasValue['createDate']);
      }
      NotificationModel notification = NotificationModel(
        notificationDetailId: notificationDetailId,
        title: title,
        content: content,
        createDate: createDate,
        //为了显示信息为已读
        readDate: DateTime.now(),
      );
      var arguments = notification.toJson();
      Navigator.of(context)
          .pushNamed(notificationDetailPath, arguments: arguments);
    }

    /*
    if (extras != null) {
      var extrasValue = json.decode(extras);
      int notificationDetailId =
          int.tryParse(extrasValue['notificationDetailId']);
      DateTime createDate;
      if (extrasValue['createDate'] != null) {
        createDate = DateTime.parse(extrasValue['createDate']);
      }
      NotificationModel notification = NotificationModel(
        notificationDetailId: notificationDetailId,
        title: message['title'],
        content: message['alert'],
        createDate: createDate,
        //为了显示信息为已读
        readDate: DateTime.now(),
      );
      var arguments = notification.toJson();
      Navigator.of(context)
          .pushNamed(notificationDetailPath, arguments: arguments);
    }
    */
  }

  /*
  static void setTag(String userId) async {
    if (Utils.textIsEmptyOrWhiteSpace(userId)) return;

    if (_inited) {
      await jpush.resumePush();
      jpush.setAlias(userId).then((map) {
        var tags = map['tags'];
        print("set tags success: $map $tags");
      }).catchError((error) {
        jpush.stopPush();
        print('$error');
      });
    }
  }

  static void deleteTag(String userId) {
    if (Utils.textIsEmptyOrWhiteSpace(userId)) return;

    // jpush.deleteTags([idToJPushTag(userId)]);
    // jpush.setTags(['']);
    jpush.setAlias('');
    jpush.stopPush();
  }
  */
}
