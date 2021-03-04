import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/sales_price.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/search_text_field.dart';
import 'package:mis_app/widget/sticky_header_container.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SearchPricePage extends StatefulWidget {
  final Map arguments;
  SearchPricePage({Key key, this.arguments}) : super(key: key);

  @override
  _SearchPricePageState createState() => _SearchPricePageState();
}

class _SearchPricePageState extends State<SearchPricePage> {
  CustModel _cust;
  String _searchKeyword;
  List<String> _suggestList = [];
  // List<SalesPriceModel> _priceList = List();
  bool _selecting;
  List<SalesPriceModel> _recentList = [];
  List<SalesPriceModel> _notRecentList = [];
  List<Map<String, dynamic>> _viewList = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _suggestList = Prefs.getSelectHistory(Prefs.keyHistorySelectSalesPrice);

    if (widget.arguments != null) {
      var cust = widget.arguments['cust'];
      _selecting = widget.arguments['selecting'];

      if (cust != null) {
        _cust = CustModel.fromJson(cust);
      }
    }

    _selecting = _selecting ?? false;

    if (_cust == null) {
      _cust = CustModel();
    }

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      if (_cust.custId > 0) {
        _searchPrice();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('价格查询'),
      ),
      body: SafeArea(
        child: Container(
          // padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Container(
                color: backgroundColor,
                padding: EdgeInsets.all(8.0),
                child: _headerWidget,
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                  child: _priceListWidget,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _priceListWidget {
    /*
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        SalesPriceModel item = _priceList[index];
        return _priceItemWidget(item);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemCount: _priceList.length,
    );
    */
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return StickyHeader(
          header: StickyHeaderContainer(
              title:
                  '${_viewList[index]["name"]} (${_viewList[index]["data"].length})'),
          content: Column(
            children: _buildGroup(_viewList[index]['data']),
          ),
        );
      },
      itemCount: _viewList.length,
    );
  }

  List<Widget> _buildGroup(List<SalesPriceModel> list) {
    return list.map((item) {
      return _priceItemWidget(item, item == list[list.length - 1]);
    }).toList();
  }

  Widget _priceItemWidget(SalesPriceModel item, bool isLast) {
    bool islayoutResourceKind1 = Global.islayoutResourceKind1;
    Widget itemNameWidget = Text(
      item.itemName,
      style: TextStyle(
        color: item.expired ? Colors.red : Colors.black,
      ),
    );
    Widget ruleAndUomWidget = Text(
      '${item.rule}/${item.uomCode}',
      style: TextStyle(
        color: defaultFontColor,
        fontSize: fontSizeDetail,
      ),
    );
    Widget stockQtyWidget = Text(
      '${Utils.getQtyStr(item.stockQty)}',
      style: TextStyle(
        color:
            item.stockQty <= Global.stockQtyWarning ? Colors.red : Colors.blue,
      ),
    );

    return InkWell(
      onTap: () {
        _clickPriceItem(item);
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    item.itemCode,
                    style: TextStyle(
                      color: defaultFontColor,
                    ),
                  ),
                ),
                Text(
                  '￥${item.sPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: defaultFontColor,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 8.0),
                Text('￥${item.price.toStringAsFixed(2)}'),
              ],
            ),

            //两种布局主要差异部分--开始
            if (islayoutResourceKind1)
              itemNameWidget
            else
              Row(
                children: <Widget>[
                  Expanded(
                    child: itemNameWidget,
                  ),
                  ruleAndUomWidget,
                  SizedBox(width: 6.0),
                  stockQtyWidget,
                ],
              ),
            if (islayoutResourceKind1)
              Row(
                children: <Widget>[
                  Expanded(
                    child: ruleAndUomWidget,
                  ),
                  SizedBox(width: 6.0),
                  stockQtyWidget,
                ],
              ),
            //两种布局主要差异部分--结束

            if (!Utils.textIsEmptyOrWhiteSpace(item.itemRemarks))
              Text(
                '${item.itemRemarks}',
                style: TextStyle(
                  fontSize: fontSizeDetail,
                  color: defaultFontColor,
                ),
              ),
            if (isLast)
              SizedBox(
                height: 8.0,
              )
            else
              Divider(),
          ],
        ),
      ),
    );
  }

  void _clickPriceItem(SalesPriceModel item) {
    if (!_selecting) return;

    if (item.expired) {
      DialogUtils.showToast('报价已过期');
      return;
    }
    Navigator.pop(context, item);
  }

  Widget get _headerWidget {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () {
            _selectCust();
          },
          child: Row(
            children: <Widget>[
              Text('客户：'),
              Expanded(
                // child: Text('${_cust.name}'),
                child: Text(
                  _cust.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSizeDetail,
                    color: getcustGradeColorByCust(_cust),
                  ),
                ),
              ),
              if (!_selecting)
                Icon(
                  Icons.keyboard_arrow_right,
                  color: Theme.of(context).primaryColor,
                ),
            ],
          ),
        ),
        SearchTextField(
          suggestList: _suggestList,
          hintText: '请输入产品编号，名称，规格',
          style: TextStyle(fontSize: fontSizeDefault),
          onTextChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          onSearch: () {
            _suggestList = Utils.updateHistoryList(_suggestList, _searchKeyword,
                maxHistoryCount: 20);
            Prefs.saveSelectHistory(
                Prefs.keyHistorySelectSalesPrice, _suggestList);
            _searchPrice();
            Utils.closeInput(context);
          },
        ),
      ],
    );
  }

  void _selectCust() {
    if (_selecting) return;

    Navigator.pushNamed(
      context,
      custPath,
      arguments: {'selecting': true},
    ).then((value) async {
      if (value != null) {
        CustModel cust = value;
        setState(() {
          _cust = cust;
        });
        _searchPrice();
      }
    });
  }

  void _searchPrice() async {
    if (_cust.custId <= 0) {
      DialogUtils.showToast('请选择客户');
      return;
    }

    await _progressDialog?.show();
    try {
      List<SalesPriceModel> priceList =
          await SalesService.getSalesPrice(_cust.custId, _searchKeyword);
      _buildViewList(priceList);
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _buildViewList(List<SalesPriceModel> list) {
    _viewList.clear();

    _recentList.clear();
    _notRecentList.clear();

    for (SalesPriceModel item in list) {
      if (item.recentUsed) {
        _recentList.add(item);
      } else {
        _notRecentList.add(item);
      }
    }

    if (_recentList.length > 0) {
      _viewList.add({'name': '最近有开单', 'data': _recentList});
    }

    if (_notRecentList.length > 0) {
      _viewList.add({'name': '最近未开单', 'data': _notRecentList});
    }
  }
}
