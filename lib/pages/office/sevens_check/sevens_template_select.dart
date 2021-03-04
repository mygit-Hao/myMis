import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/sevens_basedb.dart';
import 'package:mis_app/utils/utils.dart';

class SevensTempletePage extends StatefulWidget {
  @override
  _SevensTempletePageState createState() => _SevensTempletePageState();
}

class _SevensTempletePageState extends State<SevensTempletePage> {
  bool _offStageCategory = false;
  bool _offStageDropDown = false;

  int _templateKindId;
  String _templateKindValue;

  List<Template> _templateList;
  List<TemplateKind> _templateKindList;
  List<DropdownMenuItem> _templateDrapDown = [];

  TextEditingController _keywordContr = TextEditingController();

  @override
  void initState() {
    super.initState();
    _templateList = SevensBaseDBModel.baseDBModel.templateList;
    _templateKindList = SevensBaseDBModel.baseDBModel.templateKindList;
    _templateKindId = _templateKindList[0].kindId;
    // _templateKindValue = _templateKindList[0].kindName;
    _getTemplateKindDropDown();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text("缺陷选择"),
          actions: <Widget>[
            Offstage(
              offstage: _offStageCategory,
              child: IconButton(
                  icon: Icon(Icons.clear_all),
                  onPressed: () {
                    setState(() {
                      _offStageCategory = true;
                      _offStageDropDown = false;
                      _templateList = _getTemplateListOfKind();
                      _keywordContr.clear();
                    });
                  }),
            ),
          ],
        ),
        body: SafeArea(
            child: Container(
          padding: EdgeInsets.only(left: 8, right: 8),
          child: Column(
            children: <Widget>[
              _searchViewCustom(),
              _tempSelect(),
              _templateListView(),
            ],
          ),
        )),
      ),
    );
  }

  //顶部搜索
  Widget _searchViewCustom() {
    return Container(
      color: Colors.white,
      height: ScreenUtil().setHeight(85),
      width: ScreenUtil().setWidth(750),
      padding: EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _keywordContr,
              autofocus: false,
              decoration: InputDecoration(
                filled: true,
                hintText: "关键字查询",
                contentPadding: EdgeInsets.only(left: 5),
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  setState(() {
                    _templateList = _keywordSearch(val);
                    _offStageCategory = false;
                    _offStageDropDown = true;
                  });
                });
              },
            ),
          ),
          Container(
              padding: EdgeInsets.only(left: 8),
              child: InkWell(
                  onTap: () {
                    setState(() {
                      _offStageCategory = false;
                      _offStageDropDown = true;
                      _templateList = _keywordSearch(_keywordContr.text);
                    });
                  },
                  child: Icon(
                    Icons.search,
                    color: Colors.blue,
                    size: 40,
                  ))),
        ],
      ),
    );
  }

  Widget _tempSelect() {
    return Offstage(
        offstage: _offStageDropDown,
        child: Row(
          children: <Widget>[
            Text("缺陷类别"),
            Expanded(
              child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: DropdownButton(
                      onTap: () {
                        Utils.closeInput(context);
                      },
                      underline: Container(height: 0.0),
                      isExpanded: true,
                      items: _templateDrapDown,
                      value: _templateKindValue,
                      hint: Text(
                        "请选择缺陷类型",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _getSelectTemplateKindId(v);
                          _templateKindValue = v;
                          _templateList = _getTemplateListOfKind();
                        });
                      })),
            ),
          ],
        ));
  }

  Widget _templateListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _templateList.length,
        itemBuilder: (context, index) {
          return InkWell(
              onTap: () {
                Navigator.pop(context, _templateList[index].templateName);
              },
              child: Container(
                padding: EdgeInsets.only(top: 12, bottom: 12),
                decoration: bottomLineDecotation,
                child: Text(_templateList[index].templateName),
              ));
        },
      ),
    );
  }

  void _getTemplateKindDropDown() {
    _templateKindList.forEach((element) {
      _templateDrapDown.add(
        DropdownMenuItem(
          child: Text(
            element.kindName,
            style: TextStyle(color: Colors.blue),
          ),
          value: element.kindName,
        ),
      );
    });
  }

  List _keywordSearch(String keyword) {
    List<Template> templateList = [];
    List<Template> list = SevensBaseDBModel.baseDBModel.templateList;
    list.forEach((element) {
      if (element.templateName.contains(keyword)) {
        templateList.add(element);
      }
    });
    return templateList;
  }

  void _getSelectTemplateKindId(String kindName) {
    _templateKindList.forEach((element) {
      if (element.kindName == kindName) {
        _templateKindId = element.kindId;
      }
    });
  }

  List _getTemplateListOfKind() {
    List<Template> list = [];
    List<Template> templateList = SevensBaseDBModel.baseDBModel.templateList;
    templateList.forEach((element) {
      if (element.kindId == _templateKindId) {
        list.add(element);
      }
    });
    return list;
  }
}
