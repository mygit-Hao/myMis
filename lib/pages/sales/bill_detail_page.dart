import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/model/bill.dart';
import 'package:mis_app/model/bill_detail.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/critical_button.dart';
import 'package:progress_dialog/progress_dialog.dart';

class BillDetailPage extends StatefulWidget {
  final Map arguments;
  BillDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _BillDetailPageState createState() => _BillDetailPageState();
}

class _BillDetailPageState extends State<BillDetailPage> {
  BillModel _bill;
  List<BillDetailModel> _detailList;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _bill = BillModel();
    _detailList = List();
    if (widget.arguments != null) {
      int billType = widget.arguments['billType'];
      String billId = widget.arguments['billId'].toString();

      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData(billType, billId);
      });
    }
  }

  void _loadData(int billType, String billId) async {
    await _progressDialog?.show();
    try {
      Map<String, dynamic> result =
          await SalesService.getBillDetail(billType, billId);
      _bill = result['bill'];
      _bill.billType = billType;
      _detailList = result['billDetail'];

      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_bill.billTypePrefix}明细'),
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
        _headerWidget,
        Expanded(
          child: _listWidget,
        ),
        _summaryWidget,
        if (UserProvide.currentUser.canNewSalesOrder)
          Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 8.0,
            ),
            child: CriticalButton(
              title: '再次下单',
              onPressed: _reorder,
            ),
          ),
      ],
    );
  }

  Widget get _listWidget {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        BillDetailModel item = _detailList[index];
        return _itemWidget(item);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemCount: _detailList.length,
    );
  }

  Widget _itemWidget(BillDetailModel item) {
    bool islayoutResourceKind1 = Global.islayoutResourceKind1;
    Widget itemNameWidget = Text(item.itemName);
    Widget ruleWidget = Text(
      '(${item.rule})',
      style: TextStyle(
        fontSize: fontSizeDetail,
        color: defaultFontColor,
      ),
    );
    Widget qtyWidget = Text(
      Utils.getQtyStr(
        item.qty,
      ),
      style: TextStyle(
        color: item.stockQty >= item.qty ? Colors.blue : Colors.red,
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
              Text('￥${Utils.getCurrencyStr(item.price)}/${item.uomCode}'),
            ],
          ),

          //两种布局主要差异部分--开始
          if (islayoutResourceKind1)
            itemNameWidget
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      itemNameWidget,
                      SizedBox(width: 8.0),
                      if (!Utils.textIsEmptyOrWhiteSpace(item.rule)) ruleWidget,
                    ],
                  ),
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
                SizedBox(width: 8.0),
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
          if (!Utils.textIsEmptyOrWhiteSpace(item.remarks))
            Text(
              item.remarks,
              style: TextStyle(fontSize: fontSizeSmall),
            ),
        ],
      ),
    );
  }

  void _reorder() async {
    if (await DialogUtils.showConfirmDialog(context, '确定要再次下单？')) {
      RequestResult result =
          await SalesService.reorder(_bill.billType, _bill.billId);
      if (result.success) {
        // 如果再次下单成功，就打开销售开单页面
        Navigator.pushNamed(context, salesCartPath);
      } else {
        DialogUtils.showToast('操作发生错误');
      }
    }
  }

  Widget get _summaryWidget {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(
        vertical: 4.0,
        horizontal: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                Text('数量：'),
                Text(
                  Utils.getQtyStr(_bill.qty),
                ),
              ],
            ),
          ),
          Container(
            child: Row(
              children: <Widget>[
                Text('金额：'),
                Text(
                  '￥${Utils.getCurrencyStr(_bill.amount)}',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get _headerWidget {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 8.0,
      ),
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[
          _infoWidget('${_bill.billTypePrefix}单号：', _bill.billCode),
          _infoWidget('客户：', _bill.custName),
          _infoWidget('交期：', Utils.dateTimeToStr(_bill.billDate)),
        ],
      ),
    );
  }

  Widget _infoWidget(String title, String content) {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSizeDefault,
      ),
      child: Row(
        children: <Widget>[
          Text(title),
          Text(content ?? ''),
        ],
      ),
    );
  }
}
