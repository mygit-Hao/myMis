import 'dart:io';

import 'package:mis_app/model/receive.dart';
import 'package:mis_app/model/receivePhone.dart';
import 'package:mis_app/utils/utils.dart';

class ReceiveWrapper {
  int errCode;
  String errMsg;
  ReceiveList receiveList;
  List<ReceiveDetail> detail;
  List<ReceiveRoom> room;
  List<Attachment> attachment;
  List<ReceivePerson> personList;

  ReceiveWrapper(
      {this.errCode,
      this.errMsg,
      this.receiveList,
      this.detail,
      this.room,
      this.attachment,
      this.personList});

  ReceiveWrapper.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    var dataList = json['Data'];
    if (dataList != null) {
      receiveList = new ReceiveList();
      if (dataList.length > 0) {
        var jsonData = json['Data'][0];
        receiveList = ReceiveList.fromJson(jsonData);
      }
    }
    if (json['Detail'] != null) {
      detail = new List<ReceiveDetail>();
      json['Detail'].forEach((v) {
        detail.add(new ReceiveDetail.fromJson(v));
      });
    }
    if (json['Room'] != null) {
      room = new List<ReceiveRoom>();
      json['Room'].forEach((v) {
        room.add(new ReceiveRoom.fromJson(v));
      });
    }
    if (json['Attachment'] != null) {
      attachment = new List<Attachment>();
      json['Attachment'].forEach((v) {
        attachment.add(new Attachment.fromJson(v));
      });
    }
    if (json['PersonList'] != null) {
      personList = new List<ReceivePerson>();
      json['PersonList'].forEach((v) {
        personList.add(new ReceivePerson.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.receiveList != null) {
      data['Data'][0] = this.receiveList.toJson();
    }
    if (this.detail != null) {
      data['Detail'] = this.detail.map((v) => v.toJson()).toList();
    }
    if (this.room != null) {
      data['Room'] = this.room.map((v) => v.toJson()).toList();
    }
    if (this.attachment != null) {
      data['Attachment'] = this.attachment.map((v) => v.toJson()).toList();
    }
    if (this.personList != null) {
      data['PersonList'] = this.personList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReceiveDetail {
  String receiveDtlId;
  int staffId;
  int deptId;
  int sexCode;
  String gender;
  String staffName;
  String staffCode;
  String deptName;
  String posi;
  String phone;

  ReceiveDetail(
      {this.receiveDtlId,
      this.staffId,
      this.deptId = 0,
      this.sexCode,
      this.gender,
      this.staffName,
      this.staffCode = '',
      this.deptName,
      this.posi = '',
      this.phone});

  ReceiveDetail.fromJson(Map<String, dynamic> json) {
    receiveDtlId = json['ReceiveDtlId'];
    staffId = json['StaffId'];
    deptId = json['DeptId'] ?? 0;
    sexCode = json['SexCode'];
    gender = json['Gender'];
    staffName = json['StaffName'];
    staffCode = json['StaffCode'] ?? '工号(选填)';
    deptName = json['DeptName'];
    posi = json['Posi'] ?? '';
    phone = json['Phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReceiveDtlId'] = this.receiveDtlId;
    data['StaffId'] = this.staffId;
    data['DeptId'] = this.deptId;
    data['SexCode'] = this.sexCode;
    data['Gender'] = this.gender;
    data['StaffName'] = this.staffName;
    data['StaffCode'] = this.staffCode;
    data['DeptName'] = this.deptName;
    data['Posi'] = this.posi;
    data['Phone'] = this.phone;
    return data;
  }
}

class ReceiveRoom {
  String receiveRoomId;
  int roomType;
  int roomAmount;
  double roomPrice;
  DateTime beginDate;
  DateTime finishDate;
  int day;
  double roomMoney;
  String roomTypeName;

  ReceiveRoom(
      {this.receiveRoomId,
      this.roomType,
      this.roomAmount,
      this.roomPrice,
      this.beginDate,
      this.finishDate,
      this.day,
      this.roomMoney,
      this.roomTypeName});

  ReceiveRoom.fromJson(Map<String, dynamic> json) {
    receiveRoomId = json['ReceiveRoomId'];
    roomType = json['RoomType'];
    roomAmount = json['RoomAmount'];
    roomPrice = json['RoomPrice'];
    beginDate = DateTime.parse(json['BeginDate']);
    finishDate = DateTime.parse(json['FinishDate']);
    day = json['Day'];
    roomMoney = json['RoomMoney'];
    roomTypeName = json['RoomTypeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReceiveRoomId'] = this.receiveRoomId;
    data['RoomType'] = this.roomType;
    data['RoomAmount'] = this.roomAmount;
    data['RoomPrice'] = this.roomPrice;
    data['BeginDate'] = this.beginDate.toString();
    data['FinishDate'] = this.finishDate.toString();
    data['Day'] = this.day;
    data['RoomMoney'] = this.roomMoney;
    data['RoomTypeName'] = this.roomTypeName;
    return data;
  }
}

class Attachment {
  String receiveFileId;
  int fileId;
  String fileName;
  String remarks;
  String fileType;
  File file;
  String fileExt;
  String shortName;

  Attachment(
      {this.receiveFileId,
      this.fileId,
      this.fileName,
      this.remarks,
      this.fileType});

  Attachment.fromJson(Map<String, dynamic> json) {
    receiveFileId = json['ReceiveFileId'];
    fileId = json['FileId'];
    fileName = json['FileName'];
    remarks = json['Remarks'];
    fileType = json['FileType'];
    this.fileExt = Utils.getFileExt(fileName);
    this.shortName = Utils.getFileName(fileName);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReceiveFileId'] = this.receiveFileId;
    data['FileId'] = this.fileId;
    data['FileName'] = this.fileName;
    data['Remarks'] = this.remarks;
    data['FileType'] = this.fileType;
    return data;
  }
}
