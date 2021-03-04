import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/boiler_feeding.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/boiler_feeding_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class BoilerFeedingAddPage extends StatefulWidget {
  @override
  _BoilerFeedingAddPageState createState() => _BoilerFeedingAddPageState();
}

class _BoilerFeedingAddPageState extends State<BoilerFeedingAddPage> {
  // int _areaId;
  // int _fDeviceId;
  // int _fueId;
  // String _uom;
  DateTime _readDate = DateTime.now();
  TimeOfDay _readTime = TimeOfDay.now();
  BoilerFeedingDtlModel _detailModel = BoilerFeedingDtlModel();
  List<DropdownMenuItem> _areaList = [];
  List<DropdownMenuItem> _deviceList = [];
  List<DropdownMenuItem> _fueList = [];

  TextEditingController _qtyController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _getBaseDb();
    _getDropDownData();
    _getDetailData();
  }

  void _getDropDownData() {
    UserProvide.areaList.forEach((element) {
      _areaList.add(DropdownMenuItem(
          value: element.areaId, child: Text(element.shortName)));
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('投料数据'),
        actions: <Widget>[_scanCodeWidget()],
      ),
      resizeToAvoidBottomPadding: true,
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: <Widget>[
            // customText(value: '请扫描设备二维码'),
            // _scanCodeWidget(),
            Expanded(child: _detailWidget()),
            _buttons(),
          ],
        ),
      ),
    );
  }

  Widget _scanCodeWidget() {
    return InkWell(
      onTap: () async {
        var scanResult = await BarcodeScanner.scan(
          options: ScanOptions(strings: scanOptionsStrings),
        );
        _getScanData(scanResult.rawContent);
      },
      child: Container(
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.crop_free,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailWidget() {
    return Container(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _area(),
            _diviceWidget(),
            _flueWidget(),
            _qtyWidget(),
            _dateWidget(),
            _remarkWidget(),
          ],
        ),
      ),
    );
  }

  Widget _area() {
    return Row(
      children: <Widget>[
        Expanded(child: Text('项目')),
        _customContainer(DropdownButton(
            underline: Container(),
            isExpanded: true,
            items: _areaList,
            value: _detailModel.areaId,
            hint: Text('(请选择地区)'),
            onChanged: (val) {
              setState(() {
                _detailModel.areaId = val;
                _areaValueChange();
              });
            })),
      ],
    );
  }

  Widget _diviceWidget() {
    return Row(
      children: <Widget>[
        Expanded(child: Text('锅炉设备')),
        _customContainer(DropdownButton(
            underline: Container(),
            isExpanded: true,
            items: _deviceList,
            hint: Text('(请选择设备)'),
            value: _detailModel.fuelDeviceId,
            onChanged: (v) {
              setState(() {
                _detailModel.fuelDeviceId = v;
                _deviceChange();
              });
            }))
      ],
    );
  }

  Widget _flueWidget() {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        Expanded(child: Text('燃料')),
        _customContainer(DropdownButton(
            underline: Container(),
            isExpanded: true,
            items: _fueList,
            value: _detailModel.fuelId,
            hint: Text('(请选择燃料)'),
            onChanged: (v) {
              setState(() {
                _detailModel.fuelId = v;
                _getUon();
              });
            })),
      ],
    );
  }

  Widget _qtyWidget() {
    return Row(
      children: <Widget>[
        Expanded(child: Text('重量(${_detailModel.uom ?? ''})')),
        _customContainer(TextField(
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
          ],
          decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              )),
          controller: _qtyController,
        )),
      ],
    );
  }

  Widget _dateWidget() {
    return Container(
      child: Row(
        children: <Widget>[
          Expanded(child: Text('读取时间')),
          _customContainer(Row(
            children: <Widget>[
              _dataPiack(),
              _timePiack(),
            ],
          ))
        ],
      ),
    );
  }

  Widget _dataPiack() {
    String date = Utils.dateTimeToStr(_readDate, pattern: 'yyyy-MM-dd');
    return Expanded(
        child: InkWell(
      onTap: () async {
        DialogUtils.showDatePickerDialog(context, _readDate, onValue: (val) {
          if (val == null) return;
          setState(() {
            _readDate = val;
          });
        });
      },
      child: Row(
        children: <Widget>[
          Icon(
            Icons.date_range,
            color: Colors.blue,
          ),
          Text('$date')
        ],
      ),
    ));
  }

  Widget _timePiack() {
    return Expanded(
        child: InkWell(
      onTap: () async {
        await showTimePicker(context: context, initialTime: _readTime)
            .then((value) {
          if (value == null) return;
          setState(() {
            _readTime = value;
          });
        });
      },
      child: Row(
        children: <Widget>[
          Icon(
            Icons.access_time,
            color: Colors.orange,
          ),
          Text('${_readTime.format(context)}')
        ],
      ),
    ));
  }

  Widget _remarkWidget() {
    return Row(
      children: <Widget>[
        _customContainer(
            TextField(
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5),
                    hintText: '请输入备注',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    )),
                maxLines: 5,
                controller: _remarkController),
            height: 100),
      ],
    );
  }

  Widget _customContainer(Widget child, {double height}) {
    return Expanded(
        flex: 4,
        child: Container(
          padding: EdgeInsets.all(5),
          height: height ?? 40,
          decoration: BoxDecoration(
              border: Border.all(width: 0, color: Colors.blue),
              color: Colors.white,
              borderRadius: BorderRadius.circular(5)),
          margin: EdgeInsets.all(5),
          child: child,
        ));
  }

  Widget _buttons() {
    return Row(
      children: <Widget>[
        if (BFStcData.recoardId != 0) customButtom(Colors.red, '删除', _delete),
        customButtom(Colors.blue, '保存', _save),
      ],
    );
  }

  void _save() async {
    setPageDataChanged(this.widget, true);
    BFStcData.isUpdate = true;
    if (_detailModel.areaId == null) {
      DialogUtils.showToast('项目不能为空！');
    } else if (_detailModel.fuelDeviceId == null) {
      DialogUtils.showToast('锅炉设备量不能为空！');
    } else if (_detailModel.fuelId == null) {
      DialogUtils.showToast('燃料不能为空！');
    } else if (_qtyController.text == '') {
      DialogUtils.showToast('重量不能为空！');
    } else {
      await _progressDialog.show();
      _detailModel.readQty = double.parse(_qtyController.text);
      _detailModel.remarks = _remarkController.text;
      _detailModel.readTime = DateTime(_readDate.year, _readDate.month,
          _readDate.day, _readTime.hour, _readTime.minute);
      // try {
      await BoilerFeedingService.save(_detailModel).then((value) async {
        await _progressDialog.hide();
        if (value['Success']) {
          DialogUtils.showToast('保存成功');
        } else {
          var msg = value['Msg'];
          DialogUtils.showAlertDialog(context, msg);
        }
      });
    }
  }

  void _delete() async {
    setPageDataChanged(this.widget, true);
    var result = await DialogUtils.showConfirmDialog(context, '是否删除该条记录?',
        iconData: Icons.info, color: Colors.red);
    if (result) {
      // await _progressDialog.show();
      var responseData = await BoilerFeedingService.delete(BFStcData.recoardId);
      // await _progressDialog.hide();
      if (responseData['Success']) {
        DialogUtils.showToast('删除成功');
        BFStcData.isUpdate = true;
        Navigator.pop(context);
      } else {
        var msg = responseData['Msg'];
        DialogUtils.showAlertDialog(context, msg);
      }
    }
  }

  void _getBaseDb() async {
    if (BFStcData.categoryList.length == 0) {
      await BoilerFeedingService.getBaseDb().then((value) {
        setState(() {
          BFStcData.categoryList = value;
        });
      });
    }
  }

  void _getScanData(String scanCode) async {
    await BoilerFeedingService.getScanData(scanCode).then((value) {
      if (value['FoundData']) {
        setState(() {
          _detailModel.areaId = value['AreaId'];
          _areaValueChange();
          _detailModel.fuelDeviceId = value['FuelDeviceId'];
          _detailModel.fuelId = value['DefaultFuelId'];
        });
      } else {
        DialogUtils.showToast('没有找到数据');
      }
    });
  }

  void _getDetailData() async {
    int id = BFStcData.recoardId;
    if (id == 0) return;
    BoilerFeedingDtlModel model = await BoilerFeedingService.getDetailData(id);
    _updateUi(model);
  }

  void _updateUi(BoilerFeedingDtlModel model) {
    setState(() {
      _detailModel.areaId = model.areaId;
      _areaValueChange();
      _detailModel.fuelDeviceId = model.fuelDeviceId;
      _detailModel.fuelId = model.fuelId;
      _getUon();
      _readDate = model.readTime;
      _readTime = TimeOfDay.fromDateTime(model.readTime);
      _qtyController.text = model.readQty.toString();
      _remarkController.text = model.remarks;
    });
  }

//根据地区获取地区的设备,根据默认的设备获取燃料
// 如果有两个锅炉默认获取锅炉的燃料
  void _areaValueChange() {
    _deviceList.clear();
    _fueList.clear();
    _detailModel.fuelDeviceId = null;
    _detailModel.fuelId = null;
    BFStcData.categoryList.forEach((element) {
      if (element.areaId == _detailModel.areaId) {
        _deviceList.add(DropdownMenuItem(
          value: element.deviceId,
          child: Text(element.name),
        ));
        if (_deviceList.length <= 1) {
          _detailModel.fuelDeviceId = element.deviceId;
          _detailModel.fuelId = element.defaultFuelId;
          element.availableFuelList.forEach((val) {
            if (val.fuelId == _detailModel.fuelId) {
              _detailModel.uom = val.uom;
            }
            _fueList.add(DropdownMenuItem(
              value: val.fuelId,
              child: Text(val.name),
            ));
          });
        }
      }
    });
  }

  ///更改设备,获取燃料list
  void _deviceChange() {
    _fueList.clear();
    BFStcData.categoryList.forEach((element) {
      if (element.deviceId == _detailModel.fuelDeviceId) {
        element.availableFuelList.forEach((val) {
          _detailModel.uom = val.uom;
          _detailModel.fuelId = element.defaultFuelId;
          _fueList.add(DropdownMenuItem(
            value: val.fuelId,
            child: Text(val.name),
          ));
        });
      }
    });
  }

  void _getUon() {
    BFStcData.categoryList.forEach((element) {
      if (_detailModel.fuelDeviceId == element.deviceId) {
        element.availableFuelList.forEach((item) {
          if (_detailModel.fuelId == item.fuelId) {
            _detailModel.uom = item.uom;
          }
        });
      }
    });
  }
}
