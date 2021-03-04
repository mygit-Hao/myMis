class ReceiveModel {
  List<ReceiveList> list;

  ReceiveModel({this.list});

  ReceiveModel.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list = new List<ReceiveList>();
      json['List'].forEach((v) {
        list.add(new ReceiveList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.list != null) {
      data['List'] = this.list.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReceiveList {
  String receiveId;
  String receiveCode;
  int requestStaffId;
  String requestStaffName;
  String requestDeptName;
  String reason;
  int qualityValue;
  String receiveQuality;
  int standardValue;
  String receiveStandard;
  int dinnerValue;
  String dinnerStandard;
  String dinner;
  int tavernValue;
  String tavernStandard;
  int cigarettes;
  int fruit;
  int gift;
  int other;
  String otherOption;
  int manAmount;
  int madamAmount;
  String currency;
  double tavernMoney;
  double dinnerMoney;
  double otherMoney;
  double totalMoney;
  int areaId;
  String areaName;
  int status;
  String statusName;
  DateTime createDate;
  DateTime applyDate;
  String approval;
  String wApproval;

  ReceiveList({
    this.receiveId,
    this.receiveCode,
    this.requestStaffId,
    this.requestStaffName,
    this.requestDeptName,
    this.reason,
    this.qualityValue,
    this.receiveQuality,
    this.standardValue,
    this.receiveStandard,
    this.dinnerValue,
    this.dinnerStandard,
    this.dinner,
    this.tavernValue,
    this.tavernStandard,
    this.cigarettes,
    this.fruit,
    this.gift,
    this.other,
    this.otherOption,
    this.manAmount,
    this.madamAmount,
    this.currency,
    this.tavernMoney,
    this.dinnerMoney,
    this.otherMoney,
    this.totalMoney,
    this.areaId,
    this.areaName,
    this.status,
    this.statusName,
    this.createDate,
    this.applyDate,
    this.approval,
    this.wApproval,
  });

  ReceiveList.fromJson(Map<String, dynamic> json) {
    receiveId = json['ReceiveId'];
    receiveCode = json['ReceiveCode'];
    requestStaffId = json['RequestStaffId'];
    requestStaffName = json['RequestStaffName'];
    requestDeptName = json['RequestDeptName'];
    reason = json['Reason'];
    qualityValue = json['QualityValue'];
    receiveQuality = json['ReceiveQuality'];
    standardValue = json['StandardValue'];
    receiveStandard = json['ReceiveStandard'];
    dinnerValue = json['DinnerValue'];
    dinnerStandard = json['DinnerStandard'];
    tavernValue = json['TavernValue'];
    tavernStandard = json['TavernStandard'];
    cigarettes = json['Cigarettes'];
    fruit = json['Fruit'];
    gift = json['Gift'];
    other = json['Other'];
    otherOption = json['OtherOption'];
    manAmount = json['ManAmount'];
    madamAmount = json['MadamAmount'];
    currency = json['Currency'];
    tavernMoney = json['TavernMoney'];
    dinnerMoney = json['DinnerMoney'];
    otherMoney = json['OtherMoney'];
    totalMoney = json['TotalMoney'];
    areaId = json['AreaId'];
    areaName = json['AreaName'];
    status = json['Status'];
    statusName = json['StatusName'];
    createDate = DateTime.parse(json['CreateDate']);
    applyDate = DateTime.parse(json['ApplyDate']);
    approval = json['Approval'];
    wApproval = json['WApproval'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReceiveId'] = this.receiveId;
    data['ReceiveCode'] = this.receiveCode;
    data['RequestStaffId'] = this.requestStaffId;
    data['RequestStaffName'] = this.requestStaffName;
    data['RequestDeptName'] = this.requestDeptName;
    data['Reason'] = this.reason;
    data['QualityValue'] = this.qualityValue;
    data['ReceiveQuality'] = this.receiveQuality;
    data['StandardValue'] = this.standardValue;
    data['ReceiveStandard'] = this.receiveStandard;
    data['DinnerValue'] = this.dinnerValue;
    data['DinnerStandard'] = this.dinnerStandard;
    data['Dinner'] = this.dinnerStandard;
    data['TavernValue'] = this.tavernValue;
    data['TavernStandard'] = this.tavernStandard;
    data['Cigarettes'] = this.cigarettes;
    data['Fruit'] = this.fruit;
    data['Gift'] = this.gift;
    data['Other'] = this.other;
    data['OtherOption'] = this.otherOption;
    data['ManAmount'] = this.manAmount;
    data['MadamAmount'] = this.madamAmount;
    data['Currency'] = this.currency;
    data['TavernMoney'] = this.tavernMoney;
    data['DinnerMoney'] = this.dinnerMoney;
    data['OtherMoney'] = this.otherMoney;
    data['TotalMoney'] = this.totalMoney;
    data['AreaId'] = this.areaId;
    data['AreaName'] = this.areaName;
    data['Status'] = this.status;
    data['StatusName'] = this.statusName;
    data['CreateDate'] = this.createDate.toString();
    data['ApplyDate'] = this.applyDate.toString();
    data['Approval'] = this.approval;
    data['WApproval'] = this.wApproval;
    return data;
  }
}
