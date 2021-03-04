import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/large_button.dart';

class ChangePasswordPage extends StatefulWidget {
  ChangePasswordPage({Key key}) : super(key: key);

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  static const double _titleWidth = 160.0;
  static const int _passwordLenLimited = 6;

  TextEditingController _oldPasswordController = TextEditingController();
  TextEditingController _newPasswordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String displayName = UserProvide.displayUserName;

    return Scaffold(
      appBar: AppBar(
        title: Text('更改密码'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // padding: const EdgeInsets.symmetric(horizontal: 10.0),
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                _userInfoWidget(displayName),
                _passwordItem('原密码', '填写原密码',
                    controller: _oldPasswordController, autofocus: true),
                _passwordItem('新密码', '填写新密码',
                    controller: _newPasswordController),
                _passwordItem('确认密码', '再次填写密码',
                    controller: _confirmPasswordController),
                Container(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    '密码建议使用8-16位的数字、字符组合',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                SizedBox(
                  height: 25.0,
                ),
                _finishBtn,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _userInfoWidget(String userFullname) {
    return Row(
      children: <Widget>[
        Container(
          child: Text('当前用户：'),
          width: ScreenUtil().setWidth(_titleWidth),
        ),
        Text(
          userFullname,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget get _finishBtn {
    return LargeButton(
      title: '完成',
      onPressed: _onFinish,
    );
  }

  void _onFinish() async {
    String oldPassword = _oldPasswordController.text;
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (Utils.textIsEmptyOrWhiteSpace(newPassword) ||
        (newPassword.length < _passwordLenLimited)) {
      DialogUtils.showToast('密码长度不能少于$_passwordLenLimited位');
      return;
    }

    if (newPassword != confirmPassword) {
      DialogUtils.showToast('确定密码与新密码不一致');
      return;
    }

    _changePassword(oldPassword, newPassword);
  }

  void _changePassword(String oldPassword, String newPassword) async {
    /*
    if (!await checkNetworkAvailable()) {
      return;
    }
    */

    RequestResult result =
        await UserService.changePassword(oldPassword, newPassword);
    if (!result.success) {
      DialogUtils.showToast(result.msg);
    } else {
      DialogUtils.showToast('密码已更改');
      Prefs.updatePassword(newPassword);
      Navigator.pop(context);
    }
  }

  Widget _passwordItem(String label, String hintText,
      {TextEditingController controller, autofocus = false}) {
    return Row(
      children: <Widget>[
        Container(
          width: ScreenUtil().setWidth(_titleWidth),
          child: Text(label),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: hintText,
            ),
            controller: controller,
            obscureText: true,
            autofocus: autofocus,
          ),
        ),
      ],
    );
  }
}
