import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/device.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class DeviceDataPage extends StatefulWidget {
  @override
  _DeviceDataPageState createState() => _DeviceDataPageState();
}

class _DeviceDataPageState extends State<DeviceDataPage> {
  bool _hasMoreDate = true;
  String _type;
  DateTime _beginData = DateTime.now();
  DateTime _endData = DateTime.now();
  List<DevTypeModel> _typeList = [];
  List<DevData> _devList = [];
  List<DropdownMenuItem> _typeItems = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getDeviceType();
      _getDeviceData(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('设备原始数据'),
        // backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(6),
              color: Colors.grey[100],
              child: Column(
                children: <Widget>[
                  _typeWidget(),
                  _time(),
                ],
              ),
            ),
            _listView(),
            // _button(),
          ],
        ),
      ),
    );
  }

  Widget _typeWidget() {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          customText(value: '设备类型  ', fontSize: 14),
          Expanded(
            child: DropdownButton(
              underline: Container(),
              isExpanded: true,
              isDense: true,
              items: _typeItems,
              value: _type,
              hint: customText(value: '(请选择)', color: Colors.blue),
              onChanged: (v) {
                setState(() {
                  _type = v;
                  _getTypeItems();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _time() {
    String begin = Utils.dateTimeToStr(_beginData);
    String end = Utils.dateTimeToStr(_endData);
    return Container(
      margin: EdgeInsets.only(top: 3, bottom: 5),
      child: Row(
        children: <Widget>[
          customText(value: '读取时间  ', fontSize: 14),
          Expanded(
              child: InkWell(
            onTap: () {
              DialogUtils.showDatePickerDialog(context, _beginData,
                  onValue: (v) {
                //如果开始时间晚于结束时间,或者开始结束时间不在同一个月
                setState(() {
                  _beginData = v;
                  if (!Utils.inSameMonth(_beginData, _endData) ||
                      _beginData.isAfter(_endData)) {
                    _endData = Utils.lastDayOfMonth(_beginData);
                  }
                });
              });
            },
            child: _customText(begin),
          )),
          customText(value: '至 '),
          Expanded(
              child: InkWell(
            onTap: () {
              DialogUtils.showDatePickerDialog(context, _endData, onValue: (v) {
                setState(() {
                  _endData = v;
                  if (!Utils.inSameMonth(_beginData, _endData) ||
                      _beginData.isAfter(_endData)) {
                    _beginData = Utils.firstDayOfMonth(_endData);
                  }
                });
              });
            },
            child: _customText(end),
          )),
          InkWell(
            onTap: _search,
            child: Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(3)),
              child: Icon(
                Icons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _customText(String value) {
    return Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(3),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(5)),
        child: customText(value: value, color: Colors.orange));
  }

  Widget _listView() {
    return Expanded(
        child: Container(
      color: Colors.white,
      child: EasyRefresh(
        child: ListView.separated(
            itemBuilder: (context, index) {
              DevData item = _devList[index];
              return _item(item);
            },
            separatorBuilder: (context, index) {
              return Divider(height: 1);
            },
            itemCount: _devList.length),
        onRefresh: () async {
          _getDeviceData(true);
        },
        onLoad: () async {
          _getDeviceData(false);
        },
      ),
    ));
  }

  Widget _item(DevData item) {
    String value = item.value10 != null ? item.value10.toString() : '';
    String date =
        Utils.dateTimeToStr(item.createDate, pattern: 'yyyy-MM-dd HH:mm');
    return Container(
      padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          customText(
              value: item.deviceTypeName + ' (No: ${item.deviceNo}) ',
              fontSize: 14,
              color: Colors.blue),

          // customText(value: 'No: ' + item.deviceNo, fontSize: 13.5),
          Container(height: 2),
          customText(value: '值: ' + value, fontSize: 13.5, color: Colors.green),
          Container(height: 2),
          customText(
            value: '读取时间：' + date,
            fontSize: 13.5,
            // color: Colors.yellow[900],
          ),
          Container(height: 2),
          customText(
              value: item.areaName +
                  ' - ' +
                  item.comLocation +
                  ' - ' +
                  item.deviceLocation,
              fontSize: 13.5),
          Container(height: 2),
          customText(
              value: item.comPort + ' - ' + item.comServiceIp, fontSize: 13.5),
          // customText(value: item.comPort, fontSize: 13),
        ],
      ),
    );
  }

  // Widget _button() {
  //   return Row(children: <Widget>[customButtom(Colors.blue, '查询', _search)]);
  // }

  void _getDeviceType() async {
    Map<String, dynamic> map = {'action': 'get_device_type'};
    await request(serviceUrl[deviceDataUrl], queryParameters: map)
        .then((value) {
      var responseData = jsonDecode(value.data.toString());
      responseData.forEach((val) {
        DevTypeModel item = DevTypeModel.fromJson(val);
        _typeList.add(item);
      });
      _getTypeItems();
      setState(() {});
    });
  }

  void _getTypeItems() {
    _typeItems.clear();
    _typeList.forEach((element) {
      _typeItems.add(DropdownMenuItem(
        child: customText(
            value: element.deviceName,
            fontSize: 15,
            color: element.code == _type ? Colors.blue : Colors.black),
        value: element.code,
      ));
    });
  }

  void _search() async {
    _getDeviceData(true);
  }

  void _getDeviceData(bool isRefresh) async {
    if (isRefresh) {
      _devList.clear();
      _hasMoreDate = true;
    }
    if (!_hasMoreDate) return;
    await _progressDialog?.show();
    int maxid = isRefresh == true ? 0 : _devList.last.comDataId;
    try {
      Map<String, dynamic> map = {
        'action': 'get_device_data',
        'devicetype': _type ?? '',
        'datefrom': _beginData,
        'dateto': _endData,
        'maxId': maxid,
      };
      await request(serviceUrl[deviceDataUrl], queryParameters: map)
          .then((value) {
        List responseData = jsonDecode(value.data.toString());
        if (responseData.length > 0) {
          responseData.forEach((val) {
            DevData item = DevData.fromJson(val);
            _devList.add(item);
          });
        } else {
          _hasMoreDate = false;
        }
      });
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }
}
