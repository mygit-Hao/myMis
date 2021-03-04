import 'package:flutter/cupertino.dart';
import 'package:mis_app/model/week_plan_detail.dart';

class WeekPlanProvide with ChangeNotifier {
  WeekPlanDtlModel detailModel = WeekPlanDtlModel();
  setDetailData(WeekPlanDtlModel detail) {
    detailModel = detail;
    notifyListeners();
  }
}
