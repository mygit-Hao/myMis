import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/cust_unlock_request.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/date_view.dart';

class CustUnlockPgae extends StatefulWidget {
  final Map arguments;
  CustUnlockPgae({Key key, this.arguments}) : super(key: key);

  @override
  _CustUnlockPgaeState createState() => _CustUnlockPgaeState();
}

class _CustUnlockPgaeState extends State<CustUnlockPgae> {
  int _custId;
  CustUnlockRequestModel _request;
  DateTime _expectedPayDate;
  TextEditingController _reasonController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  GlobalKey _scrollViewKey = GlobalKey();
  double _scrollViewHeight = 100;

  @override
  void initState() {
    super.initState();

    _expectedPayDate = Utils.today;
    if (widget.arguments != null) {
      _custId = widget.arguments['custId'];
      // print('cust: $_custId');
    }
    _request = CustUnlockRequestModel();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Utils.closeInput(context);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      // 由于SingleChildScrollView包裹Expanded会出错
      // 所以，先计算SingleChildScrollView的高度，把高度赋值内部的Container，避免滚动
      setState(() {
        _scrollViewHeight = _scrollViewKey.currentContext.size.height;
      });
    });

    _loadRequest();
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _loadRequest() async {
    if (_custId == null) return;

    CustUnlockRequestModel request =
        await SalesService.getCustUnlockRequest(_custId);

    setState(() {
      _request = request;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('客户解锁'),
      ),

      /*
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(4.0),
            color: Colors.grey[200],
            child: Column(
              children: <Widget>[
                _custWidget,
                if (_request.lastRequestDate != null) _lastRequestWidget,
                _inputWidget,
                _functionButtons,
              ],
            ),
          ),
        ),
      ),
      */
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                key: _scrollViewKey,
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  height: _scrollViewHeight,
                  color: backgroundColor,
                  child: Column(
                    children: <Widget>[
                      _custWidget,
                      if (_request.lastRequestDate != null) _lastRequestWidget,
                      _inputWidget,
                    ],
                  ),
                ),
              ),
            ),
            Container(
              color: backgroundColor,
              child: _functionButtons,
            ),
          ],
        ),
      ),
    );
  }

  Widget get _inputWidget {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(4.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              _labelWidget('预计付款日期：'),
              DateView(
                value: _expectedPayDate,
                onTap: () {
                  Utils.closeInput(context);
                  DialogUtils.showDatePickerDialog(context, _expectedPayDate,
                      onValue: (val) {
                    setState(() {
                      _expectedPayDate = val;
                    });
                  });
                },
              ),
            ],
          ),
          _labelWidget('解锁原因：'),
          TextField(
            controller: _reasonController,
            focusNode: _focusNode,
            autofocus: false,
            minLines: 4,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: '请输入解锁原因',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _functionButtons {
    return ButtonBar(
      children: <Widget>[
        OutlineButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.cancel),
          label: Text('取消'),
        ),
        OutlineButton.icon(
          onPressed: _unlock,
          icon: Icon(Icons.lock_open),
          label: Text('解锁'),
        ),
      ],
    );
  }

  void _unlock() {
    if (_expectedPayDate.isBefore(Utils.today)) {
      DialogUtils.showToast('预计付款日期不能早于今天');
      return;
    }

    String reason = _reasonController.text;

    if (Utils.textIsEmptyOrWhiteSpace(reason)) {
      DialogUtils.showToast('请输入解锁原因');
      return;
    }

    Map<String, dynamic> map = {
      'expectedPayDate': _expectedPayDate,
      'reason': reason.trim()
    };

    Navigator.pop(context, map);
  }

  Widget get _lastRequestWidget {
    return Container(
      margin: EdgeInsets.only(top: 8.0),
      padding: EdgeInsets.all(4.0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Text('上次申请情况'),
          Row(
            children: <Widget>[
              _labelWidget('申请日期：'),
              _contentWidget(
                  '${Utils.dateTimeToStr(_request.lastRequestDate)}'),
            ],
          ),
          Row(
            children: <Widget>[
              _labelWidget('解锁原因：'),
              _contentWidget(_request.reason),
            ],
          ),
          Row(
            children: <Widget>[
              _labelWidget('预计付款日期：'),
              _contentWidget(
                  '${Utils.dateTimeToStr(_request.expectedPayDate)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _custWidget {
    return Container(
      padding: EdgeInsets.all(4.0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _labelWidget('客户编号：'),
              _contentWidget(_request.custCode),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _labelWidget('客户名称：'),
              Expanded(
                child: _contentWidget(_request.custName),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelWidget(String label) {
    return Text(
      label,
      style: TextStyle(
        color: defaultFontColor,
      ),
    );
  }

  Widget _contentWidget(String content) {
    return Text(
      content,
      style: TextStyle(
        color: Colors.blue,
      ),
    );
  }
}
