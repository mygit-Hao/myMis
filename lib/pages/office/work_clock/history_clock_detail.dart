import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/history_clock_detail.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/pages/office/work_clock/work_clock.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:mis_app/utils/utils.dart';

class HistoryClockDetailPage extends StatefulWidget {
//  final Map arguments;
//   HistoryClockDetailPage({Key key, this.arguments}) : super(key: key);
  // HistoryClockDetailPage(this.arguments);

  @override
  _HistoryClockDetailPageState createState() => _HistoryClockDetailPageState();
}

class _HistoryClockDetailPageState extends State<HistoryClockDetailPage> {
  // List<Data>_detailDataList=[];
  // Data _detailData;
  bool _canMidify = false;
  String _clockkindName = '';
  String _clockTime = '';
  String _address = '';
  String _remarks = '';
  String _reportData = '';
  List<String> _urlList = [];

  List<Photos> _photeList = [];

  @override
  void initState() {
    super.initState();
    _requestDetailData(ClockStaticData.clockId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('打卡详细')),
      body: Container(
        // color: Colors.grey[100],
        padding: EdgeInsets.all(8),
        child: Column(children: <Widget>[
          _clockKindAndTime(),
          _report(context),
          _photes(),
        ]),
      ),
    );
  }

  Widget _clockKindAndTime() {
    return Container(
      // color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.category, color: Colors.blue),
              Text('类型：'),
              _containerText(_clockkindName, color: Colors.blue),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Row(
              children: <Widget>[
                Icon(Icons.timer, color: Colors.blue),
                Text('时间：'),
                _containerText(_clockTime,
                    color: Colors.blue,
                    bgColor: Color.fromARGB(100, 227, 243, 253)),
              ],
            ),
          ),
          _lacation(),
        ],
      ),
    );
  }

  Widget _containerText(String text, {Color color, Color bgColor}) {
    return Container(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: bgColor == null ? Colors.grey[50] : bgColor),
        child: Text(
          text,
          style: TextStyle(color: color ?? Colors.black, fontSize: 14.5),
        ));
  }

  Widget _lacation() {
    return Container(
        margin: EdgeInsets.only(top: 8),
        child: Row(
          children: <Widget>[
            Icon(Icons.location_on, color: Colors.orange),
            Text('地点：'),
            _containerText(_address)
          ],
        ));
  }

  Widget _report(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 10),
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(bottom: 4),
              child: Row(
                children: <Widget>[
                  Text('报告：'),
                  _canMidify
                      ? InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, reportEditPath,
                                arguments: {
                                  'isGetCache': false,
                                  'reportData': _reportData
                                }).then((value) {
                              if (value == 'update')
                                _requestDetailData(ClockStaticData.clockId);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(3),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(5)),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        )
                      : Text('')
                ],
              ),
            ),
            Container(
                width: ScreenUtil().setWidth(750),
                child: _containerText(_remarks,
                    color: Color(0x99000000), bgColor: Colors.grey[100])),
          ],
        ));
  }

  Widget _photes() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('照片：'),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 5),
                // color: Colors.grey[100],
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                    ),
                    itemCount: _photeList.length,
                    itemBuilder: (context, index) {
                      // var imageUrl = Utils.getImageUrl(
                      //     _photeList[index].photoFileId,
                      //     clockRecId: ClockStaticData.clockId);
                      return InkWell(
                        onTap: () {
                          Navigator.push(context,
                              CustomRoute(ViewPhoto(_urlList[index], null)));
                        },
                        child: Image.network(
                          _urlList[index],
                          fit: BoxFit.cover,
                        ),
                      );
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _requestDetailData(int clockRecId) async {
    await WorkClockService.getHistoryDetail(clockRecId).then((value) {
      HistoryClockDetailModel historyClockDetailModel = value;
      setState(() {
        var detailData = historyClockDetailModel.data[0];
        _canMidify = detailData.canModify;
        _clockkindName = detailData.clockKindName;
        _clockTime = detailData.clockTime;
        _address = detailData.address;
        _remarks = detailData.remarks;
        _reportData = detailData.contentData;
        _photeList = historyClockDetailModel.photos;
        for (var item in _photeList) {
          var iamgeUrl = Utils.getImageUrl(item.photoFileId,
              clockRecId: ClockStaticData.clockId);
          _urlList.add(iamgeUrl);
        }
      });
    });
  }
}
