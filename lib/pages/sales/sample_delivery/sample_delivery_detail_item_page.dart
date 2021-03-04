import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/model/sample_item.dart';
import 'package:mis_app/pages/sales/sample_delivery/search_sample_item.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/dense_text_field.dart';
import 'package:mis_app/widget/box_container.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/large_button.dart';

class SampleDeliveryDetailItemPage extends StatefulWidget {
  final Map arguments;
  SampleDeliveryDetailItemPage({Key key, this.arguments}) : super(key: key);

  @override
  _SampleDeliveryDetailItemPageState createState() =>
      _SampleDeliveryDetailItemPageState();
}

class _SampleDeliveryDetailItemPageState
    extends State<SampleDeliveryDetailItemPage> {
  List<String> _prodNameSelections = ['(请选择成品)'];
  List<String> _gluingSelections = ['(请选择涂胶操作)'];
  List<String> _heatingSelections = ['(请选择加热方式)'];
  List<String> _materialSelections = ['(请选择材料)'];
  bool _initedSelections = false;
  TextEditingController _prodNameController = TextEditingController();
  TextEditingController _material1Controller = TextEditingController();
  TextEditingController _material2Controller = TextEditingController();
  TextEditingController _treatingAgent1Controller = TextEditingController();
  TextEditingController _treatingAgent2Controller = TextEditingController();
  TextEditingController _dryController = TextEditingController();
  TextEditingController _pressingController = TextEditingController();
  TextEditingController _operationTechController = TextEditingController();
  TextEditingController _specialReqController = TextEditingController();
  TextEditingController _predictDemandController = TextEditingController();
  SampleDeliveryDetailModel _deliveryDetail;
  String _selectedItemName = '';
  bool _polish1 = false;
  bool _polish2 = false;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() async {
    if (widget.arguments != null) {
      _deliveryDetail = SampleDeliveryDetailModel.fromJson(widget.arguments);
    } else {
      _deliveryDetail = SampleDeliveryDetailModel();
    }

    _selectedItemName =
        _deliveryDetail.isNewSample ? "" : _deliveryDetail.itemDesc;
    _polish1 = Utils.strToBool(_deliveryDetail.ot2);
    _polish2 = Utils.strToBool(_deliveryDetail.ot4);

    _initSelections();
    _updateView();

    setState(() {});
  }

  void _updateView() {
    _prodNameController.text =
        getControllerText(_prodNameSelections, _deliveryDetail.ot1);
    _material1Controller.text =
        getControllerText(_materialSelections, _deliveryDetail.item1);
    _material2Controller.text =
        getControllerText(_materialSelections, _deliveryDetail.item2);
    _treatingAgent1Controller.text = _deliveryDetail.ot3;
    _treatingAgent2Controller.text = _deliveryDetail.ot5;
    _dryController.text = _deliveryDetail.ot8;
    _pressingController.text = _deliveryDetail.ot9;
    _operationTechController.text = _deliveryDetail.operationTech;
    _specialReqController.text = _deliveryDetail.specialReq;
    _predictDemandController.text = _deliveryDetail.predictDemand;
  }

  String getControllerText(List<String> seletions, String value) {
    return seletions.contains(value) ? '' : value;
  }

  void _initSelections() {
    if (!_initedSelections) {
      SalesService.buildSampleSelectionList(
          _prodNameSelections, 'SampleProd', true);
      SalesService.buildSampleSelectionList(_gluingSelections, 'Gluing', false);
      SalesService.buildSampleSelectionList(
          _heatingSelections, 'Heating', false);
      SalesService.buildSampleSelectionList(
          _materialSelections, 'Material', true);

      _initedSelections = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('添加样品'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        Expanded(child: _editingArea),
        _okButton,
      ],
    );
  }

  Widget get _editingArea {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _prodSelectionWidget,
            _prodKindWidget,
            _itemDivider,
            _prodWidget,
            _qtyWidget,
            _material1Widget,
            _itemDivider,
            _material2Widget,
            _itemDivider,
            _operationTechWidget,
            _itemDivider,
            _operationTechTextField,
            _specialReqTextField,
            _predictDemandTextField,
          ],
        ),
      ),
    );
  }

  Widget get _operationTechTextField {
    return _remarksTextField(
        hintText: '请输入操作工艺', controller: _operationTechController);
  }

  Widget get _specialReqTextField {
    return _remarksTextField(
        hintText: '请输入特殊要求', controller: _specialReqController);
  }

  Widget get _predictDemandTextField {
    return _remarksTextField(
        hintText: '请输入预计需求', controller: _predictDemandController);
  }

  Widget get _operationTechWidget {
    return BoxContainer(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              LabelText('涂胶操作：'),
              Expanded(
                child: _dropDownSelections(
                  _gluingSelections,
                  value: _deliveryDetail.ot6,
                  isExpanded: true,
                  onChanged: (String value) {
                    setState(() {
                      _deliveryDetail.ot6 = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              LabelText('加热方式：'),
              Expanded(
                child: _dropDownSelections(
                  _heatingSelections,
                  value: _deliveryDetail.ot7,
                  isExpanded: true,
                  onChanged: (String value) {
                    setState(() {
                      _deliveryDetail.ot7 = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              LabelText('干燥时间：'),
              Expanded(
                child: DenseTextField(
                  controller: _dryController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
              LabelText('分钟'),
            ],
          ),
          Row(
            children: <Widget>[
              LabelText('贴合加压：'),
              Expanded(
                child: DenseTextField(
                  controller: _pressingController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                ),
              ),
              LabelText('分钟'),
            ],
          ),
        ],
      ),
    );
  }

  bool _selectionTextEnabled(List<String> list, String text) {
    // return text == list[list.length - 1];
    return !Utils.textIsEmptyOrWhiteSpace(text) &&
        ((text == list.last) || (!list.contains(text)));
  }

  TextStyle _selectionTextStyle(bool enabled) {
    return enabled
        ? TextStyle(fontSize: fontSizeDetail)
        : TextStyle(color: disabledFontColor, fontSize: fontSizeDetail);
  }

  Widget get _material1Widget {
    bool textFieldEnabled =
        _selectionTextEnabled(_materialSelections, _deliveryDetail.item1);

    return BoxContainer(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              LabelText('面料：'),
              _dropDownSelections(
                _materialSelections,
                value: _getSelectionValue(
                    _materialSelections, _deliveryDetail.item1),
                onChanged: (String value) {
                  setState(() {
                    _deliveryDetail.item1 = value;
                  });
                },
              ),
              Expanded(
                  child: DenseTextField(
                controller: _material1Controller,
                enabled: textFieldEnabled,
                style: _selectionTextStyle(textFieldEnabled),
              )),
              if (_deliveryDetail.needPolish) LabelText('打磨'),
              if (_deliveryDetail.needPolish)
                Switch(
                  value: _polish1,
                  onChanged: (bool value) {
                    setState(() {
                      _polish1 = value;
                    });
                  },
                ),
            ],
          ),
          if (_deliveryDetail.needPolish)
            Row(
              children: <Widget>[
                LabelText('处理剂'),
                Expanded(
                  child: DenseTextField(controller: _treatingAgent1Controller),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget get _material2Widget {
    bool textFieldEnabled =
        _selectionTextEnabled(_materialSelections, _deliveryDetail.item2);

    return BoxContainer(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              LabelText('底料：'),
              _dropDownSelections(
                _materialSelections,
                value: _getSelectionValue(
                    _materialSelections, _deliveryDetail.item2),
                onChanged: (String value) {
                  setState(() {
                    _deliveryDetail.item2 = value;
                  });
                },
              ),
              Expanded(
                child: DenseTextField(
                  controller: _material2Controller,
                  enabled: textFieldEnabled,
                  style: _selectionTextStyle(textFieldEnabled),
                ),
              ),
              if (_deliveryDetail.needPolish) LabelText('打磨'),
              if (_deliveryDetail.needPolish)
                Switch(
                  value: _polish2,
                  onChanged: (bool value) {
                    setState(() {
                      _polish2 = value;
                    });
                  },
                ),
            ],
          ),
          if (_deliveryDetail.needPolish)
            Row(
              children: <Widget>[
                LabelText('处理剂'),
                Expanded(
                  child: DenseTextField(controller: _treatingAgent2Controller),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget get _qtyWidget {
    return Row(
      children: <Widget>[
        LabelText('数量：'),
        Expanded(
          child: _dropDownSelections(
            SampleDeliveryDetailModel.qtyList,
            value: _deliveryDetail.qtyDesc,
            isExpanded: true,
            onChanged: (String value) {
              setState(() {
                _deliveryDetail.setQtyDesc(value);
              });
            },
          ),
        ),
        SizedBox(width: 6.0),
        LabelText('客供参照样品'),
        Switch(
          value: _deliveryDetail.custProvideSample,
          onChanged: (bool value) {
            setState(() {
              _deliveryDetail.custProvideSample = value;
            });
          },
        ),
      ],
    );
  }

  Widget get _prodWidget {
    bool selectedItem = !Utils.textIsEmptyOrWhiteSpace(_selectedItemName);

    return InkWell(
      onTap: () {
        _selectedItem();
      },
      child: Row(
        children: <Widget>[
          LabelText('产品：'),
          Expanded(
            child: Text(
              selectedItem ? _selectedItemName : '请选择产品',
              style: selectedItem
                  ? null
                  : TextStyle(
                      color: defaultFontColor,
                    ),
            ),
          ),
          Icon(Icons.keyboard_arrow_right),
        ],
      ),
    );
  }

  void _selectedItem() async {
    var result = await showSearch(
      context: context,
      delegate: SearchSampleItemDelegate(Prefs.keyHistorySelectSampleItem),
    );

    if (Utils.textIsEmptyOrWhiteSpace(result)) return;

    SampleItemModel item = SampleItemModel.fromJson(json.decode(result));
    setState(() {
      _selectedItemName = item.itemName;
    });
  }

  Widget get _prodKindWidget {
    return Row(
      children: <Widget>[
        Expanded(
          child: CupertinoSegmentedControl<bool>(
            groupValue: _deliveryDetail.isNewSample,
            onValueChanged: (bool value) {
              setState(() {
                _deliveryDetail.isNewSample = value;
              });
            },
            children: {
              false: Text('现有产品'),
              true: Text('新开发样品'),
            },
          ),
        ),
      ],
    );
  }

  Widget get _prodSelectionWidget {
    bool textFieldEnabled =
        _selectionTextEnabled(_prodNameSelections, _deliveryDetail.ot1);

    return Row(
      children: <Widget>[
        LabelText('成品：'),
        _dropDownSelections(
          _prodNameSelections,
          value: _getSelectionValue(_prodNameSelections, _deliveryDetail.ot1),
          onChanged: (String value) {
            _deliveryDetail.ot1 = value;
            bool needPolish =
                SampleDeliveryDetailModel.prodNeedPolish(_deliveryDetail.ot1);
            _deliveryDetail.ot10 = (Utils.boolToString(needPolish));
            setState(() {});
          },
        ),
        Expanded(
          child: DenseTextField(
            controller: _prodNameController,
            enabled: textFieldEnabled,
            style: _selectionTextStyle(textFieldEnabled),
          ),
        ),
      ],
    );
  }

  String _getSelectionValue(List<String> selections, String value) {
    if (Utils.textIsEmptyOrWhiteSpace(value)) return null;
    return selections.contains(value) ? value : selections.last;
  }

  Widget get _itemDivider {
    return SizedBox(height: 6.0);
  }

  Widget get _okButton {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: LargeButton(
        title: '确定',
        height: 40.0,
        onPressed: () {
          if (_updateToData()) {
            Navigator.pop(context, _deliveryDetail.toJson());
          }
        },
      ),
    );
  }

  bool _updateToData() {
    String selectedProdName = _getSelection(_prodNameSelections, '成品',
        _deliveryDetail.ot1, _prodNameController.text);

    if (Utils.textIsEmptyOrWhiteSpace(selectedProdName)) {
      return false;
    }

    if ((!_deliveryDetail.isNewSample) &&
        Utils.textIsEmptyOrWhiteSpace(_selectedItemName)) {
      DialogUtils.showToast('请选择产品');
      _selectedItem();

      return false;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.qtyDesc)) {
      DialogUtils.showToast('请选择数量');
      return false;
    }

    String selectedMaterial1 = _getSelection(_materialSelections, '面料材料',
        _deliveryDetail.item1, _material1Controller.text);
    String selectedMaterial2 = _getSelection(_materialSelections, '底料材料',
        _deliveryDetail.item2, _material2Controller.text);

    if (Utils.textIsEmptyOrWhiteSpace(selectedMaterial1) ||
        Utils.textIsEmptyOrWhiteSpace(selectedMaterial2)) {
      return false;
    }

    _deliveryDetail.ot3 =
        _deliveryDetail.needPolish ? _treatingAgent1Controller.text : '';
    _deliveryDetail.ot5 =
        _deliveryDetail.needPolish ? _treatingAgent2Controller.text : '';
    _deliveryDetail.ot8 = _dryController.text;
    _deliveryDetail.ot9 = _pressingController.text;
    _deliveryDetail.operationTech = _operationTechController.text;
    _deliveryDetail.specialReq = _specialReqController.text;
    _deliveryDetail.predictDemand = _predictDemandController.text;

    if (_deliveryDetail.needPolish) {
      if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.ot3)) {
        DialogUtils.showToast('请输入面料处理剂');
        return false;
      }
      if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.ot5)) {
        DialogUtils.showToast('请输入底料处理剂');
        return false;
      }
    }

    if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.ot6) ||
        _deliveryDetail.ot6 == _gluingSelections[0]) {
      DialogUtils.showToast('请选择涂胶操作');
      return false;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.ot7) ||
        _deliveryDetail.ot7 == _heatingSelections[0]) {
      DialogUtils.showToast('请选择加热方式');
      return false;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.ot8)) {
      DialogUtils.showToast('请输入干燥时间');
      return false;
    }

    if (Utils.textIsEmptyOrWhiteSpace(_deliveryDetail.ot9)) {
      DialogUtils.showToast('请输入加压时间');
      return false;
    }

    String itemDesc = _deliveryDetail.isNewSample
        ? '$selectedMaterial1/$selectedMaterial2'
        : _selectedItemName;

    _deliveryDetail.itemDesc = itemDesc;

    _deliveryDetail.ot1 = selectedProdName;
    _deliveryDetail.item1 = selectedMaterial1;
    _deliveryDetail.item2 = selectedMaterial2;

    _deliveryDetail.ot2 =
        Utils.boolToString(_deliveryDetail.needPolish && _polish1);
    _deliveryDetail.ot4 =
        Utils.boolToString(_deliveryDetail.needPolish && _polish2);

    return true;
  }

  String _getSelection(List<String> selections, String selectionName,
      String selectedValue, String editValue) {
    String selection =
        selectedValue == selections.last ? editValue : selectedValue;
    if (Utils.textIsEmptyOrWhiteSpace(selection)) {
      DialogUtils.showToast('请选择$selectionName');
    }

    return selection.trim();
  }

  Widget _dropDownSelections(List<String> list,
      {String value, bool isExpanded = false, Function(String) onChanged}) {
    return DropdownButton<String>(
      value: value == '' ? null : value,
      items: list.map((String item) {
        return DropdownMenuItem(
          child: Text(
            item,
            style: TextStyle(fontSize: fontSizeDetail),
          ),
          value: item,
        );
      }).toList(),
      isExpanded: isExpanded,
      onChanged: (String value) {
        // 收起键盘，如果弹出键盘后不收起：
        // 点击DropdownButton的项目后，SingleChildScrollView会自动滚动后之前键盘录入的位置
        Utils.closeInput(context);
        if (onChanged != null) {
          onChanged(value);
        }
      },
    );
  }

  Widget _remarksTextField(
      {String hintText, TextEditingController controller}) {
    return DenseTextField(
      controller: controller,
      minLines: 1,
      maxLines: 2,
      hintText: hintText,
      showBorder: true,
    );
  }
}
