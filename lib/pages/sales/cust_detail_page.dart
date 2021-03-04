import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/model/arrearage.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CustDetailPage extends StatefulWidget {
  final Map arguments;
  CustDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _CustDetailPageState createState() => _CustDetailPageState();
}

class _CustDetailPageState extends State<CustDetailPage> {
  CustModel _cust;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _cust = CustModel();
    _cust.custId = widget.arguments['custId'];

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadCustDetail();
    });
  }

  void _loadCustDetail() async {
    // print('Loading: ${_cust.custId}');
    await _progressDialog?.show();
    try {
      CustModel cust = await SalesService.getCustDetail(_cust.custId);
      setState(() {
        _cust = cust;
      });
    } finally {
      await _progressDialog?.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('客户资料'),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: _detailWidget,
          ),
        ),
        ButtonBar(
          mainAxisSize: MainAxisSize.min,
          alignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _functionButton(
              '销售开单',
              ConstValues.icon_order,
              onPressed: () {
                Navigator.pushNamed(context, salesCartPath,
                    arguments: {'custId': _cust.custId});
              },
            ),
            _functionButton(
              '销售跟踪',
              Icons.update,
              onPressed: () {
                Navigator.pushNamed(context, salesOrderPath,
                    arguments: _cust.toJson());
              },
            ),
            _functionButton(
              '价格查询',
              ConstValues.icon_price,
              onPressed: () {
                Map cust = _cust.toJson();

                Navigator.pushNamed(context, searchPricePath, arguments: {
                  'cust': cust,
                  'selecting': false,
                });
              },
            ),
            if (Global.hasRightForRoute(sampleDeliveryDetailPath))
              _functionButton(
                '送样申请',
                Icons.move_to_inbox,
                onPressed: () {
                  Map cust = _cust.toJson();

                  // Navigator.pushNamed(context, sampleDeliveryDetailPath,
                  //     arguments: {
                  //       'cust': cust,
                  //     });

                  navigateTo(context, sampleDeliveryDetailPath, arguments: {
                    'cust': cust,
                  });
                },
              ),
            _functionButton(
              _cust.requestUnlock ? '撤销申请' : '申请解锁',
              _cust.requestUnlock ? Icons.undo : Icons.lock_open,
              enabled: !_cust.trade,
              onPressed: _cust.trade ? null : _unlock,
            ),
          ],
        ),
      ],
    );
  }

  void _unlock() async {
    // print('unlock');
    if (_cust.trade) {
      DialogUtils.showToast('当前客户不用解锁');
      return;
    }

    if (_cust.requestUnlock) {
      if (await DialogUtils.showConfirmDialog(
          context, '确定撤销 ${_cust.name} 的申请吗?',
          confirmText: '撤销', confirmTextColor: Colors.red)) {
        RequestResult result = await SalesService.cancelUnlock(_cust.custId);
        if (result.success) {
          DialogUtils.showToast('已撤销申请');
          _loadCustDetail();
        } else {
          DialogUtils.showToast(result.msg);
          return;
        }
      }
    } else {
      SalesService.unlockCust(context, _cust.custId, () {
        DialogUtils.showToast('已提交解锁申请');
        _loadCustDetail();
      });
    }
  }

  Widget get _detailWidget {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _itemWidget('客户编号', _cust.code),
          _itemWidget('客户名称', _cust.name),
          _itemWidget('结算方式', _cust.termName),
          _itemWidget('结算天数', '${_cust.payday}'),
          _itemWidget('公司地址', _cust.address),
          _itemWidget('电话号码', _cust.tel,
              style: TextStyle(color: Colors.blue),
              dataLeading: phoneIcon, onTap: () {
            callPhone(_cust.tel);
          }),
          _itemWidget('公司传真', _cust.fax),
          _itemWidget('联系人', _cust.contactPerson),
          _itemWidget(
            '手机',
            _cust.contactPersonMobile,
            style: TextStyle(color: Colors.blue),
            dataLeading:
                Utils.textIsEmptyOrWhiteSpace(_cust.contactPersonMobile)
                    ? null
                    : phoneIcon,
            onTap: () {
              callPhone(_cust.contactPersonMobile);
            },
          ),
          _arrearageWidget,
          if (_cust.imprest != null && _cust.imprest > 0)
            _itemWidget('预付款', '${_cust.imprest}'),
          if (_cust.showLockReason) _itemWidget('锁定原因', _cust.lockReason),
        ],
      ),
    );
  }

  Widget get _arrearageWidget {
    var receivable = _cust.receivable ?? 0;
    return InkWell(
      child: _itemWidget(
        '欠款',
        '￥${_cust.receivable?.toStringAsFixed(2)}',
        style: TextStyle(color: receivable > 0 ? Colors.red : Colors.black),
      ),
      onTap: () {
        if (receivable > 0) {
          ArrearageModel item = ArrearageModel(
              custId: _cust.custId,
              code: _cust.code,
              name: _cust.name,
              arrearage: receivable,
              custGrade: _cust.grade);
          Navigator.pushNamed(context, arrearageDetailPath,
              arguments: item.toJson());
        }
      },
    );
  }

  Widget _itemWidget(String title, String data,
      {TextStyle style, Widget dataLeading, Function onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 4.0,
        ),
        child: Row(
          children: <Widget>[
            Container(
              child: Text(
                title,
                style: TextStyle(color: defaultFontColor),
              ),
              width: ScreenUtil().setWidth(150.0),
            ),
            if (dataLeading != null) dataLeading,
            Expanded(
              child: Text(
                data ?? '',
                style: style,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _functionButton(String title, IconData icon,
      {bool enabled = true, Function onPressed}) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Column(
          children: <Widget>[
            Icon(
              icon,
              color: enabled ? Theme.of(context).primaryColor : Colors.grey,
            ),
            SizedBox(
              height: 4.0,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: fontSizeSmall,
                color: enabled ? Colors.black : disabledFontColor,
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border:
              Border.all(width: 2.0, color: Theme.of(context).highlightColor),
          color: Colors.grey[200],
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
        ),
      ),
      onTap: onPressed,
    );
  }
}
