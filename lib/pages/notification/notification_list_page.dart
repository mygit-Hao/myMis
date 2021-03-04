import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/notification.dart';
import 'package:mis_app/model/notification_category.dart';
import 'package:mis_app/pages/notification/notification_item_widget.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/widget/dismissible_background.dart';
import 'package:visibility_detector/visibility_detector.dart';

class NotificationListPage extends StatefulWidget {
  final Map arguments;
  NotificationListPage({Key key, this.arguments}) : super(key: key);

  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  static const int _checkReadTime = 3;
  NotificationCategoryModel _category;
  List<NotificationModel> _list = [];
  List<int> _exclusiveMarkList = [];
  Timer _timer;
  bool _hasMoreData;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    _stopTimer();

    super.dispose();
  }

  void _init() {
    _category = NotificationCategoryModel();

    var arguments = widget.arguments;
    if (arguments != null) {
      var categoryJson = arguments['category'];
      if (categoryJson != null) {
        setState(() {
          _category = NotificationCategoryModel.fromJson(categoryJson);
        });

        WidgetsBinding.instance.addPostFrameCallback((Duration d) {
          _loadData(true);
        });
      }
    }
  }

  void _startTimer() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: _checkReadTime), (Timer t) {
        List<int> list = [];
        _list.forEach((NotificationModel element) {
          if ((!_exclusiveMarkList.contains(element.notificationDetailId)) &&
              (element.isNew) &&
              (element.wholeVisible)) {
            list.add(element.notificationDetailId);
          }
        });
        _stopTimer();

        _updateReadStatus(list);
      });
    }
  }

  void _updateReadStatus(List<int> notificationDetailIds) async {
    if ((notificationDetailIds == null) || (notificationDetailIds.length <= 0))
      return;

    setPageDataChanged(this.widget, true);

    await UserService.updateNotificationListReadStatus(
        _list, notificationDetailIds);
    setState(() {});
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
      // print('停止计时');
    }
  }

  void _loadData(bool renewing) async {
    if (_category.notificationCategoryId <= 0) return;
    if (renewing) {
      _hasMoreData = true;
      _list.clear();
    }

    if (!_hasMoreData) return;
    int maxId = _list.length > 0 ? _list.last.notificationId : 0;

    List<NotificationModel> list = await UserService.getNotificationList(
        _category.notificationCategoryId,
        maxId: maxId);
    if (list.length > 0) {
      //防止重复加载数据
      /*
      if ((_list.length > 0) &&
          (list.first.notificationId >= _list.last.notificationId)) {
        return;
      }
      */

      _list.addAll(list);
      setState(() {});
    } else {
      _hasMoreData = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _startTimer();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(_category.name),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification) {
            // print('滚动开始');
            _stopTimer();
          }
          // if (notification is ScrollUpdateNotification) {
          //   print('滚动中');
          // }
          if (notification is ScrollEndNotification) {
            // print('停止滚动');
            _startTimer();
          }
          return false;
        },
        child: EasyRefresh(
          onRefresh: () async {
            _loadData(true);
          },
          onLoad: () async {
            _loadData(false);
          },
          child: ListView.separated(
            reverse: true,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              NotificationModel item = _list[index];
              // var key = Key(item.notificationDetailId.toString());

              return VisibilityDetector(
                key: Key(item.notificationDetailId.toString()),
                onVisibilityChanged: (VisibilityInfo info) {
                  item.wholeVisible = info.visibleFraction >= 1;
                },
                child: Dismissible(
                  key: Key('d_${item.notificationDetailId}'),
                  // child: _listItemWidget(item),
                  child: NotificationItemWidget(
                    item: item,
                    onTap: () {
                      _markNotification(item, false);
                      openNotificationFunction(context, item);
                    },
                  ),
                  confirmDismiss: (DismissDirection direction) {
                    return _markNotification(
                        item, direction == DismissDirection.startToEnd);
                  },
                  background: DismissibleBackground(
                    alignment: MainAxisAlignment.start,
                    title: '标为未读',
                    icon: Icon(
                      Icons.markunread,
                      color: Colors.white,
                    ),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  secondaryBackground: DismissibleBackground(
                    title: '标为已读',
                    icon: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    color: Colors.orangeAccent,
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider(
                height: 16.0,
                thickness: 16.0,
                color: backgroundColor,
              );
            },
            itemCount: _list.length,
          ),
        ),
      ),
    );
  }

  /*
  Widget _listItemWidget(NotificationModel item) {
    return Column(
      children: [
        _dateWidget(item),
        InkWell(
          onTap: () {
            _markNotification(item, false);
            openNotificationFunction(context, item);
          },
          child: _contentWidget(item),
        ),
      ],
    );
  }

  Widget _navigatorWidget(NotificationModel item) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return item.canOpen
        ? Row(
            children: [
              Text(
                '查看详情',
                style: TextStyle(fontSize: defaultFontSize - 2),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: defaultFontColor,
                size: 20.0,
              ),
            ],
          )
        : Container();
  }

  Widget _contentWidget(NotificationModel item) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.isNew)
                Icon(
                  Icons.lens,
                  color: Colors.red,
                  size: 6.0,
                ),
              Text(
                item.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: defaultFontSize + 2,
                  fontWeight: item.isNew ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          if (!Utils.textIsEmptyOrWhiteSpace(item.content))
            LabelText(item.content),
          SizedBox(height: 12.0),
          Divider(),
          _navigatorWidget(item),
        ],
      ),
    );
  }

  Widget _dateWidget(NotificationModel item) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LabelText(
        Utils.dateTimeToStr(
          item.createDate,
          pattern: formatPatternDateTime,
        ),
        color: Colors.white,
        fontSize: defaultFontSize - 2.0,
      ),
    );
  }
  */

  Future<bool> _markNotification(NotificationModel item, bool reset) async {
    if (reset == item.isNew) return false;

    int notificationDetailId = item.notificationDetailId;

    //加进排除列表，避免自动标记
    if (reset) {
      if (!_exclusiveMarkList.contains(notificationDetailId))
        _exclusiveMarkList.add(notificationDetailId);
    }

    setPageDataChanged(this.widget, true);

    await UserService.updateNotificationListReadStatus(
        _list, [notificationDetailId],
        reset: reset);
    setState(() {});

    return false;
  }
}
