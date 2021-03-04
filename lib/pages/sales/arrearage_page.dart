import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/arrearage.dart';
import 'package:mis_app/model/salesman.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ArrearagePage extends StatefulWidget {
  final Map arguments;
  ArrearagePage({Key key, this.arguments}) : super(key: key);

  @override
  _ArrearagePageState createState() => _ArrearagePageState();
}

class _ArrearagePageState extends State<ArrearagePage> {
  final SalesmanModel _nullSalesman =
      SalesmanModel(salesmanId: 0, salesmanName: '(请选择营业员)');

  List<SalesmanModel> _salesmanList;
  SalesmanModel _selectedSalesman;
  List<ArrearageModel> _list = [];
  int _recordCount;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() async {
    _salesmanList = List()..add(_nullSalesman);

    List<SalesmanModel> list = await DataCache.getSalesmanList();
    setState(() {
      _salesmanList = list;
    });

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('欠款情况'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _loadData();
              }),
        ],
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  void _loadData() async {
    await _progressDialog?.show();
    try {
      _recordCount = await SalesService.getArreageCountBySalesman(_salesmanId);

      _list.clear();

      if (_recordCount > 0) {
        List<ArrearageModel> list =
            await SalesService.getArrearageBySalesman(_salesmanId, 1);
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
    bool canViewAreaCust = UserProvide.currentUser.canViewAreaCust;

    return Column(
      children: <Widget>[
        if (canViewAreaCust)
          Container(
            padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            color: backgroundColor,
            child: _salesmanWidget,
          ),
        Expanded(
          child: Container(
            padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
            child: _listWidget,
          ),
        ),
      ],
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          ArrearageModel item = _list[index];
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

  void _showDetail(ArrearageModel item) {
    Navigator.pushNamed(context, arrearageDetailPath, arguments: item.toJson());
  }

  void _loadMore() async {
    int currentSize = _list.length;
    if (currentSize >= _recordCount) return;

    List<ArrearageModel> list =
        await SalesService.getArrearageBySalesman(_salesmanId, currentSize + 1);
    _list.addAll(list);
    setState(() {});
  }

  Widget _itemWidget(ArrearageModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: DefaultTextStyle(
            style: TextStyle(
              color: getcustGradeColor(item.custGrade),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(item.code),
                    Text(
                      '￥${Utils.getCurrencyStr(item.arrearage)}',
                      style: TextStyle(
                        color: item.arrearage > 0 ? Colors.red : Colors.blue,
                      ),
                    ),
                  ],
                ),
                Text(item.name),
              ],
            ),
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right,
          color: Theme.of(context).primaryColor,
        )
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
}
