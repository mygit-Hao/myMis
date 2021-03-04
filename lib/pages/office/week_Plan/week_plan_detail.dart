import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_file.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_progress.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_progress_web.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_project.dart';
import 'package:mis_app/utils/utils.dart';

class WeekPlanDetailPage extends StatefulWidget {
  final int projId;
  const WeekPlanDetailPage({Key key, this.projId}) : super(key: key);
  @override
  _WeekPlanDetailPageState createState() => _WeekPlanDetailPageState();
}

class _WeekPlanDetailPageState extends State<WeekPlanDetailPage>
    with SingleTickerProviderStateMixin {
  List<Tab> _tabs = [];
  TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabs
      ..add(Tab(
        text: '项目',
      ))
      ..add(
        Tab(text: '进展预览'),
      )
      ..add(
        Tab(text: '进展编辑'),
      )
      ..add(
        Tab(text: '附件'),
      );
    this._tabCtrl = TabController(length: _tabs.length, vsync: this);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _setDetail(projId: this.widget.projId);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Utils.closeInput(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('明细'),
        ),
        body: Container(
          child: Column(
            children: [
              Container(
                width: ScreenUtil().setWidth(750),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 0.2))),
                child: TabBar(
                  isScrollable: true,
                  tabs: _tabs,
                  controller: _tabCtrl,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                ),
              ),
              Expanded(
                  child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      controller: _tabCtrl,
                      children: [
                    // _project,
                    WeekPlanProjectPage(),
                    WeekPlanProgressWebPage(),
                    WeekPlanProgressPage(),
                    WeekPlanFilePage(
                      arguments: {},
                    ),
                    // _attachementWidget(),
                  ]))
            ],
          ),
        ),
      ),
    );
  }
}
