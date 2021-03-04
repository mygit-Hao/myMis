class EntranceModel {
  bool hasData;
  List<Entry> entryList;
  List<MaterialData> materialList;

  EntranceModel({this.hasData, this.entryList, this.materialList});

  EntranceModel.fromJson(Map<String, dynamic> json) {
    hasData = json['HasData'];
    if (json['Entry'] != null) {
      entryList = new List<Entry>();
      json['Entry'].forEach((v) {
        entryList.add(new Entry.fromJson(v));
      });
    }
    if (json['Material'] != null) {
      materialList = new List<MaterialData>();
      json['Material'].forEach((v) {
        materialList.add(new MaterialData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['HasData'] = this.hasData;
    if (this.entryList != null) {
      data['Entry'] = this.entryList.map((v) => v.toJson()).toList();
    }
    if (this.materialList != null) {
      data['Material'] = this.materialList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entry {
  String id;
  String visitorName;
  String visitorComp;
  String reason;
  String contactPerson;
  String contactTel;
  String inDate;
  String visitorMaterial;

  Entry(
      {this.id,
      this.visitorName,
      this.visitorComp,
      this.reason,
      this.contactPerson,
      this.contactTel,
      this.inDate,
      this.visitorMaterial});

  Entry.fromJson(Map<String, dynamic> json) {
    id = json['Id'];
    visitorName = json['VisitorName'];
    visitorComp = json['VisitorComp'];
    reason = json['Reason'];
    contactPerson = json['ContactPerson'];
    contactTel = json['ContactTel'];
    inDate = json['InDate'];
    visitorMaterial = json['VisitorMaterial'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Id'] = this.id;
    data['VisitorName'] = this.visitorName;
    data['VisitorComp'] = this.visitorComp;
    data['Reason'] = this.reason;
    data['ContactPerson'] = this.contactPerson;
    data['ContactTel'] = this.contactTel;
    data['InDate'] = this.inDate;
    data['VisitorMaterial'] = this.visitorMaterial;
    return data;
  }
}

class MaterialData {
  String material;

  MaterialData({this.material});

  MaterialData.fromJson(Map<String, dynamic> json) {
    material = json['Material'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Material'] = this.material;
    return data;
  }
}
