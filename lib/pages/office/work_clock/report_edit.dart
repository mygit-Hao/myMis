import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/visit_customer_category.dart';
import 'package:mis_app/pages/office/work_clock/work_clock.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';

class ReportEditPage extends StatefulWidget {
  final Map arguments;
  ReportEditPage({Key key, this.arguments}) : super(key: key);

  @override
  _ReportEditPageState createState() => _ReportEditPageState();
}

class _ReportEditPageState extends State<ReportEditPage> {
  int _categoryId = 1;
  bool _isManualInput = false;
  // bool _hasSelect = false;
  String _descript = '';
  List<Category> _categoryList = [];
  List<Items> _allItemsList = [];
  List _reportList = [];
  String _selectStr = '';
  List<String> _selectList = [];

  Map<int, List<Items>> _categoryItems = {};

  TextEditingController _textEditingController = new TextEditingController();

  bool _isgetCache = true;
  @override
  void initState() {
    super.initState();
    if (this.widget.arguments != null) {
      _isgetCache = this.widget.arguments['isGetCache'];
      var reportContent = this.widget.arguments['reportData'];
      _reportList = reportContent == '' ? [] : jsonDecode(reportContent);
    } else {
      _reportList = Prefs.getVisitReportList(Prefs.keyVisitReportList) ?? [];
    }
    _getCategoryData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('编辑报告')),
      body: Container(
          child: Column(
        children: <Widget>[
          Expanded(
            // height: ScreenUtil().setHeight(1000),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _visitCategory(),
                  _visititems(),
                ]),
          ),
          _buttons(),
        ],
      )),
    );
  }

  ///大类列表
  Widget _visitCategory() {
    return Container(
      color: Colors.grey[200],
      height: ScreenUtil().setHeight(1000),
      width: 134,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _categoryList.length,
          itemBuilder: (context, index) {
            var isClick = false;
            var categoryId = _categoryList[index].categoryId;
            isClick = (categoryId == _categoryId) ? true : false;
            var hasSelect = _categoryList[index].hasSelect;
            return InkWell(
              onTap: () {
                setState(() {
                  _descript = _categoryList[index].description;
                  _isManualInput = _categoryList[index].manualInput;
                  _categoryId = categoryId;
                  _textEditingController.text = '';
                });
              },
              child: Container(
                  color: isClick ? Colors.white : Colors.grey[200],
                  padding: EdgeInsets.symmetric(vertical: 17, horizontal: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Offstage(
                          offstage: hasSelect ? false : true,
                          child:
                              Icon(Icons.done, size: 16, color: Colors.blue)),
                      Text(
                        '${_categoryList[index].name}',
                        style: TextStyle(
                            color: isClick ? Colors.blue : Colors.black,
                            fontSize: 14),
                      ),
                      Offstage(
                          offstage: isClick ? false : true,
                          child: Icon(Icons.chevron_right,
                              size: 22, color: Colors.blue)),
                    ],
                  )),
            );
          }),
    );
  }

  ///小类item列表
  Widget _visititems() {
    return Expanded(
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: (_categoryItems[_categoryId] == null)
              ? 0
              : _categoryItems[_categoryId].length,
          itemBuilder: (context, index) {
            var item = _categoryItems[_categoryId][index];
            _textEditingController.text =
                _categoryItems[_categoryId][index].inputData;
            return _isManualInput
                ? _inputText(index)
                : _checkBoxTile(index, item);
          }),
    );
  }

  ///需要自己填写的item
  Widget _inputText(int index) {
    return TextField(
      maxLines: 40,
      style: TextStyle(fontSize: 15),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(borderSide: BorderSide.none),
        hintText: _descript,
      ),
      controller: _textEditingController,
      onChanged: (value) {
        _categoryItems[_categoryId][index].inputData = value;
        if (value != null && value != "") {
          _categoryItems[_categoryId][index].isCheck = true;
        } else {
          _categoryItems[_categoryId][index].isCheck = false;
        }

        ///判断是否选择
        var categoryIndex = _getCategoryIndex(_categoryId);
        bool hasSelect = _isSelect(_categoryId);
        _categoryList[categoryIndex].hasSelect = hasSelect;
      },
    );
  }

  ///选择控件item
  Widget _checkBoxTile(int index, item) {
    return CheckboxListTile(
      value: _categoryItems[_categoryId][index].isCheck,
      onChanged: (isCheck) {
        setState(() {
          _categoryItems[_categoryId][index].isCheck = isCheck;

          ///判断是否选择
          var categoryIndex = _getCategoryIndex(_categoryId);
          bool hasSelect = _isSelect(_categoryId);
          _categoryList[categoryIndex].hasSelect = hasSelect;
        });
      },
      title: Text(
        item.itemName,
        style: TextStyle(fontSize: 15),
      ),
      selected: _categoryItems[_categoryId][index].isCheck,
      //选择控件放的位置
      controlAffinity: ListTileControlAffinity.platform,
    );
  }

  Widget _buttons() {
    return Container(
      child: Row(
        children: <Widget>[
          // Expanded(
          //     child: Container(
          //   padding: EdgeInsets.all(10),
          //   child: FlatButton(
          //     color: Colors.red,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(5)),
          //     onPressed: () {
          //       Navigator.pop(context);
          //     },
          //     child: Text(
          //       '取消',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // )),
          // Expanded(
          //     child: Container(
          //   padding: EdgeInsets.all(10),
          //   child: FlatButton(
          //     color: Colors.blue,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(5)),
          //     onPressed: () {
          //       _formatSeparateItemData();
          //       if (_isgetCache) {
          //         Prefs.saveVisitReportList(
          //             Prefs.keyVisitReportList, _selectList);
          //         Prefs.saveVisitReportStr(Prefs.keyVIsitReportStr, _selectStr);
          //         Navigator.pop(context);
          //       } else {
          //         _updateReport();
          //       }
          //     },
          //     child: Text(
          //       '确认',
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // ))
          customButtom(Colors.blue, '确定', () {
            _formatSeparateItemData();
            if (_isgetCache) {
              Prefs.saveVisitReportList(Prefs.keyVisitReportList, _selectList);
              Prefs.saveVisitReportStr(Prefs.keyVIsitReportStr, _selectStr);
              Navigator.pop(context);
            } else {
              _updateReport();
            }
          })
        ],
      ),
    );
  }

  void _getCategoryData() async {
    CustomerVisitCateModel visitCategoryModel =
        await WorkClockService.getVisitCategoryData();
    setState(() {
      _categoryList = visitCategoryModel.category;
      _allItemsList = visitCategoryModel.items;
      _getItemsList();
    });
  }

  ///获取所有类别的Items、初始化赋值
  void _getItemsList() {
    _categoryList.forEach((element) {
      var categoryId = element.categoryId;
      List<Items> list = [];
      _allItemsList.forEach((element) {
        if (categoryId == element.categoryId) {
          list.add(element);
        }
        _categoryItems[categoryId] = list;
      });
    });
    _getPrefsOrHistoryData();
  }

  ///将选择的所有item整理为两部分
  void _formatSeparateItemData() {
    int index = 0;
    String categoryName = '';
    String itemsName = '';
    bool isManualInput = false;
    _categoryItems.forEach((key, value) {
      SelectFormatData contentData = new SelectFormatData();
      contentData.categoryId = key;
      //获取itemsId和itemsName
      List itemsIdList = [];
      List itemsNameList = [];
      itemsName = '';
      value.forEach((element) {
        if (element.isCheck) {
          //获取类型名和是否可修改
          categoryName = _getCategoryName(key);
          isManualInput = _getItemEditable(key);
          //获取item信息添加到list
          var itemName = isManualInput ? element.inputData : element.itemName;
          itemsName += (itemsName == '') ? itemName : ('、' + itemName);
          itemsIdList.add(element.visitItemId);
          itemsNameList
              .add(isManualInput ? element.inputData : element.itemName);
        }
      });
      contentData.itemsIds = json.encode(itemsIdList);
      // contentData.items = json.encode(itemsNameList);
      contentData.items = json.encode(itemsNameList);
      //将数据添加到list
      if (itemsIdList.length > 0) {
        index++;
        String contentStr = json.encode(contentData.toJson());
        _selectList.add(contentStr);
        _selectStr += '  $index . $categoryName ：$itemsName \n';
      }
    });
  }

  String _getCategoryName(int categoryId) {
    String categoryName = '';
    _categoryList.forEach((element) {
      if (categoryId == element.categoryId) {
        categoryName = element.name;
        return;
      }
    });
    return categoryName;
  }

  bool _getItemEditable(int categoryId) {
    bool isManualInput;
    _categoryList.forEach((element) {
      if (categoryId == element.categoryId) {
        isManualInput = element.manualInput;
        return;
      }
    });
    return isManualInput;
  }

  ///获取缓存的数据或者历史记录并显示
  void _getPrefsOrHistoryData() {
    int categoryId = 1;
    List itemsIdList = [];
    List itemsNameList = [];
    _reportList.forEach((element) {
      var json = jsonDecode(element);
      SelectFormatData selectFormatData = SelectFormatData.fromJson(json);
      categoryId = selectFormatData.categoryId;
      itemsIdList = jsonDecode(selectFormatData.itemsIds);
      itemsNameList = jsonDecode(selectFormatData.items);
      _categoryItems[categoryId].forEach((v) {
        for (int i = 0; i < itemsIdList.length; i++) {
          if (itemsIdList[i] == v.visitItemId) {
            v.isCheck = true;
            v.inputData = itemsNameList[i];
            // _categoryList[i].hasSelect = true;
            int index = _getCategoryIndex(categoryId);
            _categoryList[index].hasSelect = true;
          }
        }
      });
    });
  }

  bool _isSelect(int categoryId) {
    bool hasSelect = false;
    _categoryItems[categoryId].forEach((element) {
      if (element.isCheck == true) {
        hasSelect = true;
      }
    });
    return hasSelect;
  }

  int _getCategoryIndex(int categoryId) {
    int index = 0;
    for (int i = 0; i < _categoryList.length; i++) {
      if (_categoryList[i].categoryId == categoryId) {
        index = i;
      }
    }
    return index;
  }

  void _updateReport() async {
    var contentData = jsonEncode(_selectList);
    await WorkClockService.updateVisitReport(
            ClockStaticData.clockId, _selectStr, contentData)
        .then((value) {
      if (value['ErrCode'] == 0) {
        toastBlackStyle('修改成功');
        Navigator.pop(context, 'update');
      } else {
        var errMsg = value['ErrMsg'];
        DialogUtils.showAlertDialog(context, errMsg);
      }
    });
  }
}
