import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/pages/common/user_login.dart';
import 'package:mis_app/provide/login_status_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:provide/provide.dart';

class BaseInnerPage extends StatelessWidget {
  final String title;
  final Widget child;

  const BaseInnerPage({this.title, @required this.child});

  @override
  Widget build(BuildContext context) {
    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        /*
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
          ),
          // body: SafeArea(child: _getBody(Global.logined)),
          body: SafeArea(child: _getBody(LoginStatusProvide.loginStatus)),
        );
        */
        return SafeArea(child: _getBody(LoginStatusProvide.loginStatus));
      },
    );
  }

  Widget _getBody(LoginStatus status) {
    if (status == LoginStatus.logout) {
      return UserLogin();
    } else {
      return child;
    }
  }
}
