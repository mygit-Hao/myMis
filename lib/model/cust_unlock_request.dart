class CustUnlockRequestModel {
  DateTime lastRequestDate;
  String reason;
  DateTime expectedPayDate;
  int custId;
  String custCode;
  String custName;

  CustUnlockRequestModel(
      {this.lastRequestDate,
      this.reason = '',
      this.expectedPayDate,
      this.custId,
      this.custCode = '',
      this.custName = ''});

  CustUnlockRequestModel.fromJson(Map<String, dynamic> json) {
    if (json['dt_CreateDate'] != null) {
      lastRequestDate = DateTime.parse(json['dt_CreateDate']);
    }

    reason = json['nc_Reason'] ?? '';

    if (json['dt_ExpectedPayDate'] != null) {
      expectedPayDate = DateTime.parse(json['dt_ExpectedPayDate']);
    }
    custId = json['i_CustId'];
    custCode = json['nc_CustCode'];
    custName = json['nc_CustName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dt_CreateDate'] = this.lastRequestDate?.toIso8601String();
    data['nc_Reason'] = this.reason ?? '';
    data['dt_ExpectedPayDate'] = this.expectedPayDate?.toIso8601String();
    data['i_CustId'] = this.custId;
    data['nc_CustCode'] = this.custCode ?? '';
    data['nc_CustName'] = this.custName ?? '';
    return data;
  }
}
