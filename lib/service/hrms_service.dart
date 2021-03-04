import 'dart:convert';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/attendance.dart';
import 'package:mis_app/model/attendance_scard.dart';
import 'package:mis_app/model/dept.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/utils.dart';

class HrmsService {
  static Future<List<AttendanceModel>> getTimes(
      int staffId, DateTime startDate, DateTime endDate) async {
    List<AttendanceModel> list = List<AttendanceModel>();

    Map<String, dynamic> queryParameters = {
      'action': 'times',
      'staffId': staffId,
      'datefrom': startDate,
      'dateto': endDate,
    };

    await request(serviceUrl[hrmsUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        // print(responseData.runtimeType);

        if (responseData == null) return;

        responseData.forEach((v) {
          // print(v.runtimeType);
          list.add(new AttendanceModel.fromJson(v));
        });

        // print(list);
      },
    );

    return list;
  }

  static Future<List<AttendanceSCardModel>> getSCard(
      int staffId, DateTime date) async {
    List<AttendanceSCardModel> list;

    Map<String, dynamic> queryParameters = {
      'action': 'scard',
      'staffId': staffId,
      'date': date,
    };

    await request(serviceUrl[hrmsUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        list = List<AttendanceSCardModel>();
        responseData.forEach((v) {
          list.add(new AttendanceSCardModel.fromJson(v));
        });

        // 为列表补足8个，方便调用
        while (list.length < AttendanceSCardModel.sCardCount) {
          list.add(new AttendanceSCardModel());
        }
      },
    );

    return list;
  }

  static Future<List<StaffModel>> getStaffList(String keyword,
      {int deptId,
      bool includeBranch = false,
      bool canSearchAll = false}) async {
    List<StaffModel> list = List();

    Map<String, dynamic> queryParameters = {
      'action': 'stafflist',
      'keyword': keyword,
      'includeBranch': Utils.boolToString(includeBranch),
      'can-search-all': Utils.boolToString(canSearchAll),
    };
    if (deptId != null) {
      queryParameters['deptid'] = deptId;
    }

    await request(serviceUrl[hrmsUrl], queryParameters: queryParameters).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());

        if (responseData == null) return;

        responseData.forEach((v) {
          list.add(new StaffModel.fromJson(v));
        });

        // print(list);
      },
    );

    return list;
  }

  static Future<List<DeptModel>> getDeptList(String keyword,
      {int areaId}) async {
    List<DeptModel> list = [];
    Map<String, dynamic> map = {
      'action': 'deptlist',
      'keyword': keyword,
      'areaId': areaId ?? 0
    };
    await request(serviceUrl[hrmsUrl], queryParameters: map).then((value) {
      var responseData = jsonDecode(value.data.toString());
      if (responseData == null) return;
      responseData.forEach((v) {
        list.add(DeptModel.fromJson(v));
      });
    });
    return list;
  }
}
