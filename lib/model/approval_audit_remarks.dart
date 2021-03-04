class ApprovalAuditRemarksModel {
  DateTime auditDate;
  String userName;
  String type;
  String auditRemarks;

  ApprovalAuditRemarksModel(
      {this.auditDate, this.userName, this.type, this.auditRemarks});

  ApprovalAuditRemarksModel.fromJson(Map<String, dynamic> json) {
    auditDate = DateTime.parse(json['dt_AuditDate']);
    userName = json['nc_userchnname'];
    type = json['nc_type'];
    auditRemarks = json['nc_AuditRmk'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dt_AuditDate'] = this.auditDate;
    data['nc_userchnname'] = this.userName;
    data['nc_type'] = this.type;
    data['nc_AuditRmk'] = this.auditRemarks;
    return data;
  }
}
