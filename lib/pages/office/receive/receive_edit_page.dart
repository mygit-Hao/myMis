import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/download_result.dart';
import 'package:mis_app/model/receive.dart';
import 'package:mis_app/model/receiveBase.dart';
import 'package:mis_app/model/receiveWrapper.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/receive_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ReceiveEditPage extends StatefulWidget {
  final Map arguments;

  ReceiveEditPage({this.arguments});
  @override
  _ReceiveEditPageState createState() => _ReceiveEditPageState();
}

class _ReceiveEditPageState extends State<ReceiveEditPage> {
  TextStyle _textStyle = TextStyle(fontSize: 15.5);
  ReceiveList _dataReceive = new ReceiveList();
  List<ReceiveDetail> _detail = [];
  List<ReceiveRoom> _roomList = [];
  List<Attachment> _attachementList = [];
  final TextEditingController _quality = TextEditingController();
  final TextEditingController _dinner = TextEditingController();
  final TextEditingController _tavern = TextEditingController();
  final TextEditingController _other = TextEditingController();
  final TextEditingController _dinnerMoney = TextEditingController();
  final TextEditingController _tavernMoney = TextEditingController();
  final TextEditingController _otherMoney = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  ProgressDialog _progressDialog;
  // int _areaId = ReceiveBaseDB.areaId;
  // int _staffId = ReceiveBaseDB.staffID;
  // String _reportName = ReceiveBaseDB.staffName;
  // DateTime _selectedDate = DateTime.now();
  // String _receiveDate = Utils.dateTimeToStr(DateTime.now());
  final TextEditingController _code = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _posi = TextEditingController();
  final TextEditingController _dept = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  // int _qualityValue;
  // int _standardValue;
  // int _dinnerValue;
  // int _tavernValue;
  int _man;
  int _madam;
  int _oneRoom;
  int _twoRoom;
  int _luxuryOneRoom;
  int _luxuryTwoRoom;
  // int _cigarettes;
  // int _fruit;
  // int _gift;
  // int _otherExist;
  bool _checkDinner = false;
  bool _checkTavern = false;
  bool _checkCigarettes = false;
  bool _checkFruit = false;
  bool _checkGift = false;
  bool _checkOther = false;
  String _genderName;
  int _sexCode;

  @override
  void initState() {
    super.initState();
    _getDefaltData();
    if (this.widget.arguments != null) {
      _dataReceive.receiveId = this.widget.arguments['receiveId'];
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _getDetail();
      });
    }
  }

  void _getDefaltData() {
    _dataReceive.status = 0;
    _dataReceive.statusName = '草稿';
    // _dataReceive.areaId = _areaId;
    // _dataReceive.requestStaffId = _staffId;
    // _dataReceive.requestStaffName = _reportName;
    _dataReceive.requestDeptName = ReceiveBaseDB.deptName;
    _dataReceive.currency = "RMB";
    _dataReceive.applyDate = Utils.today;
    _dataReceive.totalMoney = 0;
    _dataReceive.manAmount = 0;
    _dataReceive.madamAmount = 0;
    _dataReceive.tavernValue = 0;
    _dataReceive.qualityValue = 0;
    _dataReceive.standardValue = 0;
    _dataReceive.dinnerValue = 0;
    // _qualityValue = 0;
    // _standardValue = 0;
    // _dinnerValue = 0;
    // _tavernValue = 0;
    _man = 0;
    _madam = 0;
    _oneRoom = 0;
    _twoRoom = 0;
    _luxuryOneRoom = 0;
    _luxuryTwoRoom = 0;
    _dataReceive.cigarettes = 0;
    _dataReceive.fruit = 0;
    _dataReceive.gift = 0;
    _dataReceive.other = 0;
    _dataReceive.areaId = ReceiveBaseDB.areaId;
    _dataReceive.requestStaffId = ReceiveBaseDB.staffID;
    _dataReceive.requestStaffName = ReceiveBaseDB.staffName;
  }

  _getDetail() async {
    var resposeJson = await receiveDetail(_dataReceive.receiveId);
    ReceiveWrapper receiveWrapper = ReceiveWrapper.fromJson(resposeJson);
    int errcode = receiveWrapper.errCode;
    String errmsg = receiveWrapper.errMsg;
    if (errcode > 0) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(title: Text(errmsg)));
    } else {
      setState(() {
        _showDetail(receiveWrapper);
      });
    }
  }

  void _showDetail(ReceiveWrapper receiveWrapper) {
    _dataReceive = receiveWrapper.receiveList;
    _detail = receiveWrapper.detail;
    _roomList = receiveWrapper.room;
    _attachementList = receiveWrapper.attachment;
    // _personList = receiveWrapper.personList;

    // _areaId = _dataReceive.areaId;
    // _staffId = _dataReceive.requestStaffId;
    // _reportName = _dataReceive.requestStaffName;
    _man = _dataReceive.manAmount;
    _madam = _dataReceive.madamAmount;
    // _selectedDate = _dataReceive.applyDate;
    // _receiveDate = Utils.dateTimeToStr(_dataReceive.applyDate);
    if (_dataReceive.qualityValue == 3) {
      _quality.text = _dataReceive.receiveQuality;
    }
    if (_dataReceive.dinnerValue != 0) {
      _checkDinner = true;
      _dinner.text = _dataReceive.dinnerStandard;
    }
    if (_dataReceive.tavernValue != 0) {
      _checkTavern = true;
      _tavern.text = _dataReceive.tavernStandard;
    }
    if (_dataReceive.cigarettes != 0) {
      _checkCigarettes = true;
    }
    if (_dataReceive.fruit != 0) {
      _checkFruit = true;
    }
    if (_dataReceive.gift != 0) {
      _checkGift = true;
    }
    if (_dataReceive.other != 0) {
      _checkOther = true;
      _dataReceive.other = 1;
      _other.text = _dataReceive.otherOption;
    }
    _dinnerMoney.text = _dataReceive.dinnerMoney.toString();
    _tavernMoney.text = _dataReceive.tavernMoney.toString();
    _otherMoney.text = _dataReceive.otherMoney.toString();
    _reason.text = _dataReceive.reason;
    _roomTypeAmount();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('招待申请'),
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Expanded(
                      child: SingleChildScrollView(
                        child: AbsorbPointer(
                          absorbing: _dataReceive.statusName != '草稿',
                          child: Column(
                            children: <Widget>[
                              _headerWidget(),
                              _areaWidget(),
                              _nameWidget(),
                              Container(height: 3),
                              _qualityWidget(),
                              Container(height: 3),
                              _standardWidget(),
                              Container(height: 3),
                              _dinnerWidget(),
                              Container(height: 3),
                              _tavernWidget(),
                              _otherWidget(),
                              _moneyWidget(),
                              _currencyWidget(),
                              _reasonWidget("招待事由：", _reason),
                              _attachementList.length == 0 &&
                                      _dataReceive.statusName != '草稿'
                                  ? Text('')
                                  : _attachementWidget(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: ScreenUtil().setHeight(400),
                    child: Column(
                      children: <Widget>[
                        AbsorbPointer(
                            absorbing: _dataReceive.statusName != '草稿',
                            child: _btaddWidget()),
                        Expanded(child: _staffWidget()),
                        _dataReceive.statusName == '草稿'
                            ? _draftButtons()
                            : (_dataReceive.statusName == '提交'
                                ? _submitButtons()
                                : Text('')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
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
                        _dataReceive.receiveCode ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('状态：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataReceive.statusName ?? '草稿',
                      textAlign: TextAlign.center,
                      style:
                          statusNameTextStyle(_dataReceive.statusName ?? '草稿'),
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

  Widget _areaWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
      child: Row(
        children: <Widget>[
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
                    value: _dataReceive.areaId,
                    items: generateItemList(),
                    onChanged: (item) {
                      Utils.closeInput(context);
                      setState(() {
                        _dataReceive.areaId = item;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('日期：'),
                Expanded(
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        Utils.closeInput(context);
                        _selectDate();
                      },
                      child: Text(
                        Utils.dateTimeToStr(_dataReceive.applyDate),
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

  Widget _nameWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('申请人：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataReceive.requestStaffName ?? "",
                      textAlign: TextAlign.center,
                      // style: TextStyle(color: Colors.blue),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Utils.closeInput(context);
                    showSearch(
                            context: context,
                            delegate:
                                SearchStaffDelegate(Prefs.keyHistorySelectDept))
                        .then((value) {
                      if (value == null) return;
                      var data = jsonDecode(value);
                      StaffModel staffModel = StaffModel.fromJson(data);
                      setState(() {
                        _dataReceive.requestStaffId = staffModel.staffId;
                        _dataReceive.requestStaffName = staffModel.name;
                        _dataReceive.requestDeptName = staffModel.deptName;
                      });
                    });
                  },
                  child: Icon(
                    Icons.search,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('部门：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataReceive.requestDeptName ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 1,
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

  Widget _qualityWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
        decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.blue),
          // color: Colors.lightBlue,
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('招待性质：'),
            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 1,
                      groupValue: _dataReceive.qualityValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _quality.text = "";
                          _dataReceive.qualityValue = value;
                        });
                      },
                    ),
                  ),
                  Text('营业性质'),
                  SizedBox(width: 20),
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 2,
                      groupValue: _dataReceive.qualityValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _quality.text = "";
                          _dataReceive.qualityValue = value;
                        });
                      },
                    ),
                  ),
                  Text('非营业性质'),
                  SizedBox(width: 20),
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 3,
                      groupValue: _dataReceive.qualityValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _dataReceive.qualityValue = value;
                        });
                      },
                    ),
                  ),
                  Text('其他'),
                ],
              ),
            ),
            if (_dataReceive.qualityValue == 3)
              Row(
                children: <Widget>[
                  Text('其他性质名称：'),
                  Expanded(child: _customtextField(_quality)),
                ],
              ),
          ],
        ));
  }

  Widget _standardWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
        decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.blue),
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('招待标准：'),
            // SizedBox(height: 8),
            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 1,
                      groupValue: _dataReceive.standardValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _dataReceive.standardValue = value;
                        });
                      },
                    ),
                  ),
                  Text('支出标准内'),
                  SizedBox(width: 20),
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 2,
                      groupValue: _dataReceive.standardValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() {
                          _dataReceive.standardValue = value;
                        });
                      },
                    ),
                  ),
                  Text('支出标准外'),
                ],
              ),
            ),
            SizedBox(height: 6),
          ],
        ));
  }

  Widget _dinnerWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 3, 5.0, 3),
        decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.blue),
          // color: Colors.lightBlue,
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                      value: _checkDinner,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() {
                          this._checkDinner = !this._checkDinner;
                          if (!_checkDinner) {
                            _dataReceive.dinnerValue = 0;
                            _dinner.text = "";
                          }
                        });
                      }),
                ),
                Text('用餐标准：'),
              ],
            ),
            // SizedBox(height: 8),
            Container(
              margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 1,
                      groupValue: _dataReceive.dinnerValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        if (_checkDinner) {
                          setState(() {
                            _dataReceive.dinnerValue = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text('签约酒店'),
                  SizedBox(width: 20),
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 2,
                      groupValue: _dataReceive.dinnerValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        if (_checkDinner) {
                          setState(() {
                            _dataReceive.dinnerValue = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text('非签约酒店'),
                  SizedBox(width: 20),
                  Container(
                    width: 20,
                    height: 20,
                    child: Radio(
                      value: 3,
                      groupValue: _dataReceive.dinnerValue,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        if (_checkDinner) {
                          setState(() {
                            _dataReceive.dinnerValue = value;
                          });
                        }
                      },
                    ),
                  ),
                  Text('厂内餐厅'),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text('酒店名称：'),
                if (_dataReceive.dinnerValue != 0)
                  Expanded(child: _customtextField(_dinner)),
              ],
            ),
          ],
        ));
  }

  Widget _tavernWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
        decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.blue),
          // color: Colors.lightBlue,
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                      value: _checkTavern,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() {
                          this._checkTavern = !this._checkTavern;
                          if (!_checkTavern) {
                            _dataReceive.tavernValue = 0;
                            _tavern.text = "";
                            _roomList.clear();
                            _roomTypeAmount();
                          }
                        });
                      }),
                ),
                Text('住宿标准：'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  child: Radio(
                    value: 1,
                    groupValue: _dataReceive.tavernValue,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      if (_checkTavern) {
                        setState(() {
                          _dataReceive.tavernValue = value;
                        });
                      }
                    },
                  ),
                ),
                Text('签约酒店'),
                SizedBox(width: 20),
                Container(
                  width: 20,
                  height: 20,
                  child: Radio(
                    value: 2,
                    groupValue: _dataReceive.tavernValue,
                    activeColor: Colors.red,
                    onChanged: (value) {
                      if (_checkTavern) {
                        setState(() {
                          _dataReceive.tavernValue = value;
                        });
                      }
                    },
                  ),
                ),
                Text('非签约酒店'),
              ],
            ),
            Row(
              children: <Widget>[
                Text('酒店名称：'),
                if (_dataReceive.tavernValue != 0)
                  Expanded(child: _customtextField(_tavern)),
              ],
            ),
            Row(
              children: <Widget>[
                Text('间数  标单:' +
                    _oneRoom.toString() +
                    ' 标双:' +
                    _twoRoom.toString() +
                    ' 豪单:' +
                    _luxuryOneRoom.toString() +
                    ' 豪双:' +
                    _luxuryTwoRoom.toString()),
                SizedBox(width: 25),
                FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Colors.yellow,
                  onPressed: () async {
                    Utils.closeInput(context);
                    if (_dataReceive.tavernValue != 0) {
                      bool dataChanged = await navigatePage(
                          context, receiveRoomPath, arguments: {
                        'roomList': _roomList,
                        'statusId': _dataReceive.statusName
                      });
                      if (dataChanged)
                        setState(() {
                          _roomTypeAmount();
                        });
                    }
                  },
                  child: Text(
                    "房间明细",
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  Widget _otherWidget() {
    return Container(
        margin: EdgeInsets.only(top: 3),
        padding: EdgeInsets.fromLTRB(5.0, 3, 5.0, 3),
        decoration: new BoxDecoration(
          border: new Border.all(width: 1.0, color: Colors.blue),
          borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('其他招待：'),
            Row(
              children: <Widget>[
                Container(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                      value: _checkCigarettes,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() {
                          this._checkCigarettes = !this._checkCigarettes;
                          if (!_checkCigarettes) {
                            _dataReceive.cigarettes = 0;
                          } else {
                            _dataReceive.cigarettes = 1;
                          }
                        });
                      }),
                ),
                Text('烟酒'),
                SizedBox(width: 20),
                Container(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                      value: _checkFruit,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() {
                          this._checkFruit = !this._checkFruit;
                          if (!_checkFruit) {
                            _dataReceive.fruit = 0;
                          } else {
                            _dataReceive.fruit = 1;
                          }
                        });
                      }),
                ),
                Text('水果'),
                SizedBox(width: 20),
                Container(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                      value: _checkGift,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() {
                          this._checkGift = !this._checkGift;
                          if (!_checkGift) {
                            _dataReceive.gift = 0;
                          } else {
                            _dataReceive.gift = 1;
                          }
                        });
                      }),
                ),
                Text('礼品'),
                SizedBox(width: 20),
                Container(
                  width: 20,
                  height: 20,
                  child: Checkbox(
                      value: _checkOther,
                      activeColor: Colors.blue,
                      onChanged: (val) {
                        setState(() {
                          this._checkOther = !this._checkOther;
                          if (!_checkOther) {
                            _dataReceive.other = 0;
                            _other.text = "";
                          } else {
                            _dataReceive.other = 1;
                          }
                        });
                      }),
                ),
                Text('其他'),
                SizedBox(width: 6),
                if (_dataReceive.other == 1)
                  Expanded(child: _customtextField(_other)),
              ],
            ),
          ],
        ));
  }

  Widget _moneyWidget() {
    return Container(
        padding: EdgeInsets.fromLTRB(5.0, 10, 5.0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 0),
              child: Text('餐费：'),
            ),
            Expanded(child: _customtextNumber(_dinnerMoney, true)),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 0),
              child: Text('住宿费：'),
            ),
            Expanded(child: _customtextNumber(_tavernMoney, false)),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4.0, 0, 0),
              child: Text('其他：'),
            ),
            Expanded(child: _customtextNumber(_otherMoney, true)),
          ],
        ));
  }

  Widget _currencyWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
            child: Text('币种：'),
          ),
          Expanded(
            child: DropdownButton(
              isExpanded: true,
              underline: Container(
                color: Colors.blue,
              ),
              value: _dataReceive.currency,
              items: getCurrencyList(),
              onChanged: (item) {
                Utils.closeInput(context);
                setState(() {
                  _dataReceive.currency = item;
                });
              },
            ),
          ),
          SizedBox(width: 20),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 10.0, 0),
            child: Text('总费用：${Utils.getFormatNum(_dataReceive.totalMoney)}'),
          )),
        ],
      ),
    );
  }

  Widget _reasonWidget(reason, controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 8.0, 5.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(reason),
          TextField(
            controller: controller,
            autofocus: false,
            maxLines: 2,
            style: TextStyle(fontSize: 15.5),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(hintText: '请输入招待事由'),
          ),
        ],
      ),
    );
  }

  Widget _attachementWidget() {
    return Container(
      child: Card(
        elevation: 0.0,
        color: Colors.grey[100],
        margin: EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.all(5),
          child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemCount: _dataReceive.statusName == '草稿'
                  ? _attachementList.length + 1
                  : _attachementList.length,
              itemBuilder: (context, index) {
                return _itemPhote(index);
              }),
        ),
      ),
    );
  }

  Widget _itemPhote(int index) {
    return (index < _attachementList.length)
        ? Stack(fit: StackFit.expand, children: [
            InkWell(
                onTap: () {
                  Utils.closeInput(context);
                  _attachementList[index].fileType == 'Photo'
                      ? Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                          return ViewPhoto(
                              Utils.getImageUrl(_attachementList[index].fileId),
                              _attachementList[index].file);
                        }))
                      : _viewAttachment(_attachementList[index]);
                },
                child: _attachementList[index].fileType == 'Photo'
                    ? Image.network(
                        Utils.getImageUrl(_attachementList[index].fileId),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 40,
                            ),
                            customText(value: _attachementList[index].fileName),
                          ],
                        ),
                      )),
            _dataReceive.statusName == '草稿'
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                        onTap: () {
                          _deleteAttachement(index);
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        )),
                  )
                : Container()
          ])
        : Container(
            color: Colors.grey[200],
            child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                    context: context,
                    builder: (context) {
                      return Container(
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  _addAttachement('camera');
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('拍照')),
                                    padding: EdgeInsets.only(bottom: 8)),
                              ),
                              InkWell(
                                onTap: () async {
                                  _addAttachement('photo');
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('相册')),
                                    padding: EdgeInsets.all(8)),
                              ),
                              InkWell(
                                onTap: () async {
                                  _addAttachement('PDF');
                                },
                                child: Container(
                                    width: ScreenUtil().setWidth(700),
                                    child: Center(child: Text('PDF文件')),
                                    padding: EdgeInsets.only(top: 8)),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Icon(Icons.add, color: Colors.grey[400], size: 40),
            ),
          );
  }

  void _viewAttachment(Attachment attachment) async {
    DownloadResultModel result = await downloadAttachmentWithFileExt(
        attachment.fileId, attachment.fileExt);
    if (result.success) {
      viewFile(context,
          storageFilePath: result.storageFilePath,
          filePath: attachment.fileName,
          title: attachment.remarks);
    } else {
      DialogUtils.showToast('附件下载失败');
    }
  }

  void _addAttachement(String type) async {
    bool isSaved = true;
    Utils.closeInput(context);
    if (_dataReceive.receiveId == null) isSaved = await _save();
    if (isSaved == null || isSaved == false) return;
    switch (type) {
      case 'camera':
        var imageFile = await Utils.takePhote();
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'photo':
        var imageFile = await Utils.takePhote(fromPhote: true);
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'PDF':
        var fileList = await Utils.selectFile();
        if (fileList != null) {
          fileList.forEach((element) {
            _uploadFile(element.path);
          });
        }
        break;
      default:
    }
  }

  void _uploadFile(filePath) async {
    await _progressDialog?.show();
    try {
      await upload(_dataReceive.receiveId, filePath).then((value) async {
        if (value.errCode == 0) {
          await _progressDialog?.hide();
          toastBlackStyle('上传成功!');
          _attachementList = value.attachment;
          setState(() {});
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg,
              iconData: Icons.info, color: Colors.red);
        }
      });
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _deleteAttachement(int index) async {
    bool result = await DialogUtils.showConfirmDialog(context, '是否删除该附件？',
        iconData: Icons.info, color: Colors.red);
    if (result) {
      String fileId = _attachementList[index].receiveFileId;
      await attachementDelete(_dataReceive.receiveId, fileId).then((value) {
        if (value.errCode == 0) {
          _attachementList.removeAt(index);
          toastBlackStyle('删除成功!');
          setState(() {});
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg);
        }
      });
    }
  }

  Widget _btaddWidget() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Row(
        children: <Widget>[
          FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.yellow,
            onPressed: () {
              Utils.closeInput(context);
              _selectUser();
            },
            child: Text(
              "集团人员",
            ),
          ),
          SizedBox(width: 20),
          FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.yellow,
            onPressed: () {
              Utils.closeInput(context);
              ReceiveDetail receiveDetail = ReceiveDetail();
              _genderName = '男';
              _sexCode = 0;
              _dept.text = '非本集团人员';
              showStaffDialog(context, receiveDetail, 0);
            },
            child: Text(
              "非集团人员",
            ),
          ),
          SizedBox(width: 25),
          Text('总计男:' + _man.toString() + ' 女:' + _madam.toString()),
        ],
      ),
    );
  }

  Widget _draftButtons() {
    bool visible = _dataReceive.receiveId == null ? false : true;
    return Container(
      height: ScreenUtil().setWidth(100),
      child: Row(
        children: <Widget>[
          if (visible) customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
          customButtom(Colors.green, '提交', _submit),
        ],
      ),
    );
  }

  Widget _submitButtons() {
    return Container(
      height: ScreenUtil().setWidth(100),
      child: Row(
        children: <Widget>[
          customButtom(Colors.orange[300], '取消提交', _toDraft),
        ],
      ),
    );
  }

  Widget _customtextField(TextEditingController _controller) {
    return Container(
      height: 30,
      child: TextField(
        maxLines: 1,
        style: _textStyle,
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(1),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _customName(TextEditingController _controller) {
    return Container(
      height: 30,
      child: TextField(
        maxLines: 1,
        style: _textStyle,
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(1),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onChanged: (val) {
          for (int i = 0; i < ReceiveBaseDB.receivePerson.length; i++) {
            if (_name.text == ReceiveBaseDB.receivePerson[i].personName) {
              _phone.text = ReceiveBaseDB.receivePerson[i].phone;
              break;
            }
          }
          setState(() {});
        },
      ),
    );
  }

  Widget _customtextCode(TextEditingController _controller) {
    return Container(
      height: 30,
      child: TextField(
        maxLines: 1,
        style: _textStyle,
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(1),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
          hintText: '(选填)',
        ),
      ),
    );
  }

  Widget _customdept(TextEditingController _controller) {
    return Container(
      height: 30,
      child: TextField(
        enabled: false,
        maxLines: 1,
        // textAlign: TextAlign.center,
        style: _textStyle,
        controller: _controller,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(1),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  Widget _staffWidget() {
    return Container(
        child: ListView.separated(
      shrinkWrap: true,
      itemCount: _detail.length,
      itemBuilder: (context, index) {
        ReceiveDetail item = _detail[index];
        return InkWell(
          onTap: () {
            Utils.closeInput(context);
            _code.text = item.staffCode.toString();
            _name.text = item.staffName.toString();
            _dept.text = item.deptName.toString();
            _posi.text = item.posi.toString();
            _phone.text = item.phone.toString();
            _genderName = item.gender;
            _sexCode = item.sexCode;
            showStaffDialog(context, item, 1);
          },
          child: Container(
              padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(child: Text(item.staffCode), flex: 2),
                    Expanded(child: Text(item.staffName), flex: 2),
                    Expanded(child: Text(item.deptName), flex: 3),
                  ]),
                  Row(children: <Widget>[
                    Expanded(child: Text(item.posi), flex: 2),
                    _dataReceive.statusName == '草稿'
                        ? SizedBox(width: 10)
                        : SizedBox(width: 0),
                    Expanded(child: Text(item.gender), flex: 2),
                    // SizedBox(width: 10),
                    Expanded(child: Text(item.phone), flex: 3),
                    _dataReceive.statusName == '草稿'
                        ? InkWell(
                            onTap: () async {
                              bool result = await DialogUtils.showConfirmDialog(
                                  context, "是否移除该人员？",
                                  iconData: Icons.info, color: Colors.red);
                              setState(() {
                                if (result == true) {
                                  _detail.removeAt(index);
                                  _staffAmount();
                                }
                              });
                            },
                            child: Icon(Icons.clear, color: Colors.red),
                          )
                        : Container(),
                  ]),
                ],
              )),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(height: 1);
      },
    ));
  }

  Widget _customtextNumber(TextEditingController _controller, bool edit) {
    return Container(
      height: 30,
      child: TextField(
        enabled: edit,
        maxLines: 1,
        textAlign: TextAlign.center,
        style: _textStyle,
        controller: _controller,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(1),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onChanged: (val) {
          _dataReceive.totalMoney = double.parse(
                  _dinnerMoney.text == '' ? "0" : _dinnerMoney.text) +
              double.parse(_tavernMoney.text == '' ? "0" : _tavernMoney.text) +
              double.parse(_otherMoney.text == '' ? "0" : _otherMoney.text);
          setState(() {});
        },
      ),
    );
  }

  Widget _customPhone(TextEditingController _controller) {
    return Container(
      height: 30,
      child: TextField(
        maxLines: 1,
        style: _textStyle,
        controller: _controller,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp("[0-9./]"))],
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: true,
          contentPadding: EdgeInsets.all(1),
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem> generateItemList() {
    var result = ReceiveBaseDB.areaList.map((Area item) {
      return DropdownMenuItem(
        child: Text(item.shortName),
        value: item.areaId,
      );
    }).toList();

    return result;
  }

  List<DropdownMenuItem> getCurrencyList() {
    var result = ReceiveBaseDB.currencyList.map((Currency item) {
      return DropdownMenuItem(
        child: Text(item.currencyName),
        value: item.currencyCode,
      );
    }).toList();

    return result;
  }

  void _roomTypeAmount() {
    double _tavern = 0;
    _oneRoom = 0;
    _twoRoom = 0;
    _luxuryOneRoom = 0;
    _luxuryTwoRoom = 0;
    for (int i = 0; i < _roomList.length; i++) {
      if (_roomList[i].roomTypeName == "标准单人房") {
        _oneRoom++;
      }
      if (_roomList[i].roomTypeName == "标准双人房") {
        _twoRoom++;
      }
      if (_roomList[i].roomTypeName == "豪华单人房") {
        _luxuryOneRoom++;
      }
      if (_roomList[i].roomTypeName == "豪华双人房") {
        _luxuryTwoRoom++;
      }
      _tavern += _roomList[i].roomMoney;
    }
    _tavernMoney.text = _tavern.toString();
    _dataReceive.totalMoney =
        double.parse(_dinnerMoney.text == '' ? "0" : _dinnerMoney.text) +
            double.parse(_tavernMoney.text == '' ? "0" : _tavernMoney.text) +
            double.parse(_otherMoney.text == '' ? "0" : _otherMoney.text);
  }

  void _staffAmount() {
    _man = 0;
    _madam = 0;
    for (int i = 0; i < _detail.length; i++) {
      if (_detail[i].gender == "男") {
        _man++;
      }
      if (_detail[i].gender == "女") {
        _madam++;
      }
    }
    _dataReceive.manAmount = _man;
    _dataReceive.madamAmount = _madam;
  }

  Future<void> _selectDate() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _dataReceive.applyDate, // 初始日期
      firstDate: DateTime(1900), // 可选择的最早日期
      lastDate: DateTime(2100), // 可选择的最晚日期
    );
    if (date == null) return;

    setState(() {
      _dataReceive.applyDate = date;
    });
  }

  Future<void> showStaffDialog(
      BuildContext context, ReceiveDetail receiveStaff, int isEdit) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (contexts, mSetState) {
            return AlertDialog(
              title: Text('人员信息详细'),
              content: Container(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AbsorbPointer(
                        absorbing: receiveStaff.staffId != null,
                        child: Row(
                          children: [
                            Text('工号：'),
                            Expanded(
                              child: _customtextCode(_code),
                            ),
                            SizedBox(width: 6),
                            Text('姓名：'),
                            Expanded(
                              child: _customName(_name),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      AbsorbPointer(
                        absorbing: receiveStaff.staffId != null,
                        child: Row(
                          children: <Widget>[
                            Text('性别：'),
                            Container(
                              width: 20,
                              height: 20,
                              child: Radio(
                                value: '男',
                                groupValue: _genderName,
                                activeColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    (context as Element).markNeedsBuild();
                                    _genderName = value;
                                    _sexCode = 0;
                                  });
                                },
                              ),
                            ),
                            Text('男'),
                            SizedBox(width: 20),
                            Container(
                              width: 20,
                              height: 20,
                              child: Radio(
                                value: '女',
                                groupValue: _genderName,
                                activeColor: Colors.red,
                                onChanged: (value) {
                                  setState(() {
                                    (context as Element).markNeedsBuild();
                                    _genderName = value;
                                    _sexCode = 1;
                                  });
                                },
                              ),
                            ),
                            Text('女'),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('部门：'),
                          Expanded(
                            child: _customdept(_dept),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      AbsorbPointer(
                        absorbing: receiveStaff.staffId != null,
                        child: Row(
                          children: [
                            Text('职务：'),
                            Expanded(
                              child: _customtextCode(_posi),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('电话：'),
                          Expanded(
                            child: _customPhone(_phone),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('取消'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _code.text = '';
                    _name.text = '';
                    _posi.text = '';
                    _phone.text = '';
                  },
                ),
                FlatButton(
                  child: Text('保存'),
                  onPressed: () {
                    if (!_checkData()) return;
                    setPageDataChanged(this.widget, true);
                    if (isEdit == 0) {
                      ReceiveDetail detailStaff = new ReceiveDetail();
                      detailStaff.staffCode = _code.text;
                      detailStaff.staffName = _name.text;
                      detailStaff.staffId = 0;
                      detailStaff.gender = _genderName;
                      detailStaff.sexCode = _sexCode;
                      // detailStaff.deptId=0;
                      detailStaff.deptName = _dept.text;
                      detailStaff.posi = _posi.text;
                      detailStaff.phone = _phone.text;
                      _detail.add(detailStaff);
                    } else {
                      receiveStaff.phone = _phone.text;
                      receiveStaff.staffCode = _code.text;
                      receiveStaff.staffName = _name.text;
                      receiveStaff.deptName = _dept.text;
                      receiveStaff.gender = _genderName;
                      receiveStaff.sexCode = _sexCode;
                      receiveStaff.posi = _posi.text;
                      receiveStaff.staffId = _dataReceive.requestStaffId;
                    }
                    _code.text = '';
                    _name.text = '';
                    _posi.text = '';
                    _phone.text = '';
                    _staffAmount();
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectUser() async {
    var result = await showSearch(
      context: context,
      delegate:
          SearchStaffDelegate(Prefs.keyHistorySelectStaff, canSearchAll: true),
    );
    if (result == "" || result == null) return;
    StaffModel staffModel = StaffModel.fromJson(json.decode(result));
    ReceiveDetail detailUser = new ReceiveDetail();
    detailUser.staffId = staffModel.staffId;
    detailUser.staffName = staffModel.name;
    detailUser.staffCode = staffModel.code;
    detailUser.posi = staffModel.posi;
    detailUser.deptId = staffModel.deptId;
    detailUser.deptName = staffModel.deptName;
    detailUser.gender = staffModel.genderName;
    detailUser.phone = staffModel.phone;

    bool isExist = false;
    _detail.forEach((ReceiveDetail detail) {
      if (detail.staffId == staffModel.staffId) {
        Fluttertoast.showToast(msg: "该人员已存在", gravity: ToastGravity.CENTER);
        isExist = true;
      }
    });
    setState(() {
      if (!isExist) {
        _detail.add(detailUser);
        _staffAmount();
      }
    });
  }

  bool _checkData() {
    bool hasData = false;
    if (_name.text == "") {
      DialogUtils.showToast('姓名不能为空!');
    } else if (_phone.text == "") {
      DialogUtils.showToast('电话号码不能为空!');
    } else {
      hasData = true;
    }
    return hasData;
  }

  bool _checkRecord() {
    bool hasData = false;
    if (_dataReceive.qualityValue <= 0) {
      DialogUtils.showToast('请选择招待性质!');
    } else if (_dataReceive.qualityValue == 3 && _quality.text == "") {
      DialogUtils.showToast('请填写招待性质名称!');
    } else if (_dataReceive.standardValue <= 0) {
      DialogUtils.showToast('请选择招待标准!');
    } else if (_dataReceive.dinnerValue > 0 && _dinner.text == '' ||
        _dinner.text == '' &&
            _dinnerMoney.text != "" &&
            _dinnerMoney.text != "0.0") {
      DialogUtils.showToast('请填写用餐酒店名称!');
    } else if (_dinnerMoney.text == '' && _dinner.text != "") {
      DialogUtils.showToast('请填写所用餐费!');
    } else if (_dataReceive.tavernValue > 0 && _tavern.text == '' ||
        _tavern.text == '' &&
            _tavernMoney.text != "" &&
            _tavernMoney.text != "0.0") {
      DialogUtils.showToast('请填写住宿酒店名称!');
    } else if (_roomList.length == 0 && _tavern.text != "") {
      DialogUtils.showToast('请选择住宿酒店的房间!');
    } else if (_dataReceive.other == 1 && _other.text == "") {
      DialogUtils.showToast('请填写其他招待内容!');
    } else if (_dataReceive.cigarettes +
                _dataReceive.fruit +
                _dataReceive.gift +
                _dataReceive.other >
            0 &&
        _otherMoney.text == "") {
      DialogUtils.showToast('请填写其他招待费用!');
    } else if (_dataReceive.cigarettes +
                _dataReceive.fruit +
                _dataReceive.gift +
                _dataReceive.other ==
            0 &&
        _otherMoney.text != "" &&
        _otherMoney.text != "0.0") {
      DialogUtils.showToast('请选择其他招待的内容!');
    } else if (_reason.text == "") {
      DialogUtils.showToast('请填写招待事由!');
    } else if (_dataReceive.totalMoney == 0) {
      DialogUtils.showToast('请填写总计接待费用!');
    } else if (_detail.length == 0) {
      DialogUtils.showToast('请选择招待人员!');
    } else {
      hasData = true;
    }
    for (int i = 0; i < _detail.length; i++) {
      if (_detail[i].phone == '') {
        hasData = false;
        DialogUtils.showToast('请输入招待人员电话号码!');
        break;
      }
    }

    return hasData;
  }

  Future<bool> _save() async {
    bool result;
    if (_checkRecord()) {
      setPageDataChanged(this.widget, true);
      result = await _request('save');
    }
    return result;
  }

  Future<void> _submit() async {
    if (_checkRecord()) {
      setPageDataChanged(this.widget, true);
      await _request('submit');
    }
  }

  void _toDraft() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否取消提交?',
        iconData: Icons.info, color: Colors.red);
    if (result) {
      setPageDataChanged(this.widget, true);
      _request('todraft');
    }
  }

  void _delete() async {
    if (await DialogUtils.showConfirmDialog(context, '是否删除该条招待申请单？',
        iconData: Icons.info, color: Colors.red)) {
      setPageDataChanged(this.widget, true);
      await delete(_dataReceive.receiveId).then((value) {
        if (value['ErrCode'] == 0) {
          DialogUtils.showToast('删除成功');
          Navigator.pop(context);
        } else {
          DialogUtils.showConfirmDialog(context, value['ErrMsg']);
        }
      });
    }
  }

  Future<bool> _request(String action) async {
    bool result;
    _dataReceive.dinnerMoney =
        double.parse(_dinnerMoney.text == '' ? "0" : _dinnerMoney.text);
    _dataReceive.tavernMoney =
        double.parse(_tavernMoney.text == '' ? "0" : _tavernMoney.text);
    _dataReceive.otherMoney =
        double.parse(_otherMoney.text == '' ? "0" : _otherMoney.text);
    _dataReceive.reason = _reason.text;
    if (_dataReceive.qualityValue == 3) {
      _dataReceive.receiveQuality = _quality.text;
    }
    if (_dataReceive.dinnerValue > 0) {
      _dataReceive.dinner = _dinner.text;
      _dataReceive.dinnerStandard = _dinner.text;
    }
    if (_dataReceive.tavernValue > 0) {
      _dataReceive.tavernStandard = _tavern.text;
    }
    if (_dataReceive.other == 1) {
      _dataReceive.otherOption = _other.text;
    }
    try {
      await _progressDialog?.show();
      ReceiveWrapper receiveWrapper = ReceiveWrapper();
      switch (action) {
        case 'save':
          String action = _dataReceive.receiveId == null ? 'add' : 'update';
          receiveWrapper = await requestData(
              action, false, _dataReceive, _detail, _roomList);
          break;
        case 'submit':
          String action = _dataReceive.receiveId == null ? 'add' : 'update';
          receiveWrapper =
              await requestData(action, true, _dataReceive, _detail, _roomList);
          break;
        case 'todraft':
          receiveWrapper = await todraft(_dataReceive.receiveId);
          break;
        default:
      }

      if (receiveWrapper.errCode == 0) {
        switch (action) {
          case 'save':
            DialogUtils.showToast('保存成功');
            break;
          case 'submit':
            DialogUtils.showToast('提交成功');
            break;
          case 'todraft':
            DialogUtils.showToast('取消成功');
            break;
          default:
        }
        setState(() {
          _dataReceive = receiveWrapper.receiveList;
          _detail = receiveWrapper.detail;
          _roomList = receiveWrapper.room;
          _quality.text = _dataReceive.receiveQuality;
          _dinner.text = _dataReceive.dinnerStandard;
          _tavern.text = _dataReceive.tavernStandard;
          _other.text = _dataReceive.otherOption;
          _dataReceive.applyDate = _dataReceive.applyDate;
          _dinnerMoney.text = _dataReceive.dinnerMoney.toString();
          _tavernMoney.text = _dataReceive.tavernMoney.toString();
          _otherMoney.text = _dataReceive.otherMoney.toString();
          _roomTypeAmount();
          _staffAmount();
        });
      }
    } finally {
      _progressDialog?.hide();
    }
    return result;
  }
}
