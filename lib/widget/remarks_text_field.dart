import 'package:flutter/material.dart';

class RemarksTextField extends StatelessWidget {
  final TextEditingController controller;
  final int minLines;
  final int maxLines;
  final String hintText;
  final bool autofocus;
  final FocusNode focusNode;
  const RemarksTextField(
      {Key key,
      this.controller,
      this.minLines = 1,
      this.maxLines = 2,
      this.hintText,
      this.autofocus = false,
      this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autofocus,
      controller: controller,
      focusNode: focusNode,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        isDense: true,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
