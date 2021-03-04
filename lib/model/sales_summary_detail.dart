class SalesSummaryDetailModel {
  String billDtlId;
  String billId;
  int billType;
  String billCode;
  DateTime billDate;
  double billHeadAmount;
  String itemCode;
  String itemName;
  String uomCode;
  String rule;
  String itemRemarks;
  double qty;
  double price;
  double amount;

  SalesSummaryDetailModel(
      {this.billDtlId,
      this.billId,
      this.billType,
      this.billCode,
      this.billDate,
      this.billHeadAmount = 0,
      this.itemCode,
      this.itemName,
      this.uomCode,
      this.rule,
      this.itemRemarks,
      this.qty = 0,
      this.price = 0,
      this.amount = 0});

  SalesSummaryDetailModel.fromJson(Map<String, dynamic> json) {
    billDtlId = json['nc_BillDtlId'];
    billId = json['BillId'];
    billType = json['BillType'];
    billCode = json['BillCode'];
    billDate = DateTime.parse(json['BillDate']);
    billHeadAmount = json['BillHeadAmount'] ?? 0;
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    uomCode = json['UomCode'];
    rule = json['Rule'];
    itemRemarks = json['ItemRemarks'];
    qty = json['Qty'] ?? 0;
    price = json['Price'] ?? 0;
    amount = json['Amount'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nc_BillDtlId'] = this.billDtlId;
    data['BillId'] = this.billId;
    data['BillType'] = this.billType;
    data['BillCode'] = this.billCode;
    data['BillDate'] = this.billDate.toIso8601String();
    data['BillHeadAmount'] = this.billHeadAmount;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['UomCode'] = this.uomCode;
    data['Rule'] = this.rule;
    data['ItemRemarks'] = this.itemRemarks;
    data['Qty'] = this.qty;
    data['Price'] = this.price;
    data['Amount'] = this.amount;
    return data;
  }
}
