class SalesmanModel {
  int salesmanId;
  String salesmanName;

  SalesmanModel({this.salesmanId, this.salesmanName});

  SalesmanModel.fromJson(Map<String, dynamic> json) {
    salesmanId = json['SalesmanId'];
    salesmanName = json['SalesmanName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesmanId'] = this.salesmanId;
    data['SalesmanName'] = this.salesmanName;
    return data;
  }
}
