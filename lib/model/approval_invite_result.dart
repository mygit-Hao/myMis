import 'package:mis_app/model/approval_head.dart';

class ApprovalInviteResultModel {
  int errCode;
  String errMsg;
  String result;
  ApprovalHeadModel data;

  ApprovalInviteResultModel(
      {this.errCode, this.errMsg, this.result, this.data});

  ApprovalInviteResultModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    result = json['Result'];
    data = json['Data'] != null
        ? new ApprovalHeadModel.fromJson(json['Data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    data['Result'] = this.result;
    if (this.data != null) {
      data['Data'] = this.data.toJson();
    }
    return data;
  }
}
