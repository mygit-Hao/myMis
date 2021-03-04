import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/borrow_detail.dart';
import 'package:mis_app/model/staff_info.dart';

class BorrowSData {
  // static int maxId = 0;
  static List<Area> area = [];
  static List<PaymentMethod> paymentMethod = [];
  static List<Currency> currency = [];
  static StaffInfo userStaff = StaffInfo();
}

class BorrowModel {
  List<BorrowData> borrowList;
  List<Area> area;
  List<PaymentMethod> paymentMethod;
  List<Currency> currency;
  List<StaffInfo> userStaff;

  BorrowModel(
      {this.borrowList,
      this.area,
      this.paymentMethod,
      this.currency,
      this.userStaff});

  BorrowModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      borrowList = new List<BorrowData>();
      json['List'].forEach((v) {
        borrowList.add(new BorrowData.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      area = new List<Area>();
      json['Area'].forEach((v) {
        area.add(new Area.fromJson(v));
      });
    }
    if (json['PaymentMethod'] != null) {
      paymentMethod = new List<PaymentMethod>();
      json['PaymentMethod'].forEach((v) {
        paymentMethod.add(new PaymentMethod.fromJson(v));
      });
    }
    if (json['Currency'] != null) {
      currency = new List<Currency>();
      json['Currency'].forEach((v) {
        currency.add(new Currency.fromJson(v));
      });
    }
    if (json['UserStaff'] != null) {
      userStaff = new List<StaffInfo>();
      json['UserStaff'].forEach((v) {
        userStaff.add(new StaffInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.borrowList != null) {
      data['List'] = this.borrowList.map((v) => v.toJson()).toList();
    }
    if (this.area != null) {
      data['Area'] = this.area.map((v) => v.toJson()).toList();
    }
    if (this.paymentMethod != null) {
      data['PaymentMethod'] =
          this.paymentMethod.map((v) => v.toJson()).toList();
    }
    if (this.currency != null) {
      data['Currency'] = this.currency.map((v) => v.toJson()).toList();
    }
    if (this.userStaff != null) {
      data['UserStaff'] = this.userStaff.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaymentMethod {
  String methodCode;
  String methodName;

  PaymentMethod({this.methodCode, this.methodName});

  PaymentMethod.fromJson(Map<String, dynamic> json) {
    methodCode = json['MethodCode'];
    methodName = json['MethodName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MethodCode'] = this.methodCode;
    data['MethodName'] = this.methodName;
    return data;
  }
}

class Currency {
  String currencyCode;
  String currencyName;
  bool isDefault;

  Currency({this.currencyCode, this.currencyName, this.isDefault});

  Currency.fromJson(Map<String, dynamic> json) {
    currencyCode = json['CurrencyCode'];
    currencyName = json['CurrencyName'];
    isDefault = json['IsDefault'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CurrencyCode'] = this.currencyCode;
    data['CurrencyName'] = this.currencyName;
    data['IsDefault'] = this.isDefault;
    return data;
  }
}
