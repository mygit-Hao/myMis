import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/notification.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/label_text.dart';

class NotificationItemWidget extends StatelessWidget {
  final NotificationModel item;
  final Function onTap;
  const NotificationItemWidget({Key key, @required this.item, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _dateWidget(context),
        InkWell(
          onTap: onTap,
          child: _contentWidget(context),
        ),
      ],
    );
  }

  Widget _dateWidget(BuildContext context) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LabelText(
        Utils.dateTimeToStr(
          item.createDate,
          pattern: formatPatternDateTime,
        ),
        color: Colors.white,
        fontSize: defaultFontSize - 2.0,
      ),
    );
  }

  Widget _contentWidget(BuildContext context) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return Container(
      padding: EdgeInsets.all(8.0),
      color: Colors.white,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (item.isNew)
                Icon(
                  Icons.lens,
                  color: Colors.red,
                  size: 6.0,
                ),
              Text(
                item.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: defaultFontSize + 2,
                  fontWeight: item.isNew ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          if (!Utils.textIsEmptyOrWhiteSpace(item.content))
            LabelText(item.content),
          SizedBox(height: 12.0),
          Divider(),
          _navigatorWidget(context),
        ],
      ),
    );
  }

  Widget _navigatorWidget(BuildContext context) {
    double defaultFontSize = Theme.of(context).textTheme.bodyText1.fontSize;

    return item.canOpen
        ? Row(
            children: [
              Text(
                '查看详情',
                style: TextStyle(fontSize: defaultFontSize - 2),
              ),
              Icon(
                Icons.keyboard_arrow_right,
                color: defaultFontColor,
                size: 20.0,
              ),
            ],
          )
        : Container();
  }
}
