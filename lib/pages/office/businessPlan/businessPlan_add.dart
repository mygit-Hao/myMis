import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/businessPlan_data.dart';
import 'package:mis_app/model/businessPlan_list.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class BusinessPlanAddPage extends StatefulWidget {
  final BusinessPlanLine item;

  const BusinessPlanAddPage({Key key, this.item}) : super(key: key);

  @override
  _BusinessPlanAddPageState createState() => _BusinessPlanAddPageState();
}

class _BusinessPlanAddPageState extends State<BusinessPlanAddPage> {
  BusinessPlanLine _businessPlanLine = BusinessPlanLine();
  TextEditingController _planCtrl = TextEditingController();
  TextEditingController _addressCtrl = TextEditingController();
  TextEditingController _contactCtrl = TextEditingController();
  List<DropdownMenuItem> _typeItems = [];
  @override
  void initState() {
    super.initState();
    if (this.widget.item != null) {
      setState(() {
        _businessPlanLine = this.widget.item;
        _addressCtrl.text = _businessPlanLine.address;
        _planCtrl.text = _businessPlanLine.plan;
        _contactCtrl.text = _businessPlanLine.tel;
        _getTypeList();
      });
    } else {
      setState(() {
        _getTypeList();
        _businessPlanLine.beginDate = BusinessSData.beginData;
        _businessPlanLine.endDate = BusinessSData.endData;
      });
    }
  }

  void _getTypeList() {
    BusinessSData.vehicleKindList.forEach((element) {
      _typeItems.add(DropdownMenuItem(
        child: Text(element.name,
            style: TextStyle(
                fontSize: 15.5,
                color: element.name == _businessPlanLine.vehicleKind
                    ? Colors.blue
                    : Colors.black)),
        value: element.name,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出差计划'),
      ),
      body: AbsorbPointer(
        absorbing: BusinessSData.status < 10 ? false : true,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 15, bottom: 5),
                padding: EdgeInsets.only(left: 5),
                child: Row(
                  children: <Widget>[_begin(), _end()],
                ),
              ),
              _vType(),
              _customTextField('地点', _addressCtrl),
              _customTextField('计划', _planCtrl),
              _customTextField('电话', _contactCtrl),
              if (BusinessSData.status < 10) _button()
            ],
          ),
        ),
      ),
    );
  }

  Widget _vType() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      padding: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        // border: Border.all(width: 0.5, color: Color(0xffd4e0ef)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: <Widget>[
          Text('交通工具：'),
          DropdownButton(
              underline: Container(),
              hint: customText(value: '请选择'),
              value: _businessPlanLine.vehicleKind,
              items: _typeItems,
              onChanged: (v) {
                setState(() {
                  _businessPlanLine.vehicleKind = v;
                });
              })
        ],
      ),
    );
  }

  Widget _begin() {
    String beginDate = Utils.dateTimeToStr(_businessPlanLine.beginDate,
        pattern: 'yyyy-MM-dd HH:mm');
    return Expanded(
      child: Row(
        children: <Widget>[
          Text('开始：'),
          InkWell(
            onTap: () {
              _dateAndTimePick(_businessPlanLine.beginDate, 'begin');
            },
            child: customText(
              value: beginDate,
              color: Colors.blue,
              // fontWeight: FontWeight.w600
              backgroundColor: Color(0x80DFEEFC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _end() {
    String endDate = Utils.dateTimeToStr(_businessPlanLine.endDate,
        pattern: 'yyyy-MM-dd HH:mm');
    return Expanded(
      child: Row(
        children: <Widget>[
          Text('结束：'),
          InkWell(
              onTap: () {
                _dateAndTimePick(_businessPlanLine.endDate, 'end');
              },
              child: customText(
                value: endDate,
                color: Colors.blue,
                // fontWeight: FontWeight.w600
                backgroundColor: Color(0x80DFEEFC),
              )),
        ],
      ),
    );
  }

  void _dateAndTimePick(DateTime date, String type) async {
    // var date = _detail.beginDate;
    var time = TimeOfDay.fromDateTime(date);
    var datePick = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: defaultFirstDate,
        lastDate: defaultLastDate);
    if (datePick == null) return;
    var timePick = await showTimePicker(context: context, initialTime: time);
    if (timePick == null) return;
    var result = DateTime(datePick.year, datePick.month, datePick.day,
        timePick.hour, timePick.minute);
    setState(() {
      type == 'begin'
          ? _businessPlanLine.beginDate = result
          : _businessPlanLine.endDate = result;
      print(datePick.toString());
      print(timePick.toString());
    });
  }

  Widget _customTextField(String title, TextEditingController controller) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
    return Container(
      padding: EdgeInsets.only(left: 5),
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(title + '：'),
              Expanded(
                  child: TextField(
                      controller: controller,
                      onChanged: (v) {
                        if (controller != _contactCtrl) setState(() {});
                      },
                      inputFormatters:
                          (controller == _contactCtrl) ? [maskFormatter] : null,
                      keyboardType: (controller == _contactCtrl)
                          ? TextInputType.number
                          : null,
                      style: TextStyle(fontSize: 15.5),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(1),
                          hintStyle: TextStyle(fontSize: 16)))),
              if (controller.text != '' && BusinessSData.status < 10)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.text = '';
                      controller.clear(); //清除textfield的值
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(0, 5, 5, 5),
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 17,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _button() {
    String begin = Utils.dateTimeToStr(_businessPlanLine.beginDate,
        pattern: 'yyyy-MM-dd HH:mm');
    String end = Utils.dateTimeToStr(_businessPlanLine.endDate,
        pattern: 'yyyy-MM-dd HH:mm');
    return Container(
      child: Row(
        children: <Widget>[
          customButtom(Colors.blue, '确定', () {
            if (begin == end) {
              DialogUtils.showToast('开始结束时间不能相等');
            } else if (_businessPlanLine.vehicleKind == null) {
              DialogUtils.showToast('交通工具不能为空');
            } else if (_businessPlanLine.beginDate
                .isAfter(_businessPlanLine.endDate)) {
              DialogUtils.showToast('开始时间不能大于结束时间');
            } else if (_addressCtrl.text == '') {
              DialogUtils.showToast('地点不能为空');
            } else if (_planCtrl.text == '') {
              DialogUtils.showToast('计划不能为空');
            } else if (_contactCtrl.text == '') {
              DialogUtils.showToast('电话不能为空');
            } else {
              _businessPlanLine.address = _addressCtrl.text;
              _businessPlanLine.plan = _planCtrl.text;
              _businessPlanLine.tel = _contactCtrl.text;
              //如果传递过来的item为空，新增
              if (this.widget.item == null) {
                //返回item
                Navigator.pop(context, _businessPlanLine);
              } else {
                //通过修改静态变量传递的item，可以不需要返回值
                Navigator.pop(context, _businessPlanLine);
              }
            }
          })
        ],
      ),
    );
  }
}
