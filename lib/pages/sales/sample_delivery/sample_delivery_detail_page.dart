import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/pages/sales/widget/sample_delivery_detail_widget.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';

import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/custom_outline_button.dart';
import 'package:mis_app/widget/date_view.dart';
import 'package:mis_app/widget/dismissible_delete_background.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/remarks_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SampleDeliveryDetailPage extends StatefulWidget {
  final Map arguments;
  SampleDeliveryDetailPage({Key key, this.arguments}) : super(key: key);

  @override
  _SampleDeliveryDetailPageState createState() =>
      _SampleDeliveryDetailPageState();
}

class _SampleDeliveryDetailPageState extends State<SampleDeliveryDetailPage> {
  SampleDeliveryModel _sampleDelivery;
  CustModel _selectedCust;
  bool _isNewCust = true;
  int _deliveryMethodId;
  int _feePayerId;
  int _deliveryAgent;
  List<SampleDeliveryDetailModel> _list = [];
  List<int> _deletedList = [];

  TextEditingController _custNameController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  TextEditingController _posiController = TextEditingController();
  TextEditingController _telController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _remarksController = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _selectedCust = CustModel();
    _sampleDelivery = SampleDeliveryModel();

    DataCache.initSampleSelectionList();

    if (widget.arguments != null) {
      int sampleDeliveryId = widget.arguments['sampleDeliveryId'];
      if (sampleDeliveryId != null) {
        WidgetsBinding.instance.addPostFrameCallback((Duration d) {
          _loadData(sampleDeliveryId);
        });
      } else {
        var cust = widget.arguments['cust'];
        if (cust != null) {
          _setCust(CustModel.fromJson(cust));
        }
      }
    }
  }

  void _loadData(int sampleDeliveryId) async {
    if (sampleDeliveryId == null) return;

    await _progressDialog?.show();
    try {
      SampleDeliveryWrapper result =
          await SalesService.getSampleDelivery(sampleDeliveryId);
      _updateCurrentSampleDelivery(result);
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _updateCurrentSampleDelivery(SampleDeliveryWrapper result) {
    if (result == null) return;

    _deletedList.clear();

    _sampleDelivery = result.sampleDelivery;
    _list = result.sampleDeliveryDetailList;
    _selectedCust = _sampleDelivery.cust;
    _isNewCust = _sampleDelivery.custId <= 0;
    _deliveryMethodId = _sampleDelivery.deliveryMethodId;
    _feePayerId = _sampleDelivery.deliveryFeePayerId;

    _deliveryAgent = null;
    if (_sampleDelivery.deliveryOption > 0) {
      _deliveryAgent = _sampleDelivery.deliveryOption;
    }

    _updateCustView();
    _remarksController.text = _sampleDelivery.remarks;
    setState(() {});
  }

  void _updateCustView() {
    _custNameController.text = _sampleDelivery.custName;
    _contactPersonController.text = _sampleDelivery.contactPerson;
    _posiController.text = _sampleDelivery.contactPersonPosi;
    _telController.text = _sampleDelivery.contactTel;
    _addressController.text = _sampleDelivery.address;
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('送样申请'),
        // actions: <Widget>[
        //   FlatButton.icon(
        //     onPressed: () {},
        //     icon: Icon(Icons.add, color: Colors.white),
        //     label: Text('样品', style: TextStyle(color: Colors.white)),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: _mainWidget,
      ),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: _sampleDelivery.isReadonly
                      ? IgnorePointer(
                          child: _editingArea,
                        )
                      : _editingArea,
                ),
              ],
            ),
          ),
        ),
        _buttons,
      ],
    );
  }

  Widget get _buttons {
    if (_sampleDelivery.status > SampleDeliveryModel.statusSubmit) {
      return Container();
    }

    return Container(
      // color: Theme.of(context).backgroundColor,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          if (!_sampleDelivery.isReadonly)
            CustomOutlineButton(
                label: '保存',
                icon: Icons.save,
                onPressed: () {
                  _saveData(false);
                }),
          SizedBox(width: 8.0),
          CustomOutlineButton(
            label: _sampleDelivery.isReadonly ? '撤销提交' : '提交',
            icon: _sampleDelivery.isReadonly
                ? Icons.undo
                : Icons.check_circle_outline,
            onPressed: () async {
              if (_sampleDelivery.isReadonly) {
                if (await DialogUtils.showConfirmDialog(context, '确定要撤销该申请吗',
                    confirmText: '撤销', confirmTextColor: Colors.red)) {
                  _toDraft();
                }
              } else {
                _saveData(true);
              }
            },
          ),
        ],
      ),
    );
  }

  void _toDraft() async {
    if (_sampleDelivery.sampleDeliveryId <= 0) return;

    setPageDataChanged(this.widget, true);

    SampleDeliveryWrapper result = await SalesService.toDraftSampleDelivery(
        _sampleDelivery.sampleDeliveryId);
    if (result != null) {
      DialogUtils.showToast('申请已撤销');
    }

    _updateCurrentSampleDelivery(result);
  }

  void _saveData(bool toSubmit) async {
    if (!_checkDataValid(toSubmit)) {
      return;
    }

    _sampleDelivery.custId = _isNewCust ? 0 : _selectedCust.custId;
    _sampleDelivery.custName = _custNameController.text;
    _sampleDelivery.custNameInput = _custNameController.text;
    _sampleDelivery.contactPerson = _contactPersonController.text;
    _sampleDelivery.contactPersonPosi = _posiController.text;
    _sampleDelivery.contactTel = _telController.text;
    _sampleDelivery.address = _addressController.text;
    _sampleDelivery.remarks = _remarksController.text;

    _sampleDelivery.deliveryMethodId = _deliveryMethodId;
    _sampleDelivery.deliveryFeePayerId = _feePayerId ?? 0;
    _sampleDelivery.deliveryOption = _deliveryAgent ?? 0;

    // setPageDataChangedByRoute(sampleDeliveryDetailPath, true);
    setPageDataChanged(this.widget, true);

    SampleDeliveryWrapper result;
    if (_sampleDelivery.sampleDeliveryId > 0) {
      result = await SalesService.updateSampleDelivery(
          _sampleDelivery, _list, _deletedList, toSubmit);
    } else {
      result = await SalesService.addSampleDelivery(
          _sampleDelivery, _list, toSubmit);
    }

    if (result != null) {
      DialogUtils.showToast(toSubmit ? '申请已提交' : '申请已保存');
    }

    _updateCurrentSampleDelivery(result);
  }

  bool _checkDataValid(bool toSubmit) {
    if (!_isNewCust) {
      if (_selectedCust.custId <= 0) {
        DialogUtils.showToast('请选择客户');

        return false;
      }
    } else {
      if (!_checkInputText(_custNameController, "输入客户名称")) return false;
    }

    if (!_checkInputText(_contactPersonController, "输入联系人")) return false;
    if (!_checkInputText(_telController, "输入联系电话")) return false;
    if (!_checkInputText(_addressController, "输入地址")) return false;

    if (_deliveryMethodId == null) {
      DialogUtils.showToast('请选择运输方式');
      return false;
    }

    if ((_deliveryMethodId == SampleDeliveryModel.deliveryMethodByAgent) &&
        (_deliveryAgent == null)) {
      DialogUtils.showToast('请选择办事处');
      return false;
    } else if ((_deliveryMethodId ==
            SampleDeliveryModel.deliveryMethodByExpress) &&
        (_feePayerId == null)) {
      DialogUtils.showToast('请选择支付方');
      return false;
    }

    if (toSubmit && (_list.length <= 0)) {
      DialogUtils.showToast('没有明细物料，不能提交');

      return false;
    }

    return true;
  }

  bool _checkInputText(TextEditingController controller, String msg) {
    if (Utils.textIsEmptyOrWhiteSpace(controller.text)) {
      DialogUtils.showToast(msg);

      return false;
    }

    return true;
  }

  /*
  Widget _button(String label, {IconData icon, Function onPressed}) {
    Color color = Theme.of(context).primaryColor;
    // Color color = Colors.white;
    return OutlineButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: color,
      ),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
    );
  }
  */

  Widget get _editingArea {
    return Column(
      children: <Widget>[
        _custKindWidget,
        _custWidget,
        _custDetailWidget('联系人：', _contactPersonController),
        _custDetailWidget('职位：', _posiController),
        _custDetailWidget('电话：', _telController),
        _custDetailWidget('地址：', _addressController),
        _itemDivider,
        _deliveryMethodWidget,
        _itemDivider,
        if (_deliveryMethodId == SampleDeliveryModel.deliveryMethodByAgent)
          _deliveryAgentWidget
        else
          _feePayerWidget,
        _itemDivider,
        _dateWidget,
        _itemDivider,
        _listWidget,
        _itemDivider,
        // _remarksWidget,
        RemarksTextField(
          controller: _remarksController,
          hintText: '请输入备注',
        ),
      ],
    );
  }

  Widget get _dateWidget {
    Color color = Theme.of(context).primaryColor;
    return Row(
      children: <Widget>[
        Text('申请日期'),
        // Expanded(
        //   child: Text(
        //     Utils.dateTimeToStr(_sampleDelivery.date),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        DateView(
          value: _sampleDelivery.date,
          // onTap: _changeDate,
        ),
        if (!_sampleDelivery.isReadonly)
          OutlineButton.icon(
            onPressed: _addSampleDetailItem,
            icon: Icon(
              Icons.add,
              color: color,
            ),
            label: Text(
              '样品',
              style: TextStyle(color: color),
            ),
          ),
      ],
    );
  }

  void _addSampleDetailItem() async {
    if (_sampleDelivery.isReadonly) return;

    Object result =
        await Navigator.pushNamed(context, sampleDeliveryDetailItemPath);

    if (result != null) {
      SampleDeliveryDetailModel newItem =
          SampleDeliveryDetailModel.fromJson(result);
      newItem.seqNo = _list.length + 1;
      _list.add(newItem);
      setState(() {});
    }
  }

  /*
  Widget get _remarksWidget {
    return TextField(
      controller: _remarksController,
      // enabled: !_sampleDelivery.isReadonly,
      minLines: 1,
      maxLines: 2,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        isDense: true,
        hintText: '请输入备注',
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
  */

  Widget get _custKindWidget {
    return _singleLineWidget(
      '客户类型：',
      content: CupertinoSegmentedControl<bool>(
        groupValue: _isNewCust,
        onValueChanged: (bool value) {
          setState(() {
            _isNewCust = value;
          });
        },
        children: {
          false: _segmentedText('现有客户'),
          true: _segmentedText('新客户'),
        },
      ),
    );
  }

  Widget get _feePayerWidget {
    bool deliveryFeePayerEnabled =
        _deliveryMethodId == SampleDeliveryModel.deliveryMethodByExpress;

    return _singleLineWidget(
      '快递支付：',
      content: CupertinoSegmentedControl<int>(
        groupValue: _feePayerId,
        selectedColor: deliveryFeePayerEnabled
            ? Theme.of(context).primaryColor
            : Theme.of(context).disabledColor,
        onValueChanged: (int value) {
          if (deliveryFeePayerEnabled) {
            setState(() {
              _feePayerId = value;
            });
          }
        },
        children: {
          SampleDeliveryModel.deliveryFeePayerIdWe: _segmentedText('我方'),
          SampleDeliveryModel.deliveryFeePayerIdCustomer: _segmentedText('客方'),
        },
      ),
    );
  }

  Widget get _deliveryAgentWidget {
    return _singleLineWidget(
      '办事处：',
      content: CupertinoSegmentedControl<int>(
        groupValue: _deliveryAgent,
        onValueChanged: (int value) {
          setState(() {
            _deliveryAgent = value;
          });
        },
        children: {
          SampleDeliveryModel.deliveryAgentDongguan: _segmentedText('东莞办'),
          SampleDeliveryModel.deliveryAgentShenzhen: _segmentedText('深圳办'),
          SampleDeliveryModel.deliveryAgentGuangzhou: _segmentedText('广州办'),
        },
      ),
    );
  }

  Widget get _deliveryMethodWidget {
    return _singleLineWidget(
      '运输方式：',
      content: CupertinoSegmentedControl<int>(
        groupValue: _deliveryMethodId,
        onValueChanged: (int value) {
          setState(() {
            _deliveryMethodId = value;
          });
        },
        children: {
          SampleDeliveryModel.deliveryMethodByFactory: _segmentedText('跟大货'),
          SampleDeliveryModel.deliveryMethodByExpress: _segmentedText('快递'),
          SampleDeliveryModel.deliveryMethodBySelf: _segmentedText('自提'),
          SampleDeliveryModel.deliveryMethodByAgent: _segmentedText('送办事处'),
        },
      ),
    );
  }

  Widget get _custWidget {
    return InkWell(
      onTap: _selectCust,
      child: _singleLineWidget(
        '客户名称：',
        content: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                // enabled: _isNewCust && (!_sampleDelivery.isReadonly),
                enabled: _isNewCust,
                controller: _custNameController,
                style: TextStyle(fontSize: fontSizeDetail),
                decoration: InputDecoration(
                  isDense: true,
                ),
              ),
            ),
            if (!_isNewCust)
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).primaryColor,
              ),
          ],
        ),
      ),
    );
  }

  void _selectCust() async {
    Navigator.pushNamed(
      context,
      custPath,
      arguments: {'selecting': true},
    ).then((value) async {
      if (value != null) {
        /*
        _selectedCust = value;
        _sampleDelivery.updateCust(_selectedCust);
        _updateCustView();
        */
        _setCust(value);
      }
    });
  }

  void _setCust(CustModel cust) {
    _selectedCust = cust;
    _sampleDelivery.updateCust(_selectedCust);
    _isNewCust = false;
    _updateCustView();
  }

  Widget get _listWidget {
    return Container(
      color: Color(0xFFF5F1E6),
      child: ListView.separated(
        shrinkWrap: true,
        physics: new NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          SampleDeliveryDetailModel item = _list[index];

          Widget itemWidget = InkWell(
            onTap: () async {
              Object result = await Navigator.pushNamed(
                  context, sampleDeliveryDetailItemPath,
                  arguments: item.toJson());
              if (result != null) {
                SampleDeliveryDetailModel newItem =
                    SampleDeliveryDetailModel.fromJson(result);
                _list[index] = newItem;
                setState(() {});
              }
            },
            // child: _listItemWidget(item),
            child: SampleDeliveryDetailWidget(
              item: item,
              sampleDeliveryStatus: _sampleDelivery.status,
              onQtyChanged: (String value) {
                if (!_sampleDelivery.isReadonly) {
                  setState(() {
                    item.setQtyDesc(value);
                  });
                }
              },
            ),
          );

          return _sampleDelivery.isReadonly
              ? itemWidget
              : Dismissible(
                  key: Key(item.sampleDeliveryDtlId.toString()),
                  // background: Container(color: backgroundColor),
                  background: DismissibleDeleteBackground(),
                  onDismissed: (DismissDirection direction) {
                    setState(() {
                      _deletedList.add(item.sampleDeliveryDtlId);
                      _removeFromList(item);
                    });
                  },
                  confirmDismiss: (DismissDirection direction) async {
                    return DialogUtils.showConfirmDialog(context, '确定要删除当前项吗？');
                  },
                  child: itemWidget,
                );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: _list.length,
      ),
    );
  }

  void _removeFromList(SampleDeliveryDetailModel oldItem) {
    _list.remove(oldItem);
    int seqNo = 0;
    for (SampleDeliveryDetailModel item in _list) {
      seqNo++;
      item.seqNo = seqNo;
    }
  }

  /*
  Widget _listItemWidget(SampleDeliveryDetailModel item) {
    Color primaryColor = Theme.of(context).primaryColor;
    TextStyle descStyle =
        TextStyle(color: defaultFontColor, fontSize: fontSizeSmall);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
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
            _qtyWidget(item),
          ],
        ),
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
      ],
    );
  }

  Widget _qtyWidget(SampleDeliveryDetailModel item) {
    return _sampleDelivery.isReadonly
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
            onChanged: (String value) {
              if (!_sampleDelivery.isReadonly) {
                setState(() {
                  item.setQtyDesc(value);
                });
              }
            },
          );
  }
  */

  Widget get _itemDivider {
    return SizedBox(height: 6.0);
  }

  Widget _segmentedText(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: fontSizeSmall),
    );
  }

  Widget _custDetailWidget(String label, TextEditingController controller) {
    Widget placeHolder = Visibility(
      child: Text('客户'),
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: false,
    );

    return Row(
      children: <Widget>[
        placeHolder,
        LabelText(
          label,
          fontSize: fontSizeDetail,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            // enabled: _isNewCust && (!_sampleDelivery.isReadonly),
            enabled: _isNewCust,
            style: TextStyle(fontSize: fontSizeDetail),
            decoration: InputDecoration(
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _singleLineWidget(String label, {Widget content}) {
    return Row(
      children: <Widget>[
        LabelText(label),
        Expanded(child: content),
      ],
    );
  }
}
