import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/bill.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/critical_button.dart';
import 'package:mis_app/widget/sticky_header_container.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sticky_headers/sticky_headers.dart';

const int _pendingApprovalIndex = 0;
const int _undeliveredIndex = 1;
const int _deliveredIndex = 2;

class SalesOrderPage extends StatefulWidget {
  final Map arguments;
  SalesOrderPage({Key key, this.arguments}) : super(key: key);

  @override
  _SalesOrderPageState createState() => _SalesOrderPageState();
}

class _SalesOrderPageState extends State<SalesOrderPage>
    with TickerProviderStateMixin {
  List<bool> _dateFilterList;
  List<bool> _statusFilterList;
  CustModel _currentCust, _selectedCust;
  TextEditingController _keywordController = TextEditingController();
  List<Tab> _tabList = [
    Tab(text: '未完成'),
    Tab(text: '近1周'),
    Tab(
      child: Row(
        children: <Widget>[
          Text('自定义'),
          SizedBox(
            width: 4.0,
          ),
          Icon(
            Icons.filter_list,
            size: 16.0,
          ),
        ],
      ),
    )
  ];
  TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // List<BillModel> _billList = [];
  int _count;
  int _pendingApprovalCount;
  int _undeliveredCount;
  int _deliveredCount;
  int _loadedDeliveredCount = 0;
  List<BillModel> _pendingApprovalList = [];
  List<BillModel> _undeliveredList = [];
  List<BillModel> _deliveredList = [];
  List<Map<String, dynamic>> _viewList = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _initTab();

    if (widget.arguments != null) {
      _currentCust = CustModel.fromJson(widget.arguments);
    } else {
      _currentCust = CustModel();
    }
    _selectedCust = _currentCust;

    _initData();
    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadDataByIndex(0);
    });
  }

  void _initTab() {
    _tabController = TabController(vsync: this, length: _tabList.length)
      ..addListener(() {
        int index = _tabController.index;

        // 如果是最后一项（自定义）打开drawer
        if ((_tabController.indexIsChanging) &&
            (index == (_tabList.length - 1))) {
          _openDrawer();
          return;
        }

        // 如果不是最后一项就直接加载数据
        // 解决重复触发事件的问题
        if ((_tabController.index.toDouble() ==
                _tabController.animation.value) &&
            (index < (_tabList.length - 1))) {
          _loadDataByIndex(index);
        }
      });
  }

  void _buildViewList(List<BillModel> list) {
    _viewList.clear();

    _pendingApprovalList.clear();
    _undeliveredList.clear();
    _deliveredList.clear();

    for (BillModel item in list) {
      if (item.status == BillModel.statusPendingApproval) {
        _pendingApprovalList.add(item);
      } else if (item.status == BillModel.statusDelivered) {
        _deliveredList.add(item);
      } else {
        _undeliveredList.add(item);
      }
    }

    if (_pendingApprovalList.length > 0) {
      _viewList.add({
        'index': _pendingApprovalIndex,
        'name': '未审批',
        'data': _pendingApprovalList,
        'count': _pendingApprovalCount
      });
    }

    if (_undeliveredList.length > 0) {
      _viewList.add({
        'index': _undeliveredIndex,
        'name': '待送货',
        'data': _undeliveredList,
        'count': _undeliveredCount
      });
    }

    if (_deliveredList.length > 0) {
      _viewList.add({
        'index': _deliveredIndex,
        'name': '已送货',
        'data': _deliveredList,
        'count': _deliveredCount
      });
    }
  }

  /// 按index查找显示列表_viewList中的项目
  Map<String, dynamic> _findList(int index) {
    for (Map<String, dynamic> item in _viewList) {
      if (item['index'] == index) {
        return item;
      }
    }

    return null;
  }

  void _loadDataByIndex(int index) {
    if (index == 0) {
      // 未完成
      _dateFilterList = [false, false, true];
      _statusFilterList = [true, true, false];
    } else {
      // 1周内
      _dateFilterList = [true, false, false];
      _statusFilterList = [true, true, true];
    }
    _keywordController.text = '';
    setState(() {});

    _loadData();
  }

  void _openDrawer() {
    if ((!_scaffoldKey.currentState.isDrawerOpen)) {
      _scaffoldKey.currentState.openEndDrawer();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('销售跟踪'),
      ),
      endDrawer: _drawer,
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              if (_currentCust.custId > 0) _custWidget,
              Container(
                decoration: BoxDecoration(
                  // color: Theme.of(context).primaryColor,
                  color: backgroundColor,
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  indicatorColor: Colors.pink,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: _tabList,
                  onTap: (int index) {
                    if (index == _tabList.length - 1) {
                      _openDrawer();
                    }
                  },
                ),
              ),
              Expanded(
                child: Container(
                  child: _listWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      /*
      child: ListView.separated(
        // shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          BillModel item = _billList[index];
          return _itemWidget(item);
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: _billList.length,
      ),
      */

      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return StickyHeader(
            header: StickyHeaderContainer(
                title:
                    '${_viewList[index]["name"]} (${_viewList[index]["count"]})'),
            content: Column(
              children: _buildGroup(_viewList[index]['data']),
            ),
          );
        },
        itemCount: _viewList.length,
      ),
      onRefresh: () async {
        _loadData();
      },
      onLoad: () async {
        _loadMoreData();
      },
    );
  }

  List<Widget> _buildGroup(List<BillModel> list) {
    return list.map((item) {
      return InkWell(
        onTap: () {
          Navigator.pushNamed(context, billDetailPath, arguments: {
            'billType': item.billType,
            'billId': item.billId,
          });
        },
        child: _itemWidget(item, item == list[list.length - 1]),
      );
    }).toList();
  }

  void _loadMoreData() async {
    if (_loadedDeliveredCount >= _deliveredCount) return;

    List<BillModel> list = await SalesService.getDeliveredSalesOrder(
        _currentCust.custId,
        _keywordController.text ?? '',
        _dateOption,
        _loadedDeliveredCount + 1);
    // _billList.addAll(list);

    // 对显示列表 _viewList 中查找对应项目追加新数据
    Map<String, dynamic> item = _findList(_deliveredIndex);
    if (item != null) {
      item['data'].addAll(list);
    }

    _loadedDeliveredCount += list.length;

    setState(() {});
  }

  Widget _itemWidget(BillModel item, bool isLast) {
    bool showContactInfo = !Utils.textIsEmptyOrWhiteSpace(item.contactInfo) &&
        (item.status == BillModel.statusUndelivered);
    bool showContactTel = !Utils.textIsEmptyOrWhiteSpace(item.contactTel) &&
        (item.status == BillModel.statusUndelivered);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                item.billCode,
                style: TextStyle(
                  color: item.isSalesOrder ? Colors.black : Colors.blue,
                ),
              ),
              Expanded(
                child: Text(
                  item.statusName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: item.isPending ? Colors.red : Colors.blue,
                  ),
                ),
              ),
              Text(Utils.dateTimeToStr(item.billDate)),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                item.custName,
                style: TextStyle(
                  fontSize: fontSizeDetail,
                ),
              )),
              SizedBox(width: 8.0),
              Text('￥${Utils.getCurrencyStr(item.amount)}'),
            ],
          ),
          if (showContactInfo)
            Text(
              item.contactInfo,
              style: TextStyle(
                color: defaultFontColor,
                fontSize: fontSizeDetail,
              ),
            ),
          if (showContactTel) _contactTelWidget(item),
          if (item.status == BillModel.statusPendingApproval)
            Align(
                alignment: Alignment.centerRight,
                child: CriticalButton(
                  title: '撤销',
                  onPressed: () {
                    _cancelOrder(item);
                  },
                )),
          if (isLast)
            SizedBox(
              height: 8.0,
            )
          else
            Divider(),
        ],
      ),
    );
  }

  void _cancelOrder(BillModel item) async {
    if (await DialogUtils.showConfirmDialog(
        context, '确定要撤销订单 ${item.billCode} 吗？',
        confirmText: '撤销', confirmTextColor: Colors.red)) {
      RequestResult result = await SalesService.cancelSalesOrder(item.billId);
      if (result.success) {
        _removeFromList(item);
        DialogUtils.showToast('订单已撤销');
      } else {
        DialogUtils.showToast('订单未能撤销, ${result.msg}');
      }
    }
  }

  void _removeFromList(BillModel item) {
    int status = item.status;
    Map<String, dynamic> list;
    if (status == BillModel.statusPendingApproval) {
      _pendingApprovalList.remove(item);
      list = _findList(_pendingApprovalIndex);
    } else if (status == BillModel.statusDelivered) {
      _deliveredList.remove(item);
      list = _findList(_deliveredIndex);
    } else {
      _undeliveredList.remove(item);
      list = _findList(_undeliveredIndex);
    }
    if (list != null) {
      list['count'] = list['count'] - 1;
    }
    // _billList.remove(item);

    setState(() {});
  }

  Widget _contactTelWidget(BillModel item) {
    return InkWell(
      onTap: () {
        callPhone(item.contactTel);
      },
      child: Row(
        children: <Widget>[
          phoneIcon,
          Text(
            item.contactTel,
            style: TextStyle(
              color: Colors.blue,
              fontSize: fontSizeDetail,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _custWidget {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(8.0),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSizeDefault,
        ),
        child: Row(
          children: <Widget>[
            Text('客户：'),
            Text(_currentCust.name),
          ],
        ),
      ),
    );
  }

  Widget get _drawer {
    return Drawer(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Theme.of(context).accentIconTheme.color,
                    size: 28.0,
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Text(
                    '查询选项',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: _searchWidget,
              ),
            ),
          ),
          Container(
            color: backgroundColor,
            child: ButtonBar(
              // alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                OutlineButton(
                  child: Text(
                    '重置',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: _resetFilter,
                ),
                OutlineButton(
                  child: Text('确定'),
                  onPressed: () {
                    _currentCust = _selectedCust;
                    _tabController.index = 2;
                    Navigator.pop(context);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _loadData() async {
    String keyword = _keywordController.text ?? '';
    int dateOption = _dateOption;
    bool selectedUnconfirmed = _statusFilterList[0];
    bool selectedUndelivered = _statusFilterList[1];
    bool selectedDelivered = _statusFilterList[2];

    await _progressDialog?.show();
    try {
      Map<String, dynamic> map = await SalesService.getSalesOrderCount(
          keyword,
          _currentCust.custId,
          dateOption,
          selectedUnconfirmed,
          selectedUndelivered,
          selectedDelivered);

      _count = map['Count'];
      _pendingApprovalCount = map['PendingApprovalCount'];
      _undeliveredCount = map['UndeliveredCount'];
      _deliveredCount = map['DeliveredCount'];
      _loadedDeliveredCount = 0;

      // _billList.clear();

      if (_count > 0) {
        List<BillModel> billList = List();
        // 加载非已送货
        List<BillModel> list = await SalesService.getNonDeliveredSalesOrder(
            _currentCust.custId,
            keyword,
            dateOption,
            selectedUnconfirmed,
            selectedUndelivered);
        // _billList.addAll(list);
        billList.addAll(list);

        if (selectedDelivered) {
          list = await SalesService.getDeliveredSalesOrder(
              _currentCust.custId, keyword, dateOption, 1);
          // _billList.addAll(list);
          billList.addAll(list);

          _loadedDeliveredCount = list.length;
        }
        _buildViewList(billList);
      }
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  int get _dateOption {
    if (_dateFilterList[0]) {
      return SalesService.dateOptionWithOneWeek;
    }
    if (_dateFilterList[1]) {
      return SalesService.dateOptionWithOneMonth;
    }

    return SalesService.dateOptionAll;
  }

  void _initData() {
    _dateFilterList = [false, false, true];
    _statusFilterList = [true, true, false];
    _keywordController.text = '';
  }

  void _resetFilter() {
    _initData();
    setState(() {});
  }

  Widget get _searchWidget {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('客户'),
        InkWell(
          onTap: () {
            Utils.closeInput(context);
            _selectCust();
          },
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  color: backgroundColor,
                  child: Text(
                    _selectedCust.custId <= 0 ? '请选择客户' : _selectedCust.name,
                    style: TextStyle(
                      color: _selectedCust.custId <= 0
                          ? defaultFontColor
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.0),
        Text('关键字'),
        TextField(
          controller: _keywordController,
          decoration: InputDecoration(hintText: '请输入关键字'),
        ),
        SizedBox(height: 16.0),
        _dateFilterButtons,
        _statusFilterButtons,
      ],
    );
  }

  void _selectCust() {
    Navigator.pushNamed(
      context,
      custPath,
      arguments: {'selecting': true},
    ).then((value) async {
      if (value != null) {
        setState(() {
          _selectedCust = value;
        });
      }
    });
  }

  Widget get _statusFilterButtons {
    return Row(
      children: <Widget>[
        Text('状态'),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _multiChoiceChip(_statusFilterList, 0, '未审批'),
              _multiChoiceChip(_statusFilterList, 1, '待送货'),
              _multiChoiceChip(_statusFilterList, 2, '已送货'),
            ],
          ),
        ),
      ],
    );
  }

  Widget get _dateFilterButtons {
    return Row(
      children: <Widget>[
        Text('日期'),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _singleChoiceChip(_dateFilterList, 0, '1周内'),
              _singleChoiceChip(_dateFilterList, 1, '1个月内'),
              _singleChoiceChip(_dateFilterList, 2, '全部'),
            ],
          ),
        )
      ],
    );
  }

  Widget _singleChoiceChip(List<bool> list, int index, String title) {
    return ChoiceChip(
      label: Text(title),
      selected: list[index],
      onSelected: (bool newValue) {
        for (int i = 0; i < list.length; i++) {
          list[i] = (i == index);
        }
        setState(() {});
      },
    );
  }

  Widget _multiChoiceChip(List<bool> list, int index, String title) {
    return ChoiceChip(
      label: Text(title),
      selected: list[index],
      onSelected: (bool newValue) {
        setState(() {
          list[index] = newValue;
        });
      },
    );
  }
}
