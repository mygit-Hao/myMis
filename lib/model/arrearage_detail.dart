import 'package:mis_app/model/bill.dart';

class ArrearageDetailModel {
  int errCode;
  String errMsg;
  double sumOfArrearage;
  double imprest;
  List<ArrearageDetailItem> arrearageDetail;
  List<ArrearageSumItem> arrearageSum;

  ArrearageDetailModel(
      {this.errCode,
      this.errMsg,
      this.sumOfArrearage = 0,
      this.imprest = 0,
      this.arrearageDetail,
      this.arrearageSum}) {
    if (this.arrearageDetail == null) {
      this.arrearageDetail = List();
    }

    if (this.arrearageSum == null) {
      this.arrearageSum = List();
    }
  }

  ArrearageDetailModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    sumOfArrearage = json['SumOfArrearage'] ?? 0;
    imprest = json['Imprest'] ?? 0;
    if (json['ArrearageDetail'] != null) {
      arrearageDetail = new List<ArrearageDetailItem>();
      json['ArrearageDetail'].forEach((v) {
        arrearageDetail.add(new ArrearageDetailItem.fromJson(v));
      });
    }
    if (json['ArrearageSum'] != null) {
      arrearageSum = new List<ArrearageSumItem>();
      json['ArrearageSum'].forEach((v) {
        arrearageSum.add(new ArrearageSumItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    data['SumOfArrearage'] = this.sumOfArrearage;
    data['Imprest'] = this.imprest;
    if (this.arrearageDetail != null) {
      data['ArrearageDetail'] =
          this.arrearageDetail.map((v) => v.toJson()).toList();
    }
    if (this.arrearageSum != null) {
      data['ArrearageSum'] = this.arrearageSum.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ArrearageDetailItem {
  static const int defaultBillType = billTypeSalesInvoice;
  int salesInvoiceId;
  String code;
  DateTime salesInvoiceDate;
  double amount;
  double arrearage;
  int billType;

  ArrearageDetailItem(
      {this.salesInvoiceId,
      this.code,
      this.salesInvoiceDate,
      this.amount = 0,
      this.arrearage = 0}) {
    this.billType = defaultBillType;
  }

  ArrearageDetailItem.fromJson(Map<String, dynamic> json) {
    salesInvoiceId = json['SalesInvoiceId'];
    code = json['Code'];
    salesInvoiceDate = DateTime.parse(json['SalesInvoiceDate']);
    amount = json['Amount'] ?? 0;
    arrearage = json['Arrearage'] ?? 0;
    this.billType = defaultBillType;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesInvoiceId'] = this.salesInvoiceId;
    data['Code'] = this.code;
    data['SalesInvoiceDate'] = this.salesInvoiceDate.toIso8601String();
    data['Amount'] = this.amount;
    data['Arrearage'] = this.arrearage;
    return data;
  }
}

class ArrearageSumItem {
  static const int _invoiceStatusWaiting = 1;
  static const int _invoiceStatusFinished = 2;

  String salesInvoiceMonth;
  double arrearage;
  int invoiceStatus;

  bool get isWaitingInvoice {
    return invoiceStatus == _invoiceStatusWaiting;
  }

  bool get isFinishedInvoice {
    return invoiceStatus == _invoiceStatusFinished;
  }

  ArrearageSumItem(
      {this.salesInvoiceMonth, this.arrearage = 0, this.invoiceStatus});

  ArrearageSumItem.fromJson(Map<String, dynamic> json) {
    salesInvoiceMonth = json['SalesInvoiceMonth'];
    arrearage = json['Arrearage'] ?? 0;
    invoiceStatus = json['InvoiceStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SalesInvoiceMonth'] = this.salesInvoiceMonth;
    data['Arrearage'] = this.arrearage;
    data['InvoiceStatus'] = this.invoiceStatus;
    return data;
  }
}
