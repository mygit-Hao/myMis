class SalesPriceModel {
  int salesPriceId;
  String itemId;
  String itemCode;
  String itemName;
  String rule;
  String uomCode;
  String itemRemarks;
  double price;
  int custId;
  double sPrice;
  double stockQty;
  bool recentUsed;
  bool expired;
  String custItemName;
  String remarks;

  SalesPriceModel(
      {this.salesPriceId,
      this.itemId,
      this.itemCode,
      this.itemName,
      this.rule,
      this.uomCode,
      this.itemRemarks,
      this.price = 0,
      this.custId,
      this.sPrice = 0,
      this.stockQty,
      this.recentUsed,
      this.expired,
      this.custItemName,
      this.remarks});

  SalesPriceModel.fromJson(Map<String, dynamic> json) {
    salesPriceId = json['SalesPriceId'];
    itemId = json['ItemId'];
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    rule = json['Rule'];
    uomCode = json['UomCode'];
    itemRemarks = json['ItemRemarks'];
    price = json['Price'] ?? 0;
    custId = json['CustId'];
    sPrice = json['SPrice'] ?? 0;
    stockQty = json['StockQty'];
    recentUsed = json['RecentUsed'];
    expired = json['Expired'];
    custItemName = json['CustItemName'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesPriceId'] = this.salesPriceId;
    data['ItemId'] = this.itemId;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['Rule'] = this.rule;
    data['UomCode'] = this.uomCode;
    data['ItemRemarks'] = this.itemRemarks;
    data['Price'] = this.price;
    data['CustId'] = this.custId;
    data['SPrice'] = this.sPrice;
    data['StockQty'] = this.stockQty;
    data['RecentUsed'] = this.recentUsed;
    data['Expired'] = this.expired;
    data['CustItemName'] = this.custItemName;
    data['Remarks'] = this.remarks;
    return data;
  }
}
