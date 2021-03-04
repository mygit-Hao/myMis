import 'package:mis_app/model/releasePass.dart';

class ReleaseFileModel {
  int errCode;
  String errMsg;
  int fileId;
  List<Attachments> attachments;

  ReleaseFileModel({this.errCode, this.errMsg, this.fileId, this.attachments});

  ReleaseFileModel.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    fileId = json['NewFileId'];
    if (json['Atachments'] != null) {
      attachments = new List<Attachments>();
      json['Atachments'].forEach((v) {
        attachments.add(new Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    data['NewFileId'] = this.fileId;
    if (this.attachments != null) {
      data['Atachments'] = this.attachments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReleaseFileWrapper {
  int errCode;
  String errMsg;
  String fileId;
  List<Attachments> attachments;

  ReleaseFileWrapper(
      {this.errCode, this.errMsg, this.fileId, this.attachments});

  ReleaseFileWrapper.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    fileId = json['Data'];
    if (json['Attachments'] != null) {
      attachments = new List<Attachments>();
      json['Attachments'].forEach((v) {
        attachments.add(new Attachments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    data['Data'] = this.fileId;
    if (this.attachments != null) {
      data['Attachments'] = this.attachments.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PhotosModel {
  int newFileId;
  List<ReleasePhotos> photos;

  PhotosModel({this.newFileId, this.photos});

  PhotosModel.fromJson(Map<String, dynamic> json) {
    newFileId = json['NewFileId'];
    if (json['Photos'] != null) {
      photos = new List<ReleasePhotos>();
      json['Photos'].forEach((v) {
        photos.add(new ReleasePhotos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['NewFileId'] = this.newFileId;
    if (this.photos != null) {
      data['Photos'] = this.photos.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReleasePhotos {
  String releasePassFileId;
  int fileId;
  String remarks;

  ReleasePhotos({this.releasePassFileId, this.fileId, this.remarks});

  ReleasePhotos.fromJson(Map<String, dynamic> json) {
    releasePassFileId = json['ReleasePassFileId'];
    fileId = json['FileId'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ReleasePassFileId'] = this.releasePassFileId;
    data['FileId'] = this.fileId;
    data['Remarks'] = this.remarks;
    return data;
  }
}
