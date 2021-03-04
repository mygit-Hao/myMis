import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/meal_booking.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/service/service_method.dart';

class LifeService {
  static Future<MealBookingWrapper> updateMealBooking(
      int weekIndex, List<MealBookingModel> list) async {
    MealBookingWrapper result;

    Map<String, dynamic> map = {
      'action': 'update-v2',
      'weekidx': weekIndex,
      'data': json.encode(list)
    };

    FormData formData = FormData.fromMap(map);

    await request(serviceUrl[mealBookingUrl], data: formData).then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        if (responseData != null) {
          result = MealBookingWrapper.fromJson(responseData);
        }
      },
    );

    return result;
  }

  static Future<MealBookingWrapper> getMealBookingByWeek(int weekIndex) async {
    MealBookingWrapper result;

    Map<String, dynamic> queryParameters = {
      'action': 'getweekdata-v2',
      'weekidx': weekIndex
    };

    await request(serviceUrl[mealBookingUrl], queryParameters: queryParameters)
        .then(
      (RequestResult value) {
        var responseData = json.decode(value.data.toString());
        if (responseData != null) {
          result = MealBookingWrapper.fromJson(responseData);
        }
      },
    );

    return result;
  }
}
