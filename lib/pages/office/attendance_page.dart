import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/attendance.dart';
import 'package:mis_app/model/attendance_scard.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/hrms_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/date_view.dart';
import 'package:mis_app/widget/large_button.dart';

class AttendancePage extends StatefulWidget {
  AttendancePage({Key key}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime _startDate;
  DateTime _endDate;
  int _selectedStaffId;
  String _selectedStaffDeptName;
  String _selectedStaffName;

  List<AttendanceModel> _attendanceList;

  @override
  void initState() {
    super.initState();

    _endDate = Utils.today;
    _startDate = Utils.firstDayOfMonth(_endDate);
    _selectedStaffId = UserProvide.currentUser.staffId;
    _selectedStaffName = UserProvide.currentUser.staffName;
    _selectedStaffDeptName = UserProvide.currentUser.deptName;

    _attendanceList = List<AttendanceModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('考勤查询'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _loadData();
              }),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              _searchWidget(),
              _dataListWidget(context),
            ],
          ),
        ),
      ),
    );
  }

  void _loadData() async {
    // print('加载考勤资料');
    if (_selectedStaffId <= 0) {
      DialogUtils.showToast('请先选定员工');
      return;
    }

    List<AttendanceModel> list =
        await HrmsService.getTimes(_selectedStaffId, _startDate, _endDate);

    setState(() {
      _attendanceList = list;
    });
    // print(list);
  }

  Widget _dataListWidget(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.separated(
          itemCount: _attendanceList.length,
          itemBuilder: (BuildContext context, int index) {
            return _attendanceItemWidget(context, _attendanceList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        ),
      ),
    );
  }

  List<Widget> _detailWidgetList(
      AttendanceModel attendance, List<AttendanceSCardModel> scard) {
    bool holidaysVisible =
        (!Utils.textIsEmptyOrWhiteSpace(attendance.holidayA) ||
            !Utils.textIsEmptyOrWhiteSpace(attendance.holidayB) ||
            !Utils.textIsEmptyOrWhiteSpace(attendance.holidayC));

    bool holidayTimesVisible = attendance.holidayATimes != 0 ||
        attendance.holidayBTimes != 0 ||
        attendance.holidayCTimes != 0;

    bool lateVisible =
        attendance.lateA != 0 || attendance.lateB != 0 || attendance.lateC != 0;

    List<Widget> list = List();
    for (var i = 0; i < (AttendanceSCardModel.sCardCount / 2); i++) {
      int card1Index = i * 2;
      int card2Index = i * 2 + 1;

      if ((scard[card1Index].date != null) || scard[card2Index].date != null) {
        list.add(Row(
          children: <Widget>[
            _attendanceTimeWidget(
                '打卡${card1Index + 1}', '${scard[card1Index].toText}'),
            _attendanceTimeWidget(
                '打卡${card2Index + 1}', '${scard[card2Index].toText}'),
          ],
        ));
      }
    }

    /*
    if (!Utils.textIsEmptyOrWhiteSpace(attendance.time1) ||
        !Utils.textIsEmptyOrWhiteSpace(attendance.time2)) {
      list.add(Row(
        children: <Widget>[
          _attendanceTimeWidget('打卡1', '${attendance.time1}'),
          _attendanceTimeWidget('打卡2', '${attendance.time2}'),
        ],
      ));
    }

    if (!Utils.textIsEmptyOrWhiteSpace(attendance.time3) ||
        !Utils.textIsEmptyOrWhiteSpace(attendance.time4)) {
      list.add(Row(
        children: <Widget>[
          _attendanceTimeWidget('打卡3', '${attendance.time3}'),
          _attendanceTimeWidget('打卡4', '${attendance.time4}'),
        ],
      ));
    }

    if (!Utils.textIsEmptyOrWhiteSpace(attendance.time5) ||
        !Utils.textIsEmptyOrWhiteSpace(attendance.time6)) {
      list.add(Row(
        children: <Widget>[
          _attendanceTimeWidget('打卡5', '${attendance.time5}'),
          _attendanceTimeWidget('打卡6', '${attendance.time6}'),
        ],
      ));
    }
    */

    if (holidaysVisible || holidayTimesVisible || lateVisible) {
      list.add(SizedBox(
        height: 8.0,
      ));
    }

    if (holidaysVisible) {
      list.add(Row(
        children: <Widget>[
          _holidayWidget('早班假'),
          _holidayWidget('午班假'),
          _holidayWidget('晚班假'),
        ],
      ));
    }

    if (holidaysVisible) {
      list.add(Row(
        children: <Widget>[
          _holidayContentWidget('${attendance.holidayA}'),
          _holidayContentWidget('${attendance.holidayB}'),
          _holidayContentWidget('${attendance.holidayC}'),
        ],
      ));
    }

    if (holidayTimesVisible) {
      list.add(Row(
        children: <Widget>[
          _holidayWidget('早假时'),
          _holidayWidget('午假时'),
          _holidayWidget('晚假时'),
        ],
      ));
    }

    if (holidayTimesVisible) {
      list.add(Row(
        children: <Widget>[
          _holidayContentWidget('${attendance.holidayATimes}'),
          _holidayContentWidget('${attendance.holidayBTimes}'),
          _holidayContentWidget('${attendance.holidayCTimes}'),
        ],
      ));
    }

    if (lateVisible) {
      list.add(Row(
        children: <Widget>[
          _holidayWidget('早迟退'),
          _holidayWidget('午迟退'),
          _holidayWidget('晚迟退'),
        ],
      ));
    }

    if (lateVisible) {
      list.add(Row(
        children: <Widget>[
          _holidayContentWidget('${attendance.lateA}'),
          _holidayContentWidget('${attendance.lateB}'),
          _holidayContentWidget('${attendance.lateC}'),
        ],
      ));
    }

    return list;
  }

  void _showAttendanceDetail(
      BuildContext context, AttendanceModel attendance) async {
    // print(attendance);

    List<AttendanceSCardModel> scard =
        await HrmsService.getSCard(_selectedStaffId, attendance.date);

    if (scard == null) return;

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: _detailWidgetList(attendance, scard),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                LargeButton(
                    title: '关闭',
                    height: 40,
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          );
        });
  }

  Widget _holidayContentWidget(String content) {
    return _holidayWidget(content, color: Colors.blue);
  }

  Widget _holidayWidget(String content, {Color color}) {
    return Expanded(
      child: Center(
        child: Text(
          content,
          style: color == null
              ? TextStyle(fontSize: fontSizeDefault)
              : TextStyle(
                  fontSize: fontSizeDefault,
                  color: color,
                ),
        ),
      ),
    );
  }

  Widget _attendanceTimeWidget(String title, String time) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: fontSizeDefault),
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(
            time,
            style: TextStyle(color: Colors.blue, fontSize: fontSizeDefault),
          ),
        ],
      ),
    );
  }

  Widget _listTimeWidget(String time) {
    return Text(
      time,
      style: TextStyle(color: Colors.blue),
    );
  }

  Widget _attendanceItemWidget(
      BuildContext context, AttendanceModel attendance) {
    return InkWell(
      onTap: () {
        _showAttendanceDetail(context, attendance);
      },
      child: Container(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
              child: Column(
                children: <Widget>[
                  Text(
                    Utils.dateTimeToStr(attendance.date),
                    style:
                        TextStyle(color: _getWeekdayColor(attendance.weekDay)),
                  ),
                  Text(
                    // Utils.dateTimeToStrWithPattern(
                    //     attendance.date, 'EEEE', defaultLocale),
                    Utils.weekdayToStr(attendance.weekDay),
                    style:
                        TextStyle(color: _getWeekdayColor(attendance.weekDay)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  // Text(attendance.time1),
                  // Text(attendance.time2),
                  _listTimeWidget(attendance.time1),
                  _listTimeWidget(attendance.time2),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  // Text(attendance.time3),
                  // Text(attendance.time4),
                  _listTimeWidget(attendance.time3),
                  _listTimeWidget(attendance.time4),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  // Text(attendance.time5),
                  // Text(attendance.time6),
                  _listTimeWidget(attendance.time5),
                  _listTimeWidget(attendance.time6),
                ],
              ),
            ),
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: (!Utils.textIsEmpty(attendance.holidayA) ||
                  !Utils.textIsEmpty(attendance.holidayB) ||
                  !Utils.textIsEmpty(attendance.holidayC)),
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 20.0,
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getWeekdayColor(int weekday) {
    return weekday == 7 ? Colors.red : Colors.black;
  }

  Widget _searchWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(2.0, 4.0, 2.0, 4.0),
      color: Colors.grey[300],
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    _labelWidget('部门'),
                    _textContentWidget(_selectedStaffDeptName),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    _labelWidget('姓名'),
                    _textContentWidget(
                      _selectedStaffName,
                      trailing: UserProvide.currentUser.canViewAllAttendance
                          ? Icon(
                              Icons.person_outline,
                              size: 20.0,
                              color: Colors.blue,
                            )
                          : null,
                      onTap: () {
                        _selectStaff();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 6.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    _labelWidget('起始日期'),
                    // _textContentWidget(Utils.dateTimeToStr(_startDate),
                    //     trailing: Icon(
                    //       Icons.arrow_drop_down,
                    //       size: 20.0,
                    //     ), onTap: () {
                    //   _selectDate(true);
                    // }),
                    DateView(
                      value: _startDate,
                      onTap: () {
                        DialogUtils.showDatePickerDialog(context, _startDate,
                            onValue: (val) {
                          setState(() {
                            // 起始日期：符合以下条件之一，就修改截止日期为“起始日期所在月份的最后一天”
                            // 1.起始、截止日期不在同一个月
                            // 2.起始日期晚于截止日期
                            // if (val.isAfter(_endDate)) {
                            //   Utils.showToast('起始日期不能晚于截止日期');
                            //   return;
                            // }
                            _startDate = val;
                            if (!Utils.inSameMonth(_startDate, _endDate) ||
                                _startDate.isAfter(_endDate)) {
                              _endDate = Utils.lastDayOfMonth(_startDate);
                            }
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: <Widget>[
                    _labelWidget('截止目期'),
                    /*
                    _textContentWidget(Utils.dateTimeToStr(_endDate),
                        trailing: Icon(
                          Icons.arrow_drop_down,
                          size: 20.0,
                        ), onTap: () {
                      _selectDate(false);
                    }),
                    */
                    DateView(
                      value: _endDate,
                      onTap: () {
                        DialogUtils.showDatePickerDialog(context, _endDate,
                            onValue: (val) {
                          setState(() {
                            // 截止日期：符合以下条件之一，就修改起始日期为“截止日期所在月份的第一天”
                            // 1.起始、截止日不在同一个月
                            // 2.截止日期早于起始日期
                            // if (val.isBefore(_startDate)) {
                            //   Utils.showToast('截止日期不能早于起始日期');
                            //   return;
                            // }
                            _endDate = val;
                            if (!Utils.inSameMonth(_startDate, _endDate) ||
                                _endDate.isBefore(_startDate)) {
                              _startDate = Utils.firstDayOfMonth(_endDate);
                            }
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectStaff() async {
    if (UserProvide.currentUser.canViewAllAttendance) {
      // print('选择人员');
      // var result = await Navigator.pushNamed(context, selectStaffPage);
      // print(result);
      var result = await showSearch(
        context: context,
        delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff),
      );

      if (result == null) return;

      StaffModel staff = StaffModel.fromJson(json.decode(result));
      // print(staff);
      setState(() {
        _selectedStaffId = staff.staffId;
        _selectedStaffDeptName = staff.deptName;
        _selectedStaffName = staff.name;
      });
    } else {
      print('没有权限选择人员');
    }
  }

  Widget _labelWidget(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        title,
        style: TextStyle(fontSize: fontSizeDetail),
      ),
    );
  }

  Widget _textContentWidget(String value, {Function onTap, Widget trailing}) {
    return Expanded(
      child: InkWell(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          // padding: EdgeInsets.all(6.0),
          // color: Colors.white,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: fontSizeDefault,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
