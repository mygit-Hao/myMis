import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/box_container.dart';

class DateTimeView extends StatelessWidget {
  final DateTime value;
  final Function onDateTap;
  final Function onTimeTap;
  const DateTimeView(
      {Key key, @required this.value, this.onDateTap, this.onTimeTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = TextStyle(color: defaultFontColor);

    return BoxContainer(
      child: Row(
        children: <Widget>[
          InkWell(
            onTap: onDateTap,
            child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              child: Row(
                children: <Widget>[
                  Text(
                    Utils.dateTimeToStr(value, pattern: formatPatternDate),
                    style: textStyle,
                  ),
                  Icon(
                    // Icons.calendar_today,
                    ConstValues.icon_calendar,
                    color: Theme.of(context).primaryColor,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.0),
          InkWell(
            onTap: onTimeTap,
            child: Container(
              padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 4.0),
              child: Row(
                children: <Widget>[
                  Text(
                    Utils.dateTimeToStr(value, pattern: formatPatternShortTime),
                    style: textStyle,
                  ),
                  Icon(
                    Icons.access_time,
                    color: Theme.of(context).primaryColor,
                    size: 20.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
