class WeekPlanStatusModel {
  static List<Status> statusList = [];
  List<Status> status;

  WeekPlanStatusModel({this.status});

  WeekPlanStatusModel.fromJson(Map<String, dynamic> json) {
    if (json['Status'] != null) {
      status = new List<Status>();
      json['Status'].forEach((v) {
        status.add(new Status.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.status != null) {
      data['Status'] = this.status.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Status {
  int projStatus;
  String statusName;

  Status({this.projStatus, this.statusName});

  Status.fromJson(Map<String, dynamic> json) {
    projStatus = json['ProjStatus'];
    statusName = json['StatusName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ProjStatus'] = this.projStatus;
    data['StatusName'] = this.statusName;
    return data;
  }
}
