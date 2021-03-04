import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/model/notification.dart';
import 'package:mis_app/pages/notification/notification_item_widget.dart';
import 'package:mis_app/service/user_service.dart';

class NotificationDetailPage extends StatefulWidget {
  final Map arguments;
  NotificationDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  NotificationModel _notification;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _notification = NotificationModel();

    Map arguments = widget.arguments;
    if (arguments != null) {
      NotificationModel notification = NotificationModel.fromJson(arguments);
      if (notification != null) {
        _notification = notification;
        WidgetsBinding.instance.addPostFrameCallback((Duration d) {
          _loadData(_notification.notificationDetailId);
        });
      }
    }
  }

  void _loadData(int notificationDetailId) async {
    NotificationModel result =
        await UserService.getNotificationDetail(notificationDetailId);
    if (result != null) {
      //为了显示信息为已读
      result.readDate = DateTime.now();
      setState(() {
        _notification = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('消息'),
      ),
      body: SafeArea(
        child: NotificationItemWidget(
          item: _notification,
          onTap: () {
            _markNotificationAsRead(_notification);
            openNotificationFunction(context, _notification);
          },
        ),
      ),
    );
  }

  void _markNotificationAsRead(NotificationModel item) {
    // if (!item.isNew) return;

    UserService.updateNotificationsReadStatus(
        [item.notificationDetailId], false);
  }
}
