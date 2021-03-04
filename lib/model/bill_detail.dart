class BillDetailModel {
  String billDtlId;
  String billId;
  String itemId;
  String itemCode;
  String itemName;
  String uomCode;
  String rule;
  String itemRemarks;
  double qty;
  double price;
  double stockQty;
  String remarks;

  BillDetailModel(
      {this.billDtlId,
      this.billId,
      this.itemId,
      this.itemCode,
      this.itemName,
      this.uomCode,
      this.rule,
      this.itemRemarks,
      this.qty = 0,
      this.price = 0,
      this.stockQty = 0,
      this.remarks});

  BillDetailModel.fromJson(Map<String, dynamic> json) {
    billDtlId = json['BillDtlId'].toString();
    billId = json['BillId'].toString();
    itemId = json['ItemId'];
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    uomCode = json['UomCode'];
    rule = json['Rule'];
    itemRemarks = json['ItemRemarks'];
    qty = json['Qty'] ?? 0;
    price = json['Price'] ?? 0;
    stockQty = json['StockQty'] ?? 0;
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BillDtlId'] = this.billDtlId;
    data['BillId'] = this.billId;
    data['ItemId'] = this.itemId;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['UomCode'] = this.uomCode;
    data['Rule'] = this.rule;
    data['ItemRemarks'] = this.itemRemarks;
    data['Qty'] = this.qty;
    data['Price'] = this.price;
    data['StockQty'] = this.stockQty;
    data['Remarks'] = this.remarks;
    return data;
  }
}
