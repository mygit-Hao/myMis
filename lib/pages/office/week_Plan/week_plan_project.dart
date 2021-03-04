import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/model/week_plan_basedb.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/week_plan_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:provide/provide.dart';

class WeekPlanProjectPage extends StatefulWidget {
  final Map<String, dynamic> arguments;
  const WeekPlanProjectPage({Key key, this.arguments}) : super(key: key);

  @override
  _WeekPlanProjectPageState createState() => _WeekPlanProjectPageState();
}

class _WeekPlanProjectPageState extends State<WeekPlanProjectPage>
    with AutomaticKeepAliveClientMixin {
  final _margin = EdgeInsets.only(top: 5);
  final _padding = EdgeInsets.symmetric(horizontal: 6, vertical: 10);

  Color _color = Colors.black;
  // bool _isTCD = false;
  WeekPlanProjData _projData = WeekPlanProjData();
  List<Partner> _partnerList = [];

  List<DropdownMenuItem> _typeItems = [];
  List<DropdownMenuItem> _statusItems = [];
  TextEditingController _pNameController = TextEditingController();
  TextEditingController _areaController =
      TextEditingController(text: UserProvide.currentUserAreaName);
  TextEditingController _targetController = TextEditingController();
  TextEditingController _remarksController = TextEditingController();
  TextEditingController _disCribeController = TextEditingController();
  TextEditingController _changeController = TextEditingController();
  TextEditingController _mainPointController = TextEditingController();
  TextEditingController _requestController = TextEditingController();
  TextEditingController _putController = TextEditingController();
  TextEditingController _effectController = TextEditingController();
  GlobalKey _globalKey = GlobalKey();

  FLCountStepperController _progressController =
      FLCountStepperController(min: 0, max: 100, step: 10);
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initWeidget();
    _initData();
  }

  // @override
  // void dispose() {
  //   super.dispose();
  //   _progressController.dispose();
  // }

  void _initWeidget() {
    // _progressController = FLCountStepperController(min: 0, max: 100, step: 10);
    _typeItems.clear();
    _statusItems.clear();
    _typeItems
      ..add(DropdownMenuItem(
        child: customText(value: '计划内项目', color: _color),
        value: true,
      ))
      ..add(DropdownMenuItem(
        child: customText(value: '计划外项目', color: _color),
        value: false,
      ));
    WeekPlanStatusModel.statusList.forEach((element) {
      _statusItems.add(DropdownMenuItem(
        child: customText(value: element.statusName, color: _color),
        value: element.projStatus,
      ));
    });
  }

  void _initData() {}

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _project;
  }

  Widget get _project {
    return Provide<WeekPlanProvide>(
      builder: (context, child, detail) {
        _projData = detail.detailModel.projData ?? WeekPlanProjData();
        _partnerList = detail.detailModel.partners ?? [];
        _pNameController.text = _projData.projName;
        _areaController.text = _projData.location;
        _targetController.text = _projData.projObj;
        _remarksController.text = _projData.statusRemarks;
        _progressController.value = _projData.progress;
        _disCribeController.text = _projData.tCD1;
        _changeController.text = _projData.tCD2;
        _mainPointController.text = _projData.tCD3;
        _requestController.text = _projData.tCD4;
        _putController.text = _projData.tCD5;
        _effectController.text = _projData.tCD6;
        _color = _projData.readOnly ? Colors.black54 : Colors.black;
        _initWeidget();
        // _isTCD = _projData.tCD1 == '' ? false : true;
        return Form(
          key: _globalKey,
          // autovalidate: true,
          child: Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          // color: Colors.white,
                          child: Column(
                            children: [
                              _customTextField('项目名称', _pNameController),
                              _customTextField('目标', _targetController),
                              _customTextField('状况', _remarksController),
                              AbsorbPointer(
                                absorbing: _projData.readOnly,
                                child: Column(
                                  children: [
                                    _progressPercent(),
                                    _date(_projData),
                                    _type(_projData),
                                    _status(_projData),
                                  ],
                                ),
                              ),

                              // _customTextField('项目地点', _areaController),
                            ],
                          ),
                        ),
                        // Container(color: Colors.grey[200], height: 10),
                        _addMemberWidget(_partnerList),
                        _memberlistview(_partnerList),
                        _tcdWidget,
                      ],
                    ),
                  ),
                ),
                if (!_projData.readOnly) _draftStatueButtons(),
                // _submitStatusButtons(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _type(WeekPlanProjData projData) {
    return Container(
      margin: _margin,
      padding: _padding,
      color: Colors.grey[100],
      // decoration: containerDeroation(),
      child: Row(
        children: [
          customText(value: '计划类型：', color: _color),
          Expanded(
            child: DropdownButton(
                isDense: true,
                isExpanded: true,
                underline: Container(),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _projData.readOnly ? Colors.grey : Colors.blue,
                ),
                value: projData.planned,
                items: _typeItems,
                onChanged: (v) {
                  setState(() {
                    projData.planned = v;
                  });
                }),
          )
        ],
      ),
    );
  }

  Widget _status(WeekPlanProjData projData) {
    return Container(
      margin: _margin,
      padding: _padding,
      color: Colors.grey[100],
      // decoration: containerDeroation(),
      child: Row(
        children: [
          customText(value: '状态：', color: _color),
          Expanded(
            child: DropdownButton(
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: _projData.readOnly ? Colors.grey : Colors.blue,
                ),
                isDense: true,
                isExpanded: true,
                underline: Container(),
                value: projData.projStatus,
                items: _statusItems,
                onChanged: (v) {
                  setState(() {
                    projData.projStatus = v;
                  });
                  // projData.projStatus = v;
                }),
          )
        ],
      ),
    );
  }

  // Widget _singleChoiceChip(String label) {
  //   return ChoiceChip(label: Text(label), selected: true);
  // }

  Widget _customTextField(String label, TextEditingController controller) {
    return Container(
      // decoration: containerDeroation(),
      margin: _margin,
      child: Row(
        children: [
          // customText(value: label),
          Expanded(
            child: TextFormField(
              readOnly: _projData.readOnly,
              controller: controller,
              onChanged: (v) {
                _getFormData();
              },
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: controller == _pNameController
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: controller == _pNameController
                      ? getColor(_projData)
                      : _color),
              decoration: textFieldDecorationNoBorder(label: label),
              validator: (v) {
                return v.length > 0 ? null : '${'请输入' + label}';
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _progressPercent() {
    return Container(
      margin: _margin,
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      color: Colors.grey[100],
      // decoration: containerDeroation(),
      child: Row(
        children: [
          customText(value: '完成率:', color: _color),
          Expanded(
            child: FLCountStepper(
                controller: _progressController,
                disableInput: false, // default is true
                onChanged: (value) {
                  // setState(() {
                  //   _projData.progress = value;
                  // });
                  _projData.progress = value;
                }),
          ),
          // Text(_projData.progress.toString()),
          customText(value: '%'),
        ],
      ),
    );
  }

  Widget _date(WeekPlanProjData projData) {
    String begin = Utils.dateTimeToStr(projData.planStartDate);
    String end = Utils.dateTimeToStr(projData.planEndDate);
    return Container(
      margin: _margin,
      padding: _padding,
      color: Colors.grey[100],
      // decoration: containerDeroation(),
      child: Row(
        children: [
          customText(value: '计划时间：', color: _color),
          InkWell(
              onTap: () {
                DialogUtils.showDatePickerDialog(
                  context,
                  projData.planStartDate,
                  onValue: (val) {
                    setState(() {
                      projData.planStartDate = val;
                    });
                  },
                );
              },
              child: customText(value: begin, color: Colors.orange)),
          customText(value: ' 至 '),
          InkWell(
            onTap: () {
              DialogUtils.showDatePickerDialog(context, projData.planEndDate,
                  onValue: (val) {
                setState(() {
                  projData.planEndDate = val;
                });
              });
            },
            child: customText(value: end, color: Colors.orange),
          )
        ],
      ),
    );
  }

  Widget get _tcdWidget {
    return Container(
        child: Column(
      children: [
        Row(children: [
          customText(value: 'TCD:', color: _color),
          Switch(
              value: _projData.isTCD,
              onChanged: (v) {
                setState(() {
                  _projData.isTCD = v;
                });
              })
        ]),
        _projData.isTCD
            ? Column(
                children: [
                  _customTextField('现象定性定量描述', _disCribeController),
                  _customTextField('改善计划', _changeController),
                  _customTextField('执行要点', _mainPointController),
                  _customTextField('资源请求', _requestController),
                  _customTextField('投入成本', _putController),
                  _customTextField('预期效果', _effectController)
                ],
              )
            : Container(),
      ],
    ));
  }

  Widget _addMemberWidget(List<Partner> list) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
      child: Row(
        children: <Widget>[
          Expanded(
              child: customText(
                  value: '参与人',
                  color: Colors.blue,
                  fontWeight: FontWeight.w600)),
          if (_projData.projId != 0)
            InkWell(
              onTap: () {
                Utils.closeInput(context);
                if (!_projData.readOnly) _addPartner();
              },
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(3),
                    child: Icon(
                      Icons.person_add,
                      color: _projData.readOnly ? Colors.grey : Colors.blue,
                    ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _memberlistview(List<Partner> partnerList) {
    return ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          Partner item = partnerList[index];
          return _memberItem(partnerList, item);
        },
        separatorBuilder: (context, index) {
          return Divider(height: 0.5);
        },
        itemCount: partnerList.length);
  }

  Widget _memberItem(List<Partner> list, Partner item) {
    String def = "${item.isDefault ? '  (创建人)' : ''}";
    return Container(
        padding: EdgeInsets.only(top: 6, bottom: 6),
        child: Row(
          children: [
            Expanded(
                child: customText(
                    value: '${item.staffName + def}', color: _color)),
            if (!_projData.readOnly)
              item.isDefault
                  ? Container()
                  : InkWell(
                      onTap: () {
                        _removePartner(item);
                      },
                      child: Container(
                          padding: EdgeInsets.only(right: 3),
                          child:
                              Icon(Icons.cancel, color: Colors.grey, size: 17)),
                    )
          ],
        ));
  }

  Widget _draftStatueButtons() {
    return Container(
      child: Row(
        children: <Widget>[
          if (_projData.projId != 0 && !_projData.readOnly)
            customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
        ],
      ),
    );
  }

  void _addPartner() async {
    var result = await showSearch(
        context: context,
        delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff));
    if (result == '' || result == null) return;
    StaffModel staffModel = StaffModel.fromJson(jsonDecode(result));

    for (var item in _partnerList) {
      if (item.staffId == staffModel.staffId) {
        DialogUtils.showToast('参与人已存在');
        return;
      }
    }
    // Partner partner = new Partner();
    // partner.isDefault = false;
    // partner.staffName = staffModel.name;
    // partner.staffId = staffModel.staffId;
    // _partnerList.add(partner);
    List<int> list = _partnerList.map((e) => e.staffId).toList();
    list.add(staffModel.staffId);
    var response = await WeekPlanService.addPartner(_projData.projId, list);
    if (response.errCode == 0) {
      Provide.value<WeekPlanProvide>(context).setDetailData(response);
      DialogUtils.showToast('添加成功');
    } else {
      DialogUtils.showConfirmDialog(context, response.errMsg);
    }
  }

  void _removePartner(Partner item) async {
    bool result = await DialogUtils.showConfirmDialog(
        context, '是否移除参与人${item.staffName ?? ''}',
        color: Colors.red,
        iconData: Icons.info_outline,
        confirmTextColor: Colors.red);
    if (result == true)
      await WeekPlanService.deletePartner(_projData.projId, item.staffId)
          .then((value) {
        if (value.errCode == 0) {
          Provide.value<WeekPlanProvide>(context).setDetailData(value);
          DialogUtils.showToast('移除成功');
        } else {
          DialogUtils.showConfirmDialog(context, value.errMsg);
        }
      });
  }

  void _delete() async {
    Utils.closeInput(context);
    if (await DialogUtils.showConfirmDialog(context, '是否删除该项目？',
        iconData: Icons.info_outline,
        color: Colors.red,
        confirmTextColor: Colors.red)) {
      setPageDataChangedByRoute(weekPlanDetailPath, true);
      await WeekPlanService.requestData('delete-proj', _projData.projId)
          .then((value) {
        if (value.errCode == 0) {
          DialogUtils.showToast('删除成功');
          Navigator.pop(context);
        } else {
          DialogUtils.showToast(value.errMsg);
        }
      });
    }
  }

  void _save() async {
    // if ((_globalKey.currentState as FormState).validate()) {
    Utils.closeInput(context);
    if (_pNameController.text == '') {
      DialogUtils.showToast('项目名不能为空!');
    } else if (_targetController.text == '') {
      DialogUtils.showToast('目标不能为空!');
    } else if (_remarksController.text == '') {
      DialogUtils.showToast('状况不能为空!');
    } else if (_projData.planStartDate.isSameDate(_projData.planEndDate)) {
      DialogUtils.showToast('开始结束时间不能相等!');
    } else if (_projData.planStartDate.isAfter(_projData.planEndDate)) {
      DialogUtils.showToast('开始时间不能大于结束时间!');
    } else if (_partnerList.length == 0) {
      DialogUtils.showToast('参与人不能!');
    } else {
      setPageDataChangedByRoute(weekPlanDetailPath, true);
      _getFormData();
      await WeekPlanService.updateDetail(_projData).then((value) async {
        if (value.errCode == 0) {
          // DialogUtils.showToast('保存成功');
          // Provide.value<WeekPlanProvide>(context).setDetailData(value);
          ///保存参与人数据
          List<int> list = _partnerList.map((e) => e.staffId).toList();
          var response =
              await WeekPlanService.addPartner(value.projData.projId, list);
          if (response.errCode == 0) {
            Provide.value<WeekPlanProvide>(context).setDetailData(response);
            DialogUtils.showToast('保存成功');
          } else {
            DialogUtils.showConfirmDialog(context, response.errMsg);
          }
        } else {
          DialogUtils.showConfirmDialog(context, value.errMsg);
        }
      });
    }
    // }
  }

  void _getFormData() {
    _projData.projName = _pNameController.text;
    _projData.location = _areaController.text;
    _projData.projObj = _targetController.text;
    _projData.statusRemarks = _remarksController.text;
    _projData.progress = _progressController.value;
    _projData.tCD1 = _disCribeController.text;
    _projData.tCD2 = _changeController.text;
    _projData.tCD3 = _mainPointController.text;
    _projData.tCD4 = _requestController.text;
    _projData.tCD5 = _putController.text;
    _projData.tCD6 = _effectController.text;
  }
}
