import 'package:mis_app/utils/utils.dart';

class NotificationCategoryModel {
  int notificationCategoryId;
  String name;
  String resourceId;
  String lastNotificationTitle;
  DateTime lastNotificationDate;
  int countOfUnread;

  String get lastNotificationDateStr {
    if (lastNotificationDate == null) return '';

    if (Utils.inSameDay(lastNotificationDate, DateTime.now())) {
      return Utils.dateTimeToStrWithPattern(
          lastNotificationDate, formatPatternShortTime);
    }

    return Utils.dateTimeToStr(lastNotificationDate,
        pattern: formatPatternShortDate);
  }

  NotificationCategoryModel(
      {this.notificationCategoryId = 0,
      this.name,
      this.resourceId,
      this.lastNotificationTitle,
      this.lastNotificationDate,
      this.countOfUnread});

  NotificationCategoryModel.fromJson(Map<String, dynamic> json) {
    notificationCategoryId = json['NotificationCategoryId'];
    name = json['Name'];
    resourceId = json['ResourceId'];
    lastNotificationTitle = json['LastNotificationTitle'];
    if (json['LastNotificationDate'] != null) {
      lastNotificationDate = DateTime.parse(json['LastNotificationDate']);
    }
    countOfUnread = json['CountOfUnread'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NotificationCategoryId'] = this.notificationCategoryId;
    data['Name'] = this.name;
    data['ResourceId'] = this.resourceId;
    data['LastNotificationTitle'] = this.lastNotificationTitle;
    if (lastNotificationDate != null) {
      data['LastNotificationDate'] = lastNotificationDate.toIso8601String();
    }
    data['CountOfUnread'] = this.countOfUnread;
    return data;
  }
}
