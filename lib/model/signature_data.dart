class SignatureData {
  String signatureId;
  String signatureDate;

  SignatureData({this.signatureId, this.signatureDate});

  SignatureData.fromJson(Map<String, dynamic> json) {
    signatureId = json['SignatureId'];
    signatureDate = json['SignatureDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SignatureId'] = this.signatureId;
    data['SignatureDate'] = this.signatureDate;
    return data;
  }
}
