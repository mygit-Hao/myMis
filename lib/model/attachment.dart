import 'package:mis_app/utils/utils.dart';

class AttachmentModel {
  int fileId;
  String filePath;
  String remarks;
  String shortName;
  String fileExt;
  String storagePath;

  AttachmentModel({this.fileId, this.filePath, this.remarks}) {
    _updateFileName();
  }

  AttachmentModel.fromJson(Map<String, dynamic> json) {
    fileId = json['FileId'];
    filePath = json['FilePath'];
    remarks = json['Remarks'];

    _updateFileName();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FileId'] = this.fileId;
    data['FilePath'] = this.filePath;
    data['Remarks'] = this.remarks;
    return data;
  }

  _updateFileName() {
    this.shortName = Utils.getFileName(filePath);
    this.fileExt = Utils.getFileExt(filePath);
  }
}
