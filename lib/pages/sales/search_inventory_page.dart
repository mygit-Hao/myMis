import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/inventory.dart';
import 'package:mis_app/model/item_category.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/search_text_field.dart';
import 'package:mis_app/widget/sticky_header_container.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SearchInventoryPage extends StatefulWidget {
  SearchInventoryPage({Key key}) : super(key: key);

  @override
  _SearchInventoryPageState createState() => _SearchInventoryPageState();
}

class _SearchInventoryPageState extends State<SearchInventoryPage> {
  List<String> _suggestList = [];
  String _searchKeyword;
  ItemCategoryModel _selectedCategory;
  bool _selectedRecent = false;
  List<ItemCategoryModel> _itemCategoryList;
  final ItemCategoryModel _nullItemCategory =
      ItemCategoryModel(categoryCode: '0', categoryName: '(请选择类别)');
  // List<InventoryModel> _inventoryList = [];
  ProgressDialog _progressDialog;
  List<InventoryModel> _recentList = [];
  List<InventoryModel> _notRecentList = [];
  List<Map<String, dynamic>> _viewList = [];

  @override
  void initState() {
    super.initState();

    _itemCategoryList = List()..add(_nullItemCategory);
    _initData();
  }

  void _initData() async {
    _suggestList = Prefs.getSelectHistory(Prefs.keyHistorySearchInventory);

    List<ItemCategoryModel> list = await DataCache.getItemCategoryList();
    setState(() {
      _itemCategoryList = list;
    });
  }

  void _buildViewList(List<InventoryModel> list) {
    _viewList.clear();
    _recentList.clear();
    _notRecentList.clear();

    for (InventoryModel item in list) {
      if (item.recentUsed) {
        _recentList.add(item);
      } else {
        _notRecentList.add(item);
      }
    }

    if (_recentList.length > 0) {
      _viewList.add({'name': '最近有开单', 'data': _recentList});
    }

    if (_notRecentList.length > 0) {
      _viewList.add({'name': '最近未开单', 'data': _notRecentList});
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('库存查询'),
      ),
      body: SafeArea(
        child: _mainWidget,
      ),
    );
  }

  Widget get _mainWidget {
    return Container(
      // padding: EdgeInsets.all(6.0),
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            color: backgroundColor,
            child: _searchWidget,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
              child: _inventoryListWidget,
            ),
          ),
        ],
      ),
    );
  }

  Widget get _inventoryListWidget {
    /*
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        InventoryModel item = _inventoryList[index];
        return _getInventoryItemWidget(item);
      },
      itemCount: _inventoryList.length,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
    */
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return StickyHeader(
          header: StickyHeaderContainer(
              title:
                  '${_viewList[index]["name"]} (${_viewList[index]["data"].length})'),
          content: Column(
            children: _buildGroup(_viewList[index]['data']),
          ),
        );
      },
      itemCount: _viewList.length,
    );
  }

  List<Widget> _buildGroup(List<InventoryModel> list) {
    return list.map((item) {
      return _getInventoryItemWidget(item, item == list[list.length - 1]);
    }).toList();
  }

  Widget _getInventoryItemWidget(InventoryModel item, bool isLast) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  item.itemCode,
                  style: TextStyle(
                    color: defaultFontColor,
                  ),
                ),
              ),
              Text(
                '${item.rule}/${item.uomCode}',
                style: TextStyle(
                  color: defaultFontColor,
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(child: Text(item.itemName)),
              Text(
                '${Utils.getQtyStr(item.qty)}',
                style: TextStyle(
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (!Utils.textIsEmptyOrWhiteSpace(item.itemRemarks))
            Text(
              item.itemRemarks,
              style: TextStyle(
                color: defaultFontColor,
                fontSize: fontSizeSmall,
              ),
            ),
          if (isLast)
            SizedBox(
              height: 8.0,
            )
          else
            Divider(),
        ],
      ),
    );
  }

  Widget get _searchWidget {
    return Column(
      children: <Widget>[
        SearchTextField(
          suggestList: _suggestList,
          hintText: '请输入名称，规格',
          style: TextStyle(fontSize: fontSizeDefault),
          onTextChanged: (value) {
            setState(() {
              _searchKeyword = value;
            });
          },
          onSearch: () {
            _suggestList = Utils.updateHistoryList(_suggestList, _searchKeyword,
                maxHistoryCount: 20);
            Prefs.saveSelectHistory(
                Prefs.keyHistorySearchInventory, _suggestList);
            _searchInventory();
            Utils.closeInput(context);
          },
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: DropdownButton<ItemCategoryModel>(
                value: _selectedCategory,
                items: _itemCategoryList.map((ItemCategoryModel item) {
                  return DropdownMenuItem(
                    child: Text(item.categoryName),
                    value: item,
                  );
                }).toList(),
                isExpanded: true,
                onChanged: (ItemCategoryModel value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            Checkbox(
              value: _selectedRecent,
              onChanged: (bool value) {
                setState(() {
                  _selectedRecent = value;
                });
              },
            ),
            Text('最近开过单'),
          ],
        ),
      ],
    );
  }

  void _searchInventory() async {
    String category =
        _selectedCategory == null ? '' : _selectedCategory.categoryName;

    await _progressDialog?.show();
    try {
      List<InventoryModel> list = await SalesService.getInventory(
          _searchKeyword, category, _selectedRecent);
      _buildViewList(list);

      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }
}
