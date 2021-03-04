import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/askForLeave.dart';
import 'package:mis_app/model/askForLeaveDetail.dart';
import 'package:mis_app/service/askForLeave_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class OverTimeSelectPage extends StatefulWidget {
  final Map arguments;
  OverTimeSelectPage({this.arguments});

  @override
  _OverTimeSelectPageState createState() => _OverTimeSelectPageState();
}

class _OverTimeSelectPageState extends State<OverTimeSelectPage> {
  List<OverTimeSelectModel> _selectedList = [];
  List<OverTimeSelectModel> _overTimeList = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _selectedList = this.widget.arguments['list'] ?? [];
    print(jsonEncode(_selectedList));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getList();
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('加班单调休'),
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(10),
        child: _listView(),
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () {
                for (var item in _selectedList) {
                  if (item.overTimeDid == _overTimeList[index].overTimeDid) {
                    DialogUtils.showToast('该加班单已经添加');
                    return;
                  }
                }
                _overTimeList[index].askForLeaveId =
                    AskForLeaveSData.askForLeaveId;
                Navigator.pop(context, _overTimeList[index]);
              },
              child: _item(index));
        },
        itemCount: _overTimeList.length);
  }

  Widget _item(int index) {
    OverTimeSelectModel item = _overTimeList[index];
    String beginDate =
        Utils.dateTimeToStr(item.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String endDate =
        Utils.dateTimeToStr(item.endDate, pattern: 'yyyy-MM-dd HH:mm');
    return Card(
      elevation: 0.4,
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // customText(value: '单号: ' + item.code),
            Flex(
              direction: Axis.horizontal,
              children: <Widget>[
                Expanded(
                    flex: 3,
                    child: Row(
                      children: <Widget>[
                        customText(value: '开始: '),
                        customText(
                          value: beginDate,
                          color: Colors.blue,
                          // backgroundColor: Color.fromARGB(15, 33, 137, 255),
                        )
                      ],
                    )),
                Expanded(
                    flex: 2,
                    child: Row(
                      children: <Widget>[
                        customText(value: '共 '),
                        customText(
                            value: item.hours.toString(),
                            color: Colors.blue,
                            backgroundColor: Colors.blue[50]),
                        customText(value: ' 小时'),
                      ],
                    )),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 2),
              child: Flex(
                direction: Axis.horizontal,
                children: <Widget>[
                  Expanded(
                      flex: 3,
                      child: Row(
                        children: <Widget>[
                          customText(value: '结束: '),
                          customText(
                            value: endDate,
                            color: Colors.blue,
                            // backgroundColor: Color.fromARGB(15, 33, 137, 255),
                          )
                        ],
                      )),
                  Expanded(
                      flex: 2,
                      child: Row(
                        children: <Widget>[
                          customText(value: '已使用 '),
                          Text(
                            item.usedHours.toString(),
                            style: TextStyle(
                                color: Colors.orange,
                                backgroundColor: Colors.orange[50]),
                          ),
                          customText(value: ' 小时')
                        ],
                      )),
                ],
              ),
            ),
            Container(
                margin: EdgeInsets.only(top: 1),
                child: customText(value: item.reason))
          ],
        ),
      ),
    );
  }

  void _getList() async {
    await _progressDialog?.show();
    int id = AskForLeaveSData.staffId;
    await AskForLeaveService.getOverTimeList(id).then((value) {
      setState(() {
        _overTimeList = value ?? [];
      });
    });
    await _progressDialog?.hide();
  }
}
