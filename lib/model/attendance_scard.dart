import 'package:mis_app/utils/utils.dart';

class AttendanceSCardModel {
  static const int sCardCount = 8;

  DateTime date;

  String get toText {
    if (date == null) return '';

    return Utils.dateTimeToStr(date, pattern: formatPatternShortTime);
  }

  AttendanceSCardModel({this.date});

  AttendanceSCardModel.fromJson(Map<String, dynamic> json) {
    date = DateTime.parse(json['Dt']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.date != null) {
      data['Dt'] = this.date.toIso8601String();
    }
    return data;
  }
}
