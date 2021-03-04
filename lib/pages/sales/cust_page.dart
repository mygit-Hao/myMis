import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/salesman.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/search_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CustPage extends StatefulWidget {
  final Map arguments;
  CustPage({Key key, this.arguments}) : super(key: key);

  @override
  _CustPageState createState() => _CustPageState();
}

class _CustPageState extends State<CustPage> {
  static const int _maxHistoryCount = 20;
  final SalesmanModel _nullSalesman =
      SalesmanModel(salesmanId: 0, salesmanName: '(请选择营业员)');

  List<SalesmanModel> _salesmanList;
  String _searchKeyword;
  List<String> _suggestList = [];
  SalesmanModel _selectedSalesman;
  List<CustModel> _custList = [];
  int _recordCount = 0;
  bool _selecting = false;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _salesmanList = List()..add(_nullSalesman);

    if (widget.arguments != null) {
      _selecting = widget.arguments['selecting'];
    }

    _initData();
  }

  void _initData() async {
    _suggestList = Prefs.getSelectHistory(Prefs.keyHistorySelectCust);

    List<SalesmanModel> list = await DataCache.getSalesmanList();
    setState(() {
      _salesmanList = list;
    });

    // 检查是否有客户资料缓存
    // 如果有，从缓存中取出，改善操作体验
    if (DataCache.custList == null) {
      _searchCust();
    } else {
      setState(() {
        _custList = DataCache.custList;
      });
      await _getCustCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('客户列表'),
      ),
      body: SafeArea(
        child: Container(
          child: _mainWidget,
        ),
      ),
    );
  }

  Widget get _mainWidget {
    return Container(
      // padding: EdgeInsets.all(6.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
            color: backgroundColor,
            child: _searchWidget,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4.0),
              child: _custListWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _searchWidget {
    bool canViewAreaCust = UserProvide.currentUser.canViewAreaCust;

    return Column(
      children: <Widget>[
        if (canViewAreaCust)
          Row(
            children: <Widget>[
              Text('营业员：'),
              Expanded(
                child: DropdownButton<SalesmanModel>(
                  value: _selectedSalesman,
                  items: _salesmanList.map((SalesmanModel item) {
                    return DropdownMenuItem(
                      child: Text(item.salesmanName),
                      value: item,
                    );
                  }).toList(),
                  isExpanded: true,
                  onChanged: (SalesmanModel value) {
                    // print('营业员：${value.salesmanId} ${value.salesmanName}');
                    setState(() {
                      _selectedSalesman = value;
                    });
                  },
                ),
              )
            ],
          ),
        SearchTextField(
          suggestList: _suggestList,
          hintText: '请输入客户编号，名称',
          style: TextStyle(fontSize: fontSizeDefault),
          onTextChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          onSearch: _searchTap,
        ),
      ],
    );
  }

  void _searchTap() async {
    _suggestList = Utils.updateHistoryList(_suggestList, _searchKeyword,
        maxHistoryCount: _maxHistoryCount);
    Prefs.saveSelectHistory(Prefs.keyHistorySelectCust, _suggestList);
    Utils.closeInput(context);
    await _progressDialog?.show();
    try {
      _searchCust();
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _searchCust() async {
    _recordCount = 0;

    int salesmanId = _selectedSalesman?.salesmanId;

    // Map<String, dynamic> result =
    //     await SalesService.getCount(_searchKeyword, salesmanId);
    // _recordCount = result['Count'];
    await _progressDialog?.show();
    try {
      List<CustModel> list =
          await SalesService.getCustListByPage(_searchKeyword, salesmanId, 1);
      setState(() {
        _custList = list;
      });
      _saveToCache();
    } finally {
      await _progressDialog?.hide();
    }
    await _getCustCount(salesmanId: salesmanId);
  }

  Future<void> _getCustCount({int salesmanId}) async {
    Map<String, dynamic> result =
        await SalesService.getCustCount(_searchKeyword, salesmanId);
    _recordCount = result['Count'];
  }

  void _saveToCache() {
    DataCache.custList = _custList;
  }

  void _loadMoreCust() async {
    int currentSize = _custList.length;
    if (currentSize >= _recordCount) return;

    await _progressDialog?.show();
    try {
      List<CustModel> list = await SalesService.getCustListByPage(
          _searchKeyword, _selectedSalesman?.salesmanId, currentSize + 1);

      List<CustModel> newList = List();

      newList.addAll(_custList);
      newList.addAll(list);
      setState(() {
        _custList = newList;
      });
      _saveToCache();
    } finally {
      await _progressDialog?.hide();
    }
  }

  Widget _getCustItemWidget(CustModel item) {
    bool showContactPerson;
    bool showContactTel;

    if (_selecting) {
      showContactPerson = false;
      showContactTel = false;
    } else {
      showContactPerson =
          (!Utils.textIsEmptyOrWhiteSpace(item.contactPerson)) &&
              !((item.contactTel != null) &&
                  (item.contactPerson != null) &&
                  (item.contactTel.contains(item.contactPerson)));
      showContactTel = !Utils.textIsEmpty(item.contactTel);
    }

    Color custColor = getcustGradeColorByCust(item);

    return Card(
      child: InkWell(
        onTap: () {
          _clickCustItem(item);
        },
        child: Container(
          padding: EdgeInsets.all(6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.code,
                          // style: TextStyle(color: defaultFontColor),
                          style: TextStyle(color: custColor),
                        ),
                        Text(
                          item.name,
                          style: TextStyle(color: custColor),
                        ),
                      ],
                    ),
                  ),
                  if (!_selecting)
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),

              // 如果联系电话已包含联系人，则把联系人隐藏
              if (showContactPerson)
                Text(
                  '联系人：${item.contactPerson}',
                  style: TextStyle(
                      fontSize: fontSizeDetail, color: defaultFontColor),
                ),
              if (showContactTel)
                InkWell(
                  onTap: () {
                    callPhone(item.contactTel);
                  },
                  child: Row(
                    children: <Widget>[
                      phoneIcon,
                      Text(
                        item.contactTel,
                        style: TextStyle(
                          fontSize: fontSizeDetail,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _clickCustItem(CustModel item) async {
    if (_selecting) {
      // print('select ${item.name}');
      CustModel cust = await SalesService.getCustDetail(item.custId);
      Navigator.pop(context, cust);
    } else {
      Navigator.pushNamed(context, custDetailPath,
          arguments: {'custId': item.custId});
    }
  }

  Widget get _custListWidget {
    return EasyRefresh(
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          CustModel item = _custList[index];
          return _getCustItemWidget(item);
        },
        itemCount: _custList.length,
        shrinkWrap: true,
      ),
      onRefresh: () async {
        _searchCust();
      },
      onLoad: () async {
        _loadMoreCust();
      },
    );
  }
}
