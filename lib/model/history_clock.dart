class HistoryClock {
  int clockRecId;
  bool unfinished;
  String clockKindName;
  String clockTime;
  String address;
  String remarks;

  HistoryClock(
      {this.clockRecId,
      this.unfinished,
      this.clockKindName,
      this.clockTime,
      this.address,
      this.remarks});

  HistoryClock.fromJson(Map<String, dynamic> json) {
    clockRecId = json['ClockRecId'];
    unfinished = json['Unfinished'];
    clockKindName = json['ClockKindName'];
    clockTime = json['ClockTime'];
    address = json['Address'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClockRecId'] = this.clockRecId;
    data['Unfinished'] = this.unfinished;
    data['ClockKindName'] = this.clockKindName;
    data['ClockTime'] = this.clockTime;
    data['Address'] = this.address;
    data['Remarks'] = this.remarks;
    return data;
  }
}