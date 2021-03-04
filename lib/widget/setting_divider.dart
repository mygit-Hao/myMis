import 'package:flutter/material.dart';

class SettingDivider extends StatelessWidget {
  const SettingDivider({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: Color(0xffeaeaea),
    //   height: 6,
    // );
    return Divider(
      thickness: 6.0,
      height: 6.0,
      color: Color(0xffeaeaea),
    );
  }
}
