import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/widget/group_function_list.dart';
import 'package:provide/provide.dart';

class SalesPage extends StatefulWidget {
  SalesPage({Key key}) : super(key: key);

  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  Widget build(BuildContext context) {
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        // List<MobileFunction> functions = UserProvide.salesFunctions;
        List<Map<String, dynamic>> groupFunctions =
            UserProvide.salesGroupFunctions;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            title: Text('销售'),
          ),
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8.0),
              /*
              child: FunctionList(
                functions: functions,
                isSubPage: true,
                callFunction: callFunction,
              ),
              */
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Map<String, dynamic> item = groupFunctions[index];

                  return GroupFunctionList(
                    title: item['name'],
                    physics: NeverScrollableScrollPhysics(),
                    functions: item['functions'],
                    childAspectRatio: 1,
                    callFunction: callFunction,
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 8.0,
                    thickness: 8.0,
                    color: backgroundColor,
                  );
                },
                itemCount: groupFunctions.length,
              ),
            ),
          ),
        );
      },
    );
  }
}
