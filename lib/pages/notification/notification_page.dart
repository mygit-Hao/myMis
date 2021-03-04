import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/notification_category.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/widget/label_text.dart';

class NotificationPage extends StatefulWidget {
  NotificationPage({Key key}) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationCategoryModel> _list = [];

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _loadData();
  }

  void _loadData() async {
    _list = await UserService.getNotificationSummary();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('消息'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.white,
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            NotificationCategoryModel item = _list[index];

            return InkWell(
              onTap: () {
                _openList(item);
              },
              child: _listItemWidget(item),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: _list.length),
    );
  }

  void _openList(NotificationCategoryModel category) async {
    bool dataChanged = await navigatePage(context, notificationListPath,
        arguments: {'category': category.toJson()});

    if (dataChanged) {
      _loadData();
    }
  }

  Widget _listItemWidget(NotificationCategoryModel item) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return Container(
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.all(4.0),
                child: CircleAvatar(
                  child: getIcon(
                    item.resourceId,
                    size: 26.0,
                  ),
                  backgroundColor: Colors.grey[200],
                ),
              ),
              if (item.countOfUnread > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    Icons.lens,
                    color: Colors.red,
                    size: 10.0,
                  ),
                ),
            ],
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: defaultFontSize + 2.0,
                        ),
                      ),
                    ),
                    LabelText(
                      item.lastNotificationDateStr,
                      fontSize: defaultFontSize - 2.0,
                    ),
                  ],
                ),
                LabelText(
                  item.lastNotificationTitle ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
