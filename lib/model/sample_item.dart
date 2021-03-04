class SampleItemModel {
  String itemName;

  SampleItemModel({this.itemName});

  SampleItemModel.fromJson(Map<String, dynamic> json) {
    itemName = json['ItemName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ItemName'] = this.itemName;
    return data;
  }
}
