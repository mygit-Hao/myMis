import 'package:flutter/material.dart';

class CriticalButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onPressed;
  const CriticalButton({Key key, this.title, this.onPressed, this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Colors.red;

    Widget child = Text(
      title,
      style: TextStyle(
        color: color,
      ),
    );
    BorderSide borderSide = BorderSide(
      color: Colors.red,
    );

    if (icon == null) {
      return OutlineButton(
        onPressed: onPressed,
        child: child,
        borderSide: borderSide,
      );
    } else {
      return OutlineButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
        ),
        label: child,
      );
    }
  }
}
