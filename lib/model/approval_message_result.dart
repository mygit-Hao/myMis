import 'package:mis_app/model/approval_message.dart';

class ApprovalMessageResultModel {
  int errCode;
  String errMsg;
  List<ApprovalMessageModel> data;

  ApprovalMessageResultModel({this.errCode, this.errMsg, this.data});

  ApprovalMessageResultModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['Data'] != null) {
      data = new List<ApprovalMessageModel>();
      json['Data'].forEach((v) {
        data.add(new ApprovalMessageModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.data != null) {
      data['Data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
