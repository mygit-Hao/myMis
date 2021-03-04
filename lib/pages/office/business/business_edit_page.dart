import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/business.dart';
import 'package:mis_app/model/businessCard.dart';
import 'package:mis_app/model/businessClockRecords.dart';
import 'package:mis_app/model/businessReport.dart';
import 'package:mis_app/model/businessReportWrapper.dart';
import 'package:mis_app/model/bussinessPlan.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/business_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class BusinessEditPage extends StatefulWidget {
  final Map arguments;

  BusinessEditPage({this.arguments});
  @override
  _BusinessEditPageState createState() => _BusinessEditPageState();
}

class _BusinessEditPageState extends State<BusinessEditPage> {
  // String _businessReportyId = '';
  int _areaId = BusinessBaseDB.areaId;
  int _staffId = BusinessBaseDB.staffID;
  String _reportName = BusinessBaseDB.staffName;
  DateTime _selectedDate = DateTime.now();
  String _reportDate = Utils.dateTimeToStr(DateTime.now());

  PlaneLine _planLine;
  List<ClockRecords> _clockList = [];
  BusinessReportModel dataBusiness = new BusinessReportModel();
  String _cardTitle = '无打卡记录';
  final TextEditingController _reportTitle = TextEditingController();
  final TextEditingController _summary = TextEditingController();
  final TextEditingController _solution = TextEditingController();
  final TextEditingController _nextPlan = TextEditingController();
  final TextEditingController _thoughts = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (this.widget.arguments != null) {
      dataBusiness.onBusinessReportId =
          this.widget.arguments['onBusinessReportId'];
      _getDetail();
    }
  }

  _getDetail() async {
    var resposeJson = await businessDetail(dataBusiness.onBusinessReportId);
    BusinessReportWrapper businessReportWrapper =
        BusinessReportWrapper.fromJson(resposeJson);
    int errcode = businessReportWrapper.errCode;
    String errmsg = businessReportWrapper.errMsg;
    if (errcode > 0) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(errmsg)));
    } else {
      setState(() {
        _showDetail(businessReportWrapper);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('出差报告'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headerWidget, //地区
              _dateWidget, //日期
              _cardWidget, //打卡
              _titleWidget,
              _textWidgets("一、出差计划概述", _summary),
              _textWidgets("二、问题点和解决方案", _solution),
              _textWidgets("三、下一步工作计划", _nextPlan),
              _textWidgets("四、出差感想及收获", _thoughts),
              _saveWidget,
              _editWidget,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _headerWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('单号：'),
                Expanded(
                  child: Container(
                    height: ScreenUtil().setHeight(45.0),
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        dataBusiness.onBusinessReportId ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('项目：'),
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(
                      color: Colors.blue,
                      height: 0.0,
                    ),
                    value: _areaId,
                    items: generateItemList(),
                    onChanged: (item) {
                      setState(() {
                        _areaId = item;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem> generateItemList() {
    return BusinessBaseDB.areaList.map((Area item) {
      return DropdownMenuItem(
        child: Text(item.shortName),
        value: item.areaId,
      );
    }).toList();
  }

  Widget get _dateWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('报告人：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _reportName,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.blue),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _staffSelect(context);
                    }),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('日期：'),
                Expanded(
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        _selectDate();
                      },
                      child: Text(
                        _reportDate, // formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]),''
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // 初始日期
      firstDate: DateTime(1900), // 可选择的最早日期
      lastDate: DateTime(2100), // 可选择的最晚日期
    );
    if (date == null) return;

    setState(() {
      _selectedDate = date;
      _reportDate = Utils.dateTimeToStr(date);
    });
  }

  void _staffSelect(BuildContext context) async {
    var result = await showSearch(
        context: context,
        delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff));
    if (result == null || result == '') return;
    StaffModel staffModel = StaffModel.fromJson(jsonDecode(result));
    setState(() {
      if (result != null) {
        if (staffModel.staffId != _staffId) {
          DialogUtils.showConfirmDialog(context, '更换人员将清空出差计划单，是否继续？',
                  iconData: Icons.info, color: Colors.red)
              .then((value) {
            if (value) {
              setState(
                () {
                  _staffId = staffModel.staffId;
                  _reportName = staffModel.name;
                  dataBusiness.planId = "";
                  dataBusiness.planDid = "";
                  _clockList = [];
                  _reportTitle.text = "";
                  _summary.text = "";
                  _cardTitle = '无打卡记录';
                },
              );
            }
          });
        }
      }
    });
  }

  Widget get _cardWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: Row(
        children: <Widget>[
          Text('出差计划单：'),
          Expanded(
            flex: 2,
            child: Container(
              child: Text(
                dataBusiness.planId ?? '',
                textAlign: TextAlign.center,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _planSelect(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 10.0, 0),
            child: RaisedButton(
              color: Colors.orangeAccent,
              colorBrightness: Brightness.dark,
              splashColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Text(_cardTitle),
              onPressed: () {
                Navigator.pushNamed(context, businessCardPath,
                    arguments: _clockList);
              },
            ),
          ),
        ],
      ),
    );
  }

  _planSelect(BuildContext context) async {
    await Navigator.pushNamed(context, businessPlanPath,
        arguments: {'staffId': _staffId}).then(
      (val) {
        if (val != null) {
          BusinessPlanModel item = val;
          dataBusiness.planId = item.planId;
          dataBusiness.planDid = item.planDid;
          _reportTitle.text = item.reason;
          if (dataBusiness.planDid != null) {
            getCard();
          }
        }
      },
    );
  }

  Widget get _titleWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
            child: Text('标题：'),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: ScreenUtil().setHeight(50),
              child: TextField(
                controller: _reportTitle,
                autofocus: false,
                maxLines: 1,
                // decoration: InputDecoration(contentPadding: EdgeInsets.only(bottom:1),),
                style: TextStyle(color: Colors.red),
                // decoration: InputDecoration(
                //   fillColor: Colors.blue,
                //   filled: true,
                // ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _textWidgets(title, controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          //Padding(padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0)),
          Text(
            title,
            style: TextStyle(
              color: Colors.lightBlue,
            ),
          ),
          TextField(
            controller: controller,
            autofocus: false,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget get _saveWidget {
    if (dataBusiness.onBusinessReportId != null) {
      return SizedBox(height: 0);
    }
    return Container(
      padding: EdgeInsets.all(10.0),
      width: double.infinity,
      child: RaisedButton(
        color: Colors.green,
        colorBrightness: Brightness.dark,
        splashColor: Colors.blue,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        child: Text('保存'),
        onPressed: () async {
          if (dataBusiness.planId == "" ||
              _reportTitle.text == "" ||
              _summary.text == "" ||
              _solution.text == "" ||
              _nextPlan.text == "" ||
              _thoughts.text == "") {
            _showErrMsg();
            return;
          }
          setPageDataChanged(this.widget, true);
          getData("add");
        },
      ),
    );
  }

  Widget get _editWidget {
    if (dataBusiness.onBusinessReportId == null) {
      return SizedBox(height: 0);
    }
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(50.0, 0, 30.0, 0),
              // child: Expanded(
              child: RaisedButton(
                color: Colors.red,
                colorBrightness: Brightness.dark,
                splashColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Text('删除'),
                onPressed: () {
                  DialogUtils.showConfirmDialog(context, '您是否要删除？',
                          iconData: Icons.info, color: Colors.red)
                      .then((value) async {
                    if (value) {
                      setPageDataChanged(this.widget, true);
                      var resposeJson = await businessDel(
                          context, dataBusiness.onBusinessReportId);
                      setState(
                        () {
                          BusinessReportWrapper businessSave =
                              BusinessReportWrapper.fromJson(resposeJson);
                          int errcode = businessSave.errCode;
                          String errmsg = businessSave.errMsg;
                          if (errcode > 0) {
                            showDialog(
                                context: context,
                                builder: (context) =>
                                    AlertDialog(title: Text(errmsg)));
                          } else {
                            _toastInfo('删除成功');
                            Navigator.pop(context);
                          }
                        },
                      );
                    }
                  });
                },
              ),
              // ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(30.0, 0, 50.0, 0),
              // child: Expanded(
              child: RaisedButton(
                color: Colors.green,
                colorBrightness: Brightness.dark,
                splashColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Text('保存'),
                onPressed: () {
                  if (dataBusiness.planId == "" ||
                      _reportTitle.text == "" ||
                      _summary.text == "" ||
                      _solution.text == "" ||
                      _nextPlan.text == "" ||
                      _thoughts.text == "") {
                    _showErrMsg();
                    return;
                  }
                  setPageDataChanged(this.widget, true);
                  getData("update");
                },
              ),
              // ),
            ),
          ),
        ],
      ),
    );
  }

  void _toastInfo(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showErrMsg() {
    String msg;
    if (dataBusiness.planId == "") {
      msg = "出差计划单不能为空！";
    } else if (_reportTitle.text == "") {
      msg = "报告标题不能为空！";
    } else if (_summary.text == "") {
      msg = "出差计划概述不能为空！";
    } else if (_solution.text == "") {
      msg = "问题点和解决方案不能为空！";
    } else if (_nextPlan.text == "") {
      msg = "下一步计划不能为空!";
    } else if (_thoughts.text == "") {
      msg = "出差感想和收获不能为空!";
    }
    _toastInfo(msg);
  }

  void getCard() async {
    var resposeJson = await businessCard(
        dataBusiness.planId, _staffId, _summary.text, _cardTitle);
    setState(
      () {
        BusinessCardModel card = BusinessCardModel.fromJson(resposeJson);
        _planLine = card.planeLine;
        _clockList = card.clockRecords;

        _summary.text = _planLine.plan;
        if (_clockList.length > 0) {
          _cardTitle = _clockList.length.toString() + '条打卡记录';
        } else {
          _cardTitle = '无打卡记录';
        }
      },
    );
  }

  Future<void> getData(String action) async {
    dataBusiness.areaId = _areaId;
    dataBusiness.reporterId = _staffId.toString();
    dataBusiness.reportDate = _selectedDate;
    _reportDate = Utils.dateTimeToStr(_selectedDate);
    dataBusiness.reportTitle = _reportTitle.text;
    dataBusiness.summary = _summary.text;
    dataBusiness.solution = _solution.text;
    dataBusiness.nextPlan = _nextPlan.text;
    dataBusiness.thoughts = _thoughts.text;

    BusinessReportWrapper businessReportWrapper = await businessSave(
      context: context,
      action: action,
      dataBusiness: dataBusiness,
    );

    int errcode = businessReportWrapper.errCode;
    String errmsg = businessReportWrapper.errMsg;
    if (errcode > 0) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(errmsg)));
    } else {
      setState(
        () {
          _toastInfo('保存成功');
          _showDetail(businessReportWrapper);
        },
      );
    }
  }

  void _showDetail(BusinessReportWrapper businessReportWrapper) {
    dataBusiness = businessReportWrapper.businessReportModel;
    _clockList = businessReportWrapper.clockRecords;

    _areaId = dataBusiness.areaId;
    _staffId = int.parse(dataBusiness.reporterId);
    _reportName = dataBusiness.reporterName;
    _selectedDate = dataBusiness.reportDate;
    _reportDate = Utils.dateTimeToStr(_selectedDate);
    _reportTitle.text = dataBusiness.reportTitle;
    _summary.text = dataBusiness.summary;
    _solution.text = dataBusiness.solution;
    _nextPlan.text = dataBusiness.nextPlan;
    _thoughts.text = dataBusiness.thoughts;
    if (_clockList.length > 0) {
      _cardTitle = _clockList.length.toString() + '条打卡记录';
    } else {
      _cardTitle = '无打卡记录';
    }
  }
}
