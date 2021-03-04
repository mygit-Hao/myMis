import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/receive.dart';
import 'package:mis_app/pages/common/webview_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/receive_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class ReceiveQueryPage extends StatefulWidget {
  @override
  _ReceiveQueryPageState createState() => _ReceiveQueryPageState();
}

class _ReceiveQueryPageState extends State<ReceiveQueryPage> {
  TextEditingController _keyword = TextEditingController();
  List<ReceiveList> _dataList = [];

  @override
  void initState() {
    super.initState();
    _getReceive();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('招待申请列表'),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebViewPage(
                  arguments: {
                    'title': '招待申请',
                    'url': serviceUrl[seriveHelpUrl]
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
            searchViewCustom(_keyword, _getReceive),
            _receiveListview(),
            Row(
              children: <Widget>[customButtom(Colors.blue, '新增', _add)],
            )
          ],
        ),
      ),
    );
  }

  void _getReceive() async {
    _dataList = await receiveAction(_keyword.text);
    setState(() {});
  }

  Widget _receiveListview() {
    return Expanded(
      child: EasyRefresh(
        header: customRefreshHeader,
        footer: customRefreshFooter,
        firstRefresh: true,
        firstRefreshWidget: refreshWidget,
        child: ListView.separated(
          itemCount: _dataList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            final item = _dataList[index];
            return Dismissible(
              background: deleteBg(),
              key: Key(item.receiveId),
              confirmDismiss: (DismissDirection direction) {
                return _delete(item);
              },
              child: InkWell(
                onTap: () async {
                  Utils.closeInput(context);

                  bool dataChanged = await navigatePage(
                      context, receiveEditPath,
                      arguments: {'receiveId': item.receiveId});

                  if (dataChanged) {
                    _getReceive();
                  }
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                    child: customText(
                                        color: Colors.blue,
                                        value: item.requestStaffName)),
                                SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    item.statusName,
                                    style: statusNameTextStyle(item.statusName),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            _receiveList(
                              text1: Utils.dateTimeToStr(item.applyDate),
                              color1: Colors.orange,
                              text2:
                                  '总金额：${Utils.getFormatNum(item.totalMoney)} 元',
                              color2: Colors.black,
                            ),
                            SizedBox(height: 4),
                            _receiveList(
                                text1: '已审批人：${item.approval ?? ''}',
                                text2: '待审批人：${item.wApproval ?? ''}'),
                            SizedBox(height: 4),
                            customText(value: '招待事由：${item.reason}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        onRefresh: () async {
          _getReceive();
        },
      ),
    );
  }

  Widget _receiveList(
      {String text1, Color color1, String text2, Color color2}) {
    return Row(
      children: <Widget>[
        Expanded(
          child: customText(value: text1 ?? '', color: color1),
        ),
        SizedBox(
          width: 6,
        ),
        Expanded(
          child: customText(value: text2 ?? '', color: color2),
        ),
      ],
    );
  }

  void _add() async {
    Utils.closeInput(context);

    bool dataChanged = await navigatePage(context, receiveEditPath);
    if (dataChanged) _getReceive();
  }

  Future<bool> _delete(ReceiveList item) async {
    bool isDelete = false;
    if (item.statusName != '草稿') {
      DialogUtils.showToast(item.statusName + '状态不能删除此单据');
      return false;
    }
    bool result = await DialogUtils.showConfirmDialog(context, '是否删除该条招待申请单？',
        iconData: Icons.info, color: Colors.red);
    if (result == true) {
      await delete(item.receiveId).then((value) {
        if (value['ErrCode'] == 0) {
          isDelete = true;
          _dataList.remove(item);
          setState(() {});
          DialogUtils.showToast('删除成功');
        } else {
          DialogUtils.showConfirmDialog(context, value['ErrMsg']);
        }
      });
    }
    return isDelete;
  }
}
