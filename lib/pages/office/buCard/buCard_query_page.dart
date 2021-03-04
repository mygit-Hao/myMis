import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/buCard.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/buCard_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class BuCardQueryPage extends StatefulWidget {
  @override
  _BuCardQueryPageState createState() => _BuCardQueryPageState();
}

class _BuCardQueryPageState extends State<BuCardQueryPage> {
  TextEditingController _keyword = TextEditingController();
  List<BuCardList> _dataList = [];

  @override
  void initState() {
    super.initState();
    _getBuCard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('补卡申请列表'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            searchViewCustom(_keyword, _getBuCard),
            _buCardListview(),
            Row(
              children: <Widget>[customButtom(Colors.blue, '新增', _add)],
            )
          ],
        ),
      ),
    );
  }

  Widget _buCardListview() {
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
              key: new Key(item.buCardId),
              confirmDismiss: (DismissDirection dismissDirection) {
                return _delete(item);
              },
              background: new Container(
                alignment: Alignment.center,
                color: Colors.white,
                child: customText(value: '侧滑删除', color: Colors.red),
              ),
              child: InkWell(
                onTap: () async {
                  Utils.closeInput(context);

                  bool dataChanged = await navigatePage(context, buCardEditPath,
                      arguments: {'buCardId': item.buCardId});

                  if (dataChanged) {
                    _getBuCard();
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
                                        value: item.staffNames)),
                                SizedBox(
                                  width: 6,
                                ),
                                Expanded(
                                  child: Text(
                                    item.statusName,
                                    style: statusTextStyle(item.status),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            _buCardList(
                                text1: item.kindName,
                                text2: Utils.dateTimeToStr(item.applyDate),
                                color2: Colors.orange),
                            SizedBox(height: 4),
                            _buCardList(
                                text1: '已审批人：${item.approval ?? ''}',
                                text2: '待审批人：${item.wApproval ?? ''}'),
                            SizedBox(height: 4),
                            customText(value: '未打卡原因：${item.reason ?? ''}'),
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
          _getBuCard();
        },
      ),
    );
  }

  Widget _buCardList({String text1, Color color1, String text2, Color color2}) {
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

  void _getBuCard() async {
    _dataList = await buCardAction(_keyword.text);
    setState(() {});
  }

  void _add() async {
    Utils.closeInput(context);

    bool dataChanged = await navigatePage(context, buCardEditPath);
    if (dataChanged) _getBuCard();
  }

  Future<bool> _delete(BuCardList item) async {
    bool isDelete = false;
    isDelete = await DialogUtils.showConfirmDialog(context, '是否删除该条补卡申请单？',
        iconData: Icons.info, color: Colors.red);
    if (isDelete) {
      await toDraftOrDelete('delete', item.buCardId).then((value) {
        if (value.errCode == 0) {
          toastBlackStyle('删除成功!');
          isDelete = true;
          _dataList.remove(item);
          setState(() {});
        } else {
          isDelete = false;
          DialogUtils.showAlertDialog(context, value.errMsg);
        }
      });
    }
    return isDelete;
  }
}
