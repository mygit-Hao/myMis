import 'package:flutter/material.dart';

class DismissibleBackground extends StatelessWidget {
  final String title;
  final Icon icon;
  final Color color;
  final MainAxisAlignment alignment;
  const DismissibleBackground(
      {Key key,
      this.title,
      this.icon,
      this.color,
      this.alignment = MainAxisAlignment.end})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: alignment,
          children: <Widget>[
            if (icon != null) icon,
            Text(
              title,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
