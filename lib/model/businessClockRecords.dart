class ClockRecords {
  String clockTime;
  String address;

  ClockRecords({this.clockTime, this.address});

  ClockRecords.fromJson(Map<String, dynamic> json) {
    clockTime = json['ClockTime'];
    address = json['Address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClockTime'] = this.clockTime;
    data['Address'] = this.address;
    return data;
  }
}