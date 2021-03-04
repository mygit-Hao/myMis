import 'package:mis_app/model/staff_info.dart';
import 'area.dart';

class BaseDbModel {
  static BaseDbModel baseDbModel;
  List<Area> areaList;
  List<Currency> currencyList;
  List<StaffInfo> userStaffList;
  // List<NotificationCategory> notificationCategoryList;

  BaseDbModel({this.areaList, this.currencyList, this.userStaffList});

  BaseDbModel.fromJson(Map<String, dynamic> json) {
    if (json['Area'] != null) {
      areaList = new List<Area>();
      json['Area'].forEach((v) {
        areaList.add(new Area.fromJson(v));
      });
    }
    if (json['Currency'] != null) {
      currencyList = new List<Currency>();
      json['Currency'].forEach((v) {
        currencyList.add(new Currency.fromJson(v));
      });
    }
    if (json['UserStaff'] != null) {
      userStaffList = new List<StaffInfo>();
      json['UserStaff'].forEach((v) {
        userStaffList.add(new StaffInfo.fromJson(v));
      });
    }
    /*
    if (json['NotificationCategory'] != null) {
      notificationCategoryList = new List<NotificationCategory>();
      json['NotificationCategory'].forEach((v) {
        notificationCategoryList.add(new NotificationCategory.fromJson(v));
      });
    }
    */
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.areaList != null) {
      data['Area'] = this.areaList.map((v) => v.toJson()).toList();
    }
    if (this.currencyList != null) {
      data['Currency'] = this.currencyList.map((v) => v.toJson()).toList();
    }
    if (this.userStaffList != null) {
      data['UserStaff'] = this.userStaffList.map((v) => v.toJson()).toList();
    }
    /*
    if (this.notificationCategoryList != null) {
      data['NotificationCategory'] =
          this.notificationCategoryList.map((v) => v.toJson()).toList();
    }
    */
    return data;
  }
}

class Currency {
  String currencyCode;
  String currencyName;
  bool isDefault;

  Currency({this.currencyCode, this.currencyName, this.isDefault});

  Currency.fromJson(Map<String, dynamic> json) {
    currencyCode = json['CurrencyCode'];
    currencyName = json['CurrencyName'];
    isDefault = json['IsDefault'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CurrencyCode'] = this.currencyCode;
    data['CurrencyName'] = this.currencyName;
    data['IsDefault'] = this.isDefault;
    return data;
  }
}

// class UserStaff {
//   bool canViewAllAttendance;
//   String deptName;
//   String posi;
//   String staffCode;
//   int staffId;
//   String staffName;
//   bool userIsPurchaser;
//   int iDefaultAreaId;
//   int iDeptId;

//   UserStaff(
//       {this.canViewAllAttendance,
//       this.deptName,
//       this.posi,
//       this.staffCode,
//       this.staffId,
//       this.staffName,
//       this.userIsPurchaser,
//       this.iDefaultAreaId,
//       this.iDeptId});

//   UserStaff.fromJson(Map<String, dynamic> json) {
//     canViewAllAttendance = json['CanViewAllAttendance'];
//     deptName = json['DeptName'];
//     posi = json['Posi'];
//     staffCode = json['StaffCode'];
//     staffId = json['StaffId'];
//     staffName = json['StaffName'];
//     userIsPurchaser = json['UserIsPurchaser'];
//     iDefaultAreaId = json['i_DefaultAreaId'];
//     iDeptId = json['i_DeptId'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['CanViewAllAttendance'] = this.canViewAllAttendance;
//     data['DeptName'] = this.deptName;
//     data['Posi'] = this.posi;
//     data['StaffCode'] = this.staffCode;
//     data['StaffId'] = this.staffId;
//     data['StaffName'] = this.staffName;
//     data['UserIsPurchaser'] = this.userIsPurchaser;
//     data['i_DefaultAreaId'] = this.iDefaultAreaId;
//     data['i_DeptId'] = this.iDeptId;
//     return data;
//   }
// }
