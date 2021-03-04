import 'package:flutter/material.dart';

class CustomOutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Function onPressed;
  const CustomOutlineButton({Key key, this.label, this.icon, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return OutlineButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
      ),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
}
