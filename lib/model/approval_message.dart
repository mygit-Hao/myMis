class ApprovalMessageModel {
  int messageId;
  int messageType;
  String messageContent;

  ApprovalMessageModel({this.messageId, this.messageType, this.messageContent});

  ApprovalMessageModel.fromJson(Map<String, dynamic> json) {
    messageId = json['MessageId'];
    messageType = json['MessageType'];
    messageContent = json['MessageContent'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MessageId'] = this.messageId;
    data['MessageType'] = this.messageType;
    data['MessageContent'] = this.messageContent;
    return data;
  }
}
