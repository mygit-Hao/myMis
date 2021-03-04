import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/sales_invoice.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SelectInvoicePage extends StatefulWidget {
  final Map arguments;
  SelectInvoicePage({Key key, this.arguments}) : super(key: key);

  @override
  _SelectInvoicePageState createState() => _SelectInvoicePageState();
}

class _SelectInvoicePageState extends State<SelectInvoicePage> {
  int _custId;
  String _month;
  String _remarks;
  DateTime _selectedDate;
  List<SalesInvoiceModel> _list = [];
  TextEditingController _remarksController = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    if (widget.arguments != null) {
      var arguments = widget.arguments;
      _custId = arguments['custId'];
      _month = arguments['month'];
      _remarks = arguments['remarks'];
      _remarksController.text = _remarks;

      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData();
      });
    }
  }

  void _loadData() async {
    await _progressDialog?.show();
    try {
      _list = await SalesService.getSalesInvoiceForDi(_custId, _month);
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
        title: Text('销售发票选择'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(child: _listWidget),
          Container(
            padding: EdgeInsets.all(4.0),
            child: TextField(
              controller: _remarksController,
              minLines: 3,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: '请输入备注',
              ),
            ),
          ),
          _buttons,
        ],
      ),
    );
  }

  Widget get _buttons {
    return Container(
      color: backgroundColor,
      child: ButtonBar(
        children: <Widget>[
          OutlineButton(
            child: Text('取消'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          OutlineButton(
            child: Text('确定'),
            onPressed: () {
              if (_selectedDate == null) {
                DialogUtils.showToast('请指定日期');
                return;
              }
              Navigator.pop(context, {
                'date': _selectedDate,
                'remarks': _remarksController.text,
              });
            },
          ),
        ],
      ),
    );
  }

  Widget get _listWidget {
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        return _itemWidget(index);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemCount: _list.length,
    );
  }

  Widget _itemWidget(int index) {
    SalesInvoiceModel item = _list[index];

    return CheckboxListTile(
      value: item.selected,
      selected: item.selected,
      secondary: Text(item.code),
      title: Text(Utils.dateTimeToStr(item.salesInvoiceDate)),
      subtitle: Text('￥${Utils.getCurrencyStr(item.amount)}'),
      onChanged: (bool value) {
        _updateSelected(index);
        setState(() {
          item.selected = value;
        });
      },
    );
  }

  void _updateSelected(int position) {
    for (int i = 0; i < _list.length; i++) {
      SalesInvoiceModel item = _list[i];
      if (item.canSelect) {
        item.selected = (i >= position);
      }
    }

    SalesInvoiceModel item = _list[position];
    if (item.selected) {
      _selectedDate = item.salesInvoiceDate;
    }
  }
}
