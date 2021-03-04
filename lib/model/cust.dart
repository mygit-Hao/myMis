import 'package:mis_app/utils/utils.dart';

class CustModel {
  int custId;
  String code;
  String name;
  String termName;
  int payday;
  String address;
  String tel;
  String fax;
  String contactPerson;
  String contactPersonPosi;
  String contactPersonMobile;
  String contactTel;
  double receivable;
  double imprest;
  bool trade;
  bool requestUnlock;
  String lockReason;
  bool hasUnreadDenyRequest;
  int grade;

  CustModel(
      {this.custId = 0,
      this.code = '',
      this.name = '',
      this.termName,
      this.payday = 0,
      this.address,
      this.tel,
      this.fax,
      this.contactPerson,
      this.contactPersonPosi,
      this.contactPersonMobile,
      this.contactTel,
      this.receivable = 0,
      this.imprest = 0,
      this.trade = false,
      this.requestUnlock = false,
      this.lockReason,
      this.hasUnreadDenyRequest,
      this.grade = 0});

  CustModel.fromJson(Map<String, dynamic> json) {
    custId = json['CustId'] ?? 0;
    code = json['Code'];
    name = json['Name'];
    termName = json['TermName'];
    payday = json['Payday'];
    address = json['Address'];
    tel = json['Tel'];
    fax = json['Fax'];
    contactPerson = json['ContactPerson'];
    contactPersonPosi = json['ContactPersonPosi'];
    contactPersonMobile = json['ContactPersonMobile'];

    contactTel = json['ContactTel'];
    if (contactTel == null) {
      contactTel = Utils.textIsEmptyOrWhiteSpace(this.contactPersonMobile)
          ? this.tel
          : this.contactPersonMobile;
    }

    receivable = json['Receivable'];
    imprest = json['Imprest'];
    trade = json['Trade'] ?? false;
    requestUnlock = json['RequestUnlock'] ?? false;
    lockReason = json['LockReason'];
    hasUnreadDenyRequest = json['HasUnreadDenyRequest'];
    grade = json['Grade'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustId'] = this.custId;
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['TermName'] = this.termName;
    data['Payday'] = this.payday;
    data['Address'] = this.address;
    data['Tel'] = this.tel;
    data['Fax'] = this.fax;
    data['ContactPerson'] = this.contactPerson;
    data['ContactPersonPosi'] = this.contactPersonPosi;
    data['ContactPersonMobile'] = this.contactPersonMobile;
    data['ContactTel'] = this.contactTel;
    data['Receivable'] = this.receivable;
    data['Imprest'] = this.imprest;
    data['Trade'] = this.trade;
    data['RequestUnlock'] = this.requestUnlock;
    data['LockReason'] = this.lockReason;
    data['HasUnreadDenyRequest'] = this.hasUnreadDenyRequest;
    data['Grade'] = this.grade;
    return data;
  }

  bool get showLockReason {
    return (!trade) && (!Utils.textIsEmpty(lockReason));
  }
}
