class SevensDeptDeductModel {
  List<DetailSpot> detailSpot;

  SevensDeptDeductModel({this.detailSpot});

  SevensDeptDeductModel.fromJson(Map<String, dynamic> json) {
    if (json['DetailSpot'] != null) {
      detailSpot = new List<DetailSpot>();
      json['DetailSpot'].forEach((v) {
        detailSpot.add(new DetailSpot.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.detailSpot != null) {
      data['DetailSpot'] = this.detailSpot.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DetailSpot {
  int detailSpotId;
  int deptId;
  int spotId;
  String deptName;
  String spotName;
  String spotRemarks;
  String remarks;
  double deduct;
  DateTime rectifyDate;
  // Null inCharge;
  int photoFileId;

  DetailSpot(
      {this.detailSpotId,
      this.deptId,
      this.spotId,
      this.deptName,
      this.spotName,
      this.spotRemarks,
      this.remarks,
      this.deduct,
      this.rectifyDate,
      // this.inCharge,
      this.photoFileId});

  DetailSpot.fromJson(Map<String, dynamic> json) {
    detailSpotId = json['DetailSpotId'];
    deptId = json['DeptId'];
    spotId = json['SpotId'];
    deptName = json['DeptName'];
    spotName = json['SpotName'];
    spotRemarks = json['SpotRemarks'];
    remarks = json['Remarks'];
    deduct = json['Deduct'];
    rectifyDate = DateTime.parse(json['RectifyDate']);
    // inCharge = json['InCharge'];
    photoFileId = json['PhotoFileId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DetailSpotId'] = this.detailSpotId;
    data['DeptId'] = this.deptId;
    data['SpotId'] = this.spotId;
    data['DeptName'] = this.deptName;
    data['SpotName'] = this.spotName;
    data['SpotRemarks'] = this.spotRemarks;
    data['Remarks'] = this.remarks;
    data['Deduct'] = this.deduct;
    data['RectifyDate'] = this.rectifyDate.toString();
    // data['InCharge'] = this.inCharge;
    data['PhotoFileId'] = this.photoFileId;
    return data;
  }
}
