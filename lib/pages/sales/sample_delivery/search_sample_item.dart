import 'package:flutter/material.dart';
import 'package:mis_app/model/sample_item.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/widget/base_search.dart';

class SearchSampleItemDelegate extends BaseSearchDelegate {
  SearchSampleItemDelegate(String historyKey) : super(historyKey);

  @override
  Future<void> getDataList(String keyword) async {
    dataList = await SalesService.getSampleItem(keyword);
  }

  @override
  Widget itemWidget(BuildContext context, dynamic item) {
    SampleItemModel sampleItem = item;

    return ListTile(
      title: Text(sampleItem.itemName),
      onTap: () {
        returnDataAndClose(context, item);
      },
    );
  }
}
