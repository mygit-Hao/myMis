import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/businessPlan_data.dart';
import 'package:mis_app/model/businessPlan_list.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/staff_info.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class BusinessPlanDetailPage extends StatefulWidget {
  final int empPlanId;
  const BusinessPlanDetailPage({Key key, this.empPlanId}) : super(key: key);

  @override
  _BusinessPlanDetailPageState createState() => _BusinessPlanDetailPageState();
}

class _BusinessPlanDetailPageState extends State<BusinessPlanDetailPage> {
  BusinessPlanEmp _empdata = BusinessPlanEmp();
  List<BusinessPlanLine> _planList = [];

  @override
  void initState() {
    super.initState();

    if (this.widget.empPlanId != null) {
      int empPlanId = this.widget.empPlanId;
      BusinessSData.empList.forEach((element) {
        if (empPlanId == element.businessPlanEmpId) {
          _empdata = element;
        }
      });
      BusinessSData.businessPlanLine.forEach((element) {
        if (element.businessPlanEmpId == empPlanId) {
          _planList.add(element);
        }
      });
    } else {
      StaffInfo staffInfo = BaseDbModel.baseDbModel.userStaffList[0];
      _empdata.businessPlanId = BusinessSData.planId;
      _empdata.staffId = staffInfo.staffId;
      _empdata.staffName = staffInfo.staffName;
      _empdata.beginDate = BusinessSData.beginData;
      _empdata.endDate = BusinessSData.endData;
      // _empdata.businessPlanEmpId = staffInfo.staffId;
      BusinessSData.curEmpId--;
      _empdata.businessPlanEmpId = BusinessSData.curEmpId;
      // _empdata.tmpEmpId = staffInfo.staffId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出差人员'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(8),
              // margin: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  InkWell(
                    onTap: () async {
                      if (BusinessSData.status < 10)
                        await showSearch(
                                context: context,
                                delegate: SearchStaffDelegate(
                                    Prefs.keyHistorySelectStaff))
                            .then((value) {
                          if (value == '' || value == null) return;
                          StaffModel staff =
                              StaffModel.fromJson(jsonDecode(value.toString()));
                          setState(() {
                            //如果更换人员,将循环更换原计划列表中人员的ID
                            // if (this.widget.empPlanId == null) {
                            //   if (_planList.length > 0) {
                            //     BusinessSData.businessPlanLine
                            //         .forEach((element) {
                            //       if (element.businessPlanEmpId ==
                            //           _empdata.staffId) {
                            //         element.businessPlanEmpId = staff.staffId;
                            //       }
                            //     });
                            //   }
                            //   _empdata.businessPlanEmpId = staff.staffId;
                            // }
                            if (this.widget.empPlanId == null)
                              _empdata.businessPlanEmpId =
                                  BusinessSData.curEmpId;
                            //更换人员
                            _empdata.staffId = staff.staffId;
                            _empdata.staffName = staff.name;
                            // _empdata.businessPlanEmpId = staff.staffId;
                          });
                        });
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Text('出差人员: '),
                          Expanded(child: Text(_empdata.staffName ?? '')),
                          if (BusinessSData.status < 10)
                            Icon(Icons.search, color: Colors.blue)
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: Row(
                      children: <Widget>[
                        _begin(),
                        _end(),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                padding: EdgeInsets.all(5),
                child: Column(
                  children: <Widget>[
                    _title(),
                    _listView(),
                  ],
                ),
              ),
            ),
            Row(
              children: <Widget>[customButtom(Colors.blue, '确定', _confirm)],
            )
          ],
        ),
      ),
    );
  }

  void _confirm() {
    String begin =
        Utils.dateTimeToStr(_empdata.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String end =
        Utils.dateTimeToStr(_empdata.endDate, pattern: 'yyyy-MM-dd HH:mm');
    if (_empdata.staffName == null) {
      DialogUtils.showToast('出差人员不能为空！');
    } else if (_empdata.beginDate.isAfter(_empdata.endDate)) {
      DialogUtils.showToast('开始时间不能大于结束时间!');
    } else if (begin == end) {
      DialogUtils.showToast('开始结束时间不能相等');
    } else if (_planList.length == 0) {
      DialogUtils.showToast('计划明细不能为空！');
    } else {
      if (_empdata.beginDate.isBefore(BusinessSData.beginData))
        BusinessSData.beginData = _empdata.beginDate;
      if (_empdata.endDate.isAfter(BusinessSData.endData))
        BusinessSData.endData = _empdata.endDate;
      if (this.widget.empPlanId == null) BusinessSData.empList.add(_empdata);
      Navigator.pop(context);
    }
  }

  Widget _begin() {
    String beginDate =
        Utils.dateTimeToStr(_empdata.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    return Expanded(
      child: Row(
        children: <Widget>[
          Text('开始: '),
          InkWell(
            onTap: () {
              if (BusinessSData.status < 10)
                _dateAndTimePick(_empdata.beginDate, 'begin');
            },
            child: customText(
              value: beginDate,
              color: Colors.blue,
              // fontWeight: FontWeight.w600
              backgroundColor: Color(0x80DFEEFC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _end() {
    String endDate =
        Utils.dateTimeToStr(_empdata.endDate, pattern: 'yyyy-MM-dd HH:mm');
    return Expanded(
      child: Row(
        children: <Widget>[
          Text('结束: '),
          InkWell(
              onTap: () {
                if (BusinessSData.status < 10)
                  _dateAndTimePick(_empdata.endDate, 'end');
              },
              child: customText(
                value: endDate,
                color: Colors.blue,
                // fontWeight: FontWeight.w600
                backgroundColor: Color(0x80DFEEFC),
              )),
        ],
      ),
    );
  }

  void _dateAndTimePick(DateTime date, String type) async {
    // var date = _detail.beginDate;
    var time = TimeOfDay.fromDateTime(date);
    var datePick = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: defaultFirstDate,
        lastDate: defaultLastDate);
    if (datePick == null) return;
    var timePick = await showTimePicker(context: context, initialTime: time);
    if (timePick == null) return;
    var result = DateTime(datePick.year, datePick.month, datePick.day,
        timePick.hour, timePick.minute);
    setState(() {
      type == 'begin' ? _empdata.beginDate = result : _empdata.endDate = result;
      print(datePick.toString());
      print(timePick.toString());
    });
  }

  Widget _title() {
    return Container(
      padding: EdgeInsets.all(BusinessSData.status < 10 ? 0 : 3),
      decoration: BoxDecoration(
          color: Colors.white, border: Border(bottom: BorderSide(width: 0.5))),
      child: Row(
        children: <Widget>[
          Expanded(child: customText(value: '计划列表', color: Colors.black)),
          if (BusinessSData.status < 10)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, businessPlanAddPath).then((value) {
                  if (value != null) {
                    BusinessPlanLine item = value;
                    item.businessPlanEmpId = _empdata.businessPlanEmpId;
                    item.businessPlanId = BusinessSData.planId;
                    _planList.add(item);
                    BusinessSData.businessPlanLine.add(item);
                    if (_empdata.beginDate.isAfter(item.beginDate))
                      _empdata.beginDate = item.beginDate;
                    if (_empdata.endDate.isBefore(item.endDate))
                      _empdata.endDate = item.endDate;
                  }

                  setState(() {});
                });
              },
              child: Container(
                // color: Colors.blue[50],
                padding: EdgeInsets.all(3),
                child: Icon(Icons.add, color: Colors.blue, size: 28),
              ),
            )
        ],
      ),
    );
  }

  Widget _listView() {
    return Expanded(
        child: Container(
      color: Colors.white,
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Slidable(
                actionPane: SlidableBehindActionPane(),
                secondaryActions: <Widget>[
                  IconSlideAction(
                    onTap: () {
                      if (BusinessSData.status < 10) {
                        setState(() {
                          var item = _planList[index];
                          _planList.remove(item);
                          BusinessSData.businessPlanLine.remove(item);
                        });
                      }
                    },
                    caption: '移除',
                    color: BusinessSData.status < 10 ? Colors.red : Colors.grey,
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                  )
                ],
                child: _item(index));
          },
          separatorBuilder: (context, index) {
            return Divider(height: 1);
          },
          itemCount: _planList.length),
    ));
  }

  Widget _item(int index) {
    BusinessPlanLine item = _planList[index];
    String begin =
        Utils.dateTimeToStr(item.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String end = Utils.dateTimeToStr(item.endDate, pattern: 'yyyy-MM-dd HH:mm');
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, businessPlanAddPath, arguments: item)
            .then((value) {
          BusinessPlanLine item = value;
          if (_empdata.beginDate.isAfter(item.beginDate))
            _empdata.beginDate = item.beginDate;
          if (_empdata.endDate.isBefore(item.endDate))
            _empdata.endDate = item.endDate;
          setState(() {});
        });
      },
      child: Container(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(2),
              child: Row(
                children: <Widget>[
                  Icon(Icons.access_time, color: Colors.blue, size: 17),
                  customText(value: '时间：' + begin, fontSize: 14),
                  customText(value: ' - ', color: Colors.blue, fontSize: 14),
                  customText(value: end, fontSize: 14),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(2),
              child: Row(
                children: <Widget>[
                  Icon(Icons.place, color: Colors.red, size: 17),
                  customText(value: '地点：' + item.address, fontSize: 14),
                  customText(value: '-' + item.vehicleKind, fontSize: 14)
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(2),
              child: Row(
                children: <Widget>[
                  Icon(Icons.business_center, color: Colors.blue, size: 17),
                  Expanded(
                      child:
                          customText(value: '计划：' + item.plan, fontSize: 14)),
                ],
              ),
            ),
            // Container(
            //   padding: EdgeInsets.all(2),
            //   child: Row(
            //     children: <Widget>[
            //       Icon(Icons.phone, color: Colors.blue, size: 17),
            //       customText(value: '电话：' + item.tel, fontSize: 14)
            //     ],
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
