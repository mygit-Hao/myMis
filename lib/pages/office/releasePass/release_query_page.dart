import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/releasePass.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/releasePass_service.dart';
import 'package:mis_app/utils/utils.dart';

class ReleaseQueryPage extends StatefulWidget {
  @override
  _ReleaseQueryPageState createState() => _ReleaseQueryPageState();
}

class _ReleaseQueryPageState extends State<ReleaseQueryPage> {
  final TextEditingController _keyword = TextEditingController();
  List<ReleasePassModel> _dataList = [];
  FLToastDefaults _toastDefaults = FLToastDefaults();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getReleasePass();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('放行条'),
      ),
      body: FLToastProvider(
        defaults: _toastDefaults,
        child: Column(
          children: <Widget>[
            searchViewCustom(_keyword, _getReleasePass),
            _releaseListview(),
            _addButtom(),
          ],
        ),
      ),
    );
  }

  Widget _releaseListview() {
    return Expanded(
      child: ListView.separated(
        itemCount: _dataList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          final item = _dataList[index];
          return InkWell(
            onTap: () async {
              Utils.closeInput(context);

              bool dataChanged = await navigatePage(
                  context, releasePassEditPath,
                  arguments: {'releasePassId': item.releasePassId});

              if (dataChanged) {
                _getReleasePass();
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
                        _releaseList(
                            text1: item.name,
                            color1: Colors.blue,
                            text2: Utils.dateTimeToStr(item.applyDate),
                            color2: Colors.orange),
                        Row(
                          children: <Widget>[
                            Expanded(child: customText(value: item.passType)),
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
                        _releaseList(
                            text1: '已审批人：${item.approval ?? ''}',
                            text2: '待审批人：${item.wApproval ?? ''}'),
                        customText(value: item.reason),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _releaseList(
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

  Widget _addButtom() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      width: double.infinity,
      child: RaisedButton(
        color: Colors.blue,
        colorBrightness: Brightness.dark,
        splashColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Text('新增'),
        onPressed: () {
          Utils.closeInput(context);
          Navigator.pushNamed(context, releasePassEditPath).then((value) {
            _getReleasePass();
          });
        },
      ),
    );
  }

  void _getReleasePass() async {
    Function dismiss = FLToast.loading(text: 'Loading...');
    try {
      _dataList = await releaseAction(_keyword.text);
      setState(() {});
    } finally {
      dismiss();
    }
  }
}
