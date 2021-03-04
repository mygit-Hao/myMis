class InventoryModel {
  String itemId;
  String itemCode;
  String itemName;
  String uomCode;
  String rule;
  String itemRemarks;
  double qty;
  bool recentUsed;

  InventoryModel(
      {this.itemId,
      this.itemCode,
      this.itemName,
      this.uomCode,
      this.rule,
      this.itemRemarks,
      this.qty,
      this.recentUsed});

  InventoryModel.fromJson(Map<String, dynamic> json) {
    itemId = json['ItemId'];
    itemCode = json['ItemCode'];
    itemName = json['ItemName'];
    uomCode = json['UomCode'];
    rule = json['Rule'];
    itemRemarks = json['ItemRemarks'];
    qty = json['Qty'];
    recentUsed = json['RecentUsed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ItemId'] = this.itemId;
    data['ItemCode'] = this.itemCode;
    data['ItemName'] = this.itemName;
    data['UomCode'] = this.uomCode;
    data['Rule'] = this.rule;
    data['ItemRemarks'] = this.itemRemarks;
    data['Qty'] = this.qty;
    data['RecentUsed'] = this.recentUsed;
    return data;
  }
}
