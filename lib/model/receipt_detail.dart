class ReceiptDetailModel {
  String receiptCode;
  String pNO;
  DateTime receiptDate;
  double billAmount;
  double amount;

  ReceiptDetailModel(
      {this.receiptCode,
      this.pNO,
      this.receiptDate,
      this.billAmount,
      this.amount});

  ReceiptDetailModel.fromJson(Map<String, dynamic> json) {
    receiptCode = json['ReceiptCode'];
    pNO = json['PNO'];
    receiptDate = DateTime.parse(json['ReceiptDate']);
    billAmount = json['BillAmount'];
    amount = json['Amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReceiptCode'] = this.receiptCode;
    data['PNO'] = this.pNO;
    data['ReceiptDate'] = this.receiptDate.toIso8601String();
    data['BillAmount'] = this.billAmount;
    data['Amount'] = this.amount;
    return data;
  }
}
