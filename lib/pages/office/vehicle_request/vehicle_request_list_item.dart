import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/vehicle_request.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/label_text.dart';

class VehicleRequestListItem extends StatelessWidget {
  final VehicleRequestModel item;
  final int index;
  const VehicleRequestListItem({Key key, this.item, this.index = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double leadingWidth = ScreenUtil().setSp(55.0);

    return Container(
      padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _listItemRow1(item, leadingWidth),
          _listItemRow2(item, leadingWidth),
          Text(
            item.reason,
            style: TextStyle(
              fontSize: fontSizeDetail,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItemRow1(VehicleRequestModel item, double leadingWidth) {
    return Row(
      children: <Widget>[
        Container(
          width: leadingWidth,
          child: LabelText(
            // '[${item.seqNo}]',
            '[$index]',
          ),
        ),
        Text(item.deptName),
        Expanded(
            child: Text(
          item.requestName,
          textAlign: TextAlign.center,
        )),
        Text(
          item.statusName,
          style: TextStyle(
            color: item.scheduled ? Colors.blue : Colors.red,
            fontSize: fontSizeDetail,
          ),
        ),
      ],
    );
  }

  Widget _listItemRow2(VehicleRequestModel item, double leadingWidth) {
    return Row(
      children: <Widget>[
        SizedBox(width: leadingWidth),
        Expanded(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.flag,
                    color: Colors.green,
                    size: 16.0,
                  ),
                  Expanded(
                    child: Text(
                      item.origin,
                      style: TextStyle(
                        fontSize: fontSizeDetail,
                      ),
                    ),
                  ),
                  LabelText(
                    '${Utils.dateTimeToStrWithPattern(item.startTime, formatPatternDateTime)}',
                    fontSize: fontSizeDetail,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.flag,
                    color: Colors.red,
                    size: 16.0,
                  ),
                  Expanded(
                    child: Text(
                      item.destination,
                      style: TextStyle(
                        fontSize: fontSizeDetail,
                      ),
                    ),
                  ),
                  LabelText(
                    '${Utils.dateTimeToStrWithPattern(item.finishTime, formatPatternDateTime)}',
                    fontSize: fontSizeDetail,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setSp(190.0),
          child: LabelText(
            item.usingTime,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
