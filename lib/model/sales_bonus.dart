import 'package:mis_app/utils/utils.dart';

class SalesBonusListWrapper {
  DateTime dateFrom;
  DateTime dateTo;
  double bonus;
  List<SalesBonusModel> list;

  SalesBonusListWrapper({this.dateFrom, this.dateTo, this.bonus, this.list});

  SalesBonusListWrapper.fromJson(Map<String, dynamic> json) {
    dateFrom = DateTime.parse(json['DateFrom']);
    dateTo = DateTime.parse(json['DateTo']);
    bonus = json['Bonus'];
    if (json['List'] != null) {
      list = new List<SalesBonusModel>();
      json['List'].forEach((v) {
        list.add(new SalesBonusModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DateFrom'] = this.dateFrom.toIso8601String();
    data['DateTo'] = this.dateTo.toIso8601String();
    data['Bonus'] = this.bonus;
    if (this.list != null) {
      data['List'] = this.list.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SalesBonusModel {
  String custCode;
  String custName;
  String salesKindName;
  String termKindName;
  String currency;
  String currencySymbol;
  int custID;
  int salesInvoiceId;
  String salesInvoiceCode;
  DateTime salesInvoiceDate;
  double salesInvoiceAmount;
  double balanceAmount;
  double bonus;

  SalesBonusModel(
      {this.custCode,
      this.custName,
      this.salesKindName,
      this.termKindName,
      this.currency,
      this.currencySymbol,
      this.custID,
      this.salesInvoiceId,
      this.salesInvoiceCode,
      this.salesInvoiceDate,
      this.salesInvoiceAmount,
      this.balanceAmount,
      this.bonus});

  String get custInfo {
    String result = salesKindName;
    if ((!Utils.textIsEmptyOrWhiteSpace(salesKindName)) &&
        (!Utils.textIsEmptyOrWhiteSpace(termKindName))) {
      result = result + "/";
    }

    return result + termKindName;
  }

  SalesBonusModel.fromJson(Map<String, dynamic> json) {
    custCode = json['CustCode'];
    custName = json['CustName'];
    salesKindName = json['SalesKindName'];
    termKindName = json['TermKindName'];
    currency = json['Currency'];
    currencySymbol = json['CurrencySymbol'];
    custID = json['i_CustID'];
    salesInvoiceId = json['SalesInvoiceId'];
    salesInvoiceCode = json['SalesInvoiceCode'];
    salesInvoiceDate = DateTime.parse(json['SalesInvoiceDate']);
    salesInvoiceAmount = json['SalesInvoiceAmount'];
    balanceAmount = json['BalanceAmount'];
    bonus = json['Bonus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustCode'] = this.custCode;
    data['CustName'] = this.custName;
    data['SalesKindName'] = this.salesKindName;
    data['TermKindName'] = this.termKindName;
    data['Currency'] = this.currency;
    data['CurrencySymbol'] = this.currencySymbol;
    data['i_CustID'] = this.custID;
    data['SalesInvoiceId'] = this.salesInvoiceId;
    data['SalesInvoiceCode'] = this.salesInvoiceCode;
    data['SalesInvoiceDate'] = this.salesInvoiceDate.toIso8601String();
    data['SalesInvoiceAmount'] = this.salesInvoiceAmount;
    data['BalanceAmount'] = this.balanceAmount;
    data['Bonus'] = this.bonus;
    return data;
  }
}
