import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/model/businessClockRecords.dart';
import 'package:mis_app/model/businessPlan_data.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/pages/common/login_page.dart';
import 'package:mis_app/pages/common/view_pdf_page.dart';
import 'package:mis_app/pages/common/view_photo_page.dart';
import 'package:mis_app/pages/life/meal_booking_page.dart';
import 'package:mis_app/pages/life/meal_booking_tips_page.dart';
import 'package:mis_app/pages/mine/user_info_page.dart';
import 'package:mis_app/pages/notification/notification_detail_page.dart';
import 'package:mis_app/pages/notification/notification_list_page.dart';
import 'package:mis_app/pages/notification/notification_page.dart';
import 'package:mis_app/pages/office/askForLeave/askForLeave.dart';
import 'package:mis_app/pages/office/askForLeave/askForLeave_detail.dart';
import 'package:mis_app/pages/office/askForLeave/overtime_select.dart';
import 'package:mis_app/pages/office/boiler_feeding/boilder_feeding_add.dart';
import 'package:mis_app/pages/office/boiler_feeding/boiler_feeding.dart';
import 'package:mis_app/pages/office/borrow/borrow.dart';
import 'package:mis_app/pages/office/borrow/borrow_detail.dart';
import 'package:mis_app/pages/office/bottom_material_login/bottom_material_login.dart';
import 'package:mis_app/pages/office/buCard/buCard_edit_page.dart';
import 'package:mis_app/pages/office/buCard/buCard_query_page.dart';
import 'package:mis_app/pages/office/business/business_cards_page.dart';
import 'package:mis_app/pages/office/business/business_edit_page.dart';
import 'package:mis_app/pages/office/business/business_plan_page.dart';
import 'package:mis_app/pages/office/business/business_query_page.dart';
import 'package:mis_app/pages/office/businessPlan/businessPlan.dart';
import 'package:mis_app/pages/office/businessPlan/businessPlan_add.dart';
import 'package:mis_app/pages/office/businessPlan/businessPlan_data.dart';
import 'package:mis_app/pages/office/businessPlan/businessPlan_detail.dart';
import 'package:mis_app/pages/office/device_data.dart';
import 'package:mis_app/pages/office/entrance_page.dart';
import 'package:mis_app/pages/office/receive/receive_edit_page.dart';
import 'package:mis_app/pages/office/receive/receive_query_page.dart';
import 'package:mis_app/pages/office/receive/receive_room_page.dart';
import 'package:mis_app/pages/office/releasePass/release_edit_page.dart';
import 'package:mis_app/pages/office/releasePass/release_query_page.dart';
import 'package:mis_app/pages/office/releasepass_cam.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_detail_list_page.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_detail_page.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_group_page.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_page.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_template_select.dart';
import 'package:mis_app/pages/office/staff/staff_edit_page.dart';
import 'package:mis_app/pages/office/staff/staff_query_page.dart';
import 'package:mis_app/pages/office/vehicle_request/vehicle_request_detail_page.dart';
import 'package:mis_app/pages/office/vehicle_request/vehicle_request_page.dart';
import 'package:mis_app/pages/office/vehicle_request/vehicle_user_request_detail_page.dart';
import 'package:mis_app/pages/office/vehicle_request/vehicle_user_request_page.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_detail.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_progress_detail.dart';
import 'package:mis_app/pages/office/work_clock/customer_add.dart';
import 'package:mis_app/pages/office/work_clock/customer_select.dart';
import 'package:mis_app/pages/office/work_clock/history_clock_detail.dart';
import 'package:mis_app/pages/office/work_clock/history_clock_list.dart';
import 'package:mis_app/pages/office/work_clock/out_of_range_clock.dart';
import 'package:mis_app/pages/office/work_clock/report_edit.dart';
import 'package:mis_app/pages/office/work_clock/visit_customer.dart';
import 'package:mis_app/pages/office/work_clock/work_clock.dart';
import 'package:mis_app/pages/office/work_overtime/work_overtime.dart';
import 'package:mis_app/pages/office/work_overtime/work_overtime_add.dart';
import 'package:mis_app/pages/office/work_overtime/work_overtime_detail.dart';
import 'package:mis_app/pages/sales/arrearage_detail_page.dart';
import 'package:mis_app/pages/sales/arrearage_page.dart';
import 'package:mis_app/pages/sales/bill_detail_page.dart';
import 'package:mis_app/pages/sales/cust_page.dart';
import 'package:mis_app/pages/sales/cust_detail_page.dart';
import 'package:mis_app/pages/sales/cust_statement_page.dart';
import 'package:mis_app/pages/sales/cust_unlock_page.dart';
import 'package:mis_app/pages/sales/sales_cart_page.dart';
import 'package:mis_app/pages/sales/sales_order_page.dart';
import 'package:mis_app/pages/sales/sales_page.dart';
import 'package:mis_app/pages/sales/sales_summary_detail_page.dart';
import 'package:mis_app/pages/sales/sales_summary_page.dart';
import 'package:mis_app/pages/sales/sales_bonus_query_page.dart';
import 'package:mis_app/pages/sales/sample_delivery/sample_delivery_detail_item_page.dart';
import 'package:mis_app/pages/sales/sample_delivery/sample_delivery_detail_page.dart';
import 'package:mis_app/pages/sales/sample_delivery/sample_delivery_detail_reply.dart';
import 'package:mis_app/pages/sales/sample_delivery/sample_delivery_handle_page.dart';
import 'package:mis_app/pages/sales/sample_delivery/sample_delivery_log_page.dart';
import 'package:mis_app/pages/sales/sample_delivery/sample_delivery_page.dart';
import 'package:mis_app/pages/sales/search_inventory_page.dart';
import 'package:mis_app/pages/sales/search_price_page.dart';
import 'package:mis_app/pages/index_page.dart';
import 'package:mis_app/pages/mine/change_password_page.dart';
import 'package:mis_app/pages/office/approval/approval_attachment_page.dart';
import 'package:mis_app/pages/office/approval/approval_handle_page.dart';
import 'package:mis_app/pages/office/approval/approval_page.dart';
import 'package:mis_app/pages/office/attendance_page.dart';
import 'package:mis_app/pages/sales/select_invoice_page.dart';
import 'package:mis_app/pages/mine/security_page.dart';
import 'package:mis_app/pages/signature/signature_add_page.dart';
import 'package:mis_app/pages/signature/signature_page.dart';

const String rootPath = '/';
const String changePasswordPath = '/change_password';
const String loginPath = '/login';
const String signaturePath = '/signature';
const String signatureAddPath = '/signature_add';
const String securityPath = '/security';
const String userInfoPath = '/user_info';
// const String loginSettingPage = '/login_setting';

const String attendancePath = '/office/attendance';
const String approvalPath = '/office/approval';
const String approvalHandlePath = '/office/approval_handle';
const String approvalAttachmentPath = '/office/approval_attachment';
const String viewPhotoPath = '/common/view_photo';
const String viewPdfPath = '/common/view_pdf';
const String videoPlayerPath = '/common/video_play';
const String audioPlayerPath = '/common/audio_play';
const String fileViewPath = '/common/file_view';

const String salesPath = '/sales';
const String custPath = '/sales/cust';
const String custDetailPath = '/sales/cust_detail';
const String salesCartPath = '/sales/cart';
const String searchPricePath = '/sales/search_price';
const String custUnlockPath = '/sales/cust_unlock';
const String searchInventoryPath = '/sales/search_inventory';
const String salesOrderPath = '/sales/sales_order';
const String billDetailPath = '/sales/bill_detail';
const String salesSummaryPath = '/sales/sales_summary';
const String salesSummaryDetailPath = '/sales/sales_summary_detail';
const String salesBonusQueryPath = '/sales/sales_bonus_query';
const String arrearagePath = '/sales/arrearage';
const String arrearageDetailPath = '/sales/arrearage_detail';
const String selectInvoicePath = '/sales/select_invoice';
const String sampleDeliveryPath = '/sales/sample_delivery';
const String sampleDeliveryDetailPath = '/sales/sample_delivery_detail';
const String sampleDeliveryDetailItemPath =
    '/sales/sample_delivery_detail_item';
const String sampleDeliveryHandlePath = '/sales/sample_delivery_handle';
const String sampleDeliveryDetailReplyPath =
    '/sales/sample_delivery_detail_reply';
const String sampleDeliveryLogPath = '/sales/sample_delivery_log';
const String custStatementPath = '/sales/cust_statement';

//报餐
const String mealBookingPath = '/life/meal_booking';
const String mealBookingTipsPath = '/life/meal_booking_tips';

//车辆调度
const String vehicleRequestPath = '/office/vehicle_request';
const String vehicleRequestDetailPath = '/office/vehicle_request_detail';
const String vehicleUserRequestPath = '/office/vehicle_user_request';
const String vehicleUserRequestDetailPath =
    '/office/vehicle_user_request_detail';

//消息
const String notificationPath = '/office/notification';
const String notificationListPath = '/office/notification_list';
const String notificationDetailPath = '/office/notification_detail';

//7S
const String sevensPath = '/office/sevens';
const String sevensGroupPath = 'office/sevens_group';
const String sevensDetaiListlPath = 'office/sevens_detail_list';
const String sevensDetailPath = 'office/sevens_detail';
const String sevensTempletePath = 'office/sevens_templete_select';
//接洽
const String entrancePath = 'office/entrance';
//打卡
const String workClockPath = '/office/work_clock';
const String visitCustomerPath = '/office/visit_customer';
const String customerSelectPath = '/office/customer_select';
const String customerAddPath = '/office/customer_add';
const String outOfRangeClockPath = '/office/out_of_range_clock';
const String historyClockListPath = '/office/history_clock';
const String historyClockDetailPath = '/office/history_clock_detail';
const String reportEditPath = '/office/report_edit';
//加班
const String overTimePath = '/office/work_overtime';
const String workOverTimeDetailPath = '/office/work_overtime_detai';
const String workOverTimeAddPath = '/office/work_overtime_add';
//出差
const String businessPath = '/office/business';
const String businessEditPath = '/office/businessEdit';
const String businessCardPath = '/office/businessCard';
const String businessPlanPath = '/office/businessPlan';
//请假
const String askForLeavePath = '/office/askForLeave';
const String askForLeaveDetailPath = '/office/askForLeave_detail';
const String overTimeSelectPath = '/office/overTime_select';
const String askForLeaveAttanchementPath = '/office/askForLeave_attanchement';

const String releasePassPath = '/office/releasePass';
const String releasePassEditPath = '/office/releasePassEdit';
//锅炉投料
const String boilerFeedingPath = '/office/boider_feeding';
const String boilerFeedingAddPath = '/office/boider_feeding_add';
const String bottomMaterialLoginPath = '/office/bottom_material_login';

const String buCardPath = '/office/buCard';
const String buCardEditPath = '/office/buCardEdit';
//借款
const String borrowPath = '/office/borrow';
const String borrowDetailPath = '/office/borrowDetai';
//出差计划
const String businessPlanListPath = '/office/businessListPlan';
const String businessPlanDataPath = '/office/businessPlanData';
const String businessPlanDetailPath = '/office/businessPlanDetail';
const String businessPlanAddPath = '/office/businessPlanAdd';

const String receivePath = '/office/receive';
const String receiveEditPath = '/office/receiveEdit';
const String receiveRoomPath = '/office/receiveRoom';
//放行拍照
const String releasePassCamPath = 'office/releasePassCam';
//设备元素数据
const String equipmentPath = 'office/device_data';
//周工作计划
const String weekPlanPath = 'office/week_plan';
const String weekPlanDetailPath = 'office/week_plan_detail';
const String weekPlanProgressPath = 'office/week_plan_progress';
//人事资料
const String staffPath = 'office/staff';
const String staffEditPath = 'office/staffEdit';

Map<String, bool> _pageDataChanged = Map();
Map<String, Object> _pages = Map();

Future<bool> navigatePage(BuildContext context, String routeName,
    {Object arguments}) async {
  setPageDataChangedByRoute(routeName, false);
  await Navigator.pushNamed(context, routeName, arguments: arguments);

  bool changed = _pageDataChanged[routeName] ?? false;

  return changed;
}

void navigateTo(BuildContext context, String routeName, {Object arguments}) {
  if (Global.hasRightForRoute(routeName)) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }
}

void setPageDataChangedByRoute(String routeName, bool value) {
  if (routeName != null) {
    _pageDataChanged[routeName] = value;
  }
}

void setPageDataChanged(Object page, bool value) {
  String routeName;

  for (String key in _pages.keys) {
    if (_pages[key] == page) {
      routeName = key;
      break;
    }
  }

  setPageDataChangedByRoute(routeName, value);
}

//配置路由
final routes = {
  rootPath: (context) => IndexPage(),
  changePasswordPath: (context) => ChangePasswordPage(),
  loginPath: (context, {Map arguments}) => LoginPage(arguments: arguments),
  signaturePath: (context) => SignaturePage(),
  signatureAddPath: (context) => SignatureAddPage(),
  securityPath: (context) => SecurityPage(),
  userInfoPath: (context) => UserInfoPage(),
  attendancePath: (context) => AttendancePage(),
  approvalPath: (context) => ApprovalPage(),
  approvalHandlePath: (context, {Map arguments}) =>
      ApprovalHandlePage(arguments: arguments),
  approvalAttachmentPath: (context, {Map arguments}) =>
      ApprovalAttachmentPage(arguments: arguments),
  viewPhotoPath: (context, {Map arguments}) =>
      ViewPhotoPage(arguments: arguments),
  viewPdfPath: (context, {Map arguments}) => ViewPdfPage(arguments: arguments),
  salesPath: (context) => SalesPage(),
  custPath: (context, {Map arguments}) => CustPage(arguments: arguments),
  custDetailPath: (context, {Map arguments}) =>
      CustDetailPage(arguments: arguments),
  salesCartPath: (context, {Map arguments}) =>
      SalesCartPage(arguments: arguments),
  searchPricePath: (context, {Map arguments}) =>
      SearchPricePage(arguments: arguments),
  custUnlockPath: (context, {Map arguments}) =>
      CustUnlockPgae(arguments: arguments),

  //7S检查
  sevensPath: (context) => SevenSMainPage(),
  sevensGroupPath: (context, {Map arguments}) =>
      SevenSGroupPage(arguments: arguments),
  sevensDetaiListlPath: (context, {Map arguments}) =>
      SevenSDtlListPage(arguments: arguments),
  sevensDetailPath: (context, {Map arguments}) =>
      SevenSDetailPage(arguments: arguments),
  sevensTempletePath: (context) => SevensTempletePage(),
  //接洽确认
  entrancePath: (context) => EntrancePage(),

  searchInventoryPath: (context) => SearchInventoryPage(),
  salesOrderPath: (context, {Map arguments}) =>
      SalesOrderPage(arguments: arguments),
  custStatementPath: (context, {Map arguments}) =>
      CustStatementPage(arguments: arguments),

  //打卡
  workClockPath: (context) => WorkOclockPage(),
  visitCustomerPath: (context) => VisitCustomerPage(),
  customerSelectPath: (context) => CustomerSelectPage(),
  customerAddPath: (context) => CustomerPageAdd(),
  outOfRangeClockPath: (context) => OutOfRangeClockPage(),
  historyClockListPath: (context) => HistoryClockListPage(),
  historyClockDetailPath: (context) => HistoryClockDetailPage(),
  reportEditPath: (context, {Map arguments}) =>
      ReportEditPage(arguments: arguments),

  billDetailPath: (context, {Map arguments}) =>
      BillDetailPage(arguments: arguments),
  salesSummaryPath: (context) => SalesSummaryPage(),
  salesSummaryDetailPath: (context, {Map arguments}) =>
      SalesSummaryDetailPage(arguments: arguments),
  salesBonusQueryPath: (context) => SalesBonusQueryPage(),
  arrearagePath: (context, {Map arguments}) =>
      ArrearagePage(arguments: arguments),
  arrearageDetailPath: (context, {Map arguments}) =>
      ArrearageDetailPage(arguments: arguments),
  selectInvoicePath: (context, {Map arguments}) =>
      SelectInvoicePage(arguments: arguments),

  //送样申请
  sampleDeliveryPath: (context) => SampleDeliveryPage(),
  sampleDeliveryDetailPath: (context, {Map arguments}) =>
      SampleDeliveryDetailPage(arguments: arguments),
  sampleDeliveryDetailItemPath: (context, {Map arguments}) =>
      SampleDeliveryDetailItemPage(arguments: arguments),
  sampleDeliveryHandlePath: (context, {Map arguments}) =>
      SampleDeliveryHandlePage(arguments: arguments),
  sampleDeliveryDetailReplyPath: (context, {Map arguments}) =>
      SampleDeliveryDetailReplyPage(arguments: arguments),
  sampleDeliveryLogPath: (context, {Map arguments}) =>
      SampleDeliveryLogPage(arguments: arguments),

  //报餐
  mealBookingPath: (context) => MealBookingPage(),
  mealBookingTipsPath: (context) => MealBookingTipsPage(),

  //车辆调度
  vehicleRequestPath: (context, {Map arguments}) =>
      VehicleRequestPage(arguments: arguments),
  vehicleRequestDetailPath: (context, {Map arguments}) =>
      VehicleRequestDetailPage(arguments: arguments),
  vehicleUserRequestPath: (context) => VehicleUserRequestPage(),
  vehicleUserRequestDetailPath: (context, {Map arguments}) =>
      VehicleUserRequestDetailPage(arguments: arguments),

  //消息
  notificationPath: (context) => NotificationPage(),
  notificationListPath: (context, {Map arguments}) =>
      NotificationListPage(arguments: arguments),
  notificationDetailPath: (context, {Map arguments}) =>
      NotificationDetailPage(arguments: arguments),

  //加班单
  overTimePath: (context) => WorkOverTimePage(),
  workOverTimeDetailPath: (context, {Map arguments}) =>
      WorkOverTimeDetailPage(arguments: arguments),
  workOverTimeAddPath: (context) => WorkOverTimeAddPage(),

  //出差计划
  businessPlanListPath: (context) => BusinessPlanListPage(),
  businessPlanDataPath: (context, {int arguments}) =>
      BusinessPlanDataPage(businessId: arguments),
  businessPlanDetailPath: (context, {int arguments}) =>
      BusinessPlanDetailPage(empPlanId: arguments),
  businessPlanAddPath: (context, {BusinessPlanLine arguments}) =>
      BusinessPlanAddPage(item: arguments),

  //出差报告
  businessPath: (context) => BusinessQueryPage(),
  businessEditPath: (context, {Map arguments}) =>
      BusinessEditPage(arguments: arguments),
  businessCardPath: (context, {List<ClockRecords> arguments}) =>
      BusinessCardPage(arguments: arguments),
  businessPlanPath: (context, {Map arguments}) =>
      BusinessPlanPage(arguments: arguments),

  ///请假单
  askForLeavePath: (context) => AskForLeavePage(),
  askForLeaveDetailPath: (context) => AskForLeaveDetailPage(),
  overTimeSelectPath: (context, {Map arguments}) =>
      OverTimeSelectPage(arguments: arguments),

  //放行条
  releasePassPath: (context) => ReleaseQueryPage(),
  releasePassEditPath: (context, {Map arguments}) =>
      ReleaseEditPage(arguments: arguments),

  //放行拍照
  releasePassCamPath: (context) => ReleasePassCamPage(),

  //锅炉投料
  boilerFeedingPath: (context) => BoilerFeedingPage(),
  boilerFeedingAddPath: (context) => BoilerFeedingAddPage(),

  //底料登录验证
  bottomMaterialLoginPath: (context) => BottomMaterialLoginPage(),

  //设备原始数据
  equipmentPath: (context) => DeviceDataPage(),

  //补卡申请
  buCardPath: (context) => BuCardQueryPage(),
  buCardEditPath: (context, {Map arguments}) =>
      BuCardEditPage(arguments: arguments),

  //借款借据
  borrowPath: (context) => BorrowPage(),
  borrowDetailPath: (context, {int arguments}) =>
      BorrowDetaiPage(borrowId: arguments),

  //招待申请
  receivePath: (context) => ReceiveQueryPage(),
  receiveEditPath: (context, {Map arguments}) =>
      ReceiveEditPage(arguments: arguments),
  receiveRoomPath: (context, {Map arguments}) =>
      ReceiveRoomPage(arguments: arguments),

//周工作计划
  weekPlanPath: (context) => WeekPlanPage(),
  weekPlanDetailPath: (context, {int arguments}) =>
      WeekPlanDetailPage(projId: arguments),
  weekPlanProgressPath: (context, {Week arguments}) =>
      WeekPlanProgressDtlPage(item: arguments),

  //人事资料
  staffPath: (context) => StaffQueryPage(),
  staffEditPath: (context, {Map arguments}) =>
      StaffEditPage(arguments: arguments),
};

Route Function(RouteSettings settings) onGenerateRoute =
    (RouteSettings settings) {
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];

  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      // final Route route = MaterialPageRoute(
      //     builder: (context) =>
      //         pageContentBuilder(context, arguments: settings.arguments));
      final Route route = MaterialPageRoute(builder: (context) {
        var page = pageContentBuilder(context, arguments: settings.arguments);
        _pages[name] = page;
        return page;
      });
      return route;
    } else {
      // final Route route =
      //     MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      final Route route = MaterialPageRoute(builder: (context) {
        var page = pageContentBuilder(context);
        _pages[name] = page;
        return page;
      });
      return route;
    }
  }

  return null;
};

/*
String getRedirectPath(String page, String newPath) {
  // return '$page?redirect_path=$newPath';
  return getQueryPath(page, params: {"redirect_path": newPath});
}

String getQueryPath(String path, {Map<String, dynamic> params}) {
  String query = "";
  if (params != null) {
    int index = 0;
    for (var key in params.keys) {
      var value = Uri.encodeComponent(params[key]);
      if (index == 0) {
        query = "?";
      } else {
        query = query + "\&";
      }
      query += "$key=$value";
      index++;
    }
  }

  path = path + query;
  print('path:$path');
  return path;
}
*/

// String _getParam(Map<String, List<String>> params, String key) {
//   String value;
//   List<String> list = params[key];

//   if ((list != null) && (list.length > 0)) {
//     value = list.first;
//   }

//   return value;
// }

/*
class Routes {
  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print('ERROR====>ROUTE WAS NOT FOUND!!!');
      return;
    });

    router.define(rootPage, handler: rootHandler);
    router.define(changePasswordPage, handler: changePasswordHandler);
    router.define(loginPage, handler: loginHandler);
    router.define(signaturePage, handler: signatureHandler);
    router.define(signatureAddPage, handler: signatureAddHandler);
  }

  static String getRedirectPath(String page, String newPath) {
    // return '$page?redirect_path=$newPath';
    return getQueryPath(page, params: {"redirect_path": newPath});
  }

  static String getQueryPath(String path, {Map<String, dynamic> params}) {
    String query = "";
    if (params != null) {
      int index = 0;
      for (var key in params.keys) {
        var value = Uri.encodeComponent(params[key]);
        if (index == 0) {
          query = "?";
        } else {
          query = query + "\&";
        }
        query += "$key=$value";
        index++;
      }
    }

    path = path + query;
    print('path:$path');
    return path;
  }

  // static Future navigateTo(BuildContext context, Router router, String path,
  //     {Map<String, dynamic> params,
  //     TransitionType transition = TransitionType.native}) {
  //   String query = "";
  //   if (params != null) {
  //     int index = 0;
  //     for (var key in params.keys) {
  //       var value = Uri.encodeComponent(params[key]);
  //       if (index == 0) {
  //         query = "?";
  //       } else {
  //         query = query + "\&";
  //       }
  //       query += "$key=$value";
  //       index++;
  //     }
  //   }
  //   print('我是navigateTo传递的参数：$query');

  //   path = path + query;
  //   return router.navigateTo(context, path, transition: transition);
  // }
}
*/
