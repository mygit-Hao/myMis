class SalesReceiptBonusModel {
  String description;
  double bonus;

  SalesReceiptBonusModel({this.description, this.bonus});

  SalesReceiptBonusModel.fromJson(Map<String, dynamic> json) {
    description = json['Description'];
    bonus = json['Bonus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Description'] = this.description;
    data['Bonus'] = this.bonus;
    return data;
  }
}
