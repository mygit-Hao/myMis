import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/login_info.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/circle_icon_button.dart';
import 'package:mis_app/widget/large_button.dart';
import 'package:provide/provide.dart';

class UserLogin extends StatefulWidget {
  final bool isPage;
  final String redirectPath;
  UserLogin({Key key, this.isPage = false, this.redirectPath})
      : super(key: key);

  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextEditingController _unameController = new TextEditingController();
  TextEditingController _pwdController = new TextEditingController();
  bool pwdShow = false;
  GlobalKey _formKey = new GlobalKey<FormState>();
  bool _nameAutoFocus = true;
  String _currentUsername = '';
  // FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    /*
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('request focus');
      FocusScope.of(context).requestFocus(_focusNode);
    });
    */

    _unameController.text = Prefs.lastLoginUser;
    if (!Utils.textIsEmpty(_unameController.text)) {
      _nameAutoFocus = false;
    }
    _unameController.addListener(() {
      setState(() {
        _currentUsername = _unameController.text;
      });
    });
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (_nameAutoFocus) {
  //     FocusScope.of(context).requestFocus(_focusNode);
  //   }
  // }

  @override
  void dispose() {
    // _focusNode.dispose();
    _unameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Form(
          key: _formKey,
          // autovalidate: false,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            children: <Widget>[
              _userNameField,
              _passwordField,
              SizedBox(
                height: 25.0,
              ),
              LargeButton(
                title: '登录',
                onPressed: () {
                  _onLogin(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _userNameField {
    return TextFormField(
      controller: _unameController,
      // focusNode: _nameAutoFocus ? _focusNode : null,
      // focusNode: _focusNode,
      autofocus: _nameAutoFocus,
      // autofocus: true,
      decoration: InputDecoration(
        labelText: "用户名",
        hintText: "请输入用户名",
        prefixIcon: Icon(Icons.person),
        suffixIcon: Utils.textIsEmpty(_currentUsername)
            ? null
            : CircleIconButton(
                onPressed: () {
                  this.setState(() {
                    _unameController.clear(); //Clear value
                  });
                },
              ),
      ),
      // 校验用户名（不能为空）
      validator: (v) {
        return v.trim().isNotEmpty ? null : "请输入用户名";
      },
    );
  }

  Widget get _passwordField {
    return TextFormField(
      controller: _pwdController,
      autofocus: !_nameAutoFocus,
      // focusNode: _nameAutoFocus ? null : _focusNode,
      decoration: InputDecoration(
        labelText: "密码",
        hintText: "请输入密码",
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(pwdShow ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              pwdShow = !pwdShow;
            });
          },
        ),
      ),
      obscureText: !pwdShow,
      //校验密码（不能为空）
      validator: (v) {
        return v.trim().isNotEmpty ? null : '请输入密码';
      },
    );
  }

  void _onLogin(BuildContext context) async {
    // 先验证各个表单字段是否合法
    if ((_formKey.currentState as FormState).validate()) {
      String userName = _unameController.text;
      String password = _pwdController.text;

      /*
      if (!await checkNetworkAvailable()) {
        return;
      }
      */

      LoginInfo info = await UserService.login(userName, password);
      if (info.success) {
        Provide.value<UserProvide>(context).updateUserInfo(info, password);
        await Prefs.saveLastLogin(
            UserProvide.currentUser, password, LoginStatus.onLine);
        if (this.widget.isPage) {
          // Navigator.pop(context);
          // if (this.widget.redirectPath != null) {
          //   Navigator.pushNamed(context, this.widget.redirectPath);
          // }

          if (Utils.textIsEmpty(this.widget.redirectPath)) {
            Navigator.pop(context);
          } else {
            Navigator.pushReplacementNamed(context, this.widget.redirectPath);
          }
        }
      } else {
        if (!Utils.textIsEmpty(info.info)) {
          DialogUtils.showToast(info.info);
        } else {
          DialogUtils.showToast('登录时出现错误');
        }
      }
    }
  }
}
