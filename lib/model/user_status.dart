class UserStatusModel {
  int countOfUnreadNotification;

  UserStatusModel({this.countOfUnreadNotification});

  UserStatusModel.fromJson(Map<String, dynamic> json) {
    countOfUnreadNotification = json['CountOfUnreadNotification'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CountOfUnreadNotification'] = this.countOfUnreadNotification;
    return data;
  }
}
