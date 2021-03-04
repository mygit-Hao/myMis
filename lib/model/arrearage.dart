class ArrearageModel {
  int custId;
  String code;
  String name;
  double arrearage;
  int custGrade;

  ArrearageModel(
      {this.custId,
      this.code,
      this.name,
      this.arrearage = 0,
      this.custGrade = 0});

  ArrearageModel.fromJson(Map<String, dynamic> json) {
    custId = json['CustId'];
    code = json['Code'];
    name = json['Name'];
    arrearage = json['Arrearage'] ?? 0;
    custGrade = json['CustGrade'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CustId'] = this.custId;
    data['Code'] = this.code;
    data['Name'] = this.name;
    data['Arrearage'] = this.arrearage;
    data['CustGrade'] = this.custGrade;
    return data;
  }
}
