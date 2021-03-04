import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/businessPlan_list.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/businessPlan_service.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
// import 'package:progress_dialog/progress_dialog.dart';

class BusinessPlanListPage extends StatefulWidget {
  @override
  _BusinessPlanListPageState createState() => _BusinessPlanListPageState();
}

class _BusinessPlanListPageState extends State<BusinessPlanListPage> {
  bool _hasMoreData = true;
  List<BusinessPlanData> _businesslist = [];
  TextEditingController _keywordCtrl = TextEditingController();
  EasyRefreshController _easyRefreshCtrl = EasyRefreshController();
  // FLToastDefaults _flToastDefaults = FLToastDefaults();
  // ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getBaseDb();
      // _getList(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('出差计划列表'),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebViewPage(
                  arguments: {
                    'title': '出差计划',
                    'url': serviceUrl[businessPlanHelpUrl]
                  },
                );
              }));
            },
            child: Container(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.help_outline),
            ),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            searchViewCustom(_keywordCtrl, _search),
            _listView(),
            _addBt()
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return Container(
      child: Expanded(
        child: EasyRefresh(
          controller: _easyRefreshCtrl,
          firstRefresh: true,
          firstRefreshWidget: refreshWidget,
          header: customRefreshHeader,
          footer: customRefreshFooter,
          child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(height: 1, indent: 8, endIndent: 8);
              },
              itemCount: _businesslist.length,
              itemBuilder: (context, index) {
                BusinessPlanData item = _businesslist[index];
                return _item(item);
              }),
          onRefresh: () async {
            _getList(true);
          },
          onLoad: () async {
            _getList(false);
          },
        ),
      ),
    );
  }

  Widget _addBt() {
    return Row(
      children: <Widget>[
        customButtom(Colors.blue, '新增', _add),
      ],
    );
  }

  void _add() async {
    Utils.closeInput(context);
    bool changed = await navigatePage(context, businessPlanDataPath);
    if (changed) _getList(true);
  }

  Widget _item(BusinessPlanData item) {
    String begin =
        Utils.dateTimeToStr(item.beginDate, pattern: 'yyyy-MM-dd HH:mm');
    String end = Utils.dateTimeToStr(item.endDate, pattern: 'yyyy-MM-dd HH:mm');
    return Dismissible(
      background: deleteBg(),
      key: Key(item.businessPlanId.toString()),
      confirmDismiss: (DismissDirection direction) {
        return _delete(item);
      },
      // actionPane: SlidableDrawerActionPane(),
      // actions: <Widget>[
      //   IconSlideAction(
      //     onTap: () {
      //       if (item.status < 10) {
      //         _delete(item);
      //       } else {
      //         DialogUtils.showToast('当前状态不能删除');
      //       }
      //       ;
      //     },
      //     icon: Icons.delete_outline,
      //     caption: '删除',
      //     color: item.status < 10 ? Colors.red : Colors.grey,
      //     foregroundColor: Colors.white,
      //   )
      // ],
      child: InkWell(
        onTap: () async {
          bool dataChanged = await navigatePage(context, businessPlanDataPath,
              arguments: item.businessPlanId);
          if (dataChanged) _getList(true);
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: customText(
                            value: item.emps,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 5),
                        child: Text(
                          item.statusName,
                          style: statusNameTextStyle(item.statusName),
                        ),
                      ),
                    ],
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 3, bottom: 1),
                      child: customText(value: item.planType, fontSize: 14)),
                  Container(
                      padding: EdgeInsets.only(top: 2, bottom: 1),
                      child:
                          customText(value: begin + ' - ' + end, fontSize: 14)),
                  Container(
                      padding: EdgeInsets.only(top: 2),
                      child: customText(value: item.reason, fontSize: 14)),
                ],
              )),

              // Expanded(
              //     child: Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   // crossAxisAlignment: CrossAxisAlignment.start,
              //   children: <Widget>[
              //     Text(
              //       item.statusName,
              //       style: statusNameTextStyle(item.statusName),
              //     ),
              //     customText(value: begin, fontSize: 14),
              //     customText(value: end, fontSize: 14),
              //   ],
              // ))
            ],
          ),
        ),
      ),
    );
  }

//获取地区人员数据
  void _getBaseDb() async {
    BaseDbModel.baseDbModel = await UserService.getBaseDb();
  }

  void _search() {
    _getList(true);
  }

  //获取列表和基础数据
  void _getList(bool refresh) async {
    if (refresh) {
      _businesslist.clear();
      _hasMoreData = true;
    }
    if (!_hasMoreData) return;
    // Function dismiss = FLToast.showLoading();
    // await _progressDialog?.show();
    int maxId = refresh ? 0 : _businesslist.last.businessPlanId;

    try {
      BusinessPlanListModel model =
          await BusinessPlanService.getList(_keywordCtrl.text, maxId);
      if (BusinessSData.typeList.length == 0) {
        BusinessSData.typeList = model.planType;
        BusinessSData.vehicleKindList = model.vehicleKind;
      }
      if (model.businesslist.length > 0) {
        _businesslist.addAll(model.businesslist);
        if (refresh) {
          _easyRefreshCtrl.resetLoadState();
          // _easyRefreshCtrl.finishRefresh(success: true, noMore: false);
        } else {
          // _easyRefreshCtrl.finishLoad(success: true, noMore: false);
        }
      } else {
        _hasMoreData = false;
        _easyRefreshCtrl.finishLoad(success: true, noMore: true);
      }
      setState(() {});
    } finally {
      // await _progressDialog.hide();
    }
  }

  Future<bool> _delete(BusinessPlanData item) async {
    bool isDelete = false;
    if (item.status >= 10) {
      DialogUtils.showToast(item.statusName + '状态不能删除此单据');
      return false;
    }
    bool result = await DialogUtils.showConfirmDialog(context, '是否删除该条出差计划单？',
        iconData: Icons.info, color: Colors.red);
    if (result == true) {
      await BusinessPlanService.delete(item.businessPlanId).then((value) {
        if (value['ErrCode'] == 0) {
          isDelete = true;
          _businesslist.remove(item);
          setState(() {});
          DialogUtils.showToast('删除成功');
        } else {
          DialogUtils.showConfirmDialog(context, value['ErrMsg']);
        }
      });
    }
    return isDelete;
  }
}
