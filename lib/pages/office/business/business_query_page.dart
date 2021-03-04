import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/businessReport.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/business_service.dart';
import 'package:mis_app/utils/utils.dart';

class BusinessQueryPage extends StatefulWidget {
  @override
  _BusinessQueryPageState createState() => _BusinessQueryPageState();
}

class _BusinessQueryPageState extends State<BusinessQueryPage> {
  final TextEditingController _keyword = TextEditingController();
  List<BusinessReportModel> _dataList = [];

  @override
  void initState() {
    super.initState();
    _getBusiness();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出差报告'),
      ),
      body: Column(
        children: <Widget>[
          // Container(
          //   padding: EdgeInsets.all(10.0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: <Widget>[
          //       Expanded(
          //         child: TextField(
          //           controller: _keyword,
          //           autofocus: false,
          //           decoration: InputDecoration(
          //             hintText: "请输入关键字",
          //           ),
          //         ),
          //       ),
          //       IconButton(
          //         icon: Icon(Icons.search),
          //         onPressed: () {
          //           _getBusiness();
          //         },
          //       ),
          //     ],
          //   ),
          // ),
          searchViewCustom(_keyword, _getBusiness),
          Expanded(
            child: ListView.separated(
              itemCount: _dataList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _dataList[index];
                return InkWell(
                  onTap: () async {
                    Utils.closeInput(context);

                    bool dataChanged = await navigatePage(
                        context, businessEditPath, arguments: {
                      'onBusinessReportId': item.onBusinessReportId
                    });

                    if (dataChanged) {
                      _getBusiness();
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
                              Text(
                                item.reporterName,
                                style: TextStyle(color: Colors.blue),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Text(Utils.dateTimeToStr(item.reportDate)),
                              SizedBox(
                                height: 6,
                              ),
                              Text(item.reportTitle),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          item.isUsed == 0 ? '未使用' : '已使用',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            width: double.infinity,
            child: RaisedButton(
              color: Colors.blue,
              colorBrightness: Brightness.dark,
              splashColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text('新增报告'),
              onPressed: () async {
                Utils.closeInput(context);
                bool dataChanged = await navigatePage(
                  context,
                  businessEditPath,
                );

                if (dataChanged) {
                  _getBusiness();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _getBusiness() async {
    _dataList = await businessAction(_keyword.text);
    setState(() {});
  }
}
