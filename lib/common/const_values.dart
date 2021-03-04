import 'package:flutter/material.dart';
import 'package:local_auth/auth_strings.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/utils/utils.dart';

const String cancelText = '取消';
const String deleteText = '删除';
const String authReason = '扫描指纹进行身份验证';
const String unlockReason = '输入密码解锁';

const String loadingMessage = '正在加载...';
const String submittingMessage = '正在提交...';
const String updatingMessage = '正在更新...';

const String requestSuccess = "ok";
const String requestError = "error";

// const String jpushLogoutTag = 'jpush_logout';

const double defaultIconSize = 18.0;
const double defaultIconWidth = 32.0;
const double defaultIconHeight = 32.0;
const double fontSizeLarge = 20.0;
const double fontSizeHeader = 18.0;
const double fontSizeDefault = 16.0;
const double fontSizeDetail = 14.0;
const double fontSizeSmall = 12.0;

const String scanTypeUuid = 'uuid';
const String scanTypeApproval = 'approval';

DateTime defaultFirstDate = DateTime(2000);
DateTime defaultLastDate =
    Utils.dateValue(DateTime.now().add(Duration(days: 366)));

const String defaultLocale = 'zh';
const String defaultCountryCode = 'CN';

const MaterialColor defaultSwatch = Colors.blue;
const Color defaultThemeColor = Colors.blue;
const Color secondaryColor = Colors.orangeAccent;
Color defaultFontColor = Colors.grey[500];
Color disabledFontColor = Colors.grey;
Color backgroundColor = Colors.grey[50];
Color headerBackgroundColor = Colors.grey[500];

const double designScreenWidth = 750;
const double designScreenHeight = 1334;

const authAndroidStrings = const AndroidAuthMessages(
  cancelButton: '取消',
  goToSettingsButton: '去设置',
  fingerprintNotRecognized: '指纹识别失败',
  goToSettingsDescription: '请设置指纹.',
  // fingerprintHint: '指纹',
  fingerprintHint: '轻触传感器',
  fingerprintSuccess: '指纹识别成功',
  signInTitle: '指纹验证',
  fingerprintRequiredTitle: '请先录入指纹!',
);

const Map<String, String> scanOptionsStrings = {
  'cancel': '取消',
  'flash_on': '打开闪光',
  'flash_off': '关闭闪光',
};

const int functionCategoryOffice = 1;
const int functionCategoryLife = 2;
const int functionCategoryOA = 3;

const int functionIdCust = 1;
const int functionIdSalesOrder = 2;
const int functionIdPriceSearch = 3;
const int functionIdSalesCart = 4;
const int functionIdSearchInventory = 5;
const int functionIdArreage = 6;
const int functionIdSalesSummary = 7;
const int functionIdSampleDelivery = 8;
const int functionIdSalesQueryEntrance = 9;
const int functionIdSalesBonusQuery = 10;
const int functionIdWeekPlan = 11;

const int functionIdSales = 999;

const int functionIdMealBooking = 1001;
const int functionIdExpenseClaim = 2001;
const int functionIdApproval = 2002;
const int functionIdVehicleRequest = 2003;
const int functionIdVehicleRequestShift = 2004;
const int functionIdBusinessPlan = 2005;
const int functionIdReleasePass = 2006;
const int functionIdReleasePassRequest = 2007;
const int functionIdReleaseAskForLeave = 2008;
const int functionIdBorrow = 2009;
const int functionIdOvertime = 2010;
const int functionIdAttendance = 2011;
const int functionIdEquipment = 2012;
const int functionIdSevenS = 2013;
const int functionIdSupplementCard = 2014;
const int functionIdBusinessReport = 2015;
const int functionIdReceive = 2016;
const int functionIdEntrance = 2017;
const int functionIdClock = 2018;
const int functionIdboilerFeeding = 2019;
const int functionIdbottomMaterialLogin = 2020;
const int functionIdVehicleUserRequest = 2021;
const int functionIdStaff = 2022;

const int functionIdAll = 9999;

const int fileTypeUnknown = 0;
const int fileTypeWord = 1;
const int fileTypeExcel = 2;
const int fileTypePpt = 3;
const int fileTypePdf = 4;
const int fileTypePhoto = 5;
const int fileTypeAudio = 6;
const int fileTypeVideo = 7;
const int fileTypeRar = 8;
const int fileTypeZip = 9;

class ConstValues {
  static double screenShortestSide = designScreenWidth;
  static double screenLongestSide = designScreenHeight;

  static double defaultFontSize = fontSizeDefault;
  static double get detailFontSize {
    return defaultFontSize - 2;
  }

  static double get smallFontSize {
    return defaultFontSize - 4;
  }

  static double get headerFontSize {
    return defaultFontSize + 2;
  }

  static double get largeFontSize {
    return defaultFontSize + 4;
  }

  static const IconData icon_reporting_document =
      IconData(0xe7d9, fontFamily: 'MyIcons');

  static const IconData icon_clock = IconData(0xe646, fontFamily: 'MyIcons');

  static const IconData icon_pen = IconData(0xe6fe, fontFamily: 'MyIcons');

  static const IconData icon_qrcode = IconData(0xe7b8, fontFamily: 'MyIcons');

  static const IconData icon_warning = IconData(0xe619, fontFamily: 'MyIcons');

  static const IconData icon_check = IconData(0xed70, fontFamily: 'MyIcons');

  static const IconData icon_sales = IconData(0xe6c7, fontFamily: 'MyIcons');

  static const IconData icon_cust = IconData(0xe601, fontFamily: 'MyIcons');

  static const IconData icon_order = IconData(0xe60e, fontFamily: 'MyIcons');

  static const IconData icon_price = IconData(0xe6c8, fontFamily: 'MyIcons');

  static const IconData icon_donation = IconData(0xe70d, fontFamily: 'MyIcons');

  static const IconData icon_delivery = IconData(0xe73c, fontFamily: 'MyIcons');

  static const IconData icon_meal = IconData(0xe620, fontFamily: 'MyIcons');

  static const IconData icon_calendar = IconData(0xe6b4, fontFamily: 'MyIcons');

  static const IconData icon_inventory =
      IconData(0xe60f, fontFamily: 'MyIcons');

  static const IconData icon_sales_statistics =
      IconData(0xe60d, fontFamily: 'MyIcons');

  static const IconData icon_steering_wheel =
      IconData(0xe866, fontFamily: 'MyIcons');

  static const IconData icon_my_request =
      IconData(0xed21, fontFamily: 'MyIcons');

  static const IconData icon_scan = IconData(0xe90c, fontFamily: 'MyIcons');

  static const IconData icon_eraser = IconData(0xe602, fontFamily: 'MyIcons');

  static const Icon personIcon = Icon(
    Icons.person,
    color: Color(0xFF29C2D1),
  );

  static const IconData icon_week_plan =
      IconData(0xe600, fontFamily: 'MyIcons');

  static const IconData icon_person = IconData(0xe621, fontFamily: 'MyIcons');
  static const IconData icon_environ = IconData(0xe687, fontFamily: 'MyIcons');

  static Image imageAudio = Image.asset("assets/images/audio.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageExcel = Image.asset("assets/images/excel.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageFile = Image.asset("assets/images/file.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imagePdf = Image.asset("assets/images/pdf.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imagePhoto = Image.asset("assets/images/photo.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imagePpt = Image.asset("assets/images/ppt.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageRar = Image.asset("assets/images/rar.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageVideo = Image.asset("assets/images/video.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageWord = Image.asset("assets/images/word.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageZip = Image.asset("assets/images/zip.png",
      width: defaultIconWidth, height: defaultIconHeight);

  static Image imageBread = Image.asset("assets/images/bread.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageRice = Image.asset("assets/images/rice.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageDinner = Image.asset("assets/images/dinner.png",
      width: defaultIconWidth, height: defaultIconHeight);
  static Image imageSoup = Image.asset("assets/images/soup.png",
      width: defaultIconWidth, height: defaultIconHeight);
}

final List<MobileFunction> allHomeFunctions = [
  _funcApproval,
  _funcAllSales,
  _weekPlan,
];

final List<MobileFunction> allSalesFunctions = [
  _funcCust,
  _funcSalesOrder,
  _funcSalesCart,
  _funcPriceSearch,
  _funcSearchInventory,
  _funcSalesSummary,
  _funcSalesBonusQuery,
  _funcArreage,
  _funcSampleDelivery,
];

final List<MobileFunction> allOfficeFunctions = [
  _funcAttendance,
  _funOvertime,
  _funcAskForLeave,
  _funcVehicleRequest,
  _funcVehicleRequestShift,
  _funcVehicleUserRequest,
  _funcSevenS,
  _funEntrance,
  _funWorkClock,
  _funcBusinessReport,
  _funcReleasePassRequest,
  _funcSupplementCard,
  _bottomMaterialLogin,
  _boilerFeeding,
  _funcEquipment,
  _funcBorrow,
  _funcBusinessPlan,
  _funcReceive,
  _funcReleasePassCam,
  _funcStaff,
  /*
  _funcReleaseAskForLeave,
  _funOvertime,
  _funcAttendance,
  _funcVehicleRequest,
  _funcVehicleRequestShift,

  _funcBorrow,
  _funcReleasePass,

  _funcExpenseClaim,
  _funcEquipment,
  */
];

final List<Map<String, dynamic>> allOfficeGroupFunctions = [
  {
    'name': '人事考勤',
    'tag': 0,
    'functions': [
      _funcAttendance,
      _funWorkClock,
      _funOvertime,
      _funcAskForLeave,
      _funcBusinessPlan,
      _funcBusinessReport,
      _funcSupplementCard,
      _funcStaff,
    ]
  },
  {
    'name': '出入管理',
    'tag': 0,
    'functions': [
      _funcVehicleUserRequest,
      _funcVehicleRequest,
      _funcVehicleRequestShift,
      _funEntrance,
      _funcReleasePassCam,
      _funcReleasePassRequest,
      _funcReceive,
    ]
  },
  {
    'name': '设备',
    'tag': 0,
    'functions': [
      _bottomMaterialLogin,
      _boilerFeeding,
      _funcEquipment,
    ]
  },
  {
    'name': '其他',
    'tag': 0,
    'functions': [
      _funcBorrow,
      _funcSevenS,
    ]
  }
];

final List<Map<String, dynamic>> allSalesGroupFunctions = [
  {
    'name': '常用',
    'functions': [
      _funcCust,
      _funcSalesOrder,
      _funcSalesCart,
      _funcPriceSearch,
      _funcSearchInventory,
      _funcArreage,
      _funcSampleDelivery,
    ]
  },
  {
    'name': '查询',
    'functions': [
      _funcSalesSummary,
      _funcSalesBonusQuery,
    ]
  },
];

final List<MobileFunction> allLifeFunctions = [
  _funcMealBooking,
];

MobileFunction _weekPlan = MobileFunction(
    mobileFunctionId: functionIdWeekPlan,
    routeName: weekPlanPath,
    icon: Icon(
      ConstValues.icon_week_plan,
      color: Colors.amber,
    ),
    name: 'week_plan',
    functionName: '周工作');

MobileFunction _funcApproval = MobileFunction(
    mobileFunctionId: functionIdApproval,
    routeName: approvalPath,
    icon: Icon(
      ConstValues.icon_check,
      color: Color(0xFF991016),
    ),
    name: 'approval',
    functionName: '审批');

MobileFunction _funcAskForLeave = MobileFunction(
    mobileFunctionId: functionIdReleaseAskForLeave,
    routeName: askForLeavePath,
    icon: Icon(
      Icons.timelapse,
      color: Colors.amber,
    ),
    name: 'ask_for_leave',
    functionName: '请假');

MobileFunction _funOvertime = MobileFunction(
    mobileFunctionId: functionIdOvertime,
    routeName: overTimePath,
    icon: Icon(
      Icons.timelapse,
    ),
    name: 'over_time',
    functionName: '加班');

MobileFunction _funcAttendance = MobileFunction(
    mobileFunctionId: functionIdAttendance,
    routeName: attendancePath,
    icon: Icon(
      Icons.access_time,
      color: Color(0xFF29C2D1),
    ),
    name: 'attendance',
    functionName: '考勤查询');

MobileFunction _funcSevenS = MobileFunction(
    mobileFunctionId: functionIdSevenS,
    routeName: sevensPath,
    icon: Icon(
      Icons.check,
    ),
    name: 'sevens',
    functionName: '7S检查');

MobileFunction _funEntrance = MobileFunction(
    mobileFunctionId: functionIdEntrance,
    routeName: entrancePath,
    icon: Icon(
      Icons.people,
    ),
    name: 'entrance',
    functionName: '接洽');

MobileFunction _funWorkClock = MobileFunction(
    mobileFunctionId: functionIdClock,
    routeName: workClockPath,
    needPermission: true,
    icon: Icon(
      Icons.location_on,
    ),
    name: 'work_clock',
    functionName: '打卡');

MobileFunction _funcBusinessReport = MobileFunction(
    mobileFunctionId: functionIdBusinessReport,
    routeName: businessPath,
    icon: Icon(
      Icons.business_center,
      color: Color(0xFFD9DD93),
    ),
    name: 'business',
    functionName: '出差报告');

MobileFunction _funcReleasePassRequest = MobileFunction(
    mobileFunctionId: functionIdReleasePassRequest,
    routeName: releasePassPath,
    icon: Icon(
      Icons.reorder,
      color: Color(0xFF52639B),
    ),
    name: 'release_pass',
    functionName: '放行条');

MobileFunction _boilerFeeding = MobileFunction(
    mobileFunctionId: functionIdboilerFeeding,
    routeName: boilerFeedingPath,
    icon: Icon(
      Icons.gradient,
      color: Colors.amber,
    ),
    name: 'boiler_feeding',
    functionName: '锅炉投料');

MobileFunction _bottomMaterialLogin = MobileFunction(
    mobileFunctionId: functionIdbottomMaterialLogin,
    routeName: bottomMaterialLoginPath,
    icon: Icon(
      Icons.playlist_add_check,
    ),
    name: 'bottom_material_login',
    functionName: '底料登录验证');

MobileFunction _funcSupplementCard = MobileFunction(
    mobileFunctionId: functionIdSupplementCard,
    routeName: buCardPath,
    icon: Icon(
      Icons.card_giftcard,
      color: Color(0xFFC26915),
    ),
    name: 'supplement_card',
    functionName: '补卡申请');

MobileFunction _funcBorrow = MobileFunction(
    mobileFunctionId: functionIdBorrow,
    routeName: borrowPath,
    icon: Icon(
      Icons.monetization_on,
      color: Colors.amber,
    ),
    name: 'borrow',
    functionName: '借款借据');

MobileFunction _funcBusinessPlan = MobileFunction(
    mobileFunctionId: functionIdBusinessPlan,
    routeName: businessPlanListPath,
    icon: Icon(
      Icons.flight_takeoff,
      color: Colors.amber,
    ),
    name: 'business',
    functionName: '出差计划');

MobileFunction _funcReceive = MobileFunction(
    mobileFunctionId: functionIdReceive,
    routeName: receivePath,
    icon: Icon(
      Icons.nature_people,
      color: Colors.amber,
    ),
    name: 'receive',
    functionName: '招待申请');

MobileFunction _funcReleasePassCam = MobileFunction(
    mobileFunctionId: functionIdReleasePass,
    routeName: releasePassCamPath,
    icon: Icon(
      Icons.camera_alt,
    ),
    name: 'release_pass_cam',
    functionName: '放行拍照');

MobileFunction _funcEquipment = MobileFunction(
    mobileFunctionId: functionIdEquipment,
    routeName: equipmentPath,
    icon: Icon(
      Icons.devices_other,
      color: Colors.amber,
    ),
    name: 'device_data',
    functionName: '设备原始数据');

MobileFunction _funcStaff = MobileFunction(
    mobileFunctionId: functionIdStaff,
    routeName: staffPath,
    icon: Icon(
      Icons.perm_data_setting,
      color: Color(0xFF47996B),
    ),
    name: 'staff_data',
    functionName: '人事资料');

/*
MobileFunction _funcVehicleRequest = MobileFunction(
    mobileFunctionId: functionIdVehicleRequest,
    icon: IconData(0xe646, fontFamily: 'MyIcons'),
    functionName: '车辆调度');

MobileFunction _funcVehicleRequestShift = MobileFunction(
    mobileFunctionId: functionIdVehicleRequestShift,
    icon: IconData(0xe646, fontFamily: 'MyIcons'),
    functionName: '出车变更');


MobileFunction _funcExpenseClaim = MobileFunction(
    mobileFunctionId: functionIdExpenseClaim,
    icon: IconData(0xe646, fontFamily: 'MyIcons'),
    functionName: '报销');



*/

MobileFunction _funcAllSales = MobileFunction(
    mobileFunctionId: functionIdSales,
    routeName: salesPath,
    icon: Icon(
      ConstValues.icon_sales,
      color: Color(0xFFE86B00),
    ),
    name: 'sales',
    functionName: '销售');

MobileFunction _funcCust = MobileFunction(
    mobileFunctionId: functionIdCust,
    routeName: custPath,
    icon: Icon(
      ConstValues.icon_cust,
      color: Color(0xFF32B3AE),
    ),
    name: 'cust',
    functionName: '我的客户');

MobileFunction _funcSalesCart = MobileFunction(
    mobileFunctionId: functionIdSalesCart,
    routeName: salesCartPath,
    icon: Icon(
      ConstValues.icon_order,
      color: Color(0xFFDD633D),
    ),
    name: 'sales_cart',
    functionName: '销售开单');

MobileFunction _funcPriceSearch = MobileFunction(
    mobileFunctionId: functionIdPriceSearch,
    routeName: searchPricePath,
    icon: Icon(
      ConstValues.icon_sales,
      color: Color(0xFF5F98F2),
    ),
    name: 'search_price',
    functionName: '价格查询');

MobileFunction _funcSearchInventory = MobileFunction(
    mobileFunctionId: functionIdSearchInventory,
    routeName: searchInventoryPath,
    icon: Icon(
      ConstValues.icon_inventory,
      color: Color(0XFF9BB26E),
    ),
    name: 'search_inventory',
    functionName: '库存查询');

MobileFunction _funcSalesOrder = MobileFunction(
    mobileFunctionId: functionIdSalesOrder,
    routeName: salesOrderPath,
    icon: Icon(
      Icons.collections_bookmark,
      color: Color(0xFFF7B500),
    ),
    name: 'sales_order',
    functionName: '销售跟踪');

MobileFunction _funcSalesSummary = MobileFunction(
    mobileFunctionId: functionIdSalesSummary,
    routeName: salesSummaryPath,
    icon: Icon(
      ConstValues.icon_sales_statistics,
      color: Color(0xFF126CF3),
    ),
    name: 'sales_summary',
    functionName: '销售查询');

MobileFunction _funcArreage = MobileFunction(
    mobileFunctionId: functionIdArreage,
    routeName: arrearagePath,
    icon: Icon(
      ConstValues.icon_donation,
      color: Color(0xFFFFD507),
    ),
    name: 'arrearage',
    functionName: '欠款情况');

MobileFunction _funcSampleDelivery = MobileFunction(
    mobileFunctionId: functionIdSampleDelivery,
    routeName: sampleDeliveryPath,
    childRoutes: [
      sampleDeliveryDetailItemPath,
      sampleDeliveryDetailPath,
      sampleDeliveryDetailReplyPath,
      sampleDeliveryHandlePath,
      sampleDeliveryLogPath,
    ],
    icon: Icon(
      ConstValues.icon_delivery,
      color: Color(0XFFFFA002),
    ),
    name: 'sample_delivery',
    functionName: '送样申请');

MobileFunction _funcSalesBonusQuery = MobileFunction(
    mobileFunctionId: functionIdSalesBonusQuery,
    routeName: salesBonusQueryPath,
    icon: Icon(
      Icons.account_balance_wallet,
      color: Color(0xFFFF9292),
    ),
    name: 'sales_bonus_query',
    functionName: '佣金查询');

MobileFunction _funcMealBooking = MobileFunction(
    mobileFunctionId: functionIdMealBooking,
    routeName: mealBookingPath,
    icon: Icon(
      ConstValues.icon_meal,
      color: Color(0xFFE83C1A),
    ),
    name: 'meal_booking',
    functionName: '报餐');

MobileFunction _funcVehicleRequest = MobileFunction(
    mobileFunctionId: functionIdVehicleRequest,
    routeName: vehicleRequestPath,
    icon: Icon(
      Icons.directions_car,
      color: Color(0xFF73D0F4),
    ),
    name: 'vehicle_request',
    functionName: '车辆调度');

MobileFunction _funcVehicleRequestShift = MobileFunction(
    mobileFunctionId: functionIdVehicleRequestShift,
    routeName: vehicleRequestPath,
    routeArguments: {'shifting': true},
    icon: Icon(
      ConstValues.icon_steering_wheel,
      color: Color(0xFFFAC546),
    ),
    name: 'vehicle_request',
    functionName: '出车变更');

MobileFunction _funcVehicleUserRequest = MobileFunction(
    mobileFunctionId: functionIdVehicleUserRequest,
    routeName: vehicleUserRequestPath,
    icon: Icon(
      ConstValues.icon_my_request,
      color: Color(0xFFADD175),
    ),
    name: 'vehicle_user_request',
    functionName: '用车申请');

Icon getIcon(String resourceId, {double size}) {
  /*
  switch (resourceId) {
    case 'sales':
      return Icon(
        ConstValues.icon_sales,
        color: Color(0xFFE86B00),
        size: size,
      );
    case 'business_center':
      return Icon(
        Icons.business_center,
        color: Color(0xFFD9DD93),
        size: size,
      );
    case 'person':
      return Icon(
        Icons.person,
        color: Color(0xFF29C2D1),
        size: size,
      );
    default:
      return null;
  }
  */
  Icon originalIcon;

  switch (resourceId) {
    case 'sales':
      originalIcon = _funcAllSales.icon;
      break;
    case 'business_center':
      originalIcon = _funcBusinessReport.icon;
      break;
    case 'person':
      originalIcon = ConstValues.personIcon;
      break;
    default:
      originalIcon = null;
  }

  if (originalIcon != null) {
    return Icon(
      originalIcon.icon,
      color: originalIcon.color,
      size: size,
    );
  }
  return null;
}
