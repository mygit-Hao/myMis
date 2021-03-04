import 'package:mis_app/model/buCard.dart';

class BuCardWrapper {
  int errCode;
  String errMsg;
  BuCardList buCardList;
  List<Detail> detail;

  BuCardWrapper({this.errCode, this.errMsg, this.buCardList, this.detail});

  BuCardWrapper.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['Data'] != null) {
      var jsonData = json['Data'][0];
      buCardList = BuCardList.fromJson(jsonData);
    }
    if (json['Detail'] != null) {
      detail = new List<Detail>();
      json['Detail'].forEach((v) {
        detail.add(new Detail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.buCardList != null) {
      data['Data'][0] = this.buCardList.toJson();
    }
    if (this.detail != null) {
      data['Detail'] = this.detail.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Detail {
  String buCardId;
  String buCardDid;
  int staffId;
  String staffCode;
  String staffName;
  String deptName;
  String posi;

  Detail(
      {this.buCardId,
      this.buCardDid,
      this.staffId,
      this.staffCode,
      this.staffName,
      this.deptName,
      this.posi});

  Detail.fromJson(Map<String, dynamic> json) {
    buCardId = json['BuCardId'];
    buCardDid = json['BuCardDid'];
    staffId = json['StaffId'];
    staffCode = json['StaffCode'];
    staffName = json['StaffName'];
    deptName = json['DeptName'];
    posi = json['Posi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BuCardId'] = this.buCardId;
    data['BuCardDid'] = this.buCardDid;
    data['StaffId'] = this.staffId;
    data['StaffCode'] = this.staffCode;
    data['StaffName'] = this.staffName;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    return data;
  }
}
