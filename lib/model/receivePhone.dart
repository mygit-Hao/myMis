class ReceivePhoneModel {
  List<ReceiveRoomBase> roomlist;
  List<ReceivePerson> personlist;

  ReceivePhoneModel({this.roomlist, this.personlist});

  ReceivePhoneModel.fromJson(Map<String, dynamic> json) {
    if (json['RoomType'] != null) {
      roomlist = new List<ReceiveRoomBase>();
      json['RoomType'].forEach((v) {
        roomlist.add(new ReceiveRoomBase.fromJson(v));
      });
    }
    if (json['Person'] != null) {
      personlist = new List<ReceivePerson>();
      json['Person'].forEach((v) {
        personlist.add(new ReceivePerson.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.roomlist != null) {
      data['RoomType'] = this.roomlist.map((v) => v.toJson()).toList();
    }
    if (this.personlist != null) {
      data['Person'] = this.personlist.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReceiveRoomBase {
  int roomType;
  String typeName;

  ReceiveRoomBase({
    this.roomType,
    this.typeName,
  });

  ReceiveRoomBase.fromJson(Map<String, dynamic> json) {
    roomType = json['RoomType'];
    typeName = json['TypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RoomType'] = this.roomType;
    data['TypeName'] = this.typeName;
    return data;
  }
}

class ReceivePerson {
  String personName;
  String phone;

  ReceivePerson({
    this.personName,
    this.phone,
  });

  ReceivePerson.fromJson(Map<String, dynamic> json) {
    personName = json['PersonName'];
    phone = json['Phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PersonName'] = this.personName;
    data['Phone'] = this.phone;
    return data;
  }
}
