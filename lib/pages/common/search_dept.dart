import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/dept.dart';
import 'package:mis_app/service/hrms_service.dart';
import 'package:mis_app/widget/base_search.dart';

class SearchDeptDelegate extends BaseSearchDelegate {
  final int areaId;

  SearchDeptDelegate(String historyKey, {this.areaId}) : super(historyKey);
  @override
  Future<void> getDataList(String keyword) async {
    dataList = await HrmsService.getDeptList(keyword, areaId: areaId);
  }

  @override
  Widget itemWidget(BuildContext context, item) {
    DeptModel dept = item;
    return Card(
      borderOnForeground: false,
      // shadowColor: Colors.black,
      elevation: 0.5,
      child: InkWell(
        onTap: () {
          returnDataAndClose(context, dept);
        },
        child: Container(
          padding: EdgeInsets.all(8),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Expanded(flex: 2, child: customText(value: dept.areaName)),
              Expanded(
                flex: 3,
                child: customText(value: dept.name, color: Colors.blue[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
