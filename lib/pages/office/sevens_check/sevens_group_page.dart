import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/sevens_basedb.dart';
import 'package:mis_app/model/sevens_group_detail.dart';
import 'package:mis_app/model/user.dart';
import 'package:mis_app/pages/common/search_user.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sevens_check_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/base_container.dart';

class SevenSGroupPage extends StatefulWidget {
  final Map arguments;
  SevenSGroupPage({Key key, this.arguments}) : super(key: key);

  @override
  _SevenSGroupPageState createState() => _SevenSGroupPageState();
}

class _SevenSGroupPageState extends State<SevenSGroupPage> {
  final _listTitleStyle = TextStyle(
      // fontSize: ScreenUtil().setSp(32),
      fontWeight: FontWeight.w600,
      color: Colors.blue);

  // var _colorStyle = Colors.white;

  // int _checkId = 0;
  // int _status = 0;
  // int _areaId;
  var _areaValue;
  var _defaultAreaName = '';
  // int _areaGroupId;
  var _areaGroupValue;
  var _checkDate = DateTime.now();
  var _statusName = '草稿';
  int _sumDeductNum = 0;
  double _sumDeduction = 0.0;
  String _dataJson;
  String _detailUserjson;

  bool _offAddStaff = false;
  bool _offEdit = true;
  bool _offTextGroup = true;
  bool _offAddDeduction = true;
  bool _offDeductTitle = true;
  bool _offBtSubmit = true;
  bool _offContButton = false;
  bool _offBtCancelSubmit = true;
  bool _offRemoveStaff = false;
  bool _isAbsorbing = false;
  // bool _areaGroupisAbso = false;
  bool _textReadOnly = false;

  List<Area> _areaList = [];
  List<AreaGroup> _areaGroupList = [];
  List<DetailUser> _checkMemberList = [];
  List<DetailDept> _deductofDeptList = [];

  GroupCheckModel _groupCheckModel = new GroupCheckModel();

  FocusNode _textGroupFocus = new FocusNode();

  TextEditingController _groupControl = new TextEditingController();
  TextEditingController _statusControl = new TextEditingController(text: '草稿');

  List<DropdownMenuItem> _areaDropDown = [];
  List<DropdownMenuItem> _areaGroupDropDown = [];

  @override
  void initState() {
    StaticData.areaId = BaseDbModel.baseDbModel.userStaffList[0].defaultAreaId;
    _areaList = BaseDbModel.baseDbModel.areaList;
    _defaultAreaName = _getDefaultAreaName();
    _areaGroupList = _getAreaGroupList();
    StaticData.areaGroupId = _areaGroupList[0].areaGroupId;
    StaticData.isAllDept = false;
    //默认用户
    DetailUser detailUser = new DetailUser();
    detailUser.userId = SevensBaseDBModel.userList[0].userId;
    detailUser.userChnName = SevensBaseDBModel.userList[0].userChnName;
    _checkMemberList.add(detailUser);
    //设置下拉框
    _areaDropDown = _getAreaDroupDown();
    _areaGroupDropDown = _getGroupDroupDown();
    _setWidgetOffStage();
    StaticData.checkId =
        this.widget.arguments == null ? 0 : this.widget.arguments['checkId'];
    StaticData.checkId == 0
        ? print("开始检查")
        : _request(StaticData.checkId, 'get_detail');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseContainer(
      parentContext: context,
      child: Container(
        child: Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text("7S检查明细"),
          ),
          body: SafeArea(
              child: Container(
            margin: EdgeInsets.only(
                left: ScreenUtil().setWidth(20),
                right: ScreenUtil().setWidth(20),
                bottom: ScreenUtil().setWidth(10)),
            child: Column(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      AbsorbPointer(
                        absorbing: _isAbsorbing,
                        child: _topWidgets(),
                      ),
                      _btAddGroupMenber(),
                      AbsorbPointer(
                        absorbing: _isAbsorbing,
                        child: _groupMenberList(),
                      ),
                      _addDeduct(),
                    ],
                  ),
                ),
                _deductListView(),
                _btDraftStatus(),
                _btSubmit(),
                _btToDrop(),
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget _topWidgets() {
    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Text("项目："),
          _areaDropDownList(),
        ],
      ),
      Container(
        margin: EdgeInsets.only(top: 2, bottom: 7),
        child: Row(children: <Widget>[
          Text("组别："),
          _groupDropDownList(),
          Text("检查日期："),
          _selectDate(context),
        ]),
      ),
      Container(
        margin: EdgeInsets.only(top: 10),
        child: Row(
          children: <Widget>[
            Text("第"),
            _inputGroupNum(),
            Text("组"),
            Container(
                margin: EdgeInsets.only(left: ScreenUtil().setHeight(80)),
                child: Text("状态：")),
            _textStatus(),
          ],
        ),
      )
    ]);
  }

  //地区选择
  Widget _areaDropDownList() {
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(left: ScreenUtil().setWidth(10)),
        child: DropdownButton(
          focusColor: Colors.red,
          isExpanded: true,
          underline: Container(
            color: Colors.blue,
            height: 0.0,
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: _isAbsorbing ? Colors.grey : Colors.blue,
          ),
          items: _areaDropDown,
          hint: Text(_defaultAreaName),
          value: _areaValue,
          onChanged: (v) {
            setState(() {
              if (_deductofDeptList.length != 0) {
                DialogUtils.showAlertDialog(context, "已录入该地区的检查记录，不能更改！",
                    iconData: Icons.info, color: Colors.red);
              } else {
                _areaValue = v;
                _handlerAreaSelect();
              }
            });
          },
        ),
      ),
    );
  }

//区域选择
  Widget _groupDropDownList() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 4, right: 20),
      child: DropdownButton(
        isExpanded: true,
        isDense: true,
        underline: Container(height: 0.0),
        icon: Icon(
          Icons.arrow_drop_down,
          color: _isAbsorbing ? Colors.grey : Colors.blue,
        ),
        value: _areaGroupValue,
        items: _areaGroupDropDown,
        onChanged: (v) {
          setState(() {
            if (_deductofDeptList.length != 0) {
              DialogUtils.showConfirmDialog(context, "已录入该区域的检查记录，不能更改！",
                  iconData: Icons.info, color: Colors.red);
            } else {
              _areaGroupValue = v;
              StaticData.areaGroupId = _getAreaGroupId(_areaGroupValue);
            }
          });
        },
        hint:
            Text(_areaGroupList.length == 0 ? "" : _areaGroupList[0].groupName),
      ),
    ));
  }

//时间选择
  Widget _selectDate(BuildContext context) {
    return InkWell(
      child: Container(
        alignment: Alignment.center,
        height: ScreenUtil().setHeight(50),
        width: ScreenUtil().setWidth(220),
        decoration: BoxDecoration(
            // border: Border.all(color:Colors.blue,width:0.5),
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(5)),
        child: Container(
          margin: EdgeInsets.only(left: 8, right: 8),
          child: Text(
            Utils.dateTimeToStrWithPattern(_checkDate, 'yyyy-MM-dd'),
            style: TextStyle(
              fontSize: 17,
              //  color: _isAbsorbing ? Colors.grey : Colors.orange,
              color: Colors.orange,
            ),
          ),
        ),
      ),
      onTap: () {
        // 调用函数打开
        showDatePicker(
          context: context,
          initialDate: _checkDate,
          firstDate: defaultFirstDate,
          lastDate: defaultLastDate, // 加 30 天
        ).then((DateTime val) {
          if (val == null) {
            return;
          }
          setState(() {
            _checkDate = val;
          });
          print(_checkDate); // 2018-07-12 00:00:00.000
        }).catchError((err) {
          print(err);
        });
      },
    );
  }

//输入分组
  Widget _inputGroupNum() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 8, right: 8),
      height: ScreenUtil().setHeight(50),
      width: ScreenUtil().setWidth(210),
      child: TextField(
        autofocus: false,
        focusNode: _textGroupFocus,
        // style: TextStyle(color: _isAbsorbing ? Colors.grey : Colors.black),
        decoration: textFieldDecorationNoBorder(),
        textAlign: TextAlign.center,
        controller: _groupControl,
        readOnly: _textReadOnly,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
        keyboardType: TextInputType.number,
      ),
    ));
  }

//状态
  Widget _textStatus() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.only(left: 8),
      height: ScreenUtil().setHeight(50),
      child: TextField(
        enabled: false,
        textAlign: TextAlign.center,
        controller: _statusControl,
        decoration: textFieldDecorationNoBorder(),
        style: statusTextStyle(StaticData.status),
      ),
    ));
  }

//添加组员
  Widget _btAddGroupMenber() {
    return Container(
      margin: EdgeInsets.only(top: 15, bottom: 5),
      child: Row(
        children: <Widget>[
          Offstage(
              offstage: _offAddStaff,
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                color: Colors.blue,
                onPressed: () {
                  _selectUser();
                },
                child: Text(
                  "添加组员",
                  style: TextStyle(color: Colors.white),
                ),
              )),
          Offstage(
            child: Text(
              "组员列表",
              style: _listTitleStyle,
            ),
            offstage: _offTextGroup,
          ),
          Offstage(
              offstage: _offEdit,
              child: InkWell(
                child: Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Icon(Icons.edit, color: Colors.deepOrange)),
                onTap: () {
                  _request(StaticData.checkId, 'to_draft');
                },
              )),
        ],
      ),
    );
  }

  //分组人员列表
  Widget _groupMenberList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _checkMemberList.length,
      itemBuilder: (context, index) {
        return Container(
            padding: EdgeInsets.only(top: 5, bottom: 5),
            color: Colors.grey[100],
            child: Row(children: <Widget>[
              Expanded(
                  child: Text(
                _checkMemberList[index].userChnName,
                style: TextStyle(
                    color: StaticData.status >= 10
                        ? Colors.black54
                        : Colors.black),
              )),
              Offstage(
                offstage: _offRemoveStaff,
                child: InkWell(
                  onTap: () async {
                    bool result = await DialogUtils.showConfirmDialog(
                        context, "是否移除该组员？",
                        iconData: Icons.info, color: Colors.red);
                    setState(() {
                      if (result == true) {
                        _checkMemberList.removeAt(index);
                      }
                    });
                  },
                  child: Icon(Icons.clear, color: Colors.red),
                ),
              ),
            ]));
      },
    );
  }

  //扣分统计
  Widget _addDeduct() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(children: <Widget>[
        Offstage(
          offstage: _offAddDeduction,
          child: Container(
              width: ScreenUtil().setWidth(235),
              child: Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.blue,
                    child: Text("添加记录", style: TextStyle(color: Colors.white)),
                    onPressed: () async {
                      StaticData.isCopyAdd = false;
                      bool dataChanged =
                          await navigatePage(context, sevensDetailPath);
                      if (dataChanged)
                        _request(StaticData.checkId, 'get_detail');
                    },
                    // child: Text("添加记录", style: TextStyle(color: Colors.white)),
                  ))),
        ),
        Offstage(
            offstage: _offDeductTitle,
            child: Container(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                width: ScreenUtil().setWidth(235),
                child: Text('扣分列表', style: _listTitleStyle))),
        Expanded(
            child: Text(
          '总缺陷数:$_sumDeductNum',
          style: TextStyle(color: Color.fromARGB(255, 226, 135, 2)),
        )),
        Expanded(
            child: Text(
          '总扣分:$_sumDeduction',
          style: TextStyle(color: Colors.red),
        )),
      ]),
    );
  }

  //扣分列表
  Widget _deductListView() {
    return Expanded(
        child: ListView.builder(
      shrinkWrap: true,
      itemCount: _deductofDeptList.length,
      itemBuilder: (context, index) {
        return Container(
          // color: Colors.grey,
          // decoration: bottomLineDecotation,
          color: Colors.grey[100],
          child: InkWell(
            onTap: () {
              Map arguments = {
                // 'checkId':  StaticData.checkId,
                'deptId': _deductofDeptList[index].deptId
              };
              Navigator.pushNamed(context, sevensDetaiListlPath,
                      arguments: arguments)
                  .then((value) => _request(StaticData.checkId, 'get_detail'));
            },
            child: Container(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: Row(
                children: <Widget>[
                  Expanded(
                      child: Text(_deductofDeptList[index].deptName,
                          style: TextStyle(
                              color: StaticData.status >= 10
                                  ? Colors.black54
                                  : Colors.black)
                          // style: TextStyle(color: Color.fromARGB(255, 0, 40, 255)),
                          )),
                  Expanded(
                      child: Text(
                          '缺陷数：${_deductofDeptList[index].countOfDefect}',
                          style: TextStyle(
                              color: StaticData.status >= 10
                                  ? Colors.black54
                                  : Colors.black)
                          // style: TextStyle(color: Color.fromARGB(255, 226, 135, 2)),
                          )),
                  Expanded(
                      child: Text(
                          '总扣分值：${_deductofDeptList[index].sumOfDeduct}',
                          style: TextStyle(
                              color: StaticData.status >= 10
                                  ? Colors.black54
                                  : Colors.black)
                          // style: TextStyle(color: Colors.red),
                          )),
                ],
              ),
            ),
          ),
        );
      },
    ));
  }

  //草稿状态按钮
  Widget _btDraftStatus() {
    return Offstage(
      offstage: _offContButton,
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          if (StaticData.checkId != 0)
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 8, right: 8),
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  onPressed: () async {
                    var result = await DialogUtils.showConfirmDialog(
                        context, "是否删除此次检查的记录？",
                        iconData: Icons.warning, color: Colors.red);
                    if (result) _request(StaticData.checkId, 'delete');
                  },
                  color: Colors.red,
                  child: Text(
                    '删除',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  if (StaticData.checkId == 0) {
                    _requestData('add', false);
                  } else {
                    _requestData('update', false);
                  }
                },
                color: Colors.blue,
                child: Text(
                  '保存',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              margin: EdgeInsets.only(left: 8, right: 8),
              child: FlatButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                onPressed: () {
                  if (StaticData.checkId == 0) {
                    _requestData('add', true);
                  } else {
                    _requestData('update', true);
                  }
                },
                color: Colors.green,
                child: Text(
                  '开始评分',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //提交
  Widget _btSubmit() {
    return Offstage(
        offstage: _offBtSubmit,
        child: Container(
          margin: EdgeInsets.only(bottom: 5),
          width: ScreenUtil().setWidth(700),
          child: FlatButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.green,
            onPressed: () {
              setState(() {
                _request(StaticData.checkId, 'submit');
              });
            },
            child: Text(
              '提交审核',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }

  //取消提交
  Widget _btToDrop() {
    return Offstage(
      offstage: _offBtCancelSubmit,
      child: Container(
        margin: EdgeInsets.only(bottom: 5),
        width: ScreenUtil().setWidth(700),
        child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.amber,
          onPressed: () {
            _request(StaticData.checkId, 'submit_undo');
          },
          child: Text(
            '取消提交',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _selectUser() async {
    var result = await showSearch(
      context: context,
      delegate: SearchUserDelegate(Prefs.keyHistorySelectUser),
    );
    if (result == "" || result == null) return;
    UserModel userModel = UserModel.fromJson(json.decode(result));
    DetailUser detailUser = new DetailUser();
    detailUser.userId = userModel.userId;
    detailUser.userChnName = userModel.userChnName;
    bool isExist = false;
    _checkMemberList.forEach((element) {
      if (element.userId == userModel.userId) {
        DialogUtils.showToast("组员已存在");
        isExist = true;
      }
    });
    setState(() {
      if (!isExist) _checkMemberList.add(detailUser);
    });
  }

  List<DropdownMenuItem> _getAreaDroupDown() {
    List<DropdownMenuItem> list = [];
    _areaList.forEach((item) {
      list.add(
        DropdownMenuItem(
          child: Text(
            item.shortName,
            style: TextStyle(
              fontSize: 16,
              color: _isAbsorbing ? Colors.grey : Colors.black,
            ),
          ),
          value: item.shortName,
        ),
      );
    });
    return list;
  }

  List<DropdownMenuItem> _getGroupDroupDown() {
    List<DropdownMenuItem> list = [];
    _areaGroupList.forEach((item) {
      list.add(DropdownMenuItem(
        child: Container(
          child: Text(
            item.groupName,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
            ),
          ),
        ),
        value: item.groupName,
      ));
    });
    return list;
  }

  int _getAreaId(String areaName) {
    int areaId;
    _areaList.forEach((item) {
      if (areaName == item.shortName) {
        areaId = item.areaId;
      }
    });
    return areaId;
  }

  int _getAreaGroupId(String areaGroupName) {
    int areaGroupId;
    _areaGroupList.forEach((item) {
      if (areaGroupName == item.groupName) {
        areaGroupId = item.areaGroupId;
        StaticData.isAllDept = item.allDept;
      }
    });
    return areaGroupId;
  }

  String _getDefaultAreaName() {
    String defaultAreaName;
    _areaList.forEach((item) {
      if (item.areaId == StaticData.areaId) {
        defaultAreaName = item.shortName;
      }
    });
    return defaultAreaName;
  }

  List _getAreaGroupList() {
    List<AreaGroup> list = [];
    List<AreaGroup> areaGroupList = SevensBaseDBModel.baseDBModel.areaGroupList;
    areaGroupList.forEach((item) {
      if (StaticData.areaId == item.areaId) {
        list.add(item);
      }
    });
    return list;
  }

  void _handlerAreaSelect() {
    StaticData.areaId = _getAreaId(_areaValue);
    _areaGroupList = _getAreaGroupList();
    _areaGroupDropDown = _getGroupDroupDown();
    //如果设置了区域
    if (_areaGroupList.length > 0) {
      _areaGroupValue = _areaGroupDropDown[0].value;
      StaticData.areaGroupId = _areaGroupList[0].areaGroupId;
    } else {
      StaticData.areaGroupId = null;
      DialogUtils.showToast("该项目暂时没有设置区域！");
    }
  }

  void _countDeduct() {
    _sumDeductNum = 0;
    _sumDeduction = 0;
    _deductofDeptList.forEach((element) {
      _sumDeductNum += element.countOfDefect;
      _sumDeduction += element.sumOfDeduct;
    });
  }

  void _setWidgetOffStage() {
    if (StaticData.status == 0) {
      _offAddStaff = false;
      _offEdit = true;
      _offRemoveStaff = false;
      _offAddDeduction = true;
      _offDeductTitle = false;
      _offTextGroup = true;
      _offBtSubmit = true;
      _offBtCancelSubmit = true;
      _offContButton = false;
      _isAbsorbing = false;
      _textReadOnly = false;
    } else if (StaticData.status == 5) {
      _offAddStaff = true;
      _offEdit = false;
      _offRemoveStaff = true;
      _offAddDeduction = false;
      _offDeductTitle = true;
      _offTextGroup = false;
      _offBtSubmit = false;
      _offBtCancelSubmit = true;
      _offContButton = true;
      _isAbsorbing = true;
      _textReadOnly = true;
    } else if (StaticData.status == 10) {
      _offAddStaff = true;
      _offEdit = true;
      _offRemoveStaff = true;
      _offAddDeduction = true;
      _offDeductTitle = false;
      _offTextGroup = false;
      _offBtSubmit = true;
      _offBtCancelSubmit = false;
      _offContButton = true;
      _isAbsorbing = true;
      _textReadOnly = true;
    } else {
      _offAddStaff = true;
      _offEdit = true;
      _offRemoveStaff = true;
      _offAddDeduction = true;
      _offDeductTitle = false;
      _offTextGroup = true;
      _offBtSubmit = true;
      _offBtCancelSubmit = true;
      _offContButton = true;
      _isAbsorbing = true;
      _textReadOnly = true;
    }
  }

  void _convertToJsonData() {
    GroupCheckData groupCheckData = new GroupCheckData();
    groupCheckData.checkId = StaticData.checkId;
    groupCheckData.areaId = StaticData.areaId;
    groupCheckData.areaGroupId = StaticData.areaGroupId;
    groupCheckData.checkDate = _checkDate;
    groupCheckData.groupName = _groupControl.text;
    var jsondata = groupCheckData.toJson();
    _dataJson = json.encode(jsondata);
    _detailUserjson = json.encode(_checkMemberList);
  }

  //用于详细、删除、提交、取消提交
  void _request(int checkId, String action) async {
    setPageDataChanged(this.widget, true);
    if (_deductofDeptList.length == 0 && action == "submit") {
      DialogUtils.showToast("检查记录不能为空！");
      return;
    }
    var result = await SevensCheckService.getRequstResult(checkId, action);
    _handlerRequestData(result, action, false);
  }

//保存、修改、评分
  void _requestData(String action, bool confirm) async {
    setPageDataChanged(this.widget, true);
    if (StaticData.areaGroupId == null) {
      DialogUtils.showToast("区域不能为空！");
      return;
    } else if (_groupControl.text.isEmpty) {
      DialogUtils.showToast("分组不能为空！");
      return;
    } else if (_checkMemberList.length == 0) {
      DialogUtils.showToast("组员不能为空！");
      return;
    }
    _convertToJsonData();
    var result = await SevensCheckService.getRequstResult1(
        _dataJson, _detailUserjson, action, confirm);
    _handlerRequestData(result, action, confirm);
  }

  void _handlerRequestData(Map result, String action, bool confirm) {
    if (result == null) return;
    _groupCheckModel = GroupCheckModel.fromJson(result);
    if (_groupCheckModel.errCode != 0) {
      DialogUtils.showConfirmDialog(context, _groupCheckModel.errMsg,
          iconData: Icons.info, color: Colors.red);
      return;
    } else {
      if (action == 'add' || action == 'update') {
        confirm == false
            ? DialogUtils.showToast("保存成功")
            : DialogUtils.showToast("开始评分");
      } else if (action == 'delete') {
        DialogUtils.showToast("删除成功");
        Navigator.pop(context);
        return;
      } else if (action == 'to_draft') {
        DialogUtils.showToast("已进入草稿状态");
      } else if (action == 'submit') {
        DialogUtils.showToast("提交成功");
      } else if (action == 'submit_undo') {
        DialogUtils.showToast("取消成功");
      }
    }
    if (mounted) {
      setState(() {
        _textGroupFocus.unfocus();
        StaticData.checkId = _groupCheckModel.data[0].checkId;
        StaticData.areaId = _groupCheckModel.data[0].areaId;
        _areaValue = _groupCheckModel.data[0].areaName;
        _handlerAreaSelect();
        StaticData.areaGroupId = _groupCheckModel.data[0].areaGroupId;
        StaticData.isAllDept = _isAllDept();
        _areaGroupValue = _groupCheckModel.data[0].areaGroupName;
        //如果复制新增
        if (StaticData.isCopyAdd && action == 'get_detail') {
          _checkDate = DateTime.now();
          StaticData.status = 0;
          _statusName = '草稿';
          StaticData.checkId = 0;
          _groupControl.text = _groupCheckModel.data[0].groupName;
          _statusControl.text = _statusName;
          _checkMemberList = _groupCheckModel.detailUser;
          // _deductofDeptList = _groupCheckModel.detailDept;
        } else {
          _checkDate =
              DateTime.parse(_groupCheckModel.data[0].checkDate.toString());
          StaticData.status = _groupCheckModel.data[0].status;
          _statusName = _groupCheckModel.data[0].statusName;
          _groupControl.text = _groupCheckModel.data[0].groupName;
          _statusControl.text = _statusName;
          _checkMemberList = _groupCheckModel.detailUser;
          _deductofDeptList = _groupCheckModel.detailDept;
        }

        _countDeduct();
        _setWidgetOffStage();
        _areaDropDown = _getAreaDroupDown();
      });
    }
  }

  bool _isAllDept() {
    bool isAllDept = false;
    var areaGroupList = SevensBaseDBModel.baseDBModel.areaGroupList;
    areaGroupList.forEach((item) {
      if (StaticData.areaGroupId == item.areaGroupId) {
        isAllDept = item.allDept;
      }
    });
    return isAllDept;
  }
}

class StaticData {
  static int status = 0;
  static int areaId;
  static int areaGroupId;
  static bool isAllDept;
  static int checkId;
  static bool isCopyAdd;
}
