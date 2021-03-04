import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';

class SampleDeliveryDetailQtyWidget extends StatelessWidget {
  final SampleDeliveryDetailModel item;
  final int sampleDeliveryStatus;
  final Function(String) onChanged;
  const SampleDeliveryDetailQtyWidget(
      {Key key,
      @required this.item,
      this.sampleDeliveryStatus = SampleDeliveryModel.statusDraft,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool readonly = sampleDeliveryStatus >= SampleDeliveryModel.statusSubmit;

    return readonly
        ? Text(
            '  ${item.qtyDesc}',
            style: TextStyle(
              fontSize: fontSizeDetail,
              color: disabledFontColor,
            ),
          )
        : DropdownButton<String>(
            value: item.qtyDesc,
            items: SampleDeliveryDetailModel.qtyList.map((String qtyItem) {
              return DropdownMenuItem(
                child: Text(
                  qtyItem,
                  style: TextStyle(fontSize: fontSizeDetail),
                ),
                value: qtyItem,
              );
            }).toList(),
            onChanged: onChanged,
          );
  }
}
