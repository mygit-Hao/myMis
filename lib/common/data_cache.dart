import 'package:mis_app/model/approval.dart';
import 'package:mis_app/model/approval_head.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/item_category.dart';
import 'package:mis_app/model/salesman.dart';
import 'package:mis_app/model/sample_selection.dart';
import 'package:mis_app/model/staff_info.dart';
import 'package:mis_app/model/vehicle_request_base_db.dart';
import 'package:mis_app/service/approval_service.dart';
import 'package:mis_app/service/oa_service.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/utils.dart';

class DataCache {
  /// 审批列表缓存，用于审批主页面、操作页面上一单、下一单同步列序的顺序用
  /// 如果不使用缓存，可能在操作页面审批的顺序和主页面看到顺序不一致
  static List<ApprovalModel> _approvalCacheList = List();

  static List<SalesmanModel> _salesmanList;
  static List<ItemCategoryModel> _itemCategoryList;
  static List<CustModel> custList;
  static List<SampleSelectionModel> _sampleSelectionList;
  static List<RequestTypeModel> _requestTypeList;
  static List<VehicleModel> _vehicleList;
  static List<VehicleModel> _publicVehicleList;
  static List<VehicleModel> _privateVehicleList;
  static List<DriverModel> _driverList;
  static List<CarTypeModel> _carTypeList;
  static List<Currency> _currencyList;
  static List<StaffInfo> _userStaffList;
  // static List<NotificationCategory> _notificationCategoryList;
  static List<ApprovalHeadModel> _approvalHeadCacheList;

  static void clearCache() {
    clearCustList();
    clearSalesmanList();
    clearItemCategoryList();
    clearSampleSelectionList();
    clearRequestTypeList();
    clearVehicleList();
    clearDriverList();
    clearCarTypeList();
    clearGeneralBaseDb();
    clearApprovalHeadList();
  }

  /// 根据待审批列表的数据预加载各单据的头数据
  static void prepareApprovalHeadCache() async {
    List<ApprovalHeadModel> list = List();
    List<ApprovalHeadModel> expiryList = List();

    if ((_approvalCacheList != null) && (_approvalCacheList.length > 0)) {
      _approvalCacheList.forEach((element) {
        ApprovalHeadModel item =
            findApprovalHeadCache(element.docType, element.docId);
        // 如果不在缓存里，或已过期，加进列表
        if ((item == null) || (item.isExpired)) {
          if ((item != null) && (item.isExpired)) {
            expiryList.add(item);
          }

          ApprovalHeadModel newItem =
              ApprovalHeadModel(docType: element.docType, docId: element.docId);
          list.add(newItem);
        }
      });
    }

    if (list.length > 0) {
      List<ApprovalHeadModel> result = await ApprovalService.getHeads(list);
      // 因为更新缓存时，需要作比较，列表中数量越多，消耗时间越长，所以，提前清理无效缓存
      // 如果获取数据成功，且有过期的项目，先从缓存中移除
      if ((result.length > 0) && (expiryList.length > 0)) {
        expiryList.forEach((element) {
          _approvalHeadCacheList.remove(element);
        });
      }
      saveToApprovalHeadCache(result);
    }
  }

  /// 移除ApprovalHead的缓存
  static void removeApprovalHeadCache(String docType, String docId) {
    ApprovalHeadModel item = findApprovalHeadCache(docType, docId);
    if (item != null) {
      _approvalHeadCacheList.remove(item);
    }
  }

  static ApprovalHeadModel findApprovalHeadCache(String docType, String docId) {
    ApprovalHeadModel item;
    if (_approvalHeadCacheList != null) {
      item = _approvalHeadCacheList.firstWhere(
          (item) =>
              Utils.sameText(docType, item.docType) &&
              Utils.sameText(docId, item.docId),
          orElse: () => null);
    }

    return item;
  }

  static void saveToApprovalHeadCache(List<ApprovalHeadModel> list) {
    if ((list == null) || (list.length <= 0)) return;

    if ((_approvalHeadCacheList != null) &&
        (_approvalHeadCacheList.length > 0)) {
      // 先把重复的缓存删除
      list.forEach((ApprovalHeadModel element) {
        ApprovalHeadModel result =
            findApprovalHeadCache(element.docType, element.docId);

        if (result != null) {
          _approvalHeadCacheList.remove(result);
        }
      });
    } else {
      _approvalHeadCacheList = [];
    }

    _approvalHeadCacheList.addAll(list);
  }

  static void updateApprovalHeadCache(ApprovalHeadModel head) {
    ApprovalHeadModel result = findApprovalHeadCache(head.docType, head.docId);

    if (result != null) {
      _approvalHeadCacheList.remove(result);
    }
    if (_approvalHeadCacheList == null) {
      _approvalHeadCacheList = [];
    }
    _approvalHeadCacheList.add(head);
  }

  static void clearApprovalHeadList() {
    _approvalHeadCacheList = null;
  }

  static void clearRequestTypeList() {
    _requestTypeList = null;
  }

  static void clearVehicleList() {
    _vehicleList = null;
  }

  static void clearDriverList() {
    _driverList = null;
  }

  static void clearCarTypeList() {
    _carTypeList = null;
  }

  static void clearCustList() {
    custList = null;
  }

  static void clearGeneralBaseDb() {
    _currencyList = null;
    _userStaffList = null;
    // _notificationCategoryList = null;
  }

  static CarTypeModel findCarType(String carType) {
    if (carType != null) {
      return _carTypeList.firstWhere(
          (element) => Utils.sameText(element.carType, carType.trim()),
          orElse: () => null);
    }

    return null;
  }

  static Future<void> initGeneralBaseDb() async {
    if ((_currencyList == null) || (_userStaffList == null)
        // ||(_notificationCategoryList == null)
        ) {
      BaseDbModel result = await UserService.getBaseDb();

      if (result != null) {
        _currencyList = result.currencyList;
        _userStaffList = result.userStaffList;
        // _notificationCategoryList = result.notificationCategoryList;
      }
    }
  }

  static Future<void> initVehicleRequestBaseDb() async {
    if ((_requestTypeList == null) ||
        (_vehicleList == null) ||
        (_driverList == null) ||
        (_carTypeList == null)) {
      _publicVehicleList = [];
      _privateVehicleList = [];

      VehicleRequestBaseDbWrapper result =
          await OaService.getVehicleRequestBaseDb();

      if (result != null) {
        _requestTypeList = result.requestTypeList;
        _vehicleList = result.vehicleList;
        _driverList = result.driverList;
        _carTypeList = result.carTypeList;

        for (VehicleModel item in _vehicleList) {
          switch (item.vehicleType) {
            case VehicleModel.vehicleTypePublic:
              _publicVehicleList.add(item);

              break;
            case VehicleModel.vehicleTypePrivate:
              _privateVehicleList.add(item);
              break;
          }
        }
      }
    }
  }

  static List<VehicleModel> getVehicleList(int vehicleType) {
    if (vehicleType == VehicleModel.vehicleTypePrivate) {
      return _privateVehicleList;
    }

    return _publicVehicleList;
  }

  static List<RequestTypeModel> get requestTypeList {
    return _requestTypeList;
  }

  static List<VehicleModel> get vehicleList {
    return _vehicleList;
  }

  static List<DriverModel> get driverList {
    return _driverList;
  }

  static List<CarTypeModel> get carTypeList {
    return _carTypeList;
  }

  static List<SampleSelectionModel> get sampleSelectionList {
    return _sampleSelectionList;
  }

  static Future<void> initSampleSelectionList() async {
    if (_sampleSelectionList == null) {
      _sampleSelectionList = await SalesService.getSampleSelectionList();
    }
  }

  static Future<List<ItemCategoryModel>> getItemCategoryList() async {
    if (_itemCategoryList == null) {
      _itemCategoryList = await SalesService.getItemCategory();
    }

    return _itemCategoryList;
  }

  static void clearItemCategoryList() {
    _itemCategoryList = null;
  }

  static void clearSampleSelectionList() {
    _sampleSelectionList = null;
  }

  static Future<List<SalesmanModel>> getSalesmanList() async {
    if (_salesmanList == null) {
      _salesmanList = await SalesService.getSalesmanList();
    }

    return _salesmanList;
  }

  static void clearSalesmanList() {
    _salesmanList = null;
  }

  static void clearApprovalCacheList() {
    if (_approvalCacheList == null) {
      _approvalCacheList = List();
    }

    _approvalCacheList.clear();

    clearApprovalHeadList();
  }

  static void setApprovalCacheList(List<ApprovalModel> list) {
    clearApprovalCacheList();

    for (ApprovalModel item in list) {
      ApprovalModel newItem = item.copy();
      _approvalCacheList.add(newItem);
    }
  }

  static bool get hasMultiApprovalCache {
    return (_approvalCacheList != null) && (_approvalCacheList.length > 1);
  }

  static ApprovalModel getNextApprovalItem(String docType, String docId) {
    ApprovalModel item;

    for (var i = 0; i < _approvalCacheList.length; i++) {
      ApprovalModel currentItem = _approvalCacheList[i];
      if (Utils.sameText(docType, currentItem.docType) &&
          Utils.sameText(docId, currentItem.docId)) {
        if (i < (_approvalCacheList.length - 1)) {
          return _approvalCacheList[i + 1];
        }
      }
    }

    return item;
  }

  static ApprovalModel getPreviousApprovalItem(String docType, String docId) {
    ApprovalModel item;

    int size = _approvalCacheList.length;

    for (int i = 0; i < size; i++) {
      ApprovalModel currentItem = _approvalCacheList[i];
      if (Utils.sameText(docType, currentItem.docType) &&
          Utils.sameText(docId, currentItem.docId)) {
        if (i > 0) {
          return _approvalCacheList[i - 1];
        }
      }
    }

    if (size > 0) {
      item = _approvalCacheList[size - 1];
    }

    return item;
  }
}
