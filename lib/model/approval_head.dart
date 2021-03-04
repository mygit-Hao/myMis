import 'package:mis_app/utils/utils.dart';

class ApprovalHeadModel {
  static String _handleSigning = "Signing";
  static String _handleAccounting = "Accounting";
  static String _handleSignCancel = "SignCancel";
  static String _handleSignUndoing = "SignUndoing";
  static int _cacheExpirySeconds = 60 * 5;

  String docId;
  String docType;
  String docTypeName;
  String status;
  String operation;
  int fileCount;
  bool canSupport;
  bool isApprovalBill;
  String allApproval;
  // DateTime cacheTime;
  DateTime _expiryTime;

  bool get isValid {
    return !Utils.textIsEmptyOrWhiteSpace(docId);
  }

  bool get isExpired {
    // return cacheTime == null ||
    //     DateTime.now().difference(cacheTime) >
    //         Duration(seconds: _cacheExpirySeconds);
    return (_expiryTime == null) || DateTime.now().isAfter(this._expiryTime);
  }

  static getNextExpiryTime() {
    return DateTime.now().add(Duration(seconds: _cacheExpirySeconds));
  }

  void updateExpiryTime() {
    expiryTime = getNextExpiryTime();
  }

  set expiryTime(DateTime value) {
    this._expiryTime = value;
  }

  bool get canSignUndo {
    return canSupport && Utils.sameText(operation, _handleSignUndoing);
  }

  bool get canApproval {
    return canSupport && Utils.sameText(operation, _handleSigning);
  }

  bool get canAccounting {
    return canSupport && Utils.sameText(operation, _handleAccounting);
  }

  bool get canSignCancel {
    return canSupport && Utils.sameText(operation, _handleSignCancel);
  }

  ApprovalHeadModel(
      {this.docId = '',
      this.docType = '',
      this.docTypeName = '',
      this.status = '',
      this.operation = '',
      this.fileCount = 0,
      this.canSupport = false,
      this.isApprovalBill = false,
      this.allApproval = ''});

  ApprovalHeadModel.fromJson(Map<String, dynamic> json) {
    docId = json['DocId'];
    docType = json['DocType'];
    docTypeName = json['DocTypeName'];
    status = json['Status'];
    operation = json['OptStatus'];
    fileCount = json['FileCount'];
    canSupport = json['CanSupport'];
    isApprovalBill = json['IsApprovalBill'];
    allApproval = json['AllApproval'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DocId'] = this.docId;
    data['DocType'] = this.docType;
    data['DocTypeName'] = this.docTypeName;
    data['Status'] = this.status;
    data['OptStatus'] = this.operation;
    data['FileCount'] = this.fileCount;
    data['CanSupport'] = this.canSupport;
    data['IsApprovalBill'] = this.isApprovalBill;
    data['AllApproval'] = this.allApproval;
    return data;
  }
}
