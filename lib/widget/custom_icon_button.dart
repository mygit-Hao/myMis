import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Icon icon;
  final Widget child;
  final AlignmentGeometry iconAlign;
  final Function onPressed;

  const CustomIconButton(
      {Key key,
      this.icon,
      this.child,
      this.iconAlign = Alignment.centerLeft,
      this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children = List();

    if ((iconAlign == Alignment.centerRight) ||
        (iconAlign == Alignment.bottomCenter)) {
      if (child != null) children.add(child);
      children.add(icon);
    } else {
      children.add(icon);
      if (child != null) children.add(child);
    }

    return OutlineButton(
      onPressed: onPressed,
      child: ((iconAlign == Alignment.centerLeft) ||
              (iconAlign == Alignment.centerRight))
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: children,
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }
}
