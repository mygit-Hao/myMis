import 'package:flutter/material.dart';

class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Function onPressed;
  const CircularIconButton(
      {Key key, this.icon, this.color, this.backgroundColor, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ClipOval(
        child: Container(
          color: backgroundColor,
          padding: EdgeInsets.all(6.0),
          child: Icon(
            icon,
            color: color,
          ),
        ),
      ),
      onTap: onPressed,
    );
  }
}
