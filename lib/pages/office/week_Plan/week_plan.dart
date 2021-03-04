import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/week_plan_basedb.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/model/week_plan_proj.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/week_plan_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:provide/provide.dart';

class WeekPlanPage extends StatefulWidget {
  @override
  _WeekPlanPageState createState() => _WeekPlanPageState();
}

class _WeekPlanPageState extends State<WeekPlanPage> {
  int _staffId = UserProvide.currentUser.staffId;
  int _option = 0;
  List<ChargeStaff> _staffList = [];
  List<WeekPlanProjData> _projList = [];
  List<DropdownMenuItem> _staffItems = [];
  EasyRefreshController _refreshController = EasyRefreshController();
  // TextEditingController _keyWordsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _getlist(true);
    _getBaseDb();
  }

  void _getBaseDb() async {
    if (WeekPlanStatusModel.statusList.length == 0) {
      WeekPlanStatusModel model = await WeekPlanService.getbaseDb();
      WeekPlanStatusModel.statusList = model.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('项目列表'),
      ),
      body: Container(
        child: Column(
          children: [
            staffSelect,
            _statusTypeRadio,
            // _searchViewCustom(_keyWordsCtrl, () {}),
            _listView,
            Row(children: [customButtom(Colors.blue, '新增项目', _add)]),
          ],
        ),
      ),
    );
  }

  void _add() async {
    _setDetail();
    bool changed = await navigatePage(context, weekPlanDetailPath);
    if (changed) _getlist(true);
  }

  Widget get _statusTypeRadio {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
      height: 40,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: Row(
              children: [
                Radio<int>(
                    value: 0,
                    groupValue: _option,
                    onChanged: (value) {
                      setState(() {
                        _option = value;
                      });
                      _getlist(true);
                    }),
                Text('全部'),
              ],
            ),
          )),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: Row(
              children: [
                Radio<int>(
                    value: 1,
                    groupValue: _option,
                    onChanged: (value) {
                      setState(() {
                        _option = value;
                      });
                      _getlist(true);
                    }),
                Text('未结案'),
              ],
            ),
          )),
          Expanded(
              child: Container(
            alignment: Alignment.center,
            child: Row(
              children: [
                Radio<int>(
                    value: 2,
                    groupValue: _option,
                    onChanged: (value) {
                      setState(() {
                        _option = value;
                      });
                      _getlist(true);
                    }),
                Text('已结案'),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget get staffSelect {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 8, 6, 6),
      margin: EdgeInsets.fromLTRB(6, 8, 6, 6),
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          customText(value: '负责人: '),
          Expanded(
            child: DropdownButton(
                isDense: true,
                isExpanded: true,
                underline: Container(),
                value: _staffId,
                items: _staffItems,
                onChanged: (v) {
                  setState(() {
                    _staffId = v;
                    _getlist(true);
                  });
                }),
          ),
          InkWell(
            onTap: () {
              DialogUtils.showToast('您的周工作目标书已存在');
            },
            child: Container(
              margin: EdgeInsets.only(right: 5),
              child: Icon(
                Icons.person_add,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _listView {
    return Expanded(
      child: Container(
        // color: Colors.grey[100],
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: EasyRefresh(
          controller: _refreshController,
          header: customRefreshHeader,
          footer: customRefreshFooter,
          firstRefresh: true,
          firstRefreshWidget: refreshWidget,
          child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                WeekPlanProjData item = _projList[index];
                Color color =
                    ((index % 2) == 0) ? Colors.white : Colors.grey[100];
                return _item(item, color);
              },
              separatorBuilder: (context, index) {
                return Divider(height: 0.5);
              },
              itemCount: _projList.length),
          onRefresh: () async {
            _getlist(true);
          },
          // onLoad: () async {
          //   _getlist(false);
          // },
        ),
      ),
    );
  }

  Widget _item(WeekPlanProjData item, Color color) {
    String begin = Utils.dateTimeToStr(item.planStartDate);
    String end = Utils.dateTimeToStr(item.planEndDate);
    return InkWell(
      onTap: () async {
        _setDetail(projId: item.projId);
        bool changed = await navigatePage(context, weekPlanDetailPath,
            arguments: item.projId);
        if (changed) _getlist(true);
      },
      child: Card(
        child: Container(
          color: color,
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              customText(
                value: item.projNumStar + "、" + item.projNameStar,
                fontWeight: FontWeight.w600,
                fontSize: 14.5,
                color: getColor(item),
              ),
              Container(height: 1),
              customText(
                  value: '状态:${item.projStatusName ?? ''}', fontSize: 13.5),
              Container(height: 2),
              customText(value: '项目编码: WPC${item.projId}', fontSize: 13.5),
              // Container(height: 1),
              // customText(
              //     value: '状态:${item.projStatusName ?? ''}', fontSize: 14),
              Container(height: 2),
              customText(value: '计划时间: ' + begin + ' 至 ' + end, fontSize: 13.5),
              Container(height: 2),
              customText(value: '目标: ' + item.projObj, fontSize: 13.5),
              Container(height: 2),
              customText(value: '状况: ' + item.statusRemarks, fontSize: 13.5)
            ],
          ),
        ),
      ),
    );
  }

  void _getlist(bool refresh) async {
    _projList.clear();
    WeekPlanProjModel model = await WeekPlanService.getList(_staffId, _option);
    _staffList = model.staffList;
    _projList = model.projList;
    _staffItems.clear();
    _staffList.forEach((element) {
      _staffItems.add(DropdownMenuItem(
          value: element.staffId, child: customText(value: element.staffName)));
    });
    _refreshController.finishRefresh(success: true);
    if (mounted) {
      setState(() {});
    }
  }

  void _setDetail({int projId}) async {
    WeekPlanDtlModel detailModel = new WeekPlanDtlModel(partners: []);

    if (projId != null) {
      detailModel = await WeekPlanService.requestData('detail', projId);
    } else {
      // detailModel = await WeekPlanService.requestData('detail', 0);
      Partner partner = new Partner();
      partner.isDefault = true;
      partner.staffName = UserProvide.currentUser.staffName;
      partner.staffId = UserProvide.currentUser.staffId;
      detailModel.partners.add(partner);
      detailModel.projData = WeekPlanProjData();
      detailModel.projData.planStartDate = Utils.today;
      detailModel.projData.planEndDate = Utils.today;
      detailModel.projData.location = UserProvide.currentUserAreaName;
    }
    await Provide.value<WeekPlanProvide>(context).setDetailData(detailModel);
  }
}

Color getColor(WeekPlanProjData item) {
  Color color = Colors.black54;
  int status = item.projStatus;
  if (status == 10) {
    //进行中
    color = Colors.blue;
  } else if (status == 50) {
    //暂停
    color = Colors.purple;
  } else if (status == 20) {
    //结案
    color = Colors.black;
  } else if (status == 45) {
    //先结案、待付款
    color = Colors.black;
  }
  return color;
}
