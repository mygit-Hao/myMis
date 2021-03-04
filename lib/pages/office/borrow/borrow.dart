import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/borrow.dart';
import 'package:mis_app/model/borrow_detail.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/borrow_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class BorrowPage extends StatefulWidget {
  @override
  _BorrowPageState createState() => _BorrowPageState();
}

class _BorrowPageState extends State<BorrowPage> {
  // final _textStyle = TextStyle(color: Colors.black54, fontSize: 14.5);
  bool _hasMoreData = true;
  List<BorrowData> _borrowList = [];
  TextEditingController _keywordController = TextEditingController();
  FLToastDefaults _flToastDefaults = FLToastDefaults();
  EasyRefreshController _refreshController = EasyRefreshController();
  // ProgressDialog _progressDialog;

  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  // BorrowSData.maxId = 0;
  // _getList(true);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('借款借据列表'),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return WebViewPage(
                    arguments: {
                      'title': '借款借据',
                      'url': serviceUrl[borrowHelpUrl]
                    },
                  );
                }));
              },
              child: Container(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.help_outline),
              ),
            )
          ],
        ),
        body: FLToastProvider(
          defaults: _flToastDefaults,
          child: Container(
            child: Column(
              children: <Widget>[
                searchViewCustom(_keywordController, _search),
                _listView(),
                Row(
                  children: <Widget>[customButtom(Colors.blue, '新增', _add)],
                )
              ],
            ),
          ),
        ));
  }

  Widget _listView() {
    Divider divider = Divider(
      height: 0.2,
    );
    return Expanded(
        child: EasyRefresh(
      controller: _refreshController,
      header: customRefreshHeader,
      footer: customRefreshFooter,
      firstRefresh: true,
      firstRefreshWidget: refreshWidget,
      child: ListView.separated(
          itemBuilder: (context, index) {
            return _item(index);
          },
          separatorBuilder: (context, index) {
            return divider;
          },
          itemCount: _borrowList.length),
      onRefresh: () async {
        // BorrowSData.maxId = 0;
        // _borrowList.clear();
        _getList(true);
      },
      onLoad: () async {
        // BorrowSData.maxId = _borrowList[_borrowList.length - 1].borrowId;
        _getList(false);
      },
    ));
  }

  Widget _item(int index) {
    BorrowData item = _borrowList[index];
    String applyDate = Utils.dateTimeToStr(item.applyDate);
    return Dismissible(
      key: Key(item.borrowId.toString()),
      confirmDismiss: (DismissDirection dismissDirection) {
        return _delete(item);
      },
      background: deleteBg(bgcolor: Colors.red, txtColor: Colors.white),
      child: InkWell(
        onTap: () async {
          Utils.closeInput(context);
          bool dataChanged = await navigatePage(context, borrowDetailPath,
              arguments: item.borrowId);
          if (dataChanged) _getList(true);
        },
        child: Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Flex(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            item.name,
                            style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w600),
                          )),
                          Expanded(
                              child: Text(
                            applyDate,
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              // backgroundColor: Colors.orange[50],
                            ),
                          )),
                        ],
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          Expanded(
                              child: customText(
                                  value: '币种：' + item.currency,
                                  fontSize: 14.5)),
                          Expanded(
                              child: customText(
                                  value:
                                      '金额：${Utils.getFormatNum(item.amount)}',
                                  fontSize: 14.5)),
                        ],
                      ),
                      // Row(
                      //   children: <Widget>[
                      //     Expanded(
                      //         child: customText(
                      //             value: '原因：' + item.reason, fontSize: 14.5)),
                      //   ],
                      // ),
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: customText(
                                  value: '已审批：' + (item.approval ?? ''),
                                  fontSize: 14.5)),
                          // if (item.status < 20)
                          Expanded(
                              child: customText(
                                  value: '待审批：' + (item.wApproval ?? '/'),
                                  fontSize: 14.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(right: 10),
                    child: Text(item.statusName,
                        style: statusTextStyle(item.status))),
              ],
            )),
      ),
    );
  }

  void _add() async {
    Utils.closeInput(context);
    bool dataChanged = await navigatePage(context, borrowDetailPath);
    if (dataChanged) _getList(true);
  }

  Future<bool> _delete(BorrowData item) async {
    bool result = false;
    if (await DialogUtils.showConfirmDialog(context, '是否删除该借款单?',
        iconData: Icons.info, color: Colors.red)) {
      await BorrowService.delete(item.borrowId).then((value) {
        if (value['ErrCode'] == 0) {
          _borrowList.remove(item);
          setState(() {});
          DialogUtils.showToast('删除成功');
          result = true;
        } else {
          var msg = value['ErrMsg'];
          DialogUtils.showAlertDialog(context, msg);
        }
      });
    }
    return result;
  }

  void _search() {
    // _borrowList.clear();
    // BorrowSData.maxId = 0;
    _getList(true);
  }

  void _getList(bool isRefresh) async {
    if (isRefresh) {
      _borrowList.clear();
      _hasMoreData = true;
    }

    if (!_hasMoreData) return;
    Function dismiss = FLToast.showLoading();
    int maxid = isRefresh ? 0 : _borrowList.last.borrowId;
    try {
      await BorrowService.getList(_keywordController.text, maxid).then((value) {
        if (BorrowSData.area.length == 0) {
          BorrowSData.area = value.area;
          BorrowSData.currency = value.currency;
          BorrowSData.paymentMethod = value.paymentMethod;
          BorrowSData.userStaff = value.userStaff[0];
        }
        if (value.borrowList.length > 0) {
          _borrowList.addAll(value.borrowList);
          if (isRefresh) {
            _refreshController.finishRefresh(success: true);
          } else {
            _refreshController.finishLoad(success: true, noMore: false);
          }
        } else {
          _hasMoreData = false;
          _refreshController.finishLoad(success: true, noMore: true);
        }
        setState(() {});
      });
    } finally {
      dismiss();
    }
  }
}
