import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/history_clock.dart';
import 'package:mis_app/pages/office/work_clock/work_clock.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:progress_dialog/progress_dialog.dart';

class HistoryClockListPage extends StatefulWidget {
  @override
  _HistoryClockListPageState createState() => _HistoryClockListPageState();
}

class _HistoryClockListPageState extends State<HistoryClockListPage>
    with SingleTickerProviderStateMixin {
  List<HistoryClock> _todayList = [];
  List<HistoryClock> _historyList = [];
  List<Tab> tabs = [];
  TabController _tabController;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    tabs.add(Tab(
      text: '今天记录',
    ));
    tabs.add(Tab(
      text: '历史记录',
    ));
    this._tabController = new TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _getToday();
      _getHistory();
    });
  }

  ///获取今天打卡记录
  void _getToday() async {
    await WorkClockService.getHistoryData(1).then((value) {
      setState(() {
        _todayList = value;
      });
    });
  }

  ///获取历史记录
  void _getHistory() async {
    await _progressDialog?.show();
    try {
      await WorkClockService.getHistoryData(0).then((value) {
        setState(() {
          _historyList = value;
        });
      });
    } finally {
      await _progressDialog?.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(title: Text('打卡记录')),
      body: Container(
          child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1, color: Colors.grey))),
            child: TabBar(
              controller: _tabController,
              tabs: tabs,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
            ),
          ),
          Expanded(
              child: TabBarView(controller: _tabController, children: [
            _clockList(_todayList),
            _clockList(_historyList),
          ])),
        ],
      )),
    );
  }

  Widget _clockList(List<HistoryClock> list) {
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              ClockStaticData.clockId = list[index].clockRecId;
              Navigator.pushNamed(context, historyClockDetailPath);
            },
            child: Container(
              decoration: bottomLineDecotation,
              padding: EdgeInsets.all(8),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Text(
                          list[index].clockKindName,
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.access_time,
                              size: 18,
                              color: Colors.blue,
                            ),
                            Text(
                              ' ' + list[index].clockTime,
                              style: TextStyle(
                                  color: Color.fromARGB(170, 45, 45, 45),
                                  fontSize: 15),
                            )
                          ],
                        )),
                    Container(
                        margin: EdgeInsets.only(top: 3),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              size: 21,
                              color: Colors.orange,
                            ),
                            Text(
                              list[index].address,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Color.fromARGB(170, 45, 45, 45),
                                  fontSize: 14),
                            )
                          ],
                        )),
                  ]),
            ),
          );
        });
  }
}
