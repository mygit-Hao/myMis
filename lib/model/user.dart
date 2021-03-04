class UserModel {
  String userId;
  String userName;
  String userChnName;

  UserModel() {
    userId = '';
    userName = '';
    userChnName = '';
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    userName = json['UserName'];
    userChnName = json['UserChnName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserId'] = this.userId;
    data['UserName'] = this.userName;
    data['UserChnName'] = this.userChnName;

    return data;
  }
}
