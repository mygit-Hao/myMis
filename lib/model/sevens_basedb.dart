import 'package:mis_app/model/user.dart';

class SevensBaseDBModel {
  static SevensBaseDBModel baseDBModel;
  static List<UserModel>userList=[];

  List<AreaGroup> areaGroupList;
  List<Dept> deptList;
  List<Spot> spotList;
  List<Template> templateList;
  List<TemplateKind> templateKindList;

  SevensBaseDBModel(
      {this.areaGroupList, this.deptList, this.spotList, this.templateList, this.templateKindList});

  SevensBaseDBModel.fromJson(Map<String, dynamic> json) {
    if (json['AreaGroup'] != null) {
      areaGroupList = new List<AreaGroup>();
      json['AreaGroup'].forEach((v) {
        areaGroupList.add(new AreaGroup.fromJson(v));
      });
    }
    if (json['Dept'] != null) {
      deptList = new List<Dept>();
      json['Dept'].forEach((v) {
        deptList.add(new Dept.fromJson(v));
      });
    }
    if (json['Spot'] != null) {
      spotList = new List<Spot>();
      json['Spot'].forEach((v) {
        spotList.add(new Spot.fromJson(v));
      });
    }
    if (json['Template'] != null) {
      templateList = new List<Template>();
      json['Template'].forEach((v) {
        templateList.add(new Template.fromJson(v));
      });
    }
    if (json['TemplateKind'] != null) {
      templateKindList = new List<TemplateKind>();
      json['TemplateKind'].forEach((v) {
        templateKindList.add(new TemplateKind.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.areaGroupList != null) {
      data['AreaGroup'] = this.areaGroupList.map((v) => v.toJson()).toList();
    }
    if (this.deptList != null) {
      data['Dept'] = this.deptList.map((v) => v.toJson()).toList();
    }
    if (this.spotList != null) {
      data['Spot'] = this.spotList.map((v) => v.toJson()).toList();
    }
    if (this.templateList != null) {
      data['Template'] = this.templateList.map((v) => v.toJson()).toList();
    }
    if (this.templateKindList != null) {
      data['TemplateKind'] = this.templateKindList.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AreaGroup {
  bool allDept;
  int areaGroupId;
  int areaId;
  String groupName;

  AreaGroup({this.allDept, this.areaGroupId, this.areaId, this.groupName});

  AreaGroup.fromJson(Map<String, dynamic> json) {
    allDept = json['AllDept'];
    areaGroupId = json['AreaGroupId'];
    areaId = json['AreaId'];
    groupName = json['GroupName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AllDept'] = this.allDept;
    data['AreaGroupId'] = this.areaGroupId;
    data['AreaId'] = this.areaId;
    data['GroupName'] = this.groupName;
    return data;
  }
}

class Dept {
  int areaGroupId;
  int areaId;
  int deptId;
  String deptName;
  String inCharge;

  Dept(
      {this.areaGroupId,
      this.areaId,
      this.deptId,
      this.deptName,
      this.inCharge});

  Dept.fromJson(Map<String, dynamic> json) {
    areaGroupId = json['AreaGroupId'];
    areaId = json['AreaId'];
    deptId = json['DeptId'];
    deptName = json['DeptName'];
    inCharge = json['InCharge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['AreaGroupId'] = this.areaGroupId;
    data['AreaId'] = this.areaId;
    data['DeptId'] = this.deptId;
    data['DeptName'] = this.deptName;
    data['InCharge'] = this.inCharge;
    return data;
  }
}

class Spot {
  int deptId;
  int spotId;
  String spotName;
  String remarks;

  Spot({this.deptId, this.spotId, this.spotName, this.remarks});

  Spot.fromJson(Map<String, dynamic> json) {
    deptId = json['DeptId'];
    spotId = json['SpotId'];
    spotName = json['SpotName'];
    remarks = json['Remarks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DeptId'] = this.deptId;
    data['SpotId'] = this.spotId;
    data['SpotName'] = this.spotName;
    data['Remarks'] = this.remarks;
    return data;
  }
}

class Template {
  int kindId;
  String templateCode;
  String templateName;

  Template({this.kindId, this.templateCode, this.templateName});

  Template.fromJson(Map<String, dynamic> json) {
    kindId = json['KindId'];
    templateCode = json['TemplateCode'];
    templateName = json['TemplateName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['KindId'] = this.kindId;
    data['TemplateCode'] = this.templateCode;
    data['TemplateName'] = this.templateName;
    return data;
  }
}

class TemplateKind {
  String code;
  int kindId;
  String kindName;

  TemplateKind({this.code, this.kindId, this.kindName});

  TemplateKind.fromJson(Map<String, dynamic> json) {
    code = json['Code'];
    kindId = json['KindId'];
    kindName = json['KindName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Code'] = this.code;
    data['KindId'] = this.kindId;
    data['KindName'] = this.kindName;
    return data;
  }
}
