import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/boiler_feeding.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/boiler_feeding_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class BoilerFeedingPage extends StatefulWidget {
  @override
  _BoilerFeedingPageState createState() => _BoilerFeedingPageState();
}

class _BoilerFeedingPageState extends State<BoilerFeedingPage> {
  List<BoilerFeedingModel> _feedingList = [];
  TextEditingController _keywordController = TextEditingController();
  EasyRefreshController _refreshController = EasyRefreshController();
  bool _hasMoreData = true;
  // ProgressDialog _progressDialog;
  // FLToastDefaults _toastDefaults = FLToastDefaults();
  // bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // BoilerFeedingService.maxId = 0;
    BFStcData.isUpdate = false;
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('锅炉投料'),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return WebViewPage(
                  arguments: {
                    'title': '锅炉投料',
                    'url': serviceUrl[boilerFeedingHelpUrl]
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
            searchViewCustom(_keywordController, _search),
            _listView(),
            Row(
              children: <Widget>[customButtom(Colors.blue, '新增', _add)],
            )
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    Divider divider = Divider(height: 0.2, color: Colors.grey);
    return Expanded(
      child: EasyRefresh(
        // firstRefresh: true,
        enableControlFinishRefresh: true,
        enableControlFinishLoad: true,
        controller: _refreshController,
        header: customRefreshHeader,
        footer: customRefreshFooter,
        firstRefresh: true,
        firstRefreshWidget: refreshWidget,
        child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _slidable(index);
            },
            separatorBuilder: (context, index) {
              return divider;
            },
            itemCount: _feedingList.length),
        onRefresh: () async {
          _search();
        },
        onLoad: () async {
          // _feedingList.clear();
          _getList(false);
        },
      ),
    );
  }

  Widget _slidable(int index) {
    // return Slidable(
    //     actionPane: SlidableBehindActionPane(),
    //     // actionExtentRatio: 0.25,
    //     child: _item(index),
    //     secondaryActions: <Widget>[
    //       IconSlideAction(
    //         caption: '删除',
    //         closeOnTap: true,
    //         color: Colors.red,
    //         icon: Icons.delete,
    //         onTap: () async {
    //           if (await DialogUtils.showConfirmDialog(context, '确定要删除当前项吗？',
    //               confirmText: '删除', confirmTextColor: Colors.red)) {
    //             _delete(index, _feedingList[index].meterRecordId);
    //           }
    //         },
    //       ),
    //     ]);

    String key = _feedingList[index].meterRecordId.toString();
    return Dismissible(
        key: Key(key),
        background: deleteBg(),
        confirmDismiss: (DismissDirection dismissDirection) {
          dismissDirection = DismissDirection.startToEnd;
          return _delete(index, int.parse(key));
        },
        child: _item(index));
  }

  Widget _item(int index) {
    BoilerFeedingModel item = _feedingList[index];
    String time =
        Utils.dateTimeToStr(item.readTime, pattern: 'yyyy-MM-dd HH:mm') ?? '';
    return InkWell(
      onTap: () {
        BFStcData.recoardId = item.meterRecordId;
        _navigatorTodetail();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customText(
                    value: item.fuelDeviceName + '-' + item.fuelName,
                    color: Colors.blue),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  child: Container(
                    // padding: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: customText(
                      value: '投料重：' + item.readQty.toString() + item.uom,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            )),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                customText(
                  value: item.areaName,
                  fontSize: 14,
                ),
                Container(
                    margin: EdgeInsets.only(top: 4),
                    child: customText(
                      value: time,
                      fontSize: 14,
                    ))
              ],
            ))
          ],
        ),
      ),
    );
  }

  void _getList(bool isRefresh) async {
    if (isRefresh) {
      _hasMoreData = true;
      _feedingList.clear();
    }
    if (!_hasMoreData) return;
    int maxid = isRefresh ? 0 : _feedingList.last.meterRecordId;

    String keyword = _keywordController.text;
    List<BoilerFeedingModel> list =
        await BoilerFeedingService.getList(keyword, maxid);
    if (!mounted) return;
    if (list != null) {
      _feedingList.addAll(list);
      setState(() {});
      if (isRefresh) {
        _refreshController.finishRefresh(success: true);
      } else {
        _refreshController.finishLoad(success: true, noMore: false);
      }
    } else {
      _refreshController.finishLoad(success: true, noMore: true);
    }
  }

  Future<bool> _delete(int index, int id) async {
    bool isDelete = false;
    isDelete = await DialogUtils.showConfirmDialog(context, '是否删除？',
        iconData: Icons.info, color: Colors.red);
    if (isDelete) {
      await BoilerFeedingService.delete(id).then((value) {
        if (value['Success']) {
          DialogUtils.showToast('删除成功！');
          isDelete = true;
          setState(() {
            _feedingList.removeAt(index);
          });
        } else {
          String msg = value['Msg'];
          DialogUtils.showAlertDialog(context, msg);
          isDelete = false;
        }
      });
    }
    return isDelete;
  }

  void _add() {
    BFStcData.recoardId = 0;
    _navigatorTodetail();
  }

  /*
  void _navigatorTodetail({bool isDetail}) async {
    BFStcData.isUpdate = false;
    Utils.closeInput(context);
    bool dataChanged = await navigatePage(context, boilerFeedingAddPath);
    if (dataChanged) _search();
  }
  */
  void _navigatorTodetail() async {
    BFStcData.isUpdate = false;
    Utils.closeInput(context);
    bool dataChanged = await navigatePage(context, boilerFeedingAddPath);
    if (dataChanged) _search();
  }

  void _search() async {
    Utils.closeInput(context);
    _getList(true);
  }
}
