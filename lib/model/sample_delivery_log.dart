class SampleDeliveryLogModel {
  int sampleDeliveryDtlReplyId;
  DateTime qCReplyDate;
  String qCReplyStatusName;
  DateTime handleDate;
  String handleStatusName;

  SampleDeliveryLogModel(
      {this.sampleDeliveryDtlReplyId,
      this.qCReplyDate,
      this.qCReplyStatusName,
      this.handleDate,
      this.handleStatusName});

  SampleDeliveryLogModel.fromJson(Map<String, dynamic> json) {
    sampleDeliveryDtlReplyId = json['SampleDeliveryDtlReplyId'];
    qCReplyDate = DateTime.parse(json['QCReplyDate']);
    qCReplyStatusName = json['QCReplyStatusName'];
    if (json['HandleDate'] != null)
      handleDate = DateTime.parse(json['HandleDate']);
    handleStatusName = json['HandleStatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SampleDeliveryDtlReplyId'] = this.sampleDeliveryDtlReplyId;
    data['QCReplyDate'] = this.qCReplyDate.toIso8601String();
    data['QCReplyStatusName'] = this.qCReplyStatusName;
    if (this.handleDate != null)
      data['HandleDate'] = this.handleDate.toIso8601String();
    data['HandleStatusName'] = this.handleStatusName;
    return data;
  }
}
