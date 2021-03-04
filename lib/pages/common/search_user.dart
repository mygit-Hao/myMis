import 'package:flutter/material.dart';
import 'package:mis_app/model/user.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/base_search.dart';

class SearchUserDelegate extends BaseSearchDelegate {
  SearchUserDelegate(String historyKey) : super(historyKey);

  @override
  Future<void> getDataList(String keyword) async {
    dataList = await UserService.search(keyword);
  }

  @override
  Widget itemWidget(BuildContext context, dynamic item) {
    UserModel user = item;

    return ListTile(
      leading: Icon(
        Icons.person,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(user.userChnName),
      subtitle: Text(Utils.toAutoCapitalize(user.userName)),
      onTap: () {
        returnDataAndClose(context, item);
      },
    );
  }
}
