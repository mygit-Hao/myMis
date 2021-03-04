import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/utils/utils.dart';

class DateView extends StatelessWidget {
  final DateTime value;
  final TextAlign textAlign;
  final double fontSize;
  final Function onTap;
  const DateView(
      {Key key,
      this.value,
      this.textAlign = TextAlign.center,
      this.onTap,
      this.fontSize = fontSizeDefault})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 2.0),
          padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  Utils.dateTimeToStr(value),
                  textAlign: textAlign,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: fontSize,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 20.0,
              ),
            ],
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
