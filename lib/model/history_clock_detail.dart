class HistoryClockDetailModel {
  List<Data> data;
  List<Photos> photos;

  HistoryClockDetailModel({this.data, this.photos});

  HistoryClockDetailModel.fromJson(Map<String, dynamic> json) {
    if (json['Data'] != null) {
      data = new List<Data>();
      json['Data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
    if (json['Photos'] != null) {
      photos = new List<Photos>();
      json['Photos'].forEach((v) {
        photos.add(new Photos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['Data'] = this.data.map((v) => v.toJson()).toList();
    }
    if (this.photos != null) {
      data['Photos'] = this.photos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int clockRecId;
  String clockKindName;
  String clockTime;
  String address;
  String remarks;
  int photoFileId;
  bool canModify;
  String originalRemarks;
  String contentData;

  Data(
      {this.clockRecId,
      this.clockKindName,
      this.clockTime,
      this.address,
      this.remarks,
      this.photoFileId,
      this.canModify,
      this.originalRemarks,
      this.contentData});

  Data.fromJson(Map<String, dynamic> json) {
    clockRecId = json['ClockRecId'];
    clockKindName = json['ClockKindName'];
    clockTime = json['ClockTime'];
    address = json['Address'];
    remarks = json['Remarks'];
    photoFileId = json['PhotoFileId'];
    canModify = json['CanModify'];
    originalRemarks = json['OriginalRemarks'];
    contentData = json['ContentData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ClockRecId'] = this.clockRecId;
    data['ClockKindName'] = this.clockKindName;
    data['ClockTime'] = this.clockTime;
    data['Address'] = this.address;
    data['Remarks'] = this.remarks;
    data['PhotoFileId'] = this.photoFileId;
    data['CanModify'] = this.canModify;
    data['OriginalRemarks'] = this.originalRemarks;
    data['ContentData'] = this.contentData;
    return data;
  }
}

class Photos {
  int photoFileId;
  int seqNo;

  Photos({this.photoFileId, this.seqNo});

  Photos.fromJson(Map<String, dynamic> json) {
    photoFileId = json['PhotoFileId'];
    seqNo = json['SeqNo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PhotoFileId'] = this.photoFileId;
    data['SeqNo'] = this.seqNo;
    return data;
  }
}
