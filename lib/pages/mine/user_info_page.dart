import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:qr_flutter/qr_flutter.dart';

class UserInfoPage extends StatefulWidget {
  UserInfoPage({Key key}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户信息'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
            '${UserProvide.displayUserName}',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: Theme.of(context).textTheme.headline6.fontSize,
            ),
          ),
          QrImage(
            data: '${UserProvide.userQrCode}',
            version: QrVersions.auto,
            size: ScreenUtil().setWidth(450.0),
          ),
        ],
      ),
    );
  }
}
