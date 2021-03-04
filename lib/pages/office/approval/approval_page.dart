import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/approval.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/approval_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/loading_indicator.dart';

class ApprovalPage extends StatefulWidget {
  ApprovalPage({Key key}) : super(key: key);

  @override
  _ApprovalPageState createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage>
    with SingleTickerProviderStateMixin {
  static const String _pendingTitle = '待审';
  static const String _defaultDocType = '(全部)';

  TabController _tabController; //
  // List _tabs = ["待审", "已审(未完成)"];
  List<ApprovalModel> _pendingList;
  List<ApprovalModel> _approvaledList;
  List<String> _docTypeList;
  bool _loadingPending;
  bool _loadingApprovaled;
  int _approvaledDaysValue = 0;
  int _selectedDayIndex = 0;
  String _selectedDocType = _defaultDocType;

  @override
  void initState() {
    super.initState();

    // _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController = TabController(length: 2, vsync: this);
    _pendingList = List();
    _approvaledList = List();
    _docTypeList = List();
    _updateDocType();

    DataCache.clearApprovalCacheList();
    _getApprovaledDays(false);
    _refreshData(true);
  }

  @override
  void dispose() {
    DataCache.clearApprovalCacheList();

    super.dispose();
  }

  void _getApprovaledDays(bool refreshingData) {
    int daysValue = ApprovalService.getApprovaledDaysValue();
    _selectedDayIndex = ApprovalService.currentApprovaledDaysIndex;

    if (_approvaledDaysValue != daysValue) {
      setState(() {
        _approvaledDaysValue = daysValue;
      });

      if (refreshingData) {
        _loadApprovaled();
      }
    }
  }

  Future<void> _showApprovaledDaysDialog() async {
    int index = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        var child = Column(
          children: <Widget>[
            ListTile(title: Text("查看已审天数")),
            Expanded(
              child: ListView.builder(
                itemCount: ApprovalService.approvaledDaysItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return RadioListTile<int>(
                    value: index,
                    title: Text(ApprovalService.approvaledDaysItems[index]),
                    groupValue: _selectedDayIndex,
                    onChanged: (value) {
                      Navigator.of(context).pop(index);
                    },
                  );
                },
              ),
            ),
          ],
        );
        //使用AlertDialog会报错
        //return AlertDialog(content: child);

        return Dialog(child: child);
      },
    );
    if (index != null) {
      ApprovalService.setApprovaledDaysIndex(index);

      _getApprovaledDays(true);
    }
  }

  void _refreshData(bool showLoading) {
    if (showLoading) {
      _loadingPending = true;
    }
    _loadPending();

    if (showLoading) {
      _loadingApprovaled = true;
    }

    _loadApprovaled();
  }

  @override
  Widget build(BuildContext context) {
    String approvaledTitle = '已审($_approvaledDaysValue天)';

    return Scaffold(
      appBar: AppBar(
        title: Text('审批'),
        bottom: TabBar(
          //生成Tab菜单
          controller: _tabController,
          // tabs: _tabs.map((e) => Tab(text: e)).toList(),
          tabs: [Tab(text: _pendingTitle), Tab(text: approvaledTitle)],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _openSetting();
            },
          ),
          _docTypePopupMenu,
        ],
      ),
      body: SafeArea(
        child: TabBarView(
          // physics: NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: [
            _pendingListWidget,
            _approvaledListWidget,
          ],
        ),
      ),
    );
  }

  Widget get _docTypePopupMenu {
    return PopupMenuButton<String>(
      icon: Icon(Icons.playlist_play),
      color: Colors.black,
      onSelected: _onPopupMenuItemSelected,
      offset: Offset(0, kToolbarHeight),
      itemBuilder: (BuildContext context) {
        return _docTypeList.map((String e) {
          return _popupMenuItem(e);
        }).toList();
      },
    );
  }

  void _onPopupMenuItemSelected(String value) {
    setState(() {
      _selectedDocType = value;
    });
  }

  PopupMenuItem<String> _popupMenuItem(String value) {
    return PopupMenuItem(
      value: value,
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: ConstValues.detailFontSize,
      ),
      height: ScreenUtil().setHeight(80),
      child: Text(value),
    );
  }

  Widget get _pendingListWidget {
    // return _loadingPending
    //     ? LoadingIndicator()
    //     : EasyRefresh(
    //         child: ListView.separated(
    //           itemCount: _pendingList.length,
    //           itemBuilder: (BuildContext context, int index) {
    //             return _approvalWidget(_pendingList[index]);
    //           },
    //           separatorBuilder: (BuildContext context, int index) {
    //             return Divider(
    //               height: 10.0,
    //               thickness: 10.0,
    //             );
    //           },
    //         ),
    //         onRefresh: () async {
    //           _loadPending();
    //         },
    //       );

    /*
    return Column(
      children: [
        Expanded(
          child: _listWidget(_pendingList, _loadingPending, false, () async {
            _loadPending();
          }),
        ),
        _docTypeWidget,
      ],
    );
    */

    return _listWidget(_pendingList, _loadingPending, false, () async {
      _loadPending();
    });
  }

  /*
  Widget get _docTypeWidget {
    return Row(
      children: [
        Icon(
          Icons.filter_list,
          color: secondaryColor,
        ),
        Expanded(
          child: DropdownButton<String>(
            value: _selectedDocType,
            items: _docTypeList.map((String item) {
              return DropdownMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: defaultThemeColor,
                        fontSize: ConstValues.defaultFontSize,
                      ),
                    ),
                  ],
                ),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: (String value) {
              setState(() {
                _selectedDocType = value;
              });
            },
          ),
        ),
      ],
    );
  }
  */

  Widget get _approvaledListWidget {
    return _listWidget(_approvaledList, _loadingApprovaled, true, () async {
      _loadApprovaled();
    });
  }

  int get _pendingItemCount {
    if (_selectedDocType == _defaultDocType) {
      return _pendingList.length;
    }

    return _pendingList
        .where((element) => element.docTypeName == _selectedDocType)
        .length;
  }

  int _pendingItemIndex(int index) {
    if (_selectedDocType == _defaultDocType) {
      return index;
    }

    List<ApprovalModel> list = _pendingList
        .where((element) => element.docTypeName == _selectedDocType)
        .toList();
    return _pendingList.indexOf(list[index]);
  }

  Widget _listWidget(List<ApprovalModel> list, bool loadingFlag,
      bool isApprovaled, Function onRefresh) {
    int itemCount = isApprovaled ? list.length : _pendingItemCount;
    return EasyRefresh(
      child: loadingFlag
          ? Container(
              padding: EdgeInsets.all(20.0),
              child: LoadingIndicator(),
            )
          : ListView.separated(
              // itemCount: list.length,
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                // ApprovalModel item = list[index];
                ApprovalModel item =
                    isApprovaled ? list[index] : list[_pendingItemIndex(index)];
                return InkWell(
                  child: _approvalWidget(item),
                  onTap: () {
                    if (!item.canSupport) {
                      DialogUtils.showToast('暂不支持此单据审批，请使用电脑版操作');
                    } else {
                      // DataCache.prepareApprovalHeadCache();
                      Navigator.pushNamed(context, approvalHandlePath,
                          arguments: {
                            'docType': item.docType,
                            'docId': item.docId,
                            'isApprovaled': isApprovaled
                          }).then((onValue) {
                        _refreshData(false);
                      });
                    }
                  },
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 10.0,
                  thickness: 10.0,
                );
              },
            ),
      onRefresh: onRefresh,
      emptyWidget: !loadingFlag && (list.length == 0)
          ? Center(child: Text('暂无数据'))
          : null,
    );
  }

  Widget _approvalWidget(ApprovalModel item) {
    return Container(
      padding: EdgeInsets.all(5.0),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                '[${item.seqNo}]',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(
                width: 4.0,
              ),
              Visibility(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Icon(
                    Icons.lens,
                    color: Colors.red,
                    size: 6.0,
                  ),
                ),
                visible: !item.canSupport,
              ),
              Expanded(
                child: Text(
                  '${item.code}',
                  style: TextStyle(fontSize: fontSizeDefault),
                ),
              ),
              Text(
                '${Utils.dateTimeToStr(item.createDate)}',
                style: TextStyle(color: defaultFontColor),
              ),
              Expanded(
                  child: Text(
                '${item.docTypeName}',
                textAlign: TextAlign.end,
                style: TextStyle(color: defaultFontColor),
              )),
            ],
          ),
          Row(
            children: <Widget>[
              // 用于占位，与上一行对齐
              Visibility(
                child: Text('[${item.seqNo}]'),
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: false,
              ),
              SizedBox(
                width: 4.0,
              ),
              Expanded(
                child: Text(
                  '${item.operator}',
                  style: TextStyle(fontSize: fontSizeDefault),
                ),
              ),
              Text(
                '${item.status}',
                style: TextStyle(color: defaultFontColor),
              ),
              Icon(
                Icons.arrow_right,
                color: Colors.blue,
              ),
              Text(
                '${item.operation}',
                style: TextStyle(color: Colors.red),
              ),
              Expanded(
                  child: Text(
                '${item.areaName}',
                textAlign: TextAlign.end,
                style: TextStyle(color: defaultFontColor),
              )),
            ],
          ),
          if (!Utils.textIsEmptyOrWhiteSpace(item.remarks))
            Text(
              '${item.remarks}',
              style: TextStyle(color: Colors.blue, fontSize: fontSizeDetail),
            ),
        ],
      ),
    );
  }

  void _openSetting() {
    _showApprovaledDaysDialog();
  }

  void _loadPending() async {
    List<ApprovalModel> list = await ApprovalService.getPending();

    _pendingList = list;
    _loadingPending = false;
    _selectedDocType = _defaultDocType;
    _updateDocType();
    setState(() {});

    DataCache.setApprovalCacheList(list);
    DataCache.prepareApprovalHeadCache();
    // print(list);
  }

  void _updateDocType() {
    _docTypeList.clear();
    _docTypeList.add(_defaultDocType);
    _pendingList.forEach((element) {
      if (!_docTypeList.contains(element.docTypeName)) {
        _docTypeList.add(element.docTypeName);
      }
    });
  }

  void _loadApprovaled() async {
    List<ApprovalModel> list =
        await ApprovalService.getApprovaled(_approvaledDaysValue);

    setState(() {
      _approvaledList = list;
      _loadingApprovaled = false;
    });
    // print(list);
  }
}
