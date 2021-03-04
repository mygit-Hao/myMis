import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/model/cust.dart';

import 'package:mis_app/model/sales_cart.dart';
import 'package:mis_app/model/sales_price.dart';
import 'package:mis_app/model/sales_receipt_bonus.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/date_view.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/remarks_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SalesCartPage extends StatefulWidget {
  final Map arguments;
  SalesCartPage({Key key, this.arguments}) : super(key: key);

  @override
  _SalesCartPageState createState() => _SalesCartPageState();
}

class _SalesCartPageState extends State<SalesCartPage> {
  SalesCartWrapper _currentCart;
  int _initCustId;
  TextEditingController _remarksController = TextEditingController();
  FocusNode _remarksFocusNode = FocusNode();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _initCustId = 0;
    _currentCart = SalesCartWrapper();
    if (widget.arguments != null) {
      _initCustId = widget.arguments['custId'];
    }

    _remarksController.addListener(() {
      if (_currentCart != null) {
        // _currentCart.cart.remarks = _remarksController.text;
        _currentCart.updateRemarks(_remarksController.text);
      }
    });
    _remarksFocusNode.addListener(() {
      if (!_remarksFocusNode.hasFocus) {
        Utils.closeInput(context);
      }
    });

    // print('Init custId: $_initCustId');
    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadSalesCart(custId: _initCustId);
    });
  }

  @override
  void dispose() {
    _remarksFocusNode.dispose();
    _remarksController.dispose();

    super.dispose();
  }

  void _loadSalesCart({int custId}) async {
    _progressDialog?.style(message: loadingMessage);

    await _progressDialog?.show();
    try {
      SalesCartWrapper cart = await SalesService.getCart(custId);
      // setState(() {
      //   _currentCart = cart;
      // });
      // _remarksController.text = _currentCart.cart.remarks;
      // _currentCart.modified = false;
      _updateCart(cart);
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _updateCart(SalesCartWrapper cart) {
    setState(() {
      _currentCart = cart;
    });
    _remarksController.text = _currentCart.cart.remarks;
    _currentCart.modified = false;
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return WillPopScope(
      onWillPop: () async {
        //退出前如果未保存数据，自动保存
        _saveCart();

        return true;
      },
      child: _mainWidget,
    );
  }

  Future<bool> _saveCart() async {
    bool result = true;
    if (_currentCart.modified) {
      SalesCartWrapper cart = await SalesService.updateCart(_currentCart);
      result = (cart.errCode == 0);

      if (result) {
        _updateCart(cart);
      } else {
        DialogUtils.showToast(cart.errMsg);
      }
    }
    return result;
  }

  Widget get _mainWidget {
    return Scaffold(
      appBar: AppBar(
        title: Text('销售开单'),
        actions: <Widget>[
          if (!_currentCart.hasCustomerPurchaseOrderNo)
            MaterialButton(
              onPressed: () {
                _changeCustomerPurchaseOrderNo();
              },
              child: Text(
                'P.O#',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: <Widget>[
              _headerWidget,
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: _itemList,
                ),
              ),
              // _remarksWidget,
              RemarksTextField(
                controller: _remarksController,
                focusNode: _remarksFocusNode,
                hintText: '请输入备注',
              ),
              _footerWidget,
            ],
          ),
        ),
      ),
    );
  }

  /*
  Widget get _remarksWidget {
    return TextField(
      autofocus: false,
      controller: _remarksController,
      focusNode: _remarksFocusNode,
      minLines: 1,
      maxLines: 2,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        isDense: true,
        hintText: '请输入备注',
      ),
    );
  }
  */

  Widget get _itemList {
    if ((_currentCart == null) || (_currentCart.cartDtl.length <= 0))
      return Text('');

    return ListView.separated(
      shrinkWrap: true,
      itemCount: _currentCart.cartDtl.length,
      itemBuilder: (BuildContext context, int index) {
        CartDetailModel item = _currentCart.cartDtl[index];
        /*
        return Dismissible(
          key: Key(item.itemId),
          child: _itemWidget(item),
          background: Container(color: Colors.grey[200]),
          onDismissed: (DismissDirection direction) {
            setState(() {
              _currentCart.removeDetail(item);
            });
          },
          confirmDismiss: (DismissDirection direction) async {
            return DialogUtils.showConfirmDialog(context, '确定要删除当前项吗？');
          },
        );
        */

        return Slidable(
          actionPane: SlidableDrawerActionPane(),
          child: _itemWidget(item),
          actions: <Widget>[
            IconSlideAction(
              caption: '备注',
              color: Colors.blue,
              icon: Icons.edit,
              onTap: () async {
                String remarks = await DialogUtils.showTextFieldDialog(
                    context, item.remarks);

                if ((remarks != null) &&
                    (_currentCart.updateDetailRemarks(item, remarks))) {
                  setState(() {});
                }
              },
            ),
            IconSlideAction(
              caption: '删除',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () async {
                if (await DialogUtils.showConfirmDialog(context, '确定要删除当前项吗？',
                    confirmText: '删除', confirmTextColor: Colors.red)) {
                  setState(() {
                    _currentCart.removeDetail(item);
                  });
                }
              },
            ),
          ],
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

  Widget _itemWidget(CartDetailModel item) {
    bool islayoutResourceKind1 = Global.islayoutResourceKind1;
    Widget itemNameWidget = Text(item.itemName);
    Widget ruleAndUomWidget = Text(
      '${item.rule}/${item.uomCode}',
      style: TextStyle(
        color: defaultFontColor,
      ),
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(item.itemCode)),
              Text(
                '￥${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          //两种布局主要差异部分--开始
          if (islayoutResourceKind1)
            itemNameWidget
          else
            Row(
              children: <Widget>[
                Expanded(child: itemNameWidget),
                ruleAndUomWidget,
              ],
            ),
          if (islayoutResourceKind1) ruleAndUomWidget,

          //两种布局主要差异部分--结束

          if (!Utils.textIsEmptyOrWhiteSpace(item.itemRemarks))
            Text(
              '${item.itemRemarks}',
              style: TextStyle(
                color: defaultFontColor,
                fontSize: fontSizeDetail,
              ),
            ),
          if (!Utils.textIsEmptyOrWhiteSpace(item.remarks))
            Text(
              '${item.remarks}',
              style: TextStyle(
                color: defaultFontColor,
                fontSize: fontSizeSmall,
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.remove,
                  size: 20.0,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (item.qty > 1) {
                    setState(() {
                      _currentCart.updateQty(item, item.qty - 1);
                    });
                  }
                },
              ),
              InkWell(
                onTap: () async {
                  double value = await DialogUtils.showNumberDialog(context,
                      title: '修改数量', defaultValue: item.qty);
                  if (value != null) {
                    setState(() {
                      _currentCart.updateQty(item, value);
                    });
                  }
                },
                child: Container(
                  child: Text(
                    '${Utils.getQtyStr(item.qty)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          item.qty > item.stockQty ? Colors.red : Colors.black,
                    ),
                  ),
                  width: ScreenUtil().setWidth(100.0),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 20.0,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  setState(() {
                    _currentCart.updateQty(item, item.qty + 1);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget get _footerWidget {
    String buttonText;
    IconData iconData;
    if (_currentCart.locked) {
      buttonText = _currentCart.cart.requestUnlock ? '解锁中' : '申请解锁';
      iconData = Icons.lock_open;
    } else {
      buttonText = '确定下单';
      iconData = ConstValues.icon_order;
    }

    bool canGoToNext = _currentCart.locked || (_currentCart.cartDtl.length > 0);

    return Container(
      color: Colors.grey[200],
      child: Row(
        children: <Widget>[
          Expanded(
            child: _summaryWidget,
          ),
          Expanded(
            child: InkWell(
              onTap: canGoToNext ? _nextStepTap : null,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Icon(
                      iconData,
                      color: canGoToNext
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                    ),
                    Text(
                      buttonText,
                      style: TextStyle(
                        color: canGoToNext ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _summaryWidget {
    return InkWell(
      onTap: _showBonus,
      child: Container(
        padding: EdgeInsets.all(4.0),
        color: Theme.of(context).primaryColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '总数量：${Utils.getQtyStr(_currentCart.cart.qty)}',
              style: TextStyle(color: Colors.white),
            ),
            Text(
              '总金额：￥${Utils.getCurrencyStr(_currentCart.cart.amount)}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _showBonus() async {
    if ((_currentCart.cart.custId == null) || (_currentCart.cart.custId <= 0)) {
      return;
    }
    List<SalesReceiptBonusModel> list = await SalesService.getSalesReceiptBonus(
        _currentCart.cust.custId, _currentCart.cart.amount);
    if (list == null) return;

    DialogUtils.showInfoDialog(
      context,
      title: '收款时间对应佣金',
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

  Widget _receiptDetailWidget(SalesReceiptBonusModel item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        LabelText(
          item.description,
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
    );
  }

  void _nextStepTap() {
    // Utils.closeInput(context);

    if (_currentCart.locked) {
      if (_currentCart.cart.requestUnlock) {
        DialogUtils.showToast('已申请解锁，不用重复申请');
      } else {
        // _unlock();
        SalesService.unlockCust(
            context, _currentCart.cust.custId, _loadSalesCart);
      }
    } else {
      _cartToOrder();
    }
  }

  /*
  void _unlock() {
    Navigator.pushNamed(context, custUnlockPath,
        arguments: {'custId': _currentCart.cust.custId}).then((value) async {
      if (value != null) {
        Map<String, dynamic> map = value;
        String reason = map["reason"];
        DateTime expectedPayDate = map["expectedPayDate"];

        RequestResult result = await SalesService.requestUnlock(
            _currentCart.cust.custId, reason, expectedPayDate);
        if (result.success) {
          _loadSalesCart();
        } else {
          DialogUtils.showToast(result.msg);
          return;
        }
      }
    });
  }
  */

  void _cartToOrder() async {
    if (_currentCart.cart.deliveryDate.isBefore(Utils.today)) {
      DialogUtils.showToast('送货日期不能早于今天');
      return;
    }
    if (!await _saveCart()) {
      return;
    }

    String info =
        _currentCart.isOverStock ? '有部分数量超过库存（可考虑分批送货），确定要下单吗？' : '确定要下单吗？';

    if (await DialogUtils.showConfirmDialog(context, info)) {
      Map<String, dynamic> result =
          await SalesService.cartToOrder(_currentCart);
      bool succeed = result['Succeed'];
      String info = result['Info'];

      if (succeed) {
        await DialogUtils.showAlertDialog(context, '订单已提交');
        // _initCustId = 0;
        // _loadSalesCart(custId: _initCustId);

        Navigator.pushReplacementNamed(context, salesOrderPath);
      } else {
        DialogUtils.showToast(info);
      }
    }
  }

  Widget get _headerWidget {
    DateTime deliveryDate = _currentCart.cart.deliveryDate;
    // DateTime deliveryDate = Utils.today;

    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0),
      color: backgroundColor,
      child: Column(
        children: <Widget>[
          _custWidget,
          Row(
            children: <Widget>[
              Text('交期：'),
              DateView(
                value: deliveryDate,
                textAlign: TextAlign.start,
                onTap: () {
                  DialogUtils.showDatePickerDialog(
                      context, _currentCart.cart.deliveryDate, onValue: (val) {
                    setState(() {
                      _currentCart.cart.deliveryDate = val;
                    });
                  });
                },
              ),
              ButtonBar(
                children: <Widget>[
                  OutlineButton(
                    child: Text('增加'),
                    onPressed: () {
                      _selectSalesPrice();
                      // Utils.closeInput(context);
                    },
                  ),
                  OutlineButton(
                    child: Text('保存'),
                    onPressed: () {
                      _saveCart();
                    },
                  ),
                ],
              ),

              // OutlineButton.icon(
              //   onPressed: () {
              //     _selectSalesPrice();
              //     Utils.closeInput(context);
              //   },
              //   icon: Icon(Icons.add),
              //   label: Text('增加'),
              // ),
            ],
          ),
          if (_currentCart.hasCustomerPurchaseOrderNo) poWidget,
        ],
      ),
    );
  }

  Widget get poWidget {
    return InkWell(
      onTap: () {
        _changeCustomerPurchaseOrderNo();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(bottom: 4.0),
        child: Text(
          'P.O#：${_currentCart.cart.customerPurchaseOrderNo}',
          style: TextStyle(
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget get _custWidget {
    return InkWell(
      onTap: () {
        // Utils.closeInput(context);
        _selectCust();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text('客户：'),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _currentCart.cart.custName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSizeDetail,
                    color: getcustGradeColorByCust(_currentCart.cust),
                  ),
                ),
                Text(
                  _currentCart.cart.custCode,
                  style: TextStyle(
                    fontSize: fontSizeDetail,
                    color: getcustGradeColorByCust(_currentCart.cust),
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
      ),
    );
  }

  void _changeCustomerPurchaseOrderNo() async {
    String newCustomerPurchaseOrderNo = await DialogUtils.showTextFieldDialog(
        context, _currentCart.cart.customerPurchaseOrderNo);
    setState(() {
      _currentCart.updateCustomerPurchaseOrderNo(newCustomerPurchaseOrderNo);
    });
  }

  void _selectSalesPrice() async {
    if ((_currentCart.cart.custId == null) || (_currentCart.cart.custId <= 0)) {
      DialogUtils.showToast('请先选择客户');
      return;
    }

    // var result = await showSearch(
    //     context: context,
    //     delegate: SearchPriceDelegate(
    //         Prefs.keyHistorySelectSalesPrice, _currentCart.cart.custId));

    // if (result == null) return;

    // SalesPriceModel salesPrice = SalesPriceModel.fromJson(json.decode(result));
    // print(salesPrice.itemCode);
    Map cust = _currentCart.cust.toJson();

    Navigator.pushNamed(context, searchPricePath, arguments: {
      'cust': cust,
      'selecting': true,
    }).then((value) {
      if (value != null) {
        SalesPriceModel item = value;
        setState(() {
          _currentCart.addDetailByPrice(item);
        });
      }
    });
  }

  void _selectCust() async {
    if (((_currentCart.cart.custId ?? 0) > 0) &&
        (!await DialogUtils.showConfirmDialog(context, '更换客户可能导致选定的货品被删除，是否继续？',
            confirmTextColor: Colors.red))) {
      return;
    }

    Navigator.pushNamed(
      context,
      custPath,
      arguments: {'selecting': true},
    ).then((value) async {
      if (value != null) {
        CustModel cust = value;

        // SalesCartModel cart = await SalesService.updateCart(_currentCart);

        // setState(() {
        //   _currentCart.updateCust(cust);
        // });

        _currentCart.updateCust(cust);
        _loadSalesCart(custId: cust.custId);
      }
    });
  }
}
