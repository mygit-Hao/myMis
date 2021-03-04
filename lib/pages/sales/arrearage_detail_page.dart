import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/arrearage.dart';
import 'package:mis_app/model/arrearage_detail.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/sticky_header_container.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sticky_headers/sticky_headers.dart';

class ArrearageDetailPage extends StatefulWidget {
  final Map arguments;
  ArrearageDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _ArrearageDetailPageState createState() => _ArrearageDetailPageState();
}

class _ArrearageDetailPageState extends State<ArrearageDetailPage> {
  final Icon timerIcon = Icon(Icons.timelapse, color: Colors.orange);
  final Icon checkIcon = Icon(Icons.check_circle_outline, color: Colors.green);
  final Icon bookIcon = Icon(Icons.library_books, color: defaultThemeColor);

  final int _optionInvoiceByMonth = 0;
  final int _optionInvoiceByDate = 1;

  ArrearageModel _arrearage;
  ArrearageDetailModel _arrearageDetail;
  List<Map<String, dynamic>> _viewList = [];
  ProgressDialog _progressDialog;
  int _invoiceOption;
  TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _arrearageDetail = ArrearageDetailModel();

    if (widget.arguments != null) {
      _arrearage = ArrearageModel.fromJson(widget.arguments);
      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData();
      });
    } else {
      _arrearage = ArrearageModel();
    }
  }

  void _loadData() async {
    await _progressDialog?.show();
    try {
      _arrearageDetail =
          await SalesService.getArrearageDetail(_arrearage.custId);
      _buildViewList();
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _buildViewList() {
    _viewList.clear();

    if ((this._arrearageDetail.arrearageSum.length != null) &&
        (this._arrearageDetail.arrearageSum.length > 0)) {
      _viewList.add({
        'kind': 1,
        'name': '按月份',
        'data': this._arrearageDetail.arrearageSum
      });
    }

    if ((this._arrearageDetail.arrearageDetail.length != null) &&
        (this._arrearageDetail.arrearageDetail.length > 0)) {
      _viewList.add({
        'kind': 2,
        'name': '明细',
        'data': this._arrearageDetail.arrearageDetail
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('欠款情况'),
        actions: [
          IconButton(
            icon: Icon(Icons.library_books),
            onPressed: () {
              _showStatement();
            },
          ),
        ],
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  void _showStatement() {
    CustModel cust = CustModel(
        custId: _arrearage.custId,
        code: _arrearage.code,
        name: _arrearage.name);
    Navigator.pushNamed(context, custStatementPath, arguments: cust.toJson());
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        _headerWidget,
        Expanded(child: _listWidget),
      ],
    );
  }

  Widget get _listWidget {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return StickyHeader(
          header: StickyHeaderContainer(title: '${_viewList[index]["name"]}'),
          content: Container(
            padding: EdgeInsets.all(4.0),
            child: Column(
              children: _buildGroup(index),
            ),
          ),
        );
      },
      itemCount: _viewList.length,
    );
  }

  List<Widget> _buildGroup(int index) {
    int kind = _viewList[index]['kind'];
    List list = _viewList[index]['data'];

    List<Widget> widgetList = List();

    list.forEach((element) {
      bool isLast = element == list[list.length - 1];
      Widget itemWidget = kind == 1
          ? _sumWidget(element, isLast)
          : InkWell(
              onTap: () {
                ArrearageDetailItem item = element;
                Navigator.pushNamed(context, billDetailPath, arguments: {
                  'billType': item.billType,
                  'billId': item.salesInvoiceId,
                });
              },
              child: _detailWidget(element, isLast),
            );

      widgetList.add(
        DefaultTextStyle(
          style: TextStyle(
            color: defaultFontColor,
          ),
          child: itemWidget,
        ),
      );
    });

    return widgetList;
  }

  Widget _detailWidget(ArrearageDetailItem item, bool isLast) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(item.code),
                        Text('￥${Utils.getCurrencyStr(item.amount)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text('${Utils.dateTimeToStr(item.salesInvoiceDate)}'),
                        Text(
                          '欠￥${Utils.getCurrencyStr(item.arrearage)}',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        if (isLast)
          SizedBox(
            height: 8.0,
          )
        else
          Divider(),
      ],
    );
  }

  Widget _sumWidget(ArrearageSumItem item, bool isLast) {
    Icon icon = item.isWaitingInvoice
        ? timerIcon
        : (item.isFinishedInvoice ? checkIcon : bookIcon);

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(children: <Widget>[
                Text(item.salesInvoiceMonth),
                IconButton(
                  icon: icon,
                  onPressed: () {
                    if (item.isWaitingInvoice) {
                      _cancelInvoice(item);
                    } else if (!item.isFinishedInvoice) {
                      _invoice(item);
                    }
                  },
                ),
              ]),
            ),
            Text(
              '￥${Utils.getCurrencyStr(item.arrearage)}',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        ),
        if (isLast)
          SizedBox(
            height: 8.0,
          )
        else
          Divider(),
      ],
    );
  }

  void _cancelInvoice(ArrearageSumItem item) async {
    if (await DialogUtils.showConfirmDialog(context, '确定要撤销开票申请吗？',
        confirmText: '撤销', confirmTextColor: Colors.red)) {
      ArrearageDetailModel result;
      await _progressDialog?.show();
      try {
        result = await SalesService.cancelDeliveryInvoice(
            _arrearage.custId, item.salesInvoiceMonth);
      } finally {
        await _progressDialog?.hide();
      }

      if (result != null) {
        if (result.errCode != 0) {
          DialogUtils.showToast(result.errMsg);
          return;
        }

        _arrearageDetail = result;
        _buildViewList();
        setState(() {});
        DialogUtils.showToast('已取消申请');
      }
    }
  }

  void _invoice(ArrearageSumItem item) async {
    if (await _showRequestDialogDialog()) {
      DateTime date;
      String remarks = (_remarksController.text ?? '').trim();

      // 如果选择“指定日期”开票
      if (_invoiceOption == _optionInvoiceByDate) {
        var value = await Navigator.pushNamed(context, selectInvoicePath,
            arguments: {
              'custId': _arrearage.custId,
              'month': item.salesInvoiceMonth,
              'remarks': remarks
            });

        if (value == null) {
          return;
        }
        Map map = value;
        date = map['date'];
        remarks = map['remarks'];
      }

      ArrearageDetailModel result;
      await _progressDialog?.show();
      try {
        if (_invoiceOption == _optionInvoiceByMonth) {
          result = await SalesService.invoiceByMonth(
              _arrearage.custId, item.salesInvoiceMonth, remarks);
        } else {
          result = await SalesService.invoiceByDate(
              _arrearage.custId, date, remarks);
        }
      } finally {
        await _progressDialog?.hide();
      }

      if (result != null) {
        if (result.errCode != 0) {
          DialogUtils.showToast(result.errMsg);
          return;
        }

        _arrearageDetail = result;
        _buildViewList();
        setState(() {});
        DialogUtils.showToast('已申请开票');
      }
    }
  }

  Future<bool> _showRequestDialogDialog() {
    _remarksController.text = '';
    _invoiceOption = null;

    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          // title: Text("提示"),
          content: Container(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('请选择开票方式'),
                  Row(
                    children: <Widget>[
                      _invoiceOptionRadio(
                          dialogContext, '整月开票', _optionInvoiceByMonth),
                      _invoiceOptionRadio(
                          dialogContext, '指定日期', _optionInvoiceByDate),
                    ],
                  ),
                  TextField(
                    controller: _remarksController,
                    decoration: InputDecoration(
                      hintText: '请输入备注',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                if (_invoiceOption == null) {
                  DialogUtils.showToast('请选择开票方式');
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _invoiceOptionRadio(
      BuildContext dialogContext, String title, int value) {
    return Row(
      children: <Widget>[
        Radio(
            value: value,
            groupValue: _invoiceOption,
            onChanged: (value) {
              _invoiceOption = value;
              (dialogContext as Element).markNeedsBuild();
            }),
        Text(
          title,
          style: TextStyle(
            fontSize: fontSizeDetail,
          ),
        ),
      ],
    );
  }

  Widget get _headerWidget {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.all(8.0),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSizeDefault,
        ),
        child: Column(
          children: <Widget>[
            _custInfoWidget,
            _amountWidget,
          ],
        ),
      ),
    );
  }

  Widget get _amountWidget {
    double remain = _arrearageDetail.sumOfArrearage - _arrearageDetail.imprest;
    bool showImprest = _arrearageDetail.imprest > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Visibility(
          child: Container(
            child: Row(
              children: <Widget>[
                Text('预付款：'),
                Text(
                  '￥${Utils.getCurrencyStr(_arrearageDetail.imprest)}',
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          visible: showImprest,
        ),
        Column(
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Text('欠款：'),
                  Text(
                    '￥${Utils.getCurrencyStr(_arrearageDetail.sumOfArrearage)}',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            if (showImprest)
              Row(
                children: <Widget>[
                  Text('余款：'),
                  Text(
                    '￥${Utils.getCurrencyStr(remain)}',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget get _custInfoWidget {
    return Row(
      children: <Widget>[
        Text('客户：'),
        Expanded(
          child: Text(
            '${_arrearage.code} ${_arrearage.name}',
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
