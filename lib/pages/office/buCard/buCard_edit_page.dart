import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/buCard.dart';
import 'package:mis_app/model/buCardWrapper.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/buCard_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class BuCardEditPage extends StatefulWidget {
  final Map arguments;

  BuCardEditPage({this.arguments});
  @override
  _BuCardEditPageState createState() => _BuCardEditPageState();
}

class _BuCardEditPageState extends State<BuCardEditPage> {
  BuCardList _dataBuCard = new BuCardList();
  List<Detail> _detail = [];
  FLToastDefaults _flToastDefaults = FLToastDefaults();
  final TextEditingController _reason = TextEditingController();
  ProgressDialog _progressDialog;
  String noCardDate =
      Utils.dateTimeToStrWithPattern(DateTime.now(), 'yyyy-MM-dd  HH:mm');

  @override
  void initState() {
    super.initState();
    _getDefaltData();
    if (this.widget.arguments != null) {
      _dataBuCard.buCardId = this.widget.arguments['buCardId'];
      //等待界面更新后获取数据
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _getDetail();
      });
    }
  }

  void _getDefaltData() {
    _dataBuCard.status = 0;
    _dataBuCard.areaId = BuCardBaseDB.areaId;
    _dataBuCard.kindId = 1;
    _dataBuCard.deptId = BuCardBaseDB.deptId;
    _dataBuCard.deptName = BuCardBaseDB.deptName;
    _dataBuCard.applyDate = Utils.today;
    _dataBuCard.noCardDate = DateTime.now();

    Detail detailUser = new Detail();
    detailUser.staffId = BuCardBaseDB.staffID;
    detailUser.staffName = BuCardBaseDB.staffName;
    detailUser.staffCode = BuCardBaseDB.staffCode;
    detailUser.posi = BuCardBaseDB.posi;
    _detail.add(detailUser);
  }

  void _getDetail() async {
    Function dismiss = FLToast.loading();
    try {
      BuCardWrapper buCardWrapper = await buCardDetail(_dataBuCard.buCardId);
      setState(() {
        _dataBuCard = buCardWrapper.buCardList;
        _detail = buCardWrapper.detail;
        if (_dataBuCard != null) {
          noCardDate = Utils.dateTimeToStrWithPattern(
              _dataBuCard.noCardDate, 'yyyy-MM-dd  HH:mm');
          _reason.text = _dataBuCard.reason;
        }
      });
    } catch (e) {
      dismiss();
    } finally {
      dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('补卡申请'),
      ),
      body: FLToastProvider(
        defaults: _flToastDefaults,
        child: Container(
          color: Colors.grey[100],
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AbsorbPointer(
                  absorbing: _dataBuCard.status > 0,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              _headerWidget(),
                              _areaWidget(),
                              _timeWidget(),
                              _cardWidget(),
                              _reasonWidget("未打卡原因：", _reason),
                            ],
                          ),
                        ),
                        Container(height: 10),
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              _btaddWidget(),
                              _staffWidget(),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              _dataBuCard.status < 10
                  ? _draftButtons()
                  : (_dataBuCard.status == 10 ? _submitButtons() : Text('')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('单号：'),
                Container(
                  child: Center(
                    child: Text(_dataBuCard.code ?? ''),
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
                      _dataBuCard.statusName ?? '草稿',
                      // textAlign: TextAlign.center,
                      style: statusTextStyle(_dataBuCard.status ?? 0),
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
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('项目：'),
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    isDense: true,
                    underline: Container(
                      color: Colors.blue,
                      height: 0.0,
                    ),
                    value: _dataBuCard.areaId,
                    items: generateItemList(),
                    onChanged: (item) {
                      Utils.closeInput(context);
                      setState(() {
                        _dataBuCard.areaId = item;
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
                Text('部门：'),
                Expanded(
                  child: Container(
                    child: Text(_dataBuCard.deptName),
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //     Utils.closeInput(context);
                //     showSearch(
                //             context: context,
                //             delegate: SearchDeptDelegate(
                //                 Prefs.keyHistorySelectDept,
                //                 areaId: _dataBuCard.areaId))
                //         .then((value) {
                //       if (value == null) return;
                //       var data = jsonDecode(value);
                //       DeptModel deptModel = DeptModel.fromJson(data);
                //       setState(() {
                //         _dataBuCard.deptId = deptModel.deptId;
                //         _dataBuCard.deptName = deptModel.name;
                //       });
                //     });
                //   },
                //   child: Icon(
                //     Icons.search,
                //     color: Colors.blue,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 0, 5.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('申请日期：'),
                Container(
                  child: InkWell(
                    // onTap: () {
                    //   Utils.closeInput(context);
                    //   _selectDate();
                    // },
                    child: Text(
                      Utils.dateTimeToStr(_dataBuCard.applyDate),
                      textAlign: TextAlign.center,
                      // style: TextStyle(color: Colors.orange),
                    ),
                  ),
                  // decoration: BoxDecoration(
                  //   border: Border(
                  //     bottom: BorderSide(width: 1),
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('类型：'),
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(
                      color: Colors.blue,
                      height: 0.0,
                    ),
                    value: _dataBuCard.kindId,
                    items: getKindList(),
                    onChanged: (item) {
                      Utils.closeInput(context);
                      setState(() {
                        _dataBuCard.kindId = item;
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

  Widget _cardWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5, 5.0, 5),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('未打卡时间：'),
                Expanded(
                  child: Container(
                    child: InkWell(
                      onTap: () {
                        _dateAndTimePick(_dataBuCard.noCardDate);
                      },
                      child: Row(
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(2),
                              decoration: timePickDecoration,
                              child: customText(
                                  value: noCardDate, color: Colors.orange)),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Icon(
                              Icons.date_range,
                              color: Colors.orange,
                              size: 22,
                            ),
                          )
                        ],
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

  Widget _reasonWidget(reason, controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 8.0, 5.0, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(reason),
          TextField(
            controller: controller,
            autofocus: false,
            maxLines: 3,
            style: TextStyle(fontSize: 15.5),
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              filled: true,
              hintText: '请输入未打卡原因',
              contentPadding: EdgeInsets.all(1),
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btaddWidget() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      alignment: Alignment.centerLeft,
      child: Text(" 未打卡人员"),
    );
  }

  Widget _staffWidget() {
    return Container(
        child: ListView.separated(
      shrinkWrap: true, //内容适配
      itemCount: _detail.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
            color: Colors.white,
            child: Row(children: <Widget>[
              Expanded(child: Text(_detail[index].staffCode)),
              Expanded(child: Text(_detail[index].staffName)),
              Expanded(child: Text(_detail[index].posi)),
              // _dataBuCard.status < 10
              //     ? InkWell(
              //         onTap: () async {
              //           bool result = await DialogUtils.showConfirmDialog(
              //               context, "是否移除该人员？",
              //               iconData: Icons.info, color: Colors.red);
              //           setState(() {
              //             if (result == true) {
              //               _detail.removeAt(index);
              //             }
              //           });
              //         },
              //         child: Icon(Icons.clear, color: Colors.red),
              //       )
              //     : Container(),
            ]));
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    ));
  }

  Widget _draftButtons() {
    bool visible = _dataBuCard.code == null ? false : true;
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

  List<DropdownMenuItem> generateItemList() {
    var result = BuCardBaseDB.areaList.map((Area item) {
      return DropdownMenuItem(
        child: customText(
            value: item.shortName,
            color:
                _dataBuCard.areaId == item.areaId ? Colors.blue : Colors.black),
        value: item.areaId,
      );
    }).toList();

    return result;
  }

  List<DropdownMenuItem> getKindList() {
    var result = BuCardBaseDB.kindList.map((Kind item) {
      return DropdownMenuItem(
        child: customText(value: item.kindName, color: Colors.black),
        value: item.kindId,
      );
    }).toList();

    return result;
  }

  // Future<void> _selectDate() async {
  //   final DateTime date = await showDatePicker(
  //     context: context,
  //     initialDate: _dataBuCard.applyDate, // 初始日期
  //     firstDate: DateTime(1900), // 可选择的最早日期
  //     lastDate: DateTime(2100), // 可选择的最晚日期
  //   );
  //   if (date == null) return;

  //   setState(() {
  //     _dataBuCard.applyDate = date;
  //   });
  // }

  Future<void> _dateAndTimePick(DateTime date) async {
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
      _dataBuCard.noCardDate = result;
      noCardDate = Utils.dateTimeToStrWithPattern(result, 'yyyy-MM-dd  HH:mm');
    });
  }

  // Future<void> _selectUser() async {
  //   var result = await showSearch(
  //     context: context,
  //     delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff,
  //         deptId: _dataBuCard.deptId),
  //   );
  //   if (result == "" || result == null) return;
  //   StaffModel staffModel = StaffModel.fromJson(json.decode(result));
  //   Detail detailUser = new Detail();
  //   detailUser.staffId = staffModel.staffId;
  //   detailUser.staffName = staffModel.name;
  //   detailUser.staffCode = staffModel.code;
  //   detailUser.posi = staffModel.posi;
  //   bool isExist = false;
  //   _detail.forEach((Detail detail) {
  //     if (detail.staffId == staffModel.staffId) {
  //       Fluttertoast.showToast(msg: "该人员已存在", gravity: ToastGravity.CENTER);
  //       isExist = true;
  //     }
  //   });
  //   setState(() {
  //     if (!isExist) _detail.add(detailUser);
  //   });
  // }

  bool _checkData() {
    if (!_checkInputText(_reason, "请输入未打卡原因！")) return false;
    if (_detail.length == 0) {
      DialogUtils.showToast("请添加人员！");
      return false;
    } else if (!_dataBuCard.noCardDate.isBefore(_dataBuCard.applyDate)) {
      DialogUtils.showToast('未打卡日期应早于申请日期');
      return false;
    }
    return true;
  }

  bool _checkInputText(TextEditingController controller, String msg) {
    if (Utils.textIsEmptyOrWhiteSpace(controller.text)) {
      DialogUtils.showToast(msg);
      return false;
    }
    return true;
  }

  Future<void> _request(String action) async {
    try {
      await _progressDialog?.show();
      _dataBuCard.reason = _reason.text;
      BuCardWrapper _data;
      setPageDataChanged(this.widget, true);
      switch (action) {
        case 'save':
          _data = _dataBuCard.code == null
              ? await buCardService('add', _dataBuCard, _detail, '')
              : await buCardService('update', _dataBuCard, _detail, '');
          break;
        case 'submit':
          _data = _dataBuCard.code == null
              ? await buCardService('add', _dataBuCard, _detail, 'submit')
              : await buCardService('update', _dataBuCard, _detail, 'submit');
          break;
        case 'todraft':
          _data = await toDraftOrDelete('todraft', _dataBuCard.buCardId);
          break;
        case 'delete':
          _data = await toDraftOrDelete('delete', _dataBuCard.buCardId);
          if (_data.errCode == 0) {
            Fluttertoast.showToast(msg: "删除成功！", gravity: ToastGravity.CENTER);
            Navigator.of(context).pop();
          } else {
            DialogUtils.showConfirmDialog(context, _data.errMsg.toString());
          }
          break;
        default:
      }
      int errCode = _data.errCode;
      String errMsg = _data.errMsg;
      if (errCode == 0) {
        await _progressDialog?.hide();
        if (action == 'save') {
          toastBlackStyle('保存成功!');
        } else if (action == 'submit') {
          toastBlackStyle('提交成功!');
        } else if (action == 'todraft') {
          toastBlackStyle('取消成功!');
        }
        setState(() {
          _dataBuCard = _data.buCardList;
          _detail = _data.detail;
          _reason.text = _dataBuCard.reason;
          Utils.closeInput(context);
        });
      } else {
        await _progressDialog?.hide();
        DialogUtils.showAlertDialog(context, errMsg);
      }
    } catch (e) {} finally {
      await _progressDialog?.hide();
    }
  }

  void _save() async {
    if (_checkData()) {
      setPageDataChanged(this.widget, true);
      await _request('save');
    }
  }

  void _submit() {
    if (!_checkData()) {
      setPageDataChanged(this.widget, true);
      return;
    }
    _request('submit');
  }

  void _toDraft() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否取消提交?',
        iconData: Icons.info, color: Colors.red);
    if (result) _request('todraft');
  }

  void _delete() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否删除该条记录?',
        iconData: Icons.info, color: Colors.red);
    if (result) _request('delete');
  }
}
