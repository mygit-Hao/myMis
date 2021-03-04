// class CustomerVisitCateModel {
//   List<Category> category;
//   List<Items> items;

//   CustomerVisitCateModel({this.category, this.items});

//   CustomerVisitCateModel.fromJson(Map<String, dynamic> json) {
//     if (json['Category'] != null) {
//       category = new List<Category>();
//       json['Category'].forEach((v) {
//         category.add(new Category.fromJson(v));
//       });
//     }
//     if (json['Items'] != null) {
//       items = new List<Items>();
//       json['Items'].forEach((v) {
//         items.add(new Items.fromJson(v));
//       });
//     }
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.category != null) {
//       data['Category'] = this.category.map((v) => v.toJson()).toList();
//     }
//     if (this.items != null) {
//       data['Items'] = this.items.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }

// class Category {
//   int categoryId;
//   String category;

//   Category({this.categoryId, this.category});

//   Category.fromJson(Map<String, dynamic> json) {
//     categoryId = json['CategoryId'];
//     category = json['Category'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['CategoryId'] = this.categoryId;
//     data['Category'] = this.category;
//     return data;
//   }
// }

// class Items {
//   int visitItemId;
//   int categoryId;
//   String category;
//   String itemName;
//   String content;
//   bool isCheck;

//   Items(
//       {this.visitItemId,
//       this.categoryId,
//       this.category,
//       this.itemName,
//       this.content,
//       this.isCheck = false});

//   Items.fromJson(Map<String, dynamic> json) {
//     visitItemId = json['VisitItemId'];
//     categoryId = json['CategoryId'];
//     category = json['Category'];
//     itemName = json['ItemName'];
//     content = json['Content'];
//     isCheck = json['IsCheck'] ?? false;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['VisitItemId'] = this.visitItemId;
//     data['CategoryId'] = this.categoryId;
//     data['Category'] = this.category;
//     data['ItemName'] = this.itemName;
//     data['Content'] = this.content;
//     data['IsCheck'] = this.isCheck;
//     return data;
//   }
// }

class SelectFormatData {
  int categoryId = 0;
  String itemsIds = '';
  String items = '';

  SelectFormatData({this.categoryId, this.items, this.itemsIds});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryId'] = this.categoryId;
    data['itemsIds'] = this.itemsIds;
    data['items'] = this.items;
    return data;
  }

  SelectFormatData.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    itemsIds = json['itemsIds'];
    items = json['items'];
  }
}

class CustomerVisitCateModel {
  List<Category> category;
  List<Items> items;

  CustomerVisitCateModel({this.category, this.items});

  CustomerVisitCateModel.fromJson(Map<String, dynamic> json) {
    if (json['Category'] != null) {
      category = new List<Category>();
      json['Category'].forEach((v) {
        category.add(new Category.fromJson(v));
      });
    }
    if (json['Items'] != null) {
      items = new List<Items>();
      json['Items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.category != null) {
      data['Category'] = this.category.map((v) => v.toJson()).toList();
    }
    if (this.items != null) {
      data['Items'] = this.items.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Category {
  int categoryId;
  int seqNo;
  String name;
  String description;
  bool required;
  bool manualInput;
  bool hasSelect;

  Category(
      {this.categoryId,
      this.seqNo,
      this.name,
      this.description,
      this.required,
      this.manualInput,
      this.hasSelect});

  Category.fromJson(Map<String, dynamic> json) {
    categoryId = json['CategoryId'];
    seqNo = json['SeqNo'];
    name = json['Name'];
    description = json['Description'];
    required = json['Required'];
    manualInput = json['ManualInput'];
    hasSelect = json['hasSelect'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CategoryId'] = this.categoryId;
    data['SeqNo'] = this.seqNo;
    data['Name'] = this.name;
    data['Description'] = this.description;
    data['Required'] = this.required;
    data['ManualInput'] = this.manualInput;
    data['hasSelect'] = this.hasSelect;
    return data;
  }
}

class Items {
  int visitItemId;
  int seqNo;
  int categoryId;
  String itemName;
  String content;
  bool isCheck;
  String inputData;

  Items(
      {this.visitItemId,
      this.seqNo,
      this.categoryId,
      this.itemName,
      this.content});

  Items.fromJson(Map<String, dynamic> json) {
    visitItemId = json['VisitItemId'];
    seqNo = json['SeqNo'];
    categoryId = json['CategoryId'];
    itemName = json['ItemName'];
    content = json['Content'];
    isCheck = json['IsCheck'] ?? false;
    inputData = '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['VisitItemId'] = this.visitItemId;
    data['SeqNo'] = this.seqNo;
    data['CategoryId'] = this.categoryId;
    data['ItemName'] = this.itemName;
    data['Content'] = this.content;
    data['IsCheck'] = this.isCheck;
    return data;
  }
}
