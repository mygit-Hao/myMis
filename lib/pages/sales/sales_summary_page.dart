import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/sales_summary.dart';
import 'package:mis_app/model/salesman.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/date_view.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SalesSummaryPage extends StatefulWidget {
  SalesSummaryPage({Key key}) : super(key: key);

  @override
  _SalesSummaryPageState createState() => _SalesSummaryPageState();
}

class _SalesSummaryPageState extends State<SalesSummaryPage> {
  final SalesmanModel _nullSalesman =
      SalesmanModel(salesmanId: 0, salesmanName: '(请选择营业员)');

  List<SalesmanModel> _salesmanList;
  CustModel _currentCust;
  SalesmanModel _selectedSalesman;
  DateTime _startDate;
  DateTime _endDate;
  int _recordCount;
  double _amount;
  List<SalesSummaryModel> _list = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _initData();
  }

  void _initData() async {
    _endDate = Utils.today;
    _startDate = Utils.firstDayOfMonth(_endDate);

    _salesmanList = List()..add(_nullSalesman);
    _currentCust = CustModel();

    List<SalesmanModel> list = await DataCache.getSalesmanList();
    setState(() {
      _salesmanList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('销售查询'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _loadData();
              }),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: _mainWidget,
        ),
      ),
    );
  }

  void _loadData() async {
    await _progressDialog?.show();

    try {
      Map<String, dynamic> result = await SalesService.getSalesSummaryTotal(
          _currentCust.custId, _startDate, _endDate, _salesmanId);

      _recordCount = result['Count'];
      _amount = result['Amount'];
      _list.clear();

      if (_recordCount > 0) {
        List<SalesSummaryModel> list = await SalesService.getSalesSummary(
            _currentCust.custId, _startDate, _endDate, _salesmanId, 1);
        _list.addAll(list);
      }
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  int get _salesmanId {
    return _selectedSalesman == null ? 0 : _selectedSalesman.salesmanId;
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          color: backgroundColor,
          child: _headerWidget,
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: _listWidget,
          ),
        ),
        _summaryWidget,
      ],
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          SalesSummaryModel item = _list[index];
          return InkWell(
            onTap: () {
              _showDetail(item);
            },
            child: _itemWidget(item),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: _list.length,
      ),
      onRefresh: () async {
        _loadData();
      },
      onLoad: () async {
        _loadMore();
      },
    );
  }

  void _showDetail(SalesSummaryModel item) {
    Navigator.pushNamed(context, salesSummaryDetailPath, arguments: {
      'summary': item.toJson(),
      'startDate': _startDate,
      'endDate': _endDate
    });
  }

  void _loadMore() async {
    int currentSize = _list.length;
    if (currentSize >= _recordCount) return;

    List<SalesSummaryModel> list = await SalesService.getSalesSummary(
        _currentCust.custId,
        _startDate,
        _endDate,
        _salesmanId,
        currentSize + 1);
    _list.addAll(list);
    setState(() {});
  }

  Widget _itemWidget(SalesSummaryModel item) {
    bool canViewAreaCust = UserProvide.currentUser.canViewAreaCust;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: defaultFontColor,
                        fontSize: fontSizeDetail,
                      ),
                      child: Row(
                        children: <Widget>[
                          Text('${item.custCode}'),
                          if (canViewAreaCust) Text(' - ${item.salesmanName}'),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    '￥${Utils.getCurrencyStr(item.amount)}',
                    style: TextStyle(
                      color: item.amount >= 0 ? Colors.blue : Colors.red,
                    ),
                  ),
                ],
              ),
              Text(
                item.custName,
                style: TextStyle(
                  color: getcustGradeColor(item.custGrade),
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget get _summaryWidget {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ),
      alignment: Alignment.centerRight,
      child: Text('金额：￥${Utils.getCurrencyStr(_amount)}'),
    );
  }

  Widget get _headerWidget {
    bool canViewAreaCust = UserProvide.currentUser.canViewAreaCust;

    return Column(
      children: <Widget>[
        _custWidget,
        if (canViewAreaCust) _salesmanWidget,
        _dateWidget,
      ],
    );
  }

  Widget get _dateWidget {
    return Row(
      children: <Widget>[
        Text('送货日期：'),
        DateView(
          value: _startDate,
          textAlign: TextAlign.start,
          onTap: () {
            DialogUtils.showDatePickerDialog(context, _startDate,
                onValue: (DateTime val) {
              setState(() {
                _startDate = val;
              });
            });
          },
        ),
        SizedBox(width: 8.0),
        Icon(
          Icons.remove,
          size: 16.0,
        ),
        SizedBox(width: 8.0),
        DateView(
          value: _endDate,
          textAlign: TextAlign.start,
          onTap: () {
            DialogUtils.showDatePickerDialog(context, _endDate,
                onValue: (DateTime val) {
              setState(() {
                _endDate = val;
              });
            });
          },
        ),
      ],
    );
  }

  Widget get _salesmanWidget {
    return Row(
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
              setState(() {
                _selectedSalesman = value;
              });
            },
          ),
        )
      ],
    );
  }

  Widget get _custWidget {
    return InkWell(
      onTap: () {
        _selectCust();
      },
      child: Row(
        children: <Widget>[
          Text('客户：'),
          Expanded(
            child: Text(
              _currentCust.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fontSizeDetail,
                color: getcustGradeColorByCust(_currentCust),
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  void _selectCust() {
    Navigator.pushNamed(
      context,
      custPath,
      arguments: {'selecting': true},
    ).then((value) async {
      if (value != null) {
        CustModel cust = value;
        setState(() {
          _currentCust = cust;
        });
      }
    });
  }
}
