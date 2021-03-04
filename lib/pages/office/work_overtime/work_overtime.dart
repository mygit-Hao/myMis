import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/overtime.dart';
import 'package:mis_app/model/overtime_detail.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_overtime_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class WorkOverTimePage extends StatefulWidget {
  @override
  _WorkOverTimePageState createState() => _WorkOverTimePageState();
}

class _WorkOverTimePageState extends State<WorkOverTimePage> {
  bool _hasMoreData = true;
  List<OverTimeListData> _overTimeList = [];
  TextEditingController _keywordControl = new TextEditingController();
  FLToastDefaults _toastDefaults = FLToastDefaults();
  final SlidableController _slidableController = SlidableController();
  EasyRefreshController _refreshController = EasyRefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getList(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('加班单列表'), actions: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return WebViewPage(
                arguments: {'title': '加班单', 'url': serviceUrl[overtimeHelpUrl]},
              );
            }));
          },
          child: Container(
              padding: EdgeInsets.all(10), child: Icon(Icons.help_outline)),
        )
      ]),
      body: FLToastProvider(
        defaults: _toastDefaults,
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              searchViewCustom(_keywordControl, _search),
              _overtimeListview(),
              Row(
                children: [
                  customButtom(
                    Colors.blue,
                    '新增',
                    () async {
                      bool dataChanged =
                          await navigatePage(context, workOverTimeDetailPath);
                      if (dataChanged) _getList(true);
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overtimeListview() {
    return Expanded(
      child: EasyRefresh(
        controller: _refreshController,
        header: customRefreshHeader,
        footer: customRefreshFooter,
        child: ListView.builder(
            itemCount: _overTimeList.length,
            itemBuilder: (context, index) {
              OverTimeListData item = _overTimeList[index];
              return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  controller: _slidableController,
                  secondaryActions: [
                    IconSlideAction(
                      icon: Icons.content_copy,
                      caption: '复制新增',
                      color: Colors.blue,
                      onTap: () async {
                        WorkOverTimeSData.isCopy = true;
                        bool dataChanged = await navigatePage(
                            context, workOverTimeDetailPath,
                            arguments: {'overtimeId': item.overTimeId});
                        if (dataChanged) _getList(true);
                      },
                    ),
                    IconSlideAction(
                      icon: Icons.delete,
                      caption: '删除',
                      color: Colors.red,
                      onTap: () {
                        _delete(item);
                      },
                    )
                  ],
                  child: _item(_overTimeList[index]));
              // return Dismissible(
              //     key: Key(item.overTimeId.toString()),
              //     background: copyNewBg(),
              //     secondaryBackground: deleteBg(),
              //     confirmDismiss: (DismissDirection direction) {
              //       if (direction == DismissDirection.startToEnd) {
              //         WorkOverTimeSData.isCopy = true;
              //         Navigator.push(
              //             context,
              //             CustomRoute(WorkOverTimeDetailPage(
              //                 arguments: {'overtimeId': item.overTimeId})));

              //         return null;
              //       } else {
              //         return _delete(item);
              //       }
              //     },
              //     child: _item(_overTimeList[index]));
            }),
        onRefresh: () async {
          _getList(true);
        },
        onLoad: () async {
          _getList(false);
        },
      ),
    );
  }

  Widget _item(OverTimeListData item) {
    DateTime dt = DateTime.parse(item.applyDate);
    var applydate = Utils.dateTimeToStr(dt);
    return InkWell(
      onTap: () async {
        WorkOverTimeSData.isCopy = false;
        bool dataChanged = await navigatePage(context, workOverTimeDetailPath,
            arguments: {'overtimeId': item.overTimeId});
        if (dataChanged) _getList(true);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: bottomLineDecotation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            customText(
                value: item.names,
                color: Colors.blue,
                fontWeight: FontWeight.w600),
            Container(
              margin: EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      applydate,
                      style: TextStyle(
                        // background: Paint()..color = Colors.orange[50],
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Text(
                    item.statusName,
                    style: statusTextStyle(item.status),
                  ))
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                    child: customText(
                        value: '已审批人：${item.approval ?? ''}', fontSize: 14)),
                if (item.status < 20)
                  Expanded(
                      child: customText(
                          value: '待审批人：${item.wApproval ?? '/'}',
                          fontSize: 14)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Widget _addButtom() {
  //   return Container(
  //     width: ScreenUtil().setWidth(750),
  //     child: RaisedButton(
  //       onPressed: () async {
  //         bool dataChanged =
  //             await navigatePage(context, workOverTimeDetailPath);
  //         if (dataChanged) _getList(true);
  //       },
  //       color: Colors.blue,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  //       child: Text(
  //         '新增',
  //         style: TextStyle(color: Colors.white),
  //       ),
  //     ),
  //   );
  // }

  void _search() async {
    _getList(true);
  }

  void _getList(bool isRefresh) async {
    if (isRefresh) {
      _overTimeList.clear();
      _hasMoreData = true;
    }
    if (!_hasMoreData) return;
    int maxid = isRefresh ? 0 : _overTimeList.last.overTimeId;
    var dismiss = FLToast.loading();
    try {
      print(_keywordControl.text);
      await WorkOverTimeService.query(_keywordControl.text, maxid)
          .then((value) {
        if (WorkOverTimeSData.areaList == null) {
          WorkOverTimeSData.areaList = value.areaList;
          WorkOverTimeSData.typeList = value.typeList;
          WorkOverTimeSData.userStaff = value.userStaff;
        }
        if (value.overTimeList.length > 0) {
          _overTimeList.addAll(value.overTimeList);
          if (isRefresh) _refreshController.resetLoadState();
        } else {
          _hasMoreData = false;
          _refreshController.finishLoad(success: true, noMore: true);
        }
      });
      setState(() {});
    } finally {
      dismiss();
    }
  }

  Future<bool> _delete(OverTimeListData item) async {
    bool isDelete = false;
    if (item.status >= 10) {
      DialogUtils.showToast(item.statusName + '状态不能删除');
      return isDelete;
    }
    var result = await DialogUtils.showConfirmDialog(context, '是否删除该条记录?',
        iconData: Icons.info, color: Colors.red);
    if (result == true) {
      OverTimeDetaiModel responseData =
          await WorkOverTimeService.deleteOrToDraft('delete', item.overTimeId);
      if (responseData.errCode == 0) {
        isDelete = true;
        _overTimeList.remove(item);
        setState(() {});
        DialogUtils.showToast('删除成功');
      } else {
        DialogUtils.showConfirmDialog(context, responseData.errMsg);
      }
    }
    return isDelete;
  }
}
