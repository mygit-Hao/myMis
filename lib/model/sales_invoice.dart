class SalesInvoiceModel {
  int salesInvoiceId;
  String code;
  DateTime salesInvoiceDate;
  double amount;
  bool canSelect;
  bool selected;

  SalesInvoiceModel(
      {this.salesInvoiceId,
      this.code,
      this.salesInvoiceDate,
      this.amount,
      this.canSelect,
      this.selected = false});

  SalesInvoiceModel.fromJson(Map<String, dynamic> json) {
    salesInvoiceId = json['SalesInvoiceId'];
    code = json['Code'];
    salesInvoiceDate = DateTime.parse(json['SalesInvoiceDate']);
    amount = json['Amount'];
    canSelect = json['CanSelect'];
    selected = json['Selected'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesInvoiceId'] = this.salesInvoiceId;
    data['Code'] = this.code;
    data['SalesInvoiceDate'] = this.salesInvoiceDate.toIso8601String();
    data['Amount'] = this.amount;
    data['CanSelect'] = this.canSelect;
    data['Selected'] = this.selected;
    return data;
  }
}
