import 'package:mis_app/utils/utils.dart';

class NotificationModel {
  int notificationDetailId;
  int notificationId;
  String title;
  String content;
  String routeName;
  String routeArguments;
  DateTime createDate;
  DateTime readDate;
  bool wholeVisible;

  bool get isNew {
    return readDate == null;
  }

  bool get canOpen {
    return !Utils.textIsEmptyOrWhiteSpace(routeName);
  }

  NotificationModel(
      {this.notificationDetailId,
      this.notificationId,
      this.title,
      this.content,
      this.routeName,
      this.routeArguments,
      this.createDate,
      this.readDate,
      this.wholeVisible = false});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    notificationDetailId = json['NotificationDetailId'];
    notificationId = json['NotificationId'];
    title = json['Title'] ?? '';
    content = json['Content'] ?? '';
    routeName = json['RouteName'];
    routeArguments = json['RouteArguments'];
    if (json['CreateDate'] != null) {
      createDate = DateTime.parse(json['CreateDate']);
    }
    if (json['ReadDate'] != null) {
      readDate = DateTime.parse(json['ReadDate']);
    }
    wholeVisible = json['WholeVisible'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NotificationDetailId'] = this.notificationDetailId;
    data['NotificationId'] = this.notificationId;
    data['Title'] = this.title;
    data['Content'] = this.content;
    data['RouteName'] = this.routeName;
    data['RouteArguments'] = this.routeArguments;
    if (this.createDate != null) {
      data['CreateDate'] = this.createDate.toIso8601String();
    }
    if (this.readDate != null) {
      data['ReadDate'] = this.readDate.toIso8601String();
    }
    data['WholeVisible'] = this.wholeVisible;
    return data;
  }
}
