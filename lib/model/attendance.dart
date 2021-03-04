class AttendanceModel {
  String deptName;
  String staffCode;
  String staffName;
  DateTime date;
  int weekDay;
  String time1;
  String time2;
  String time3;
  String time4;
  String time5;
  String time6;
  String holidayA;
  String holidayB;
  String holidayC;
  int holidayATimes;
  int holidayBTimes;
  int holidayCTimes;
  int lateA;
  int lateB;
  int lateC;
  int staffId;

  AttendanceModel(
      {this.deptName,
      this.staffCode,
      this.staffName,
      this.date,
      this.weekDay,
      this.time1,
      this.time2,
      this.time3,
      this.time4,
      this.time5,
      this.time6,
      this.holidayA,
      this.holidayB,
      this.holidayC,
      this.holidayATimes,
      this.holidayBTimes,
      this.holidayCTimes,
      this.lateA,
      this.lateB,
      this.lateC,
      this.staffId});

  AttendanceModel.fromJson(Map<String, dynamic> json) {
    deptName = json['DeptName'];
    staffCode = json['StaffCode'];
    staffName = json['StaffName'];
    // date = json['Date'];
    date = DateTime.parse(json['Date']);
    weekDay = json['WeekDay'];
    time1 = json['Time1'];
    time2 = json['Time2'];
    time3 = json['Time3'];
    time4 = json['Time4'];
    time5 = json['Time5'];
    time6 = json['Time6'];
    holidayA = json['HolidayA'];
    holidayB = json['HolidayB'];
    holidayC = json['HolidayC'];
    holidayATimes = json['HolidayATimes'];
    holidayBTimes = json['HolidayBTimes'];
    holidayCTimes = json['HolidayCTimes'];
    lateA = json['LateA'];
    lateB = json['LateB'];
    lateC = json['LateC'];
    staffId = json['StaffId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DeptName'] = this.deptName;
    data['StaffCode'] = this.staffCode;
    data['StaffName'] = this.staffName;
    data['Date'] = this.date.toIso8601String();
    data['WeekDay'] = this.weekDay;
    data['Time1'] = this.time1;
    data['Time2'] = this.time2;
    data['Time3'] = this.time3;
    data['Time4'] = this.time4;
    data['Time5'] = this.time5;
    data['Time6'] = this.time6;
    data['HolidayA'] = this.holidayA;
    data['HolidayB'] = this.holidayB;
    data['HolidayC'] = this.holidayC;
    data['HolidayATimes'] = this.holidayATimes;
    data['HolidayBTimes'] = this.holidayBTimes;
    data['HolidayCTimes'] = this.holidayCTimes;
    data['LateA'] = this.lateA;
    data['LateB'] = this.lateB;
    data['LateC'] = this.lateC;
    data['StaffId'] = this.staffId;
    return data;
  }
}
