import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DenseTextField extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final String hintText;
  final bool showBorder;
  final TextInputType keyboardType;
  final bool enabled;
  final TextStyle style;
  final TextAlign textAlign;
  final List<TextInputFormatter> inputFormatters;

  const DenseTextField(
      {Key key,
      this.controller,
      this.minLines,
      this.maxLines,
      this.hintText,
      this.showBorder = false,
      this.keyboardType,
      this.enabled,
      this.style,
      this.textAlign = TextAlign.start,
      this.inputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: textAlign,
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: enabled,
      style: style,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        border: showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              )
            : null,
        isDense: true,
        hintText: hintText,
        enabledBorder: showBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              )
            : null,
      ),
    );
  }
}
