class SalesSummaryModel {
  int custId;
  double amount;
  String custCode;
  String custName;
  String salesmanName;
  int custGrade;

  SalesSummaryModel(
      {this.custId,
      this.amount = 0,
      this.custCode,
      this.custName,
      this.salesmanName,
      this.custGrade = 0});

  SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    custId = json['CustId'];
    amount = json['Amount'] ?? 0;
    custCode = json['CustCode'];
    custName = json['CustName'];
    salesmanName = json['SalesmanName'];
    custGrade = json['CustGrade'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustId'] = this.custId;
    data['Amount'] = this.amount;
    data['CustCode'] = this.custCode;
    data['CustName'] = this.custName;
    data['SalesmanName'] = this.salesmanName;
    data['CustGrade'] = this.custGrade;
    return data;
  }
}
