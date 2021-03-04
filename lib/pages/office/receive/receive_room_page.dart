import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mis_app/model/receiveBase.dart';
import 'package:mis_app/model/receivePhone.dart';
import 'package:mis_app/model/receiveWrapper.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class ReceiveRoomPage extends StatefulWidget {
  final Map arguments;
  ReceiveRoomPage({this.arguments});
  @override
  _ReceiveRoomPageState createState() => _ReceiveRoomPageState();
}

class _ReceiveRoomPageState extends State<ReceiveRoomPage> {
  TextStyle _textStyle = TextStyle(fontSize: 15.5);
  final TextEditingController _amount = TextEditingController();
  final TextEditingController _value = TextEditingController();
  final TextEditingController _day = TextEditingController();
  ReceiveRoom _receiveRoom = new ReceiveRoom();

  double _totalMoney = 0;
  List<ReceiveRoom> _roomList = [];
  // int _statusId = 0;
  String _statusName='草稿';

  @override
  void initState() {
    super.initState();

    _receiveRoom.roomType = 1;
    _receiveRoom.roomTypeName = "标准单人房";
    Map arguments = widget.arguments;
    if (arguments != null) {
      _roomList = arguments['roomList'];
      _statusName = arguments['statusId'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('房间详情'),
      ),
      body: Column(
        children: <Widget>[
          _roomWidget(),
          _receiveRoomList(),
        ],
      ),
    );
  }

  Widget _roomWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
      child: FlatButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.green,
        onPressed: () async {
          showRoowDialog(context, _receiveRoom, 0);
          _receiveRoom.beginDate = DateTime.now();
          _receiveRoom.finishDate = DateTime.now();
        },
        child: Text(
          "添加房间",
        ),
      ),
    );
  }

  Widget _receiveRoomList() {
    return Expanded(
      child: ListView.separated(
        itemCount: _roomList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemBuilder: (BuildContext context, int index) {
          ReceiveRoom item = _roomList[index];
          return InkWell(
            onTap: () async {
              _amount.text = item.roomAmount.toString();
              _day.text = item.day.toString();
              _value.text = item.roomPrice.toString();
              _totalMoney = item.roomMoney;
              _receiveRoom.beginDate = item.beginDate;
              _receiveRoom.finishDate = item.finishDate;
              showRoowDialog(context, item, 1);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(child: Text(item.roomTypeName)),
                            Expanded(
                              child: Text(
                                '住房天数: ' + item.day.toString(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Container(
                              // margin: EdgeInsets.only(left: 5),
                              child: Icon(
                                Icons.date_range,
                                color: Colors.orange,
                                size: 22,
                              ),
                            ),
                            Text(
                              Utils.dateTimeToStr(item.beginDate),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              ' — ' + Utils.dateTimeToStr(item.finishDate),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                                    '房间数量: ' + item.roomAmount.toString())),
                            Expanded(
                                child:
                                    Text('单价: ' + item.roomPrice.toString())),
                            Expanded(
                                child:
                                    Text('总金额: ' + item.roomMoney.toString())),
                            _statusName == '草稿'
                                ? InkWell(
                                    onTap: () async {
                                      bool result =
                                          await DialogUtils.showConfirmDialog(
                                              context, "是否移除该房间？",
                                              iconData: Icons.info,
                                              color: Colors.red);
                                      setState(() {
                                        if (result == true) {
                                          _roomList.removeAt(index);
                                          setPageDataChanged(this.widget, true);
                                        }
                                      });
                                    },
                                    child: Icon(Icons.clear, color: Colors.red),
                                  )
                                : Container(),
                          ],
                        ),
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

  Future<void> showRoowDialog(
      BuildContext context, ReceiveRoom receiveRoom, int isEdit) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (contexts, mSetState) {
            return AlertDialog(
              title: Text('房间信息详细'),
              content: Container(
                // padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('类别：'),
                          Expanded(
                            child: DropdownButton(
                              isExpanded: true,
                              underline: Container(
                                color: Colors.blue,
                                height: 0.0,
                              ),
                              value: receiveRoom.roomType,
                              items: generateItemList(),
                              onChanged: (item) {
                                mSetState(() {
                                  receiveRoom.roomType = item;
                                  receiveRoom.roomTypeName = ReceiveBaseDB
                                      .receiveRoom[item - 1].typeName;
                                  Utils.closeInput(context);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('数量：'),
                          Expanded(
                              child: _customtextNumber(contexts, _amount, 1)),
                          SizedBox(width: 20),
                          Text('住房天数：'),
                          Expanded(child: _customtextNumber(contexts, _day, 1)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('单价：'),
                          Expanded(
                              child: _customtextNumber(contexts, _value, 0)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('起始日期：'),
                          Expanded(
                            child: Container(
                              child: InkWell(
                                onTap: () {
                                  Utils.closeInput(context);
                                  _selectBeginDate();
                                },
                                child: Text(
                                  Utils.dateTimeToStr(_receiveRoom.beginDate),
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
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('结束日期：'),
                          Expanded(
                            child: Container(
                              child: InkWell(
                                onTap: () {
                                  Utils.closeInput(context);
                                  _selectFinishDate();
                                },
                                child: Text(
                                  Utils.dateTimeToStr(_receiveRoom.finishDate),
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('总金额：'),
                          Text(_totalMoney.toString(),
                              style: TextStyle(color: Colors.red)),
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
                    // receiveRoom.roomType = 1;
                    _amount.text = '';
                    _day.text = '';
                    _value.text = '';
                    _totalMoney = 0;
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('保存'),
                  onPressed: () {
                    if (!checkData()) return;
                    setPageDataChanged(this.widget, true);
                    if (isEdit == 0) {
                      ReceiveRoom detailRoom = new ReceiveRoom();
                      // detailRoom.receiveRoomId = receiveRoom.roomType;
                      detailRoom.roomType = receiveRoom.roomType;
                      detailRoom.roomAmount = int.parse(_amount.text);
                      detailRoom.roomPrice = double.parse(_value.text);
                      detailRoom.beginDate = receiveRoom.beginDate;
                      detailRoom.finishDate = receiveRoom.finishDate;
                      detailRoom.day = int.parse(_day.text);
                      detailRoom.roomMoney = _totalMoney;
                      detailRoom.roomTypeName = receiveRoom.roomTypeName;
                      _roomList.add(detailRoom);
                    } else {
                      receiveRoom.roomAmount = int.parse(_amount.text);
                      receiveRoom.roomPrice = double.parse(_value.text);
                      receiveRoom.day = int.parse(_day.text);
                      receiveRoom.beginDate = _receiveRoom.beginDate;
                      receiveRoom.finishDate = _receiveRoom.finishDate;
                      receiveRoom.roomMoney = _totalMoney;
                    }

                    _amount.text = '';
                    _day.text = '';
                    _value.text = '';
                    _totalMoney = 0;
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

  Widget _customtextNumber(
      BuildContext dialogContext, TextEditingController _controller, int dian) {
    return Container(
      height: 30,
      child: TextField(
        maxLines: 1,
        textAlign: TextAlign.center,
        style: _textStyle,
        controller: _controller,
        inputFormatters: dian == 0
            ? [FilteringTextInputFormatter.allow(RegExp("[0-9.]"))]
            : [FilteringTextInputFormatter.allow(RegExp("[0-9]"))],
        // [ThousandsFormatter(allowFraction: true)],
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
          (dialogContext as Element).markNeedsBuild();
          setState(() {
            _totalMoney =
                double.parse(_amount.text == '' ? "0" : _amount.text) *
                    double.parse(_value.text == '' ? "0" : _value.text) *
                    double.parse(_day.text == '' ? "0" : _day.text);
          });
        },
      ),
    );
  }

  Future<void> _selectBeginDate() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _receiveRoom.beginDate, // 初始日期
      firstDate: DateTime(1900), // 可选择的最早日期
      lastDate: DateTime(2100), // 可选择的最晚日期
    );
    if (date == null) return;
    _receiveRoom.beginDate = date;
  }

  Future<void> _selectFinishDate() async {
    final DateTime date = await showDatePicker(
      context: context,
      initialDate: _receiveRoom.finishDate, // 初始日期
      firstDate: DateTime(1900), // 可选择的最早日期
      lastDate: DateTime(2100), // 可选择的最晚日期
    );
    if (date == null) return;
    _receiveRoom.finishDate = date;
  }

  List<DropdownMenuItem> generateItemList() {
    return ReceiveBaseDB.receiveRoom.map((ReceiveRoomBase item) {
      return DropdownMenuItem(
        child: Text(item.typeName),
        value: item.roomType,
      );
    }).toList();
  }

  bool checkData() {
    bool hasData = false;
    if (_amount.text == "") {
      DialogUtils.showToast('数量不能为空!');
    } else if (_day.text == "") {
      DialogUtils.showToast('住房天数不能为空!');
    } else if (_value.text == "") {
      DialogUtils.showToast('单价不能为空!');
    } else if (_receiveRoom.beginDate.isAfter(_receiveRoom.finishDate)) {
      DialogUtils.showToast('结束日期不能小于开始日期!');
    } else if (_totalMoney == 0) {
      DialogUtils.showToast('总金额不能为零!');
    } else {
      hasData = true;
    }
    return hasData;
  }
}
