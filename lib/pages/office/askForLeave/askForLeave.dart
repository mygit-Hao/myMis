import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/askForLeave.dart';
import 'package:mis_app/model/askForLeaveDetail.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/askForLeave_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
// import 'package:progress_dialog/progress_dialog.dart';

class AskForLeavePage extends StatefulWidget {
  @override
  _AskForLeavePageState createState() => _AskForLeavePageState();
}

class _AskForLeavePageState extends State<AskForLeavePage> {
  List<AskForLeaveData> _askForLeaveList = [];
  TextEditingController _keywordController = TextEditingController();
  EasyRefreshController _easyRefreshCtrl = EasyRefreshController();
  // ProgressDialog _progressDialog;
  bool _hasMoreData = true;

  // @override
  // void initState() {
  //   super.initState();
  //   _getList(true);
  //   // _getArrange();
  // }

  @override
  Widget build(BuildContext context) {
    // _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
        appBar: AppBar(
          title: Text('请假单列表'),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return WebViewPage(
                    arguments: {
                      'title': '请假单',
                      'url': serviceUrl[askForLeaveHelpUrl]
                    },
                  );
                }));
              },
              child: Container(
                  padding: EdgeInsets.all(10), child: Icon(Icons.help_outline)),
            )
          ],
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              searchViewCustom(_keywordController, _search),
              _listView(),
              Row(
                children: <Widget>[customButtom(Colors.blue, '新增', _add)],
              )
            ],
          ),
        ));
  }

  Widget _listView() {
    Divider divider = Divider(
      indent: 3,
      endIndent: 3,
      height: 0.5,
      color: Colors.black54,
    );
    return Expanded(
      child: EasyRefresh(
          controller: _easyRefreshCtrl,
          header: customRefreshHeader,
          footer: customRefreshFooter,
          firstRefresh: true,
          firstRefreshWidget: refreshWidget,
          child: ListView.separated(
              padding: EdgeInsets.all(4),
              itemBuilder: (context, index) {
                return _item(index);
              },
              separatorBuilder: (context, index) {
                return divider;
              },
              itemCount: _askForLeaveList.length),
          onRefresh: () async {
            Utils.closeInput(context);
            _getList(true);
          },
          onLoad: () async {
            Utils.closeInput(context);
            _getList(false);
          }),
    );
  }

  Widget _item(int index) {
    AskForLeaveData item = _askForLeaveList[index];
    String applyDate = Utils.dateTimeToStr(item.applyDate);
    String day = '共 ' + item.days.toString() + ' 天';
    String hours = '共 ' + item.hours.toString() + ' 小时';
    String approval = '已审批：' + (item.approval ?? '');
    String wapproval = '待审批：' +
        ((item.wApproval == null || item.wApproval == '')
            ? '/'
            : (item.wApproval));
    return Dismissible(
      key: new Key(item.askForLeaveId.toString()),
      confirmDismiss: (DismissDirection dismissDirection) {
        return _delete(item);
      },
      background: deleteBg(),
      child: InkWell(
        onTap: () async {
          Utils.closeInput(context);
          AskForLeaveSData.askForLeaveId = item.askForLeaveId;
          bool dataChanged = await navigatePage(context, askForLeaveDetailPath);
          if (dataChanged) _getList(true);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: customText(
                        value: item.staffName,
                        color: Colors.blue[500],
                        fontWeight: FontWeight.w600),
                  ),
                  Expanded(
                    child: customText(
                      value: applyDate,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                      // backgroudColor: Colors.orange[50],
                    ),
                  ),
                  Expanded(
                      child: Text(item.statusName,
                          style: statusTextStyle(item.status))),
                ],
              ),
              Container(
                padding: EdgeInsets.only(top: 2),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: customText(value: item.typeName, fontSize: 14)),
                    Expanded(child: customText(value: day, fontSize: 14)),
                    Expanded(child: customText(value: hours, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 3),
                child: Flex(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Expanded(
                        flex: 1,
                        child: customText(value: approval, fontSize: 14)),
                    // if (item.status < 20)
                    Expanded(
                        flex: 2,
                        child: customText(value: wapproval, fontSize: 14)),
                  ],
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 3),
                  child: customText(value: '原因：' + item.reason, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  void _add() async {
    Utils.closeInput(context);
    AskForLeaveSData.askForLeaveId = 0;
    bool dataChanged = await navigatePage(context, askForLeaveDetailPath);
    if (dataChanged) _getList(true);
  }

  Future<bool> _delete(AskForLeaveData item) async {
    bool isDelete = false;
    isDelete = await DialogUtils.showConfirmDialog(context, '是否删除该条请假单？',
        iconData: Icons.info, color: Colors.red);
    if (isDelete == true) {
      await AskForLeaveService.toDraftOrDelete('delete', item.askForLeaveId)
          .then((value) {
        if (value.errCode == 0) {
          _askForLeaveList.remove(item);
          setState(() {});
          toastBlackStyle('删除成功!');
          isDelete = true;
        } else {
          isDelete = false;
          DialogUtils.showAlertDialog(context, value.errMsg);
        }
      });
    }
    return isDelete;
  }

  void _search() {
    Utils.closeInput(context);
    _getList(true);
  }

  void _getList(bool refresh) async {
    if (refresh) {
      _hasMoreData = true;
      _askForLeaveList.clear();
    }

    if (!_hasMoreData) return;
    // await _progressDialog?.show();
    try {
      bool withbaseDb = AskForLeaveSData.areaList == null ? true : false;
      int maxid = refresh ? 0 : _askForLeaveList.last.askForLeaveId;
      await AskForLeaveService.getAskForLeaveList(
              _keywordController.text, withbaseDb, maxid)
          .then((value) {
        if (withbaseDb) {
          AskForLeaveSData.areaList = value.areaList;
          AskForLeaveSData.kindList = value.kindList;
          AskForLeaveSData.userStaff = value.userStaff;
          _getArrange();
        }
        if (value.askForLeavelist.length > 0) {
          _askForLeaveList.addAll(value.askForLeavelist);
          if (refresh) {
            _easyRefreshCtrl.resetLoadState();
            // _easyRefreshCtrl.finishRefresh(success: true, noMore: false);
          } else {
            // _easyRefreshCtrl.finishLoad(success: true, noMore: false);
          }
        } else {
          _hasMoreData = false;
          _easyRefreshCtrl.finishLoad(success: true, noMore: true);
        }
        setState(() {});
      });
    } finally {
      // await _progressDialog?.hide();
    }
  }

  void _getArrange() async {
    int id = AskForLeaveSData.userStaff[0].staffId;
    AskForLeaveSData.arrangeData = await AskForLeaveService.getArrange(id);
    print('每日工作时数' + AskForLeaveSData.arrangeData.hours.toString());
  }
}
