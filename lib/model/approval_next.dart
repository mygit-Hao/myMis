class ApprovalNextModel {
  bool hasMoreData;
  String nextDocType;
  String nextDocId;

  ApprovalNextModel({this.hasMoreData, this.nextDocType, this.nextDocId});

  ApprovalNextModel.fromJson(Map<String, dynamic> json) {
    hasMoreData = json['HasMoreData'];
    nextDocType = json['NextDocType'];
    nextDocId = json['NextDocId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['HasMoreData'] = this.hasMoreData;
    data['NextDocType'] = this.nextDocType;
    data['NextDocId'] = this.nextDocId;
    return data;
  }
}
