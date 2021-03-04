class ApprovalResultModel {
  bool success;
  String msg;
  bool hasMoreData;
  String nextDocType;
  String nextDocId;

  ApprovalResultModel(
      {this.success,
      this.msg,
      this.hasMoreData,
      this.nextDocType,
      this.nextDocId});

  ApprovalResultModel.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    msg = json['Msg'];
    hasMoreData = json['HasMoreData'];
    nextDocType = json['NextDocType'];
    nextDocId = json['NextDocId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Success'] = this.success;
    data['Msg'] = this.msg;
    data['HasMoreData'] = this.hasMoreData;
    data['NextDocType'] = this.nextDocType;
    data['NextDocId'] = this.nextDocId;
    return data;
  }
}
