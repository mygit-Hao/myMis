import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/large_button.dart';
import 'package:mis_app/widget/loading_indicator.dart';

abstract class BaseSearchDelegate extends SearchDelegate<String> {
  List<String> _recentList;
  List<dynamic> dataList;
  static const int _maxHistoryCount = 20;

  final String historyKey;
  final bool showDivider;

  BaseSearchDelegate(this.historyKey, {this.showDivider = true});

  Widget itemWidget(BuildContext context, dynamic item);
  Future<void> getDataList(String keyword);

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
      future: getDataList(query).then((onValue) {
        _updateHistory(query);
      }),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
            return new Text('');

          case ConnectionState.waiting:
            return LoadingIndicator();

          case ConnectionState.done:
            return Container(
              child: showDivider
                  ? ListView.separated(
                      itemCount: dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        dynamic item = dataList[index];

                        return itemWidget(context, item);
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider();
                      },
                    )
                  : ListView.builder(
                      itemCount: dataList.length,
                      itemBuilder: (BuildContext context, int index) {
                        dynamic item = dataList[index];

                        return itemWidget(context, item);
                      },
                    ),
            );
        }

        return Text('加载中........');
      },
    );
  }

  // 输入时的推荐及搜索结果
  @override
  Widget buildSuggestions(BuildContext context) {
    _recentList = Prefs.getSelectHistory(historyKey) ?? [];
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
            SizedBox(
              height: 25.0,
            ),
            LargeButton(
              title: '清除',
              height: 40.0,
              onPressed: () {
                _recentList = [];
                Prefs.saveSelectHistory(historyKey, _recentList);
                query = '';
                this.showSuggestions(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 选择的数据以Json格式返回，并关闭页面
  void returnDataAndClose(BuildContext context, dynamic item) {
    String dataStr = json.encode(item.toJson());
    close(context, dataStr);
  }

  void _updateHistory(String searchText) {
    // print('Update History: $searchText');

    /*
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
    */
    List<String> list = Utils.updateHistoryList(_recentList, searchText,
        maxHistoryCount: _maxHistoryCount);

    Prefs.saveSelectHistory(historyKey, list);
  }
}
