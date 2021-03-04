import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/sales_price.dart';
import 'package:mis_app/utils/utils.dart';

class SalesCartWrapper {
  int errCode;
  String errMsg;
  Cart cart;
  List<CartDetailModel> cartDtl;
  CustModel _cust;
  bool modified;

  bool get locked {
    return (cart.custId != null) && cart.custId > 0 && (!cart.custTrade);
  }

  bool get hasCustomerPurchaseOrderNo {
    return (this.cart != null) &&
        !Utils.textIsEmptyOrWhiteSpace(this.cart.customerPurchaseOrderNo);
  }

  bool get isOverStock {
    bool isOver = false;
    for (CartDetailModel item in cartDtl) {
      if (item.qty > item.stockQty) {
        isOver = true;
        break;
      }
    }
    return isOver;
  }

  void updateRemarks(String remarks) {
    remarks = remarks ?? '';
    if (this.cart.remarks != remarks) {
      this.cart.remarks = remarks;
      modified = true;
    }
  }

  void updateCustomerPurchaseOrderNo(String customerPurchaseOrderNo) {
    customerPurchaseOrderNo = customerPurchaseOrderNo ?? '';
    if (this.cart.customerPurchaseOrderNo != customerPurchaseOrderNo) {
      this.cart.customerPurchaseOrderNo = customerPurchaseOrderNo;
      modified = true;
    }
  }

  bool updateDetailRemarks(CartDetailModel detail, String remarks) {
    if (detail.remarks != remarks) {
      detail.remarks = remarks;
      modified = true;
      return true;
    }

    return false;
  }

  void updateCust(CustModel cust) {
    this.cart.custId = cust.custId;
    this.cart.custCode = cust.code;
    this.cart.custName = cust.name;
    this.cart.custGrade = cust.grade;
    this.cart.custTrade = cust.trade;

    _updateToCust();
    modified = true;
  }

  void addDetailByPrice(SalesPriceModel priceItem) {
    CartDetailModel detail = _findDetailByItemId(priceItem.itemId);
    if (detail == null) {
      detail = CartDetailModel(
        salesCartDtlId: 0,
        salesCartId: this.cart.salesCartId,
        itemId: priceItem.itemId,
        qty: 1,
      );
      this.cartDtl.add(detail);
    } else {
      detail.qty = detail.qty + 1;
    }

    detail.itemCode = priceItem.itemCode;
    detail.itemName = priceItem.itemName;
    detail.rule = priceItem.rule;
    detail.uomCode = priceItem.uomCode;
    detail.itemRemarks = priceItem.itemRemarks;
    detail.stockQty = priceItem.stockQty;
    detail.price = priceItem.price;
    detail.sPrice = priceItem.sPrice;
    detail.remarks = priceItem.remarks;

    _updateSumary();
  }

  void updateQty(CartDetailModel detail, double qty) {
    if (detail.qty != qty) {
      detail.qty = qty;
      _updateSumary();
    }
  }

  void removeDetail(CartDetailModel detail) {
    this.cartDtl.remove(detail);
    _updateSumary();
  }

  void _updateSumary() {
    double sumOfQty = 0;
    double sumOfAmount = 0;

    for (CartDetailModel item in this.cartDtl) {
      sumOfQty = sumOfQty + item.qty;
      sumOfAmount = sumOfAmount + item.price * item.qty;
    }

    this.cart.qty = sumOfQty;
    this.cart.amount = sumOfAmount;
    modified = true;
  }

  CartDetailModel _findDetailByItemId(String itemId) {
    CartDetailModel result;
    for (CartDetailModel item in this.cartDtl) {
      if (itemId == item.itemId) {
        result = item;
        break;
      }
    }
    return result;
  }

  void _updateToCust() {
    if (_cust == null) {
      _cust = CustModel();
    }
    _cust.custId = this.cart.custId;
    _cust.code = this.cart.custCode;
    _cust.name = this.cart.custName;
    _cust.grade = this.cart.custGrade;
    _cust.trade = this.cart.custTrade;
  }

  CustModel get cust {
    return _cust;
  }

  SalesCartWrapper({this.errCode, this.errMsg, this.cart, this.cartDtl}) {
    modified = false;
    if (this.cart == null) {
      this.cart = Cart(deliveryDate: Utils.today);
    }
    if (this.cartDtl == null) {
      this.cartDtl = List();
    }

    _updateToCust();
  }

  SalesCartWrapper.fromJson(Map<String, dynamic> json) {
    modified = false;
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    var cartData = json['Cart'];
    if (cartData != null) {
      if (cartData.length > 0) {
        cart = new Cart.fromJson(cartData[0]);
      }
    }
    if (json['CartDtl'] != null) {
      cartDtl = new List<CartDetailModel>();
      json['CartDtl'].forEach((v) {
        cartDtl.add(new CartDetailModel.fromJson(v));
      });
    }

    _updateToCust();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.cart != null) {
      List<Cart> cartList = new List<Cart>();
      cartList.add(this.cart);

      data['Cart'] = cartList.map((v) => v.toJson()).toList();
    }
    if (this.cartDtl != null) {
      data['CartDtl'] = this.cartDtl.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cart {
  int salesCartId;
  int custId;
  DateTime deliveryDate;
  double qty;
  double amount;
  String remarks;
  String customerPurchaseOrderNo;
  String custCode;
  String custName;
  bool custTrade;
  int versionId;
  bool requestUnlock;
  bool hasUnreadDenyRequest;
  int custGrade;

  Cart(
      {this.salesCartId,
      this.custId,
      this.deliveryDate,
      this.qty = 0,
      this.amount = 0,
      this.remarks = '',
      this.customerPurchaseOrderNo,
      this.custCode = '',
      this.custName = '',
      this.custTrade,
      this.versionId,
      this.requestUnlock,
      this.hasUnreadDenyRequest,
      this.custGrade = 0});

  Cart.fromJson(Map<String, dynamic> json) {
    salesCartId = json['SalesCartId'];
    custId = json['CustId'];
    deliveryDate = DateTime.parse(json['DeliveryDate']);
    qty = json['Qty'] ?? 0;
    amount = json['Amount'] ?? 0;
    remarks = json['Remarks'] ?? '';
    customerPurchaseOrderNo = json['CustomerPurchaseOrderNo'];
    custCode = json['CustCode'] ?? '';
    custName = json['CustName'] ?? '';
    custTrade = json['CustTrade'] ?? 0;
    versionId = json['VersionId'];
    requestUnlock = json['RequestUnlock'];
    hasUnreadDenyRequest = json['HasUnreadDenyRequest'];
    custGrade = json['CustGrade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesCartId'] = this.salesCartId;
    data['CustId'] = this.custId;
    data['DeliveryDate'] = this.deliveryDate.toIso8601String();
    data['Qty'] = this.qty;
    data['Amount'] = this.amount;
    data['Remarks'] = this.remarks;
    data['CustomerPurchaseOrderNo'] = this.customerPurchaseOrderNo;
    data['CustCode'] = this.custCode;
    data['CustName'] = this.custName;
    data['CustTrade'] = this.custTrade;
    data['VersionId'] = this.versionId;
    data['RequestUnlock'] = this.requestUnlock;
    data['HasUnreadDenyRequest'] = this.hasUnreadDenyRequest;
    data['CustGrade'] = this.custGrade;
    return data;
  }
}

class CartDetailModel {
  int salesCartDtlId;
  int salesCartId;
  String itemId;
  String itemCode;
  String itemName;
  String uomCode;
  String rule;
  String itemRemarks;
  double qty;
  double stockQty;
  double price;
  double sPrice;
  String remarks;

  CartDetailModel(
      {this.salesCartDtlId,
      this.salesCartId,
      this.itemId,
      this.itemCode,
      this.itemName,
      this.uomCode,
      this.rule,
      this.itemRemarks,
      this.qty,
      this.stockQty,
      this.price,
      this.sPrice,
      this.remarks});

  CartDetailModel.fromJson(Map<String, dynamic> json) {
    salesCartDtlId = json['SalesCartDtlId'];
    salesCartId = json['SalesCartId'];
    itemId = json['ItemId'];
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    uomCode = json['UomCode'];
    rule = json['Rule'];
    itemRemarks = json['ItemRemarks'];
    qty = json['Qty'];
    stockQty = json['StockQty'];
    price = json['Price'];
    sPrice = json['SPrice'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesCartDtlId'] = this.salesCartDtlId;
    data['SalesCartId'] = this.salesCartId;
    data['ItemId'] = this.itemId;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['UomCode'] = this.uomCode;
    data['Rule'] = this.rule;
    data['ItemRemarks'] = this.itemRemarks;
    data['Qty'] = this.qty;
    data['StockQty'] = this.stockQty;
    data['Price'] = this.price;
    data['SPrice'] = this.sPrice;
    data['Remarks'] = this.remarks;
    return data;
  }
}
