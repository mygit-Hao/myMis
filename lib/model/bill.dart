import 'package:mis_app/utils/utils.dart';

const int billTypeSalesOrder = 1;
const int billTypeSalesDelivery = 2;
const int billTypeSalesInvoice = 3;

class BillModel {
  static const int statusPendingApproval = 10;
  static const int statusUnbill = 15;
  static const int statusUnarrangeDelivery = 20;
  static const int statusUndelivered = 25;
  static const int statusDelivered = 30;

  String billId;
  int billType;
  String billCode;
  int custId;
  DateTime billDate;
  double qty;
  double amount;
  int status;
  String custCode;
  String custName;
  bool custTrade;
  String contactInfo;
  String contactTel;
  String remarks;

  bool get isSalesOrder {
    return billType == billTypeSalesOrder;
  }

  bool get isSalesDelivery {
    return billType == billTypeSalesDelivery;
  }

  bool get isSalesInvoice {
    return billType == billTypeSalesInvoice;
  }

  bool get isPending {
    return (status == statusPendingApproval) ||
        (status == statusUnbill) ||
        (status == statusUnarrangeDelivery) ||
        (status == statusUndelivered);
  }

  String get billTypePrefix {
    switch (billType) {
      case billTypeSalesOrder:
        return "销售";
      case billTypeSalesDelivery:
        return "送货";
      case billTypeSalesInvoice:
        return "发票";
      default:
        return "";
    }
  }

  String get statusName {
    switch (this.status) {
      case statusPendingApproval:
        return "未审批";
      case statusUnbill:
        return "未开单";
      case statusUnarrangeDelivery:
        return "未安排";
      case statusUndelivered:
        return "送货中";
      case statusDelivered:
        return "已送货";
      default:
        return "";
    }
  }

  BillModel(
      {this.billId,
      this.billType,
      this.billCode,
      this.custId,
      this.billDate,
      this.qty = 0,
      this.amount = 0,
      this.status,
      this.custCode,
      this.custName,
      this.custTrade,
      this.contactInfo,
      this.contactTel,
      this.remarks});

  BillModel.fromJson(Map<String, dynamic> json) {
    billId = json['BillId'].toString();
    billType = json['BillType'];
    billCode = (json['BillCode'] ?? '').toString().trim();
    custId = json['CustId'];

    // billDate = DateTime.parse(json['BillDate']);

    String dateField;
    if (json.containsKey('BillDate')) {
      dateField = 'BillDate';
    } else if (json.containsKey('DeliveryDate')) {
      dateField = 'DeliveryDate';
    }

    if (!Utils.textIsEmptyOrWhiteSpace(dateField)) {
      billDate = DateTime.parse(json[dateField]);
    }

    qty = json['Qty'] ?? 0;
    amount = json['Amount'] ?? 0;
    status = json['Status'];
    custCode = json['CustCode'];
    custName = json['CustName'];
    custTrade = json['CustTrade'];
    contactInfo = json['ContactInfo'];
    contactTel = json['ContactTel'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BillId'] = this.billId;
    data['BillType'] = this.billType;
    data['BillCode'] = this.billCode;
    data['CustId'] = this.custId;
    data['BillDate'] = this.billDate.toIso8601String();
    data['Qty'] = this.qty;
    data['Amount'] = this.amount;
    data['Status'] = this.status;
    data['CustCode'] = this.custCode;
    data['CustName'] = this.custName;
    data['CustTrade'] = custTrade;
    data['ContactInfo'] = this.contactInfo;
    data['ContactTel'] = this.contactTel;
    data['Remarks'] = remarks;
    return data;
  }
}
