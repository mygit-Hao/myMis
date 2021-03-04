import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/pages/common/base_inner_page.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/widget/function_list.dart';
import 'package:provide/provide.dart';

class LifePage extends StatelessWidget {
  const LifePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        List<MobileFunction> functions = UserProvide.lifeFunctions;

        return BaseInnerPage(
          title: '生活',
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
