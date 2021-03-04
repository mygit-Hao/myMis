import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/model/staff_info.dart';

class LoginInfo {
  bool success;
  String info;
  String userId;
  int oaAreaId;
  String userName;
  String userDStaffId;
  String userDStaffName;
  bool canViewAreaCust;
  List<MobileFunction> mobileFunctions;
  List<Area> areaList;
  List<Area> oaAreaList;
  List<StaffInfo> staffInfo;
  int loginedAreaId;
  bool canNewSalesOrder;
  bool canNewSampleDelivery;
  bool needSignature;
  String signatureDate;
  int orderSelectMethod;
  int layoutResourceKind;
  String tempToken;

  LoginInfo(
      {this.success = false,
      this.info = '',
      this.userId = '',
      this.oaAreaId = 0,
      this.userName = '',
      this.userDStaffId = '',
      this.userDStaffName = '',
      this.canViewAreaCust,
      this.mobileFunctions,
      this.areaList,
      this.oaAreaList,
      this.staffInfo,
      this.loginedAreaId,
      this.canNewSalesOrder,
      this.canNewSampleDelivery,
      this.needSignature,
      this.signatureDate,
      this.orderSelectMethod,
      this.layoutResourceKind = 0,
      this.tempToken});

  LoginInfo.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    info = json['Info'];
    userId = json['UserId'] ?? '';
    userId = userId.trim();
    oaAreaId = json['OaAreaId'];
    userName = json['UserName'];
    userDStaffId = json['UserDStaffId'];
    userDStaffName = json['UserDStaffName'];
    canViewAreaCust = json['CanViewAreaCust'];
    if (json['MobileFunctions'] != null) {
      mobileFunctions = new List<MobileFunction>();
      json['MobileFunctions'].forEach((v) {
        mobileFunctions.add(new MobileFunction.fromJson(v));
      });
    }
    if (json['Area'] != null) {
      areaList = new List<Area>();
      json['Area'].forEach((v) {
        areaList.add(new Area.fromJson(v));
      });
    }
    if (json['OaArea'] != null) {
      oaAreaList = new List<Area>();
      json['OaArea'].forEach((v) {
        oaAreaList.add(new Area.fromJson(v));
      });
    }
    if (json['StaffInfo'] != null) {
      staffInfo = new List<StaffInfo>();
      json['StaffInfo'].forEach((v) {
        staffInfo.add(new StaffInfo.fromJson(v));
      });
    }
    loginedAreaId = json['LoginedAreaId'];
    canNewSalesOrder = json['CanNewSalesOrder'];
    canNewSampleDelivery = json['CanNewSampleDelivery'];
    needSignature = json['NeedSignature'];
    signatureDate = json['SignatureDate'];
    orderSelectMethod = json['OrderSelectMethod'];
    layoutResourceKind = json['LayoutResourceKind'] ?? 0;
    tempToken = json['TempToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Success'] = this.success;
    data['Info'] = this.info;
    data['UserId'] = this.userId;
    data['OaAreaId'] = this.oaAreaId;
    data['UserName'] = this.userName;
    data['UserDStaffId'] = this.userDStaffId;
    data['UserDStaffName'] = this.userDStaffName;
    data['CanViewAreaCust'] = this.canViewAreaCust;
    if (this.mobileFunctions != null) {
      data['MobileFunctions'] =
          this.mobileFunctions.map((v) => v.toJson()).toList();
    }
    if (this.areaList != null) {
      data['Area'] = this.areaList.map((v) => v.toJson()).toList();
    }
    if (this.oaAreaList != null) {
      data['OaArea'] = this.oaAreaList.map((v) => v.toJson()).toList();
    }
    if (this.staffInfo != null) {
      data['StaffInfo'] = this.staffInfo.map((v) => v.toJson()).toList();
    }
    data['LoginedAreaId'] = this.loginedAreaId;
    data['CanNewSalesOrder'] = this.canNewSalesOrder;
    data['CanNewSampleDelivery'] = this.canNewSampleDelivery;
    data['NeedSignature'] = this.needSignature;
    data['SignatureDate'] = this.signatureDate;
    data['OrderSelectMethod'] = this.orderSelectMethod;
    data['LayoutResourceKind'] = this.layoutResourceKind;
    data['TempToken'] = this.tempToken;
    return data;
  }
}
