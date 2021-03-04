import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/borrow.dart';
import 'package:mis_app/model/borrow_detail.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/borrow_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/base_container.dart';
import 'package:progress_dialog/progress_dialog.dart';

class BorrowDetaiPage extends StatefulWidget {
  final int borrowId;
  const BorrowDetaiPage({Key key, this.borrowId}) : super(key: key);

  @override
  _BorrowDetaiPageState createState() => _BorrowDetaiPageState();
}

class _BorrowDetaiPageState extends State<BorrowDetaiPage> {
  final _rowMargin = EdgeInsets.only(top: 10, bottom: 5);
  // int _borrowId;
  String _upAmount = '';

  BorrowData _detailData = BorrowData();
  List<BorrowAttach> _attachList = [];
  List<DropdownMenuItem> _areaItems = [];
  List<DropdownMenuItem> _currencyItems = [];
  List<DropdownMenuItem> _payMethodItems = [];
  TextEditingController _reasonController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _bankCodeController = TextEditingController();
  TextEditingController _receiptController = TextEditingController();
  TextEditingController _bankNameController = TextEditingController();
  FLToastDefaults _flToastDefaults = FLToastDefaults();
  ProgressDialog _progressDialog;
  String text3 = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _detailData.borrowId = this.widget.borrowId;
      if (_detailData.borrowId != null) {
        _getDetail('getdetail');
      } else {
        setState(() {
          _detailData.areaId = BorrowSData.userStaff.defaultAreaId;
          _detailData.applyDate = Utils.today;
          _detailData.repaymentDate = DateTime.now();
          _detailData.staffId = BorrowSData.userStaff.staffId;
          _detailData.name = BorrowSData.userStaff.staffName;
          _detailData.deptName = BorrowSData.userStaff.deptName;
          _detailData.posi = BorrowSData.userStaff.posi;
          _getAreaDropDownItems();
          _getCurrencyDropDownItems();
          _getPayMethodDropDownItems();
        });
      }
    });
  }

  Future<bool> _willPop() async {
    bool willpop = true;
    if (_detailData.borrowId == null) {
      willpop = await DialogUtils.showConfirmDialog(context, "确定要退出吗?",
          confirmText: '退出', confirmTextColor: Colors.red);
    }
    return willpop;
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '加载中...');
    return BaseContainer(
      parentContext: context,
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.black54,
          title: Text(_detailData.borrowId != null ? '借款借据编辑' : '借款借据新增'),
        ),
        body: FLToastProvider(
          defaults: _flToastDefaults,
          child: Container(
            // padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Form(
                    // autovalidate: true,
                    autovalidateMode: AutovalidateMode.always,
                    onWillPop: _willPop,
                    child: AbsorbPointer(
                      absorbing: _detailData.status >= 10 ? true : false,
                      child: Column(
                        children: <Widget>[
                          _customTitle('基本信息'),
                          _customContainner(
                            Column(
                              children: <Widget>[
                                _borrowCode(),
                                _areaAndApplyData(),
                                _personInfo(),
                                _posi(),
                              ],
                            ),
                          ),
                          _customTitle('借款'),
                          _customContainner(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _currencyAndAmount(),
                                _capitilize(),
                                _customTextField('借款原因', _reasonController),
                              ],
                            ),
                          ),
                          _customTitle('还款'),
                          _customContainner(
                            Column(
                              children: <Widget>[
                                _payMethod(),
                                _customTextField('收款人账号', _bankCodeController),
                                _customTextField('收款人/单位', _receiptController),
                                _customTextField('收款银行', _bankNameController),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _customTitle('附件'),
                  _attachments(),
                  // Expanded(child: Container()),
                  if (_detailData.status < 10) _draftStatubuttons(),
                  if (_detailData.status == 10) _submitStatusButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _borrowCode() {
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Text('单号：'),
              Text(_detailData.code ?? '（未保存）'),
            ],
          )),
          Expanded(
              child: Row(
            children: <Widget>[
              Text('状态：'),
              Text(_detailData.statusName ?? '',
                  style: statusTextStyle(_detailData.status)),
            ],
          ))
        ],
      ),
    );
  }

  Widget _areaAndApplyData() {
    String applydate = Utils.dateTimeToStr(_detailData.applyDate);
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Text('项目：'),
              DropdownButton(
                  underline: Container(),
                  isDense: true,
                  value: _detailData.areaId,
                  items: _areaItems,
                  onChanged: (val) {
                    _detailData.areaId = val;
                    _getAreaDropDownItems();
                    setState(() {});
                  })
            ],
          )),
          Expanded(
              child: InkWell(
            // onTap: () async {
            //   DialogUtils.showDatePickerDialog(context, _detailData.applyDate,
            //       onValue: (v) {
            //     if (v == null) return;
            //     setState(() {
            //       _detailData.applyDate = v;
            //     });
            //   });
            // },
            child: Row(
              children: <Widget>[
                Text('申请日期：'),
                customText(value: applydate, color: Colors.orange),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _personInfo() {
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Text('部门：'),
              Text(_detailData.deptName ?? ''),
            ],
          )),
          Expanded(
              child: InkWell(
            onTap: () async {
              String result = await showSearch(
                  context: context,
                  delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff));
              if (result == null || result == '') return;
              StaffModel staffModel = StaffModel.fromJson(jsonDecode(result));
              setState(() {
                _detailData.staffId = staffModel.staffId;
                _detailData.deptName = staffModel.deptName;
                _detailData.posi = staffModel.posi;
                _detailData.name = staffModel.name;
              });
            },
            child: Row(
              children: <Widget>[
                Text('借款人/单位：'),
                Text(_detailData.name ?? ''),
                Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _posi() {
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Text('职位：'),
          Text(_detailData.posi ?? ''),
        ],
      ),
    );
  }

  Widget _customTitle(String title) {
    return Container(
      padding: EdgeInsets.only(left: 8, top: 8, bottom: 3),
      color: Colors.grey[100],
      child: Row(
        children: <Widget>[Expanded(child: Text(title))],
      ),
    );
  }

  Widget _customContainner(Widget child) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(width: 0.2), bottom: BorderSide(width: 0.2))),
      child: child,
    );
  }

  Widget _currencyAndAmount() {
    _amountController.text = Utils.getFormatNum(_detailData.amount);
    return Container(
      child: Flex(
        direction: Axis.horizontal,
        children: <Widget>[
          Expanded(
              flex: 3,
              child: Row(children: <Widget>[
                Text('币种：'),
                Container(
                  padding: EdgeInsets.all(1),
                  decoration: containerDeroation(color: Colors.white),
                  child: DropdownButton(
                      isDense: true,
                      underline: Container(),
                      value: _detailData.currency,
                      items: _currencyItems,
                      onChanged: (val) {
                        _detailData.currency = val;
                        _getCurrencyDropDownItems();
                        setState(() {});
                      }),
                )
              ])),
          Expanded(
              flex: 4,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                  ),
                  Text('金额：'),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        double result = await DialogUtils.showNumberDialog(
                            context,
                            title: '借款金额',
                            defaultValue: _detailData.amount);
                        if (result == null) return;
                        setState(() {
                          _detailData.amount = result;
                        });
                      },
                      child: Container(
                        height: 35,
                        padding: EdgeInsets.all(1),
                        child: TextField(
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                          enabled: false,
                          controller: _amountController,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: EdgeInsets.all(1),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                              width: 0.5,
                              color: Color(0xffd4e0ef),
                            )),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text('元')
                ],
              ))
        ],
      ),
    );
  }

  Widget _capitilize() {
    _upAmount = Utils.convertNumToChinese(_detailData.amount);
    return Container(
      alignment: Alignment.centerLeft,
      margin: _rowMargin,
      child: Wrap(
        children: <Widget>[Text('金额（大写）：'), Text(_upAmount)],
      ),
    );
  }

  Widget _payMethod() {
    String repayDate = Utils.dateTimeToStr(_detailData.repaymentDate);
    return Container(
      margin: _rowMargin,
      child: Row(
        children: <Widget>[
          Expanded(
              child: Row(
            children: <Widget>[
              Text('付款方式：'),
              Container(
                padding: EdgeInsets.all(1),
                decoration: containerDeroation(color: Colors.white),
                child: DropdownButton(
                    underline: Container(),
                    isDense: true,
                    hint: customText(value: '请选择', fontSize: 15),
                    value: _detailData.payment,
                    items: _payMethodItems,
                    onChanged: (val) {
                      _detailData.payment = val;
                      _getPayMethodDropDownItems();
                      setState(() {});
                    }),
              )
            ],
          )),
          Expanded(
              child: InkWell(
            onTap: () {
              DialogUtils.showDatePickerDialog(
                  context, _detailData.repaymentDate, onValue: (v) {
                if (v == null) return;
                setState(() {
                  _detailData.repaymentDate = v;
                });
              });
            },
            child: Row(
              children: <Widget>[
                Text('还款日期：'),
                Container(
                    padding: EdgeInsets.all(3),
                    decoration: containerDeroation(color: Colors.white),
                    child: customText(value: repayDate, color: Colors.orange)),
              ],
            ),
          ))
        ],
      ),
    );
  }

  Widget _customTextField(String title, TextEditingController controller) {
    var maskFormatter = new MaskTextInputFormatter(
        mask: '#### #### #### #### ####', filter: {"#": RegExp(r'[0-9]')});
    return Container(
        margin: EdgeInsets.only(top: 5),
        decoration: containerDeroation(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (controller == _reasonController)
              Text('借款原因：', style: TextStyle(fontSize: 15)),
            // customText(value: '借款原因：', fontSize: 15),
            Row(
              children: <Widget>[
                if (controller != _reasonController) Text(title + '：'),
                Expanded(
                    child: TextFormField(
                  controller: controller,
                  onChanged: (v) {
                    if (controller != _bankCodeController) setState(() {});
                  },
                  maxLines: controller == _reasonController ? 3 : 1,
                  // maxLength: controller != _bankCodeController ? 20 : 50,
                  inputFormatters: (controller == _bankCodeController)
                      ? [maskFormatter]
                      : null,
                  keyboardType: (controller == _bankCodeController)
                      ? TextInputType.number
                      : null,
                  style: TextStyle(fontSize: 15.5),
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(1),
                      border: InputBorder.none),
                  validator: (v) {
                    return v.length > 0 ? null : '请输入$title';
                  },
                )),
                if (controller.text != '' && _detailData.status < 10)
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
        ));
  }

  Widget _attachments() {
    return Container(
        // height: ScreenUtil().setHeight(250),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(width: 0.2), bottom: BorderSide(width: 0.2))),
        child: GridView.builder(
            shrinkWrap: true,
            itemCount: _attachList.length + 1,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, mainAxisSpacing: 5, crossAxisSpacing: 5),
            itemBuilder: (context, index) {
              return _item(index);
            }));
  }

  Widget _item(int index) {
    return (index < _attachList.length)
        ? Stack(
            fit: StackFit.expand,
            children: <Widget>[
              InkWell(
                onTap: () {
                  Utils.closeInput(context);
                  _attachList[index].fileType == 'Photo'
                      ? Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                          return ViewPhoto(
                              Utils.getImageUrl(_attachList[index].fileId),
                              _attachList[index].file);
                        }))
                      : Utils.viewAttachment(context, _attachList[index]);
                },
                child: _attachList[index].fileType == 'Photo'
                    ? Image.network(
                        Utils.getImageUrl(
                          _attachList[index].fileId,
                        ),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                              size: 40,
                            ),
                            customText(value: _attachList[index].shortName),
                          ],
                        ),
                      ),
              ),
              _detailData.status < 10
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                          onTap: () {
                            _deleteAttach(_attachList[index]);
                            setState(() {});
                          },
                          child: Icon(
                            Icons.clear,
                            color: Colors.white,
                          )),
                    )
                  : Container()
            ],
          )
        : (_detailData.status < 10
            ? Container(
                color: Colors.grey[100],
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10))),
                        context: context,
                        builder: (context) {
                          return Container(
                            // padding: EdgeInsets.all(10),
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  InkWell(
                                    onTap: () async {
                                      _addAttachement('camera');
                                    },
                                    child: Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: Center(child: Text('拍照')),
                                        padding: EdgeInsets.all(8)),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      _addAttachement('photo');
                                    },
                                    child: Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: Center(child: Text('相册')),
                                        padding: EdgeInsets.all(8)),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      _addAttachement('PDF');
                                    },
                                    child: Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: Center(child: Text('PDF文件')),
                                        padding: EdgeInsets.all(8)),
                                  ),
                                  InkWell(
                                      child: Row(
                                    children: <Widget>[
                                      customButtom(Colors.blue, '关闭', () {
                                        Navigator.pop(context);
                                      }),
                                    ],
                                  ))
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Icon(
                    Icons.add,
                    color: Colors.grey,
                  ),
                ),
              )
            : Container());
  }

  ///添加照片
  void _addAttachement(String type) async {
    bool isSaved = false;
    Utils.closeInput(context);
    if (_detailData.borrowId == null) {
      bool comfirm =
          await DialogUtils.showConfirmDialog(context, '单据尚未保存，是否保存后进行附件上传？');
      if (comfirm) isSaved = await _save();
    } else {
      isSaved = true;
    }
    if (isSaved == null || isSaved == false) return;
    switch (type) {
      case 'camera':
        var imageFile = await Utils.takePhote();
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'photo':
        var imageFile = await Utils.takePhote(fromPhote: true);
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'PDF':
        var fileList = await Utils.selectFile();
        if (fileList != null) {
          fileList.forEach((element) {
            _uploadFile(element.path);
          });
        }
        break;
      default:
    }
  }

  void _deleteAttach(BorrowAttach item) async {
    bool isDelete = await DialogUtils.showConfirmDialog(context, '是否删除该附件?',
        iconData: Icons.info, color: Colors.red);
    if (isDelete == true) {
      try {
        await _progressDialog?.show();
        await BorrowService.deleteAttach(
                _detailData.borrowId, item.borrowFileId)
            .then((value) async {
          if (value['ErrCode'] == 0) {
            await _progressDialog?.hide();
            toastBlackStyle('删除成功!');
            _attachList.clear();
            List attches = value['Attachments'];
            setState(() {
              attches.forEach((element) {
                _attachList.add(BorrowAttach.fromJson(element));
              });
            });
          } else {
            _progressDialog?.hide();
            DialogUtils.showAlertDialog(context, value['ErrMsg'],
                iconData: Icons.info, color: Colors.red);
          }
        });
      } finally {
        await _progressDialog.hide();
      }
    }
  }

  void _uploadFile(filePath) async {
    await _progressDialog?.show();
    try {
      await BorrowService.upload(_detailData.borrowId, filePath)
          .then((value) async {
        if (value['ErrCode'] == 0) {
          await _progressDialog?.hide();
          toastBlackStyle('上传成功!');
          // _updateUi(value);
          List attches = value['Atachments'];
          _attachList.clear();
          setState(() {
            attches.forEach((element) {
              _attachList.add(BorrowAttach.fromJson(element));
            });
          });
        } else {
          DialogUtils.showAlertDialog(context, value['ErrMsg'],
              iconData: Icons.info, color: Colors.red);
        }
      });
    } finally {
      await _progressDialog?.hide();
    }
  }

  Widget _draftStatubuttons() {
    return Container(
      child: Row(
        children: <Widget>[
          if (_detailData.borrowId != null)
            customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
          customButtom(Colors.green, '提交', _submit),
        ],
      ),
    );
  }

  Widget _submitStatusButtons() {
    return Container(
      child: Row(
        children: <Widget>[customButtom(Colors.amber, '取消提交', _toDraft)],
      ),
    );
  }

  void _delete() async {
    Utils.closeInput(context);
    var comfirm = await DialogUtils.showConfirmDialog(context, '是否删除该单据？',
        iconData: Icons.info, color: Colors.red);
    if (comfirm) {
      await _progressDialog?.show();
      try {
        setPageDataChanged(this.widget, true);
        Map<String, dynamic> result =
            await BorrowService.delete(_detailData.borrowId);
        if (result['ErrCode'] == 0) {
          DialogUtils.showToast('删除成功!');
          Navigator.pop(context);
        } else {
          await _progressDialog?.hide();
          var msg = result['ErrMsg'];
          DialogUtils.showAlertDialog(context, msg);
        }
      } finally {
        await _progressDialog?.hide();
      }
    }
  }

  void _toDraft() async {
    Utils.closeInput(context);
    var comfirm = await DialogUtils.showConfirmDialog(context, '是否取消提交');
    if (comfirm) {
      await _progressDialog?.show();
      try {
        setPageDataChanged(this.widget, true);
        BorrowDetaiModel detailModel =
            await BorrowService.toDraft(_detailData.borrowId);
        if (detailModel.errCode == 0) {
          DialogUtils.showToast('取消成功!');
          _updateUi(detailModel);
        } else {
          await _progressDialog?.hide();
          var msg = detailModel.errMsg;
          DialogUtils.showAlertDialog(context, msg);
        }
      } finally {
        await _progressDialog?.hide();
      }
    }
  }

  bool _getInfo() {
    bool hasData = true;
    // _detailData.amount = double.parse(_amountController.text);
    _detailData.reason = _reasonController.text;
    _detailData.bankCode = _bankCodeController.text;
    _detailData.receipt = _receiptController.text;
    _detailData.bankName = _bankNameController.text;
    if (_detailData.amount == 0.0) {
      DialogUtils.showToast('借款金额不能为空');
      hasData = false;
    } else if (_reasonController.text == '') {
      DialogUtils.showToast('借款原因不能为空');
      hasData = false;
    } else if (_detailData.payment == null) {
      DialogUtils.showToast('请选择付款方式');
      hasData = false;
    } else if (_detailData.bankCode == '') {
      DialogUtils.showToast('收款人账号不能为空');
      hasData = false;
    } else if (_detailData.receipt == '') {
      DialogUtils.showToast('收款人不能为空');
      hasData = false;
    } else if (_detailData.bankName == '') {
      DialogUtils.showToast('收款银行不能为空');
      hasData = false;
    }
    return hasData;
  }

  Future<bool> _save() async {
    bool isSave = false;
    if (_getInfo()) {
      await _progressDialog?.show();
      Utils.closeInput(context);
      setPageDataChanged(this.widget, true);
      String action = (_detailData.borrowId == null) ? 'add' : 'update';
      try {
        BorrowDetaiModel detailModel =
            await BorrowService.borrowRequest(action, _detailData, false);
        if (detailModel.errCode == 0) {
          isSave = true;
          DialogUtils.showToast('保存成功');
          _updateUi(detailModel);
        } else {
          await _progressDialog?.hide();
          var msg = detailModel.errMsg;
          DialogUtils.showAlertDialog(context, msg);
        }
      } finally {
        await _progressDialog?.hide();
      }
    }

    return isSave;
  }

  void _submit() async {
    if (_getInfo()) {
      await _progressDialog?.show();
      Utils.closeInput(context);
      setPageDataChanged(this.widget, true);
      String action = (_detailData.borrowId == null) ? 'add' : 'update';
      try {
        BorrowDetaiModel detailModel =
            await BorrowService.borrowRequest(action, _detailData, true);
        if (detailModel.errCode == 0) {
          DialogUtils.showToast('提交成功');
          _updateUi(detailModel);
        } else {
          await _progressDialog?.hide();
          String msg = detailModel.errMsg;
          DialogUtils.showAlertDialog(context, msg);
        }
      } finally {
        _progressDialog?.hide();
      }
    }
  }

  void _getDetail(String action) async {
    await _progressDialog?.show();
    try {
      BorrowDetaiModel detailModel =
          await BorrowService.getDetail(_detailData.borrowId);
      _updateUi(detailModel);
    } finally {
      await _progressDialog?.hide();
    }
  }

  _updateUi(BorrowDetaiModel detailModel) {
    setState(() {
      _detailData = detailModel.detaildata[0];
      _attachList = detailModel.attachments;
      _reasonController.text = _detailData.reason;
      _amountController.text = Utils.getFormatNum(_detailData.amount);
      _bankCodeController.text = _detailData.bankCode;
      _receiptController.text = _detailData.receipt;
      _bankNameController.text = _detailData.bankName;
      _getAreaDropDownItems();
      _getCurrencyDropDownItems();
      _getPayMethodDropDownItems();
    });
  }

  void _getAreaDropDownItems() {
    _areaItems.clear();
    BorrowSData.area.forEach((e) {
      _areaItems.add(DropdownMenuItem(
          value: e.areaId,
          child: Text(
            e.shortName,
            style: TextStyle(
                fontSize: 16,
                color: e.areaId == _detailData.areaId
                    ? Colors.blue
                    : Colors.black),
          )));
    });
  }

  void _getCurrencyDropDownItems() {
    _currencyItems.clear();
    BorrowSData.currency.forEach((e) {
      if (e.isDefault && _detailData.currency == '')
        _detailData.currency = e.currencyCode;
      _currencyItems.add(DropdownMenuItem(
          value: e.currencyCode,
          child: Text(
            e.currencyName,
            style: TextStyle(
              fontSize: 15,
              color: e.currencyCode == _detailData.currency
                  ? Colors.blue
                  : Colors.black,
            ),
          )));
    });
  }

  void _getPayMethodDropDownItems() {
    _payMethodItems.clear();
    BorrowSData.paymentMethod.forEach((element) {
      _payMethodItems.add(DropdownMenuItem(
        value: element.methodCode,
        child: Text(
          element.methodName,
          style: TextStyle(
              fontSize: 16,
              color: element.methodCode == _detailData.payment
                  ? Colors.blue
                  : Colors.black),
        ),
      ));
    });
  }
}
