class ApprovalModel {
  int seqNo;
  String docTypeName;
  String code;
  DateTime createDate;
  String areaName;
  String operator;
  String status;
  String docId;
  String operation;
  String remarks;
  String optStatus;
  String formname;
  bool canApprove;
  String docType;
  bool canSupport;

  ApprovalModel(
      {this.seqNo,
      this.docTypeName,
      this.code,
      this.createDate,
      this.areaName,
      this.operator,
      this.status,
      this.docId,
      this.operation,
      this.remarks,
      this.optStatus,
      this.formname,
      this.canApprove,
      this.docType,
      this.canSupport});

  ApprovalModel copy() => ApprovalModel(
      seqNo: this.seqNo,
      docTypeName: this.docType,
      code: this.code,
      createDate: this.createDate,
      areaName: this.areaName,
      operator: this.operator,
      status: this.status,
      docId: this.docId,
      operation: this.operation,
      remarks: this.remarks,
      optStatus: this.optStatus,
      formname: this.formname,
      canApprove: this.canApprove,
      docType: this.docType,
      canSupport: this.canSupport);

  ApprovalModel.fromJson(Map<String, dynamic> json) {
    seqNo = json['i_SeqNo'];
    docTypeName = json['nc_DocTypeName'];
    code = json['nc_Code'];
    // createDate = json['dt_CreateDate'];
    createDate = DateTime.parse(json['dt_CreateDate']);
    areaName = json['nc_AreaName'];
    operator = json['nc_Operator'];
    status = json['nc_Status'];
    docId = json['nc_Id'];
    operation = json['nc_operation'];
    remarks = json['nvc_rmk'];
    optStatus = json['nc_OptStatus'];
    formname = json['nc_formname'];
    canApprove = json['b_CanApprove'];
    docType = json['nc_DocType'];
    canSupport = json['b_CanSupport'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['i_SeqNo'] = this.seqNo;
    data['nc_DocTypeName'] = this.docTypeName;
    data['nc_Code'] = this.code;
    data['dt_CreateDate'] = this.createDate;
    data['nc_AreaName'] = this.areaName;
    data['nc_Operator'] = this.operator;
    data['nc_Status'] = this.status;
    data['nc_Id'] = this.docId;
    data['nc_operation'] = this.operation;
    data['nvc_rmk'] = this.remarks;
    data['nc_OptStatus'] = this.optStatus;
    data['nc_formname'] = this.formname;
    data['b_CanApprove'] = this.canApprove;
    data['nc_DocType'] = this.docType;
    data['b_CanSupport'] = this.canSupport;
    return data;
  }
}
