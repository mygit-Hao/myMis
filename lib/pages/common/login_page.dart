import 'package:flutter/material.dart';
import 'package:mis_app/pages/common/user_login.dart';

const String REDIRECT_PATH = 'redirect_path';

class LoginPage extends StatefulWidget {
  final Map arguments;
  LoginPage({Key key, this.arguments}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    String redirectPath;
    if (this.widget.arguments != null) {
      redirectPath = this.widget.arguments[REDIRECT_PATH];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('用户登录'),
      ),
      body: SafeArea(
        child: UserLogin(
          isPage: true,
          redirectPath: redirectPath,
        ),
      ),
    );
  }
}
