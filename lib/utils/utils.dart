import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/device_info.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/download_result.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dialog_utils.dart';

widgets(List<Widget> widgets) {
  return widgets..removeWhere((widget) => widget == null);
}

const String formatPatternQty = "###,###.##";
const String formatPatternCurrency = "###,##0.00";
const String formatPatternNumber = "0.##";
const String formatPatternDate = 'yyyy-MM-dd';
const String formatPatternShortDate = 'MM-dd';
const String formatPatternTime = 'HH:mm:ss';
const String formatPatternShortTime = 'HH:mm';
const String formatPatternDateTime = 'yyyy-MM-dd HH:mm:ss';

final MaskTextInputFormatter integerInputFormatter =
    MaskTextInputFormatter(mask: '#########', filter: {"#": RegExp(r'[0-9]')});

class Utils {
  static const String _spaceEncoded = '%20';

  static String getMd5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  static String getMd5_16(String data) {
    String md5Str = getMd5(data);
    if ((md5Str != null) && (md5Str.length >= 32))
      return md5Str.substring(8, 24);
    else
      return "";
  }

  static String toUpperCaseFirstOne(String str) {
    if ((str == null) || (str.length <= 0)) return str;

    if (str[0].toUpperCase() == str[0])
      return str;
    else
      return str.substring(0, 1).toUpperCase() + str.substring(1);
  }

  static String toAutoCapitalize(String str) {
    if ((str == null) || (str.length <= 0)) return str;

    return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();
  }

  static void saveImage(Uint8List uint8List, String filePath,
      {Function success, Function fail}) async {
    File image = File(filePath);
    bool isExist = await image.exists();
    if (isExist) await image.delete();
    image.writeAsBytes(uint8List).then((_) {
      if (success != null) success();
    });
  }

  static void clearImageCache() {
    // print('Clear image cache');
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();
  }

  static bool textIsEmpty(String text) {
    return (text == null) || (text.isEmpty) || (text == "");
  }

  static bool textIsEmptyOrWhiteSpace(String text) {
    return (text == null) || (text.isEmpty) || (text.trim() == '');
  }

  static DateTime get today {
    // DateTime now = DateTime.now();
    // return DateTime(now.year, now.month, now.day);
    return dateValue(DateTime.now());
  }

  static DateTime dateValue(DateTime time) {
    return DateTime(time.year, time.month, time.day);
  }

  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime lastDayOfMonth(DateTime date) {
    return firstDayOfMonth(firstDayOfMonth(date).add(Duration(days: 32)))
        .add(Duration(days: -1));
  }

  static String dateTimeToStr(DateTime date, {String pattern}) {
    // DateFormat formatter = new DateFormat('yyyy-MM-dd');
    // return formatter.format(date);

    if (date == null) return '';

    return dateTimeToStrWithPattern(date, pattern ?? formatPatternDate);
  }

  static String weekdayToStr(int weekday) {
    switch (weekday) {
      case 1:
        return '星期一';
      case 2:
        return '星期二';
      case 3:
        return '星期三';
      case 4:
        return '星期四';
      case 5:
        return '星期五';
      case 6:
        return '星期六';
      case 7:
        return '星期日';
      default:
        return '';
    }
  }

  static String dateTimeToStrWithPattern(DateTime date, String pattern,
      [String locale]) {
    if (date == null) return '';

    DateFormat formatter = new DateFormat(pattern, locale);
    return formatter.format(date);
  }

  static bool inSameMonth(DateTime date1, DateTime date2) {
    if (date1 == date2) return true;
    if ((date1 == null) || (date2 == null)) return false;

    return (date1.year == date2.year) && (date1.month == date2.month);
  }

  static bool inSameDay(DateTime date1, DateTime date2) {
    if (date1 == date2) return true;
    if ((date1 == null) || (date2 == null)) return false;

    return (date1.year == date2.year) &&
        (date1.month == date2.month) &&
        (date1.day == date2.day);
  }

  static bool sameText(String str1, String str2,
      {bool ignoreWhiteSpace = false}) {
    str1 = str1 ?? '';
    str2 = str2 ?? '';
    if (ignoreWhiteSpace) {
      str1 = str1.trim();
      str2 = str2.trim();
    }
    return str1.toUpperCase() == str2.toUpperCase();
  }

  static bool sameUrl(String url1, String url2) {
    url1 = url1.trim().replaceAll(' ', _spaceEncoded);
    url2 = url2.trim().replaceAll(' ', _spaceEncoded);

    if (!url1.endsWith('/')) {
      url1 = url1 + '/';
    }

    if (!url2.endsWith('/')) {
      url2 = url2 + '/';
    }

    return sameText(url1, url2);
  }

  static String getFileName(String filePath) {
    int start = filePath.lastIndexOf("/");
    if (start == -1) {
      start = filePath.lastIndexOf("\\");
    }
    int end = filePath.lastIndexOf(".");

    if (start != -1 && end != -1) {
      return filePath.substring(start + 1, end);
    } else {
      return null;
    }
  }

  static String getFileExt(String filePath) {
    return filePath.substring(filePath.lastIndexOf(".") + 1);
  }

  static Future<bool> fileHasData(File file) async {
    bool result = false;
    try {
      if (await file.exists()) {
        int len = await file.length();
        result = (len > 0);
      }
    } catch (e) {
      print(e);
    }
    return result;
  }

  static Future<bool> filePathHasData(String filePath) async {
    File file = File(filePath);
    return fileHasData(file);
  }

  static List<String> updateHistoryList(
      List<String> historyList, String searchText,
      {int maxHistoryCount = 0}) {
    if (Utils.textIsEmptyOrWhiteSpace(searchText)) {
      return historyList;
    }

    if ((historyList != null) &&
        (historyList.length > 0) &&
        (searchText == historyList[0])) {
      return historyList;
    }

    List<String> list = List();
    list.add(searchText);

    if (historyList != null) {
      for (var i = 0; i < historyList.length; i++) {
        if (searchText != historyList[i]) {
          list.add(historyList[i]);

          if ((maxHistoryCount > 0) && (list.length >= maxHistoryCount)) {
            break;
          }
        }
      }
    }

    return list;
  }

  static List<String> getPhoneNumbers(String content) {
    List<String> digitList = List();

    //正则表达式：数字、符号“-”组合，并长度>=7
    RegExp exp = RegExp("([-\\d]{7,})");

    Iterable<Match> matches = exp.allMatches(content);

    for (Match m in matches) {
      String match = m.group(0);
      print(match);
      digitList.add(match);
    }

    return digitList;
  }

  static String getQtyStr(double value) {
    return NumberFormat(formatPatternQty).format(value ?? 0);
  }

  static String getCurrencyStr(double value) {
    return NumberFormat(formatPatternCurrency).format(value ?? 0);
  }

  static String getNumberStr(double value) {
    return NumberFormat(formatPatternNumber).format(value ?? 0);
  }

  static String getDecimalStrWithPattern(double value, String pattern) {
    return NumberFormat(pattern).format(value);
  }

  /// 收起键盘
  static void closeInput(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static int boolToInt(bool value) {
    return value ? 1 : 0;
  }

  static String boolToString(bool value) {
    return value ? 'true' : 'false';
  }

  static requestPermissionAndNavigator(
      BuildContext context, String routeName) async {
    final status = await Permission.location.request();
    if (status == PermissionStatus.granted) {
      Navigator.pushNamed(context, routeName);
    } else {
      Fluttertoast.showToast(
          msg: "没有位置权限，无法进行打卡", gravity: ToastGravity.CENTER);
      // Navigator.pushNamed(context, workClockPath);
    }
  }

  ///获取照片的路径
  static String getImageUrl(int fileId, {int clockRecId}) {
    String user = UserProvide.currentUser.userName;
    String devid = DeviceInfo.devId;
    String passWordKey = UserProvide.currentUserMd5Password;
    String date = Utils.dateTimeToStrWithPattern(DateTime.now(), 'yyyyMMdd');
    String key = Utils.getMd5_16(user + passWordKey + devid + date);
    String urlToken = getUrlToken();
    String url =
        '${serviceUrl[fileServiceUrl]}?user=$user&devid=$devid&key=$key&action=getthumb&fileid=${fileId.toString()}&=$urlToken';
    if (clockRecId != null) url += '&clockRecId=$clockRecId';
    return url;
  }

  ///拍照压缩
  static Future<File> takePhote({bool fromPhote}) async {
    File imageFile;
    var imagePicker = await ImagePicker().getImage(
        source: fromPhote == true ? ImageSource.gallery : ImageSource.camera);
    if (imagePicker != null) {
      imageFile = File(imagePicker.path);
      print(">>>>>>>>>>>>>>>>拍照" + imageFile.lengthSync().toString());
      ImageProperties properties =
          await FlutterNativeImage.getImageProperties(imageFile.path);
      int height = (properties.height * 750 / properties.width).round();
      imageFile = await FlutterNativeImage.compressImage(imageFile.path,
          quality: 80, percentage: 100, targetWidth: 750, targetHeight: height);
      print(">>>>>>>>>>>>>>>>拍照" + imageFile.lengthSync().toString());
    }
    return imageFile;
  }

  ///选择文件
  static Future<List<File>> selectFile() async {
    // try {
    List<File> fileList;
    // var imagePicker = await ImagePicker().getImage(source: ImageSource.gallery);
    // if (imagePicker != null) {
    //   imageFile = File(imagePicker.path);
    // }
    /*
    fileList = await FilePicker.getMultiFile(
      type: FileType.any,
      // allowedExtensions: ['jpg', 'pdf', 'doc'],
    );
    */
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result != null) {
      fileList = result.paths.map((path) => File(path)).toList();
    }

    return fileList;
    // } catch (e) {
    //   print(e.toString());
    // }
  }

  static bool strToBool(String str) {
    return (str != null) && sameText(str, "true");
  }

  static bool containsText(Iterable<String> list, String text) {
    return list.any((element) => Utils.sameText(element, text));
  }

  ///查看下载附件
  static void viewAttachment(BuildContext context, attachment) async {
    DownloadResultModel result = await downloadAttachmentWithFileExt(
        attachment.fileId, attachment.fileExt);
    if (result.success) {
      // print('文件已下载：${result.storageFilePath}');
      viewFile(context,
          storageFilePath: result.storageFilePath,
          filePath: attachment.fileName,
          title: attachment.remarks);
    } else {
      DialogUtils.showToast('附件下载失败');
    }
  }

  static String getServerKey(List<String> list) {
    list = list.map((e) => e.trim().toLowerCase()).toList();
    list.sort((a, b) => a.compareTo(b));
    list = list.map((e) => getMd5_16(e)).toList();
    String result = list.join();
    return getMd5_16(result);
  }

  static convertNumToChinese(double num) {
    final List<String> cnUpperNumber = [
      "零",
      "壹",
      "贰",
      "叁",
      "肆",
      "伍",
      "陆",
      "柒",
      "捌",
      "玖"
    ];
    final List<String> cnUpperAmount = [
      "分",
      "角",
      "圆",
      "拾",
      "佰",
      "仟",
      "万",
      "拾",
      "佰",
      "仟",
      "亿",
      "拾",
      "佰",
      "仟",
      "兆",
      "拾",
      "佰",
      "仟"
    ];
    final String cnFull = "整";
    final String ncNegative = "负";
    final String cnZeorFull = "零圆" + cnFull;
    double sign = num.sign;
    if (sign == num) {
      return cnZeorFull;
    }
    if (num.toStringAsFixed(0).length > 15) {
      return '超出最大限额';
    }
    num = num * 100;
    int tempValue = int.parse(num.toStringAsFixed(0)).abs();

    int p = 10;
    int i = -1;
    String cnUp = '';
    bool lastZero = false;
    bool finish = false;
    bool tag = false;
    bool tag2 = false;
    while (!finish) {
      if (tempValue == 0) {
        break;
      }
      int positionNum = tempValue % p;
      double n = (tempValue - positionNum) / 10;
      tempValue = int.parse(n.toStringAsFixed(0));
      String tempChinese = '';
      i++;
      if (positionNum == 0) {
        if (cnUpperAmount[i] == "万" ||
            cnUpperAmount[i] == "亿" ||
            cnUpperAmount[i] == "兆" ||
            cnUpperAmount[i] == "圆") {
          if (lastZero && tag2) {
            cnUp = cnUpperNumber[0] + cnUp;
          }
          cnUp = cnUpperAmount[i] + cnUp;
          lastZero = false;
          tag = true;
          continue;
        }
        if (!lastZero) {
          lastZero = true;
        } else {
          continue;
        }
      } else {
        if (lastZero && !tag && tag2) {
          cnUp = cnUpperNumber[0] + cnUp;
        }
        tag = false;
        tag2 = true;
        lastZero = false;
        tempChinese = cnUpperNumber[positionNum] + cnUpperAmount[i];
      }
      cnUp = tempChinese + cnUp;
    }
    if (sign < 0) {
      cnUp = ncNegative + cnUp;
    }
    return cnUp;
  }

  static Uint8List fileToBytes(File file) {
    Uint8List bytes = Uint8List.fromList(file.readAsBytesSync());
    return bytes;
  }

  static Future<void> deleteFile(String path) async {
    File file = File(path);
    if (await file.exists()) {
      try {
        file.delete();
      } catch (e) {
        print(e);
      }
    }
  }

  static String getFormatNum(double number) {
    var format = NumberFormat('0,000.0');
    String forNum = number >= 1000 ? format.format(number) : number.toString();
    return forNum;
  }
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }

  TimeOfDay get time {
    return TimeOfDay(hour: this.hour, minute: this.minute);
  }

  DateTime replaceDate(DateTime date) {
    return DateTime(
        date.year, date.month, date.day, this.hour, this.minute, this.second);
  }

  DateTime replaceTime(TimeOfDay time) {
    return DateTime(this.year, this.month, this.day, time.hour, time.minute, 0);
  }
}
