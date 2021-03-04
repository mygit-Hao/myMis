import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/utils/utils.dart';

class SampleDeliveryWrapper {
  SampleDeliveryModel sampleDelivery;
  List<SampleDeliveryDetailModel> sampleDeliveryDetailList;

  SampleDeliveryWrapper({this.sampleDelivery, this.sampleDeliveryDetailList}) {
    if (this.sampleDelivery == null) {
      this.sampleDelivery = SampleDeliveryModel();
    }

    if (this.sampleDeliveryDetailList == null) {
      this.sampleDeliveryDetailList = List();
    }

    this.sampleDelivery._updateToCust();
  }

  SampleDeliveryWrapper.fromJson(Map<String, dynamic> json) {
    var list = json['SampleDelivery'];
    if (list != null) {
      if (list.length > 0) {
        sampleDelivery = SampleDeliveryModel.fromJson(list[0]);
      }
    }
    if (json['SampleDeliveryDtl'] != null) {
      sampleDeliveryDetailList = new List<SampleDeliveryDetailModel>();
      json['SampleDeliveryDtl'].forEach((v) {
        sampleDeliveryDetailList.add(new SampleDeliveryDetailModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.sampleDelivery != null) {
      List<SampleDeliveryModel> sampleDeliveryList =
          new List<SampleDeliveryModel>();
      sampleDeliveryList.add(this.sampleDelivery);
      data['Cart'] = sampleDeliveryList.map((v) => v.toJson()).toList();
    }
    if (this.sampleDeliveryDetailList != null) {
      data['SampleDeliveryDtl'] =
          this.sampleDeliveryDetailList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SampleDeliveryListWrapper {
  List<UrgentInfo> urgentInfo;
  List<SampleDeliveryModel> sampleDeliveryList;

  SampleDeliveryListWrapper({this.urgentInfo, this.sampleDeliveryList});

  SampleDeliveryListWrapper.fromJson(Map<String, dynamic> json) {
    if (json['UrgentInfo'] != null) {
      urgentInfo = new List<UrgentInfo>();
      json['UrgentInfo'].forEach((v) {
        urgentInfo.add(new UrgentInfo.fromJson(v));
      });
    }
    if (json['SampleDeliveryList'] != null) {
      sampleDeliveryList = new List<SampleDeliveryModel>();
      json['SampleDeliveryList'].forEach((v) {
        sampleDeliveryList.add(new SampleDeliveryModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.urgentInfo != null) {
      data['UrgentInfo'] = this.urgentInfo.map((v) => v.toJson()).toList();
    }
    if (this.sampleDeliveryList != null) {
      data['SampleDeliveryList'] =
          this.sampleDeliveryList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UrgentInfo {
  String urgentInfo;

  UrgentInfo({this.urgentInfo});

  UrgentInfo.fromJson(Map<String, dynamic> json) {
    urgentInfo = json['UrgentInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UrgentInfo'] = this.urgentInfo;
    return data;
  }
}

class SampleDeliveryModel {
  static int _maxId = 0;

  static const int statusDraft = 0;
  static const int statusSubmit = 5;
  static const int statusApproval = 10;
  static const int statusQcPending = 12;
  static const int statusPendingConfirm = 15;
  static const int statusPendingFeedback = 18;
  static const int statusFinished = 20;

  static const deliveryMethodByFactory = 0;
  static const deliveryMethodByExpress = 1;
  static const deliveryMethodBySelf = 2;
  static const deliveryMethodByAgent = 3;

  static const int deliveryFeePayerIdWe = 0;
  static const int deliveryFeePayerIdCustomer = 1;

  static const int deliveryAgentDongguan = 1;
  static const int deliveryAgentShenzhen = 2;
  static const int deliveryAgentGuangzhou = 3;

  int sampleDeliveryId;
  String code;
  String custName;
  int custId;
  String custNameInput;
  String contactPerson;
  String contactPersonPosi;
  String contactTel;
  String address;
  int deliveryMethodId;
  int deliveryOption;
  int deliveryFeePayerId;
  String remarks;
  DateTime date;
  String sampleDeliveryItems;
  int status;
  String statusName;
  bool isUrgent;
  int importanceValue;
  int versionId;

  CustModel _cust;

  bool get isReadonly {
    return this.status >= statusSubmit;
  }

  bool get needDeliveryFee {
    return deliveryMethodId == deliveryMethodByExpress;
  }

  String get deliveryFeePayerName {
    if (this.deliveryMethodId == deliveryMethodByExpress) {
      if (this.deliveryFeePayerId == deliveryFeePayerIdWe)
        return "我方";
      else
        return "客方";
    } else {
      return "";
    }
  }

  String get deliveryMethodName {
    switch (deliveryMethodId) {
      case 0:
        return "跟大货";
      case 1:
        return "快递";
      case 2:
        return "自提";
      case 3:
        String deliveryAgent;
        switch (deliveryOption) {
          case deliveryAgentDongguan:
            deliveryAgent = "(东莞)";
            break;
          case deliveryAgentShenzhen:
            deliveryAgent = "(深圳)";
            break;
          case deliveryAgentGuangzhou:
            deliveryAgent = "(广州)";
            break;
          default:
            deliveryAgent = "";
        }
        return "送办事处$deliveryAgent";
      default:
        return "";
    }
  }

  void updateCust(CustModel cust) {
    this.custId = cust.custId;
    this.custName = cust.name;
    this.contactPerson = cust.contactPerson;
    this.contactPersonPosi = cust.contactPersonPosi;
    this.contactTel = cust.contactTel;
    this.address = cust.address;

    _updateToCust();
  }

  void _updateToCust() {
    if (_cust == null) {
      _cust = CustModel();
    }
    _cust.custId = this.custId;
    _cust.name = this.custName;
    _cust.contactPerson = this.contactPerson;
    _cust.contactPersonPosi = this.contactPersonPosi;
    _cust.contactTel = this.contactTel;
    _cust.address = this.address;
  }

  CustModel get cust {
    return _cust;
  }

  String get criticalFunctionName {
    switch (this.status) {
      case statusDraft:
        return '删除';
      case statusSubmit:
        return '撤销';
      case statusPendingConfirm:
        return '回复';
      case statusPendingFeedback:
        return '反馈';
      default:
        return '查看';
    }
  }

  SampleDeliveryModel(
      {this.sampleDeliveryId,
      this.code,
      this.custName = '',
      this.custId = 0,
      this.custNameInput,
      this.contactPerson = '',
      this.contactPersonPosi = '',
      this.contactTel = '',
      this.address = '',
      this.deliveryMethodId,
      this.deliveryOption,
      this.deliveryFeePayerId,
      this.remarks,
      this.date,
      this.sampleDeliveryItems,
      this.status = statusDraft,
      this.statusName,
      this.isUrgent = false,
      this.importanceValue,
      this.versionId}) {
    _maxId--;
    this.sampleDeliveryId = _maxId;
    this.date = Utils.today;

    if (_cust == null) {
      _cust = CustModel();
    }
    isUrgent = false;
  }

  SampleDeliveryModel.fromJson(Map<String, dynamic> json) {
    sampleDeliveryId = json['SampleDeliveryId'];
    code = json['Code'] ?? '';
    custName = json['CustName'] ?? '';
    custId = json['CustId'];
    custNameInput = json['CustNameInput'];
    contactPerson = json['ContactPerson'] ?? '';
    contactPersonPosi = json['ContactPersonPosi'] ?? '';
    contactTel = json['ContactTel'] ?? '';
    address = json['Address'] ?? '';
    deliveryMethodId = json['DeliveryMethodId'];
    deliveryOption = json['DeliveryOption'];
    deliveryFeePayerId = json['DeliveryFeePayerId'];
    remarks = json['Remarks'];
    date = DateTime.parse(json['CreateDate']);
    sampleDeliveryItems = json['SampleDeliveryItems'];
    status = json['Status'];
    statusName = json['StatusName'];
    isUrgent = json['IsUrgent'] ?? false;
    importanceValue = json['ImportanceValue'];
    versionId = json['VersionId'];

    _updateToCust();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SampleDeliveryId'] = this.sampleDeliveryId;
    data['Code'] = this.code;
    data['CustName'] = this.custName;
    data['CreateDate'] = this.date.toIso8601String();
    data['CustId'] = this.custId;
    data['CustNameInput'] = this.custNameInput;
    data['ContactPerson'] = this.contactPerson;
    data['ContactPersonPosi'] = this.contactPersonPosi;
    data['ContactTel'] = this.contactTel;
    data['Address'] = this.address;
    data['DeliveryMethodId'] = this.deliveryMethodId;
    data['DeliveryOption'] = this.deliveryOption;
    data['DeliveryFeePayerId'] = this.deliveryFeePayerId;
    data['Remarks'] = this.remarks;
    data['SampleDeliveryItems'] = this.sampleDeliveryItems;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    data['IsUrgent'] = this.isUrgent;
    data['ImportanceValue'] = this.importanceValue;
    data['VersionId'] = this.versionId;
    return data;
  }
}
