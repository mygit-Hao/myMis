import 'package:flutter/material.dart';
import 'package:mis_app/model/bussinessPlan.dart';
import 'package:mis_app/service/business_service.dart';

class BusinessPlanPage extends StatefulWidget {
  final Map arguments;
  BusinessPlanPage({this.arguments});
  @override
  _BusinessPlanPageState createState() => _BusinessPlanPageState();
}

class _BusinessPlanPageState extends State<BusinessPlanPage> {
  final List<BusinessPlanModel> _planList = [];

  @override
  void initState() {
    super.initState();
    _getPlan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出差计划单'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Expanded(
          child: ListView.separated(
            itemCount: _planList.length,
            itemBuilder: (BuildContext context, int index) {
              final item = _planList[index];
              return InkWell(
                onTap: () {
                  Navigator.pop(context, item);
                },
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: <Widget>[
                                Text('单号：'),
                                Text(item.planId),
                              ],
                            ),
                          ),
                          Expanded(child: Text(item.staffName)),
                          Expanded(child: Text(item.deptName)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text.rich(TextSpan(children: [
                        TextSpan(text: '出差起始时间：'),
                        TextSpan(
                            text: item.beginDate,
                            style: TextStyle(color: Colors.orange))
                      ])),
                      SizedBox(height: 4),
                      Text.rich(TextSpan(children: [
                        TextSpan(text: '出差起始时间：'),
                        TextSpan(
                            text: item.beginDate,
                            style: TextStyle(color: Colors.orange))
                      ])),
                      SizedBox(height: 4),
                      Text('出差原因：${item.reason}'),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return Divider();
            },
          ),
        ),
      ),
    );
  }

  void _getPlan() async {
    var resposeJson = await getBusinessPlan(this.widget.arguments['staffId']);
    resposeJson.forEach((item) {
      BusinessPlanModel plan = BusinessPlanModel.fromJson(item);
      _planList.add(plan);
    });

    setState(() {});
  }
}
