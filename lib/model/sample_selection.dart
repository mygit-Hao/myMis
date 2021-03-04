class SampleSelectionModel {
  int selectionId;
  String selectionValue;
  String selectionKind;
  String extraInfo;

  SampleSelectionModel(
      {this.selectionId,
      this.selectionValue,
      this.selectionKind,
      this.extraInfo});

  SampleSelectionModel.fromJson(Map<String, dynamic> json) {
    selectionId = json['SelectionId'];
    selectionValue = json['SelectionValue'];
    selectionKind = json['SelectionKind'];
    extraInfo = json['ExtraInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SelectionId'] = this.selectionId;
    data['SelectionValue'] = this.selectionValue;
    data['SelectionKind'] = this.selectionKind;
    data['ExtraInfo'] = this.extraInfo;
    return data;
  }
}
