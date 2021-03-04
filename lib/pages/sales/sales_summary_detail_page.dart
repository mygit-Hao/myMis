import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/model/sales_summary.dart';
import 'package:mis_app/model/sales_summary_detail.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SalesSummaryDetailPage extends StatefulWidget {
  final Map arguments;
  SalesSummaryDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _SalesSummaryDetailPageState createState() => _SalesSummaryDetailPageState();
}

class _SalesSummaryDetailPageState extends State<SalesSummaryDetailPage> {
  SalesSummaryModel _summary;
  DateTime _startDate;
  DateTime _endDate;
  int _recordCount;
  double _amount;
  List<SalesSummaryDetailModel> _list = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    Map arguments = widget.arguments;
    if (arguments != null) {
      _summary = SalesSummaryModel.fromJson(arguments['summary']);
      _startDate = arguments['startDate'];
      _endDate = arguments['endDate'];

      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData();
      });
    } else {
      _summary = SalesSummaryModel();
    }
  }

  void _loadData() async {
    await _progressDialog?.show();

    try {
      Map<String, dynamic> result =
          await SalesService.getSalesSummaryDetailTotal(
              _summary.custId, _startDate, _endDate);
      _list.clear();
      _recordCount = result['Count'];
      _amount = result['Amount'];
      if (_recordCount > 0) {
        _list = await SalesService.getSalesSummaryDetail(
            _summary.custId, _startDate, _endDate, 1);
        setState(() {});
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
        title: Text('销售明细'),
      ),
      body: SafeArea(
        child: Container(
          child: _mainWidget,
        ),
      ),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        _titleWidget,
        Expanded(child: _listWidget),
      ],
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return _itemWidget(index);
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

  void _loadMore() async {
    int currentSize = _list.length;
    if (currentSize >= _recordCount) return;

    List<SalesSummaryDetailModel> list =
        await SalesService.getSalesSummaryDetail(
            _summary.custId, _startDate, _endDate, currentSize + 1);
    _list.addAll(list);
    setState(() {});
  }

  Widget _itemWidget(int index) {
    SalesSummaryDetailModel item = _list[index];
    bool showHeader = true;

    // 如果与上一项属同一个单，隐藏单头
    if (index > 0) {
      SalesSummaryDetailModel previousItem = _list[index - 1];
      if ((item.billType == previousItem.billType) &&
          (Utils.sameText(item.billId, previousItem.billId))) {
        showHeader = false;
      }
    }

    return Column(
      children: <Widget>[
        if (showHeader) _itemHeader(item),
        _itemDetail(item),
      ],
    );
  }

  Widget _itemHeader(SalesSummaryDetailModel item) {
    return Container(
      color: Colors.grey[400],
      padding: EdgeInsets.all(10.0),
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: fontSizeDefault,
        ),
        child: Row(
          children: <Widget>[
            Text(item.billCode),
            SizedBox(width: 8.0),
            Expanded(
              child: Text(Utils.dateTimeToStr(item.billDate)),
            ),
            Text(
              '￥${Utils.getCurrencyStr(item.billHeadAmount)}',
              style: TextStyle(
                color: item.billHeadAmount >= 0 ? Colors.blue : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDetail(SalesSummaryDetailModel item) {
    bool islayoutResourceKind1 = Global.islayoutResourceKind1;
    Widget itemNameWidget = Text(item.itemName);
    Widget ruleWidget = Text(
      '(${item.rule})',
      style: TextStyle(
        color: defaultFontColor,
      ),
    );
    Widget qtyWidget = Text(
      '${Utils.getQtyStr(item.qty)}',
      style: TextStyle(
        color: item.qty >= 0 ? Colors.blue : Colors.red,
      ),
    );

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(item.itemCode),
              Text('￥${item.price}/${item.uomCode}')
            ],
          ),

          //两种布局主要差异部分--开始
          if (islayoutResourceKind1)
            itemNameWidget
          else
            Row(
              children: <Widget>[
                itemNameWidget,
                SizedBox(
                  width: 4.0,
                ),
                Expanded(
                  child: ruleWidget,
                ),
                qtyWidget,
              ],
            ),
          if (islayoutResourceKind1)
            Row(
              children: <Widget>[
                Expanded(
                  child: ruleWidget,
                ),
                SizedBox(
                  width: 4.0,
                ),
                qtyWidget,
              ],
            ),
          //两种布局主要差异部分--结束

          if (!Utils.textIsEmptyOrWhiteSpace(item.itemRemarks))
            Text(
              item.itemRemarks,
              style: TextStyle(
                fontSize: fontSizeDetail,
                color: defaultFontColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget get _titleWidget {
    return Container(
      padding: EdgeInsets.all(8.0),
      color: Theme.of(context).backgroundColor,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: fontSizeHeader,
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Text(
              _summary.custName,
              overflow: TextOverflow.ellipsis,
            )),
            SizedBox(width: 8.0),
            Text('￥${Utils.getCurrencyStr(_amount)}'),
          ],
        ),
      ),
    );
  }
}
