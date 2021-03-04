import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:provide/provide.dart';

class WeekPlanProgressPage extends StatefulWidget {
  @override
  _WeekPlanProgressPageState createState() => _WeekPlanProgressPageState();
}

class _WeekPlanProgressPageState extends State<WeekPlanProgressPage> {
  final _padding = 5.0;
  final _fontsize = 13.5;
  WeekPlanProjData _projData = new WeekPlanProjData();
  // InAppWebViewController _webViewController;
  // FLCountStepperController _weekCtrl;

  @override
  void initState() {
    super.initState();
    // _weekCtrl = FLCountStepperController(min: 1, max: 100, step: 1);
    // _weekCtrl.value = 5;
  }

  @override
  Widget build(BuildContext context) {
    return Provide<WeekPlanProvide>(
      builder: (context, child, detail) {
        List<Week> weekList = detail.detailModel.weeks ?? [];
        _projData = detail.detailModel.projData;
        return Container(
          child: _progress(weekList),
        );
      },
    );
  }

  Widget _progress(List<Week> weekList) {
    return Container(
        // padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
        child: Flex(
      direction: Axis.vertical,
      children: [
        // _weekHead(),
        Expanded(
          flex: 1,
          child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Week item = weekList[index];
                return InkWell(
                  onTap: () {
                    Utils.closeInput(context);
                    if (!item.privacy) {
                      _progressEdit(item: item);
                    } else {
                      DialogUtils.showToast('该进展为隐私进展');
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                    // margin: EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: ExpansionPanelList(
                      expandedHeaderPadding: EdgeInsets.all(0),
                      expansionCallback: (panelIndex, isExpanded) {
                        setState(() {
                          item.isExpanded = !item.isExpanded;
                        });
                      },
                      children: [
                        ExpansionPanel(
                            isExpanded: item.isExpanded,
                            headerBuilder: (context, isExpanded) {
                              return _weekItem(item);
                            },
                            body: item.privacy
                                ? customText(value: '该进展为隐私进展', fontSize: 14)
                                : Container(
                                    padding: EdgeInsets.fromLTRB(8, 3, 8, 8),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        border: Border(
                                            top: BorderSide(width: 0.2))),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('目标：',
                                                  style: TextStyle(
                                                      fontSize: _fontsize)),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: _padding),
                                                child: Text(
                                                  '${item.weekObj}',
                                                  style: TextStyle(
                                                      fontSize: _fontsize,
                                                      color: Colors.purple),
                                                ),
                                              ),
                                              if (item.weekResult != '')
                                                Text('结果：',
                                                    style: TextStyle(
                                                        fontSize: _fontsize)),
                                              if (item.weekResult != '')
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: _padding),
                                                  child: Text(
                                                    '${item.weekResult}',
                                                    style: TextStyle(
                                                        fontSize: _fontsize,
                                                        color:
                                                            Colors.blue[600]),
                                                  ),
                                                ),
                                              if (item.comment != '')
                                                Text('批注：',
                                                    style: TextStyle(
                                                        fontSize: _fontsize)),
                                              if (item.comment != '')
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: _padding),
                                                  child: Text(
                                                    '${item.comment}',
                                                    style: TextStyle(
                                                        fontSize: _fontsize,
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              if (item.hasFiles)
                                                Text('附件：',
                                                    style: TextStyle(
                                                        fontSize: _fontsize)),
                                              if (item.hasFiles)
                                                Icon(Icons.attachment,
                                                    color: Colors.blue)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ))
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(height: 0.5);
              },
              itemCount: weekList.length),
        ),
        // if (_projData.projId != 0) _webView(),
        if (_projData.projId != 0 && _projData.canFollow)
          Row(children: [customButtom(Colors.blue, '新增进展', _addProgress)]),
      ],
    ));
  }

  // Widget _webView() {
  //   return Expanded(
  //       flex: 3,
  //       child: Container(
  //         decoration:
  //             BoxDecoration(border: Border.all(color: Colors.blueAccent)),
  //         child: Column(
  //           children: [
  //             Expanded(
  //               child: Container(
  //                 child: InAppWebView(
  //                   initialUrl: _getFileUrl(),
  //                   initialOptions: InAppWebViewGroupOptions(
  //                       crossPlatform: InAppWebViewOptions(supportZoom: true),
  //                       android: AndroidInAppWebViewOptions(
  //                         builtInZoomControls: true,
  //                         loadWithOverviewMode: false,
  //                       )),
  //                   onWebViewCreated: (InAppWebViewController controller) {
  //                     _webViewController = controller;
  //                   },
  //                 ),
  //               ),
  //             ),
  //             _weekChange(),
  //             // _webCtrlBt(),
  //           ],
  //         ),
  //       ));
  // }

  // Widget _weekChange() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Text('近'),
  //       FLCountStepper(
  //         controller: _weekCtrl,
  //         disableInput: false,
  //         onChanged: (value) {
  //           _webViewController.loadUrl(url: _getFileUrl());
  //         },
  //       ),
  //       Text('周'),
  //     ],
  //   );
  // }

  // Widget _weekHead() {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(10, 8, 0, 4),
  //     // decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
  //     child: Row(
  //       children: [
  //         Expanded(child: customText(value: '周数', color: Colors.black)),
  //         Expanded(child: customText(value: '参与人', color: Colors.black)),
  //         Expanded(child: customText(value: '开始', color: Colors.black)),
  //         Expanded(child: customText(value: '结束', color: Colors.black)),
  //         // Expanded(child: customText(value: '隐私', color: Colors.black)),
  //         Expanded(child: customText(value: '展开', color: Colors.black)),
  //       ],
  //     ),
  //   );
  // }

  Widget _weekItem(Week item) {
    String begin = getDateTimeStr(item.weekFrom);
    String end = getDateTimeStr(item.weekTo);
    int staffId = UserProvide.currentUser.staffId;
    return Container(
      // color: Colors.grey[100],
      // height: 10,
      // color: item.privacy ? Colors.blue : Colors.white,
      padding: EdgeInsets.only(left: 6),
      child: Flex(
        direction: Axis.horizontal,
        children: [
          Expanded(
              flex: 2,
              child: Text(
                item.week.toString(),
                // style: TextStyle(fontWeight: FontWeight.w600),
              )),
          Expanded(
              flex: 2,
              child: customText(
                  value: item.fromStaffName ?? '',
                  // fontWeight: FontWeight.w600,
                  color:
                      item.staffId == staffId ? Colors.black : Colors.purple)),
          Expanded(flex: 3, child: Text(begin + ' - ' + end)),
          Container(
              margin: EdgeInsets.only(right: 3),
              // child: item.privacy
              //     ? Icon(
              //         Icons.check_box,
              //         color: Colors.blue,
              //       )
              //     : Icon(
              //         Icons.check_box_outline_blank,
              //         color: Colors.black54,
              //       ),
              child: item.privacy
                  ? customText(value: '隐私', color: Colors.blue)
                  : Container())
        ],
      ),
    );
  }

  String getDateTimeStr(String dataStr) {
    if (dataStr != null) {
      DateTime data = DateTime.parse(dataStr);
      String str = Utils.dateTimeToStr(data, pattern: 'MM/dd');
      return str;
    } else {
      return '';
    }
  }

  void _addProgress() async {
    DateTime date = DateTime.now();
    DateTime startOfYear = new DateTime(date.year, 1, 1, 0, 0);
    int firstMonday = startOfYear.weekday;
    //第一周的天数
    int daysInFirstWeek = 8 - firstMonday;
    int diff = date.difference(startOfYear).inDays + 1;
    int weeks = ((diff - daysInFirstWeek) / 7).ceil();
    //加上第一周
    weeks += 1;
    // DateTime begin = startOfYear.add(Duration(days: 7 * (weeks - 1)));
    DateTime end =
        startOfYear.add(Duration(days: 7 * (weeks - 1) + daysInFirstWeek - 1));

    DateTime begin = end.add(Duration(days: -6));

    print("Week Range>>>>>>>>>>>>>>>>> $weeks");
    print("开始： $weeks: $begin");
    print("结束 $weeks: $end");

    Week item = Week();
    item.weekPlanObjByProjId = _projData.projId;
    item.year = date.year;
    item.week = date.year * 100 + weeks;
    item.weekFrom = Utils.dateTimeToStr(begin, pattern: 'yyyy-MM-dd');
    item.weekTo = Utils.dateTimeToStr(end, pattern: 'yyyy-MM-dd');
    item.readOnly = false;
    _progressEdit(item: item);
  }

  void _progressEdit({Week item}) async {
    await navigatePage(context, weekPlanProgressPath, arguments: item);
    // _webViewController.reload();
  }

  // String _getFileUrl() {
  //   int week = _weekCtrl.value;
  //   String user = UserProvide.currentUser.userName;
  //   String devid = DeviceInfo.devId;
  //   String passWordKey = UserProvide.currentUserMd5Password;
  //   String date = Utils.dateTimeToStrWithPattern(DateTime.now(), 'yyyyMMdd');
  //   String key = Utils.getMd5_16(user + passWordKey + devid + date);
  //   String urlToken = getUrlToken();
  //   String url =
  //       '${serviceUrl[weekProgressUrl]}?user=$user&devid=$devid&key=$key&=$urlToken&did=${_projData.projId}&weeks=$week';
  //   return url;
  // }
}
