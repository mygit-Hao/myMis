class ItemCategoryModel {
  String categoryCode;
  String categoryName;

  ItemCategoryModel({this.categoryCode, this.categoryName});

  ItemCategoryModel.fromJson(Map<String, dynamic> json) {
    categoryCode = json['CategoryCode'];
    categoryName = json['CategoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CategoryCode'] = this.categoryCode;
    data['CategoryName'] = this.categoryName;
    return data;
  }
}
