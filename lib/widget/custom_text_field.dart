import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final int minLines;
  final int maxLines;
  final String hintText;
  final bool showBorder;
  final TextInputType keyboardType;
  final bool enabled;
  final TextStyle style;
  final TextAlign textAlign;
  final List<TextInputFormatter> inputFormatters;
  final bool isDense;
  final Function(String) onChanged;
  CustomTextField(
      {Key key,
      this.minLines,
      this.maxLines = 1,
      this.hintText,
      this.showBorder = false,
      this.keyboardType,
      this.enabled,
      this.style,
      this.textAlign = TextAlign.start,
      this.inputFormatters,
      this.isDense = false,
      this.onChanged})
      : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String _inputText = "";
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: widget.textAlign,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      enabled: widget.enabled,
      style: widget.style,
      inputFormatters: widget.inputFormatters,
      onChanged: (String value) {
        _updateText(value);
      },
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        filled: true,
        suffixIcon: clearIcon(),
        border: widget.showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              )
            : null,
        isDense: widget.isDense,
        hintText: widget.hintText,
        enabledBorder: widget.showBorder
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              )
            : null,
      ),
    );
  }

  void _updateText(String value) {
    setState(() {
      _inputText = value;
    });
    if (widget.onChanged != null) {
      widget.onChanged(value);
    }
  }

  Widget clearIcon() {
    if (_inputText.length <= 0) return null;

    return IconButton(
      icon: Icon(
        Icons.clear,
        color: Colors.red,
      ),
      splashColor: Colors.redAccent,
      onPressed: () {
        _controller.clear();
        _updateText(_controller.text);
      },
    );
  }
}
