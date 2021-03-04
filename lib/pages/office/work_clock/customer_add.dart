import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/widget/base_container.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CustomerPageAdd extends StatefulWidget {
  @override
  _CustomerPageAddState createState() => _CustomerPageAddState();
}

class _CustomerPageAddState extends State<CustomerPageAdd> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactsController = TextEditingController();
  final TextEditingController _posiController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _adressController = TextEditingController();
  ProgressDialog _progressDialog;

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '正在保存数据...');
    return BaseContainer(
      parentContext: context,
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(title: Text('添加新客户')),
        body: Container(
          color: Colors.grey[100],
          width: ScreenUtil().setSp(750),
          // padding: EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _customerTextField(_nameController, '客户名称'),
                _customerTextField(_adressController, '地址'),
                _customerTextField(_contactsController, '联系人'),
                _customerTextField(_posiController, '职位'),
                _customerTextField(_phoneController, '电话号码'),
                Expanded(child: Container()),
                // _customerName(),
                // _contactPerson(),
                // _posi(),
                // _phote(),
                // _address(),
                _save()
              ]),
        ),
      ),
    );
  }

  Widget _customerTextField(TextEditingController controller, String textName) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '### #### ####', filter: {"#": RegExp(r'[0-9]')});
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.only(left: 8),
      color: Colors.white,
      child: Row(children: <Widget>[
        Text('$textName:'),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                    gapPadding: 0, borderSide: BorderSide.none),
                hintText: '请输入' + textName),
            controller: controller,
            inputFormatters:
                (controller == _phoneController) ? [maskFormatter] : null,
            keyboardType:
                (controller == _phoneController) ? TextInputType.number : null,
          ),
        )
      ]),
    );
  }

  Widget _save() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: ScreenUtil().setWidth(700),
      child: FlatButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          color: Colors.blue,
          onPressed: () {
            _addCustom();
          },
          child: Text(
            '保存',
            style: TextStyle(color: Colors.white),
          )),
    );
  }

  void _addCustom() async {
    if (_nameController.text == '') {
      toastBlackStyle('客户名称不能为空!');
    } else {
      setPageDataChanged(this.widget, true);
      try {
        await _progressDialog?.show();
        await WorkClockService.addCustom(
                _nameController.text,
                _contactsController.text,
                _posiController.text,
                _phoneController.text,
                _adressController.text,
                'recent')
            .then((value) async {
          // await _progressDialog?.hide();
          if (value['Success']) {
            toastBlackStyle("保存成功");
          } else {
            await _progressDialog?.hide();
            var msg = value['Msg'];
            DialogUtils.showAlertDialog(context, msg);
          }
        });
      } catch (e) {
        await _progressDialog?.hide();
        DialogUtils.showAlertDialog(context, e.toString());
      } finally {
        await _progressDialog?.hide();
      }
    }
  }
}
