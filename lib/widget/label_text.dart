import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';

class LabelText extends StatelessWidget {
  final String label;
  final double fontSize;
  final TextAlign textAlign;
  final Color color;
  final TextOverflow overflow;
  const LabelText(this.label,
      {Key key, this.fontSize, this.textAlign, this.color, this.overflow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: textAlign,
      overflow: overflow,
      style: TextStyle(
        color: color ?? defaultFontColor,
        fontSize: fontSize,
      ),
    );
  }
}
