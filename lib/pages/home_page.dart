import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/pages/common/base_inner_page.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/widget/function_list.dart';
import 'package:provide/provide.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*
    String status = Global.loginStatus == LoginStatus.onLine ? "在线" : "离线";
    return BaseInnerPage(
      title: '首页',
      child: Center(
        child: Text('$status 首页'),
      ),
    );
    */
    // return Provide<UserProvide>(
    //   builder: (BuildContext context, Widget child, UserProvide value) {
    //     String status =
    //         LoginStatusProvide.loginStatus == LoginStatus.onLine ? "在线" : "离线";
    //     return BaseInnerPage(
    //       title: '首页',
    //       child: Center(
    //         child: Text('$status 首页'),
    //       ),
    //     );
    //   },
    // );

    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        List<MobileFunction> functions = UserProvide.homeFunctions;
        // print('functions: $functions');

        return BaseInnerPage(
          title: '首页',
          child: Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(8.0),
            child: FunctionList(
              functions: functions,
              callFunction: callFunction,
            ),
          ),
        );
      },
    );
  }
}
