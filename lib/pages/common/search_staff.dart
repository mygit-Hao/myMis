import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/service/hrms_service.dart';
import 'package:mis_app/widget/base_search.dart';

class SearchStaffDelegate extends BaseSearchDelegate {
  final int deptId;
  final bool canSearchAll;
  SearchStaffDelegate(String historyKey,
      {this.deptId, this.canSearchAll = false})
      : super(historyKey, showDivider: false);

  @override
  Future<void> getDataList(String keyword) async {
    dataList = await HrmsService.getStaffList(keyword,
        deptId: deptId, canSearchAll: canSearchAll);
  }

  @override
  Widget itemWidget(BuildContext context, dynamic item) {
    StaffModel staff = item;
    return Card(
      child: InkWell(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    staff.name,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: fontSizeDefault,
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    staff.code,
                    style: TextStyle(
                      fontSize: fontSizeDefault,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      staff.areaName,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    staff.deptName,
                    style: TextStyle(
                      fontSize: fontSizeDetail,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text('/'),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    staff.posi,
                    style: TextStyle(
                      fontSize: fontSizeDetail,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          // String staffStr = json.encode(item.toJson());
          // close(context, staffStr);
          returnDataAndClose(context, item);
        },
      ),
    );
  }
}

/*
class SearchStaffDelegate extends SearchDelegate<String> {
  List<String> _recentList;
  List<StaffModel> _staffList;
  static const int _maxHistoryCount = 20;

  @override
  String get searchFieldLabel => '请输入查询条件';

  // 搜索条右侧的按钮执行方法，我们在这里方法里放入一个clear图标。 当点击图片时，清空搜索的内容。
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          // 清空搜索内容
          query = "";
        },
      )
    ];
  }

  // 搜索栏左侧的图标和功能，点击时关闭整个搜索页面
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, "");
      },
    );
  }

  // 搜索到内容了
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: _getStaffList(query),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
            return new Text('');

          case ConnectionState.waiting:
            return LoadingIndicator();

          case ConnectionState.done:
            return Container(
              child: ListView.builder(
                itemCount: _staffList.length,
                itemBuilder: (BuildContext context, int index) {
                  StaffModel staff = _staffList[index];

                  return _itemWidget(context, staff);
                },
              ),
            );
        }

        return Text('加载中........');
      },
    );
  }

  Widget _itemWidget(BuildContext context, StaffModel staff) {
    return Card(
      child: InkWell(
        child: Container(
          // child: Text(staff.name),
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    staff.name,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: fontSizeDefault,
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    staff.code,
                    style: TextStyle(
                      fontSize: fontSizeDefault,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      staff.areaName,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Text(
                    staff.deptName,
                    style: TextStyle(
                      fontSize: fontSizeDetail,
                    ),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text('/'),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    staff.posi,
                    style: TextStyle(
                      fontSize: fontSizeDetail,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          String staffStr = json.encode(staff.toJson());
          close(context, staffStr);
        },
      ),
    );
  }

  Future<void> _getStaffList(String keyword) async {
    _staffList = await HrmsService.getStaffList(keyword);
    _updateHistory(keyword);
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    _recentList = Prefs.getSelectStaffHistory() ?? [];
    final suggestionList = _recentList;
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            ListView.builder(
              itemCount: suggestionList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                String suggestion = suggestionList[index];
                int matchLength = 0;
                if (suggestion.startsWith(query)) {
                  matchLength = min(query.length, suggestion.length);
                }

                // 创建一个富文本，匹配的内容特别显示
                return ListTile(
                  title: RichText(
                    text: TextSpan(
                      // text: suggestionList[index].substring(0, query.length),
                      text: suggestion.substring(0, matchLength),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: suggestion.substring(matchLength),
                            style: TextStyle(color: Colors.grey))
                      ],
                    ),
                  ),
                  onTap: () {
                    query = suggestionList[index];
                    // Scaffold.of(context).showSnackBar(SnackBar(content: Text(query)));
                  },
                );
              },
            ),
            LargeButton(
              title: '清除',
              height: 40.0,
              onPressed: () {
                _recentList = [];
                Prefs.saveSelectStaffHistory(_recentList);
                query = '';
                this.showSuggestions(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateHistory(String searchText) {
    // print('Update History: $searchText');

    if (Utils.textIsEmptyOrWhiteSpace(searchText)) {
      return;
    }

    if ((_recentList.length > 0) && (searchText == _recentList[0])) {
      return;
    }

    List<String> list = List();
    list.add(searchText);

    for (var i = 0; i < _recentList.length; i++) {
      if (searchText != _recentList[i]) {
        list.add(_recentList[i]);
        if (list.length >= _maxHistoryCount) {
          break;
        }
      }
    }

    Prefs.saveSelectStaffHistory(list);
  }
}
*/
