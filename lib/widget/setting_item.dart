import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final Widget trailing;
  final Function onTap;

  const SettingItem(
      {Key key, this.leading, this.title, this.trailing, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      trailing: trailing ?? Icon(Icons.keyboard_arrow_right),
      onTap: onTap,
    );
  }
}
