import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/hrms_service.dart';
import 'package:mis_app/utils/utils.dart';

class StaffQueryPage extends StatefulWidget {
  @override
  _StaffQueryPageState createState() => _StaffQueryPageState();
}

class _StaffQueryPageState extends State<StaffQueryPage> {
  TextEditingController _keyword = TextEditingController();
  List<StaffModel> _dataList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: Text('人事资料查询')),
      body: Column(
        children: [
          searchViewCustom(_keyword, _getStaff),
          _staffListview(),
        ],
      ),
    );
  }

  Widget _staffListview() {
    return Expanded(
      child: EasyRefresh(
        header: customRefreshHeader,
        footer: customRefreshFooter,
        firstRefresh: true,
        firstRefreshWidget: refreshWidget,
        child: ListView.separated(
          itemCount: _dataList.length,
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemBuilder: (BuildContext context, int index) {
            final item = _dataList[index];
            return InkWell(
              onTap: () async {
                Utils.closeInput(context);

                bool dataChanged = await navigatePage(context, staffEditPath,
                    arguments: {'staffId': item.staffId});

                if (dataChanged) {
                  _getStaff();
                }
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              customText(
                                  color: Colors.blue,
                                  value: item.name + '  ' + item.code),
                                    SizedBox(height: 4),
                              Text('入职日期：' + Utils.dateTimeToStr(item.inDate)),
                            ],
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Expanded(
                          child: Column(
                            children: [
                              Center(child: Text(item.posi)),
                                SizedBox(height: 4),
                              Center(
                                child: Text(item.deptName),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: ScreenUtil().setWidth(8)),
                        Column(
                          children: [
                            Text(item.genderName),
                            Text(''),
                          ],
                        ),
                        SizedBox(width: ScreenUtil().setWidth(30)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Text('合同日期：'),
                        customText(
                            value: Utils.dateTimeToStr(item.contractFrom),
                            color: Colors.green),
                        customText(value: ' — ', color: Colors.green),
                        customText(
                            value: Utils.dateTimeToStr(item.contractTo),
                            color: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        onRefresh: () async {
          _getStaff();
        },
      ),
    );
  }

  void _getStaff() async {
    _dataList = await HrmsService.getStaffList(_keyword.text);
    setState(() {});
  }
}
