import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/receipt_detail.dart';
import 'package:mis_app/model/sales_bonus.dart';
import 'package:mis_app/model/salesman.dart';
import 'package:mis_app/pages/sales/widget/salesman_widget.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/custom_icon_button.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SalesBonusQueryPage extends StatefulWidget {
  SalesBonusQueryPage({Key key}) : super(key: key);

  @override
  _SalesBonusQueryPageState createState() => _SalesBonusQueryPageState();
}

class _SalesBonusQueryPageState extends State<SalesBonusQueryPage> {
  final SalesmanModel _nullSalesman =
      SalesmanModel(salesmanId: 0, salesmanName: '(请选择营业员)');
  List<SalesmanModel> _salesmanList;
  SalesmanModel _selectedSalesman;
  DateTime _startDate, _endDate;
  double _bonus = 0;
  List<SalesBonusModel> _list = [];
  int _month = 0;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() async {
    _startDate = Utils.firstDayOfMonth(Utils.today);
    _endDate = Utils.lastDayOfMonth(_startDate);

    _salesmanList = List()..add(_nullSalesman);

    List<SalesmanModel> list = await DataCache.getSalesmanList();
    setState(() {
      _salesmanList = list;
    });

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadData();
    });
  }

  void _loadData() async {
    int salesmanId =
        _selectedSalesman == null ? 0 : _selectedSalesman.salesmanId;

    await _progressDialog?.show();
    try {
      SalesBonusListWrapper result =
          await SalesService.getSalesBonusList(_month, salesmanId);

      if (result != null) {
        setState(() {
          _startDate = result.dateFrom;
          _endDate = result.dateTo;
          _bonus = result.bonus;
          _list = result.list;
        });
      }
    } finally {
      await _progressDialog?.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('佣金查询'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
          color: backgroundColor,
          child: _headerWidget,
        ),
        Expanded(child: _listWidget),
        Container(
          color: Theme.of(context).backgroundColor,
          child: _buttons,
        ),
      ],
    );
  }

  Widget get _listWidget {
    Widget content;

    if (_list.length > 0) {
      content = ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          SalesBonusModel item = _list[index];
          return InkWell(
            onTap: () {
              _showReceiptDetail(item);
            },
            child: _itemWidget(item),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: _list.length,
      );
    } else {
      content = Center(
        child: Text(
          '暂无数据',
          style: TextStyle(
            color: Colors.pinkAccent,
            fontSize: fontSizeHeader,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      child: content,
    );
  }

  void _showReceiptDetail(SalesBonusModel item) async {
    List<ReceiptDetailModel> list =
        await SalesService.getSalesInvoiceReceiptDetail(
            _startDate, _endDate, item.salesInvoiceId);
    if (list.length <= 0) {
      DialogUtils.showToast('当前记录没有收款明细');
      return;
    }

    DialogUtils.showInfoDialog(
      context,
      title: '收款冲数明细',
      content: Container(
        child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return _receiptDetailWidget(list[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: list.length,
        ),
      ),
    );
  }

  Widget _receiptDetailWidget(ReceiptDetailModel item) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  item.pNO,
                  style: TextStyle(fontSize: fontSizeDetail),
                ),
                LabelText(
                  ' / ${item.receiptCode}',
                  fontSize: fontSizeDetail,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.date_range,
                  size: 16.0,
                  color: Theme.of(context).primaryColor,
                ),
                LabelText(
                  Utils.dateTimeToStr(item.receiptDate),
                  fontSize: fontSizeDetail,
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            LabelText(
              '收：',
              fontSize: fontSizeDetail,
            ),
            Text(
              '￥${Utils.getCurrencyStr(item.billAmount)}',
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            LabelText(
              '冲：',
              fontSize: fontSizeDetail,
            ),
            Text(
              '￥${Utils.getCurrencyStr(item.amount)}',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _itemWidget(SalesBonusModel item) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LabelText(item.custCode),
                  Text(item.custName),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LabelText(
                    '${item.salesInvoiceCode} / ${Utils.dateTimeToStr(item.salesInvoiceDate)}',
                    fontSize: fontSizeDetail,
                  ),
                  Row(
                    children: <Widget>[
                      LabelText(
                        '￥${Utils.getCurrencyStr(item.salesInvoiceAmount)}',
                        fontSize: fontSizeDetail,
                      ),
                      if (item.salesInvoiceAmount != item.balanceAmount)
                        Text(
                          ' (${Utils.getCurrencyStr(item.balanceAmount)})',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: fontSizeDetail,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  LabelText(
                    item.custInfo,
                    fontSize: fontSizeDetail,
                  ),
                  Text(
                    '￥${Utils.getCurrencyStr(item.bonus)}',
                    style: TextStyle(
                      fontSize: fontSizeDetail,
                      color: Colors.blue,
                    ),
                  ),
                ],
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

  Widget get _buttons {
    bool nextEnabled = _month < 0;

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        CustomIconButton(
          icon: Icon(
            Icons.arrow_left,
            color: Colors.white,
          ),
          child: Text(
            '上一个月',
            style: TextStyle(color: Colors.white),
          ),
          iconAlign: Alignment.centerLeft,
          onPressed: () {
            _month--;
            _loadData();
          },
        ),
        CustomIconButton(
          icon: Icon(
            Icons.arrow_right,
            color: Colors.white,
          ),
          child: Text(
            '下一个月',
            style: TextStyle(
              color: nextEnabled ? Colors.white : disabledFontColor,
            ),
          ),
          iconAlign: Alignment.centerRight,
          onPressed: () {
            if (nextEnabled) {
              _month++;
            }
            _loadData();
          },
        ),
      ],
    );
  }

  Widget get _headerWidget {
    bool canViewAreaCust = UserProvide.currentUser.canViewAreaCust;

    return Column(
      children: <Widget>[
        if (canViewAreaCust)
          SalesmanWidget(
            list: _salesmanList,
            value: _selectedSalesman,
            onChanged: (SalesmanModel value) {
              setState(() {
                _selectedSalesman = value;
              });
              _loadData();
            },
          ),
        _datesWidget,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Text('佣金合计：'),
            Text(
              '￥${Utils.getCurrencyStr(_bonus)}',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget get _datesWidget {
    return Row(
      children: <Widget>[
        Text('日    期：'),
        _dateWidget(_startDate),
        SizedBox(width: 8.0),
        Icon(
          Icons.remove,
          size: 16.0,
        ),
        SizedBox(width: 8.0),
        _dateWidget(_endDate),
      ],
    );
  }

  Widget _dateWidget(DateTime value) {
    return Expanded(
      child: Text(
        Utils.dateTimeToStr(value),
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).primaryColor),
      ),
    );
  }
}
