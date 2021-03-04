import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/pages/sales/widget/sample_delivery_detail_qty_widget.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/critical_button.dart';

class SampleDeliveryDetailWidget extends StatelessWidget {
  final SampleDeliveryDetailModel item;
  final int sampleDeliveryStatus;
  final Function(String) onQtyChanged;
  final Function(SampleDeliveryDetailModel) onHandleButtonPressed;

  const SampleDeliveryDetailWidget(
      {Key key,
      @required this.item,
      this.sampleDeliveryStatus,
      this.onQtyChanged,
      this.onHandleButtonPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle descStyle =
        TextStyle(color: defaultFontColor, fontSize: fontSizeSmall);

    bool showStatus = sampleDeliveryStatus >= SampleDeliveryModel.statusSubmit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sampleItemWidget(context),
        if (!Utils.textIsEmptyOrWhiteSpace(item.otdesc2))
          Text(item.otdesc2, style: descStyle),
        if (!Utils.textIsEmptyOrWhiteSpace(item.otdesc3))
          Text(item.otdesc3, style: descStyle),
        if (!Utils.textIsEmptyOrWhiteSpace(item.otdesc4))
          Text(
            item.otdesc4,
            style: TextStyle(color: Color(0xffff9900), fontSize: fontSizeSmall),
          ),
        if (!Utils.textIsEmptyOrWhiteSpace(item.operationTech))
          Text(item.operationTech, style: descStyle),
        if (!Utils.textIsEmptyOrWhiteSpace(item.specialReq))
          Text(item.specialReq, style: descStyle),
        if (!Utils.textIsEmptyOrWhiteSpace(item.predictDemand))
          Text(item.predictDemand, style: descStyle),
        if (showStatus && (!Utils.textIsEmptyOrWhiteSpace(item.preStatusDesc)))
          Text(
            item.preStatusDesc,
            style: TextStyle(color: Colors.red, fontSize: fontSizeSmall),
          ),
        if (showStatus && (!Utils.textIsEmptyOrWhiteSpace(item.statusDesc)))
          Text(
            item.statusDesc,
            style: TextStyle(color: Colors.blueAccent, fontSize: fontSizeSmall),
          ),
        if (showStatus && item.canHandle)
          ButtonBar(
            children: <Widget>[
              CriticalButton(
                title: item.isConfirming ? '回复' : '反馈',
                onPressed: () {
                  if (onHandleButtonPressed != null) {
                    onHandleButtonPressed(item);
                  }
                },
              ),
              // CriticalButton(
              //   title: '确认',
              //   onPressed: () {},
              // ),
            ],
          ),
      ],
    );
  }

  Widget _sampleItemWidget(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    return Row(
      children: <Widget>[
        Text(
          '[${item.seqNo}]',
          style: TextStyle(color: defaultFontColor),
        ),
        SizedBox(width: 4.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(item.itemDesc),
                  Text(
                    '(${item.ot1})',
                    style: TextStyle(color: defaultFontColor),
                  ),
                ],
              ),
              Text(
                item.otdesc1,
                style: TextStyle(color: defaultFontColor),
              ),
            ],
          ),
        ),
        if (item.custProvideSample)
          Icon(
            Icons.person,
            color: primaryColor,
          ),
        if (item.custProvideSample)
          Text(
            '供样',
            style: TextStyle(color: primaryColor),
          ),
        // _qtyWidget(item),
        SampleDeliveryDetailQtyWidget(
          item: item,
          sampleDeliveryStatus: sampleDeliveryStatus,
          onChanged: onQtyChanged,
        ),
      ],
    );
  }
}
