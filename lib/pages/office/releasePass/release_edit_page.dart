import 'dart:convert';

import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/area.dart';
import 'package:mis_app/model/download_result.dart';
import 'package:mis_app/model/release.dart';
import 'package:mis_app/model/releasePass.dart';
import 'package:mis_app/model/staff.dart';
import 'package:mis_app/pages/common/search_staff.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/releasePass_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ReleaseEditPage extends StatefulWidget {
  final Map arguments;

  ReleaseEditPage({this.arguments});
  @override
  _ReleaseEditPageState createState() => _ReleaseEditPageState();
}

class _ReleaseEditPageState extends State<ReleaseEditPage> {
  ReleasePassWrapper _releasePassWrapper = new ReleasePassWrapper();
  ReleasePassModel _dataRelease = new ReleasePassModel();
  final TextEditingController _group = TextEditingController();
  final TextEditingController _reason = TextEditingController();
  FLToastDefaults _flToastDefaults = FLToastDefaults();

  List<Attachments> _attachementList = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();
    _getDefaltData();
    if (this.widget.arguments != null) {
      _dataRelease.releasePassId = this.widget.arguments['releasePassId'];
      //等待界面更新后获取数据
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _getDetail();
      });
    }
  }

  void _getDefaltData() {
    _dataRelease.status = 0;
    _dataRelease.typeCode = "1";
    _dataRelease.areaId = ReleaseBaseDB.areaId;
    _dataRelease.staffId = ReleaseBaseDB.staffID;
    _dataRelease.staffCode = ReleaseBaseDB.staffCode;
    _dataRelease.name = ReleaseBaseDB.staffName;
    _dataRelease.deptName = ReleaseBaseDB.deptName;
    _dataRelease.applyDate = Utils.today;
  }

  void _getDetail() async {
    Function dismiss = FLToast.loading();
    try {
      _releasePassWrapper = await releaseDetail(_dataRelease.releasePassId);
      // _dataRelease = _releasePassWrapper.releasePass;
      // _attachementList = _releasePassWrapper.attachments;
      //_dataRelease = await releaseDetail(_dataRelease.releasePassId);
      setState(() {
        _showDetail(_releasePassWrapper);
      });
    } catch (e) {
      dismiss();
    } finally {
      dismiss();
    }
  }

  void _showDetail(ReleasePassWrapper releasePassWrapper) {
    _dataRelease = releasePassWrapper.releasePass;
    _attachementList = releasePassWrapper.attachments;
    if (_dataRelease != null) {
      _group.text = _dataRelease.groupName;
      _reason.text = _dataRelease.reason;
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, 'loading...');
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('放行条'),
          actions: <Widget>[
            InkWell(
              onTap: () {
                DialogUtils.showAlertDialog(context, '新增时上传附件前需要保存单据！',
                    iconData: Icons.help, color: Colors.blue);
              },
              child: Container(
                  padding: EdgeInsets.all(10), child: Icon(Icons.help_outline)),
            )
          ],
        ),
        body: FLToastProvider(
          defaults: _flToastDefaults,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: AbsorbPointer(
                    absorbing: _dataRelease.status > 0,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          _headerWidget(),
                          _nameWidget(),
                          _deptWidget(),
                          _areaWidget(),
                          _typeWidget(),
                          _reasonWidget("放行原因：", _reason),
                          _attachementWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
                _dataRelease.status < 10
                    ? _draftButtons()
                    : (_dataRelease.status == 10 ? _submitButtons() : Text('')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('单号：'),
                Expanded(
                  child: Container(
                    height: ScreenUtil().setHeight(45.0),
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        _dataRelease.code ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('状态：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataRelease.statusName ?? '草稿',
                      textAlign: TextAlign.center,
                      style: statusTextStyle(_dataRelease.status ?? 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('工号：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataRelease.staffCode,
                      textAlign: TextAlign.center,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      Utils.closeInput(context);
                      _staffSelect(context);
                    }),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('姓名：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataRelease.name,
                      textAlign: TextAlign.center,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _deptWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Text('部门：'),
                Expanded(
                  child: Container(
                    child: Text(
                      _dataRelease.deptName ?? '11',
                      textAlign: TextAlign.center,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('日期：'),
                Expanded(
                  child: Container(
                    child: InkWell(
                      // onTap: () {
                      //   Utils.closeInput(context);
                      //   _selectDate();
                      // },
                      child: Text(
                        Utils.dateTimeToStr(_dataRelease.applyDate),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _areaWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                  child: Text('班组：'),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    height: ScreenUtil().setHeight(50),
                    child: TextField(
                      controller: _group,
                      autofocus: false,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Row(
              children: <Widget>[
                Text('项目：'),
                Expanded(
                  child: DropdownButton(
                    isExpanded: true,
                    underline: Container(
                      color: Colors.blue,
                      height: 0.0,
                    ),
                    value: _dataRelease.areaId,
                    items: generateItemList(),
                    onChanged: (item) {
                      Utils.closeInput(context);
                      setState(() {
                        _dataRelease.areaId = item;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeWidget() {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Row(
        children: <Widget>[
          Text('放行类型：'),
          Expanded(
            child: DropdownButton(
              isExpanded: true,
              underline: Container(
                color: Colors.blue,
                height: 0.0,
              ),
              value: _dataRelease.typeCode,
              items: getTypeList(),
              onChanged: (item) {
                Utils.closeInput(context);
                setState(() {
                  _dataRelease.typeCode = item;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _reasonWidget(reason, controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(reason),
          TextField(
            controller: controller,
            autofocus: false,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _attachementWidget() {
    return Container(
      // height: ScreenUtil().setHeight(430),
      child: Card(
        elevation: 0.0,
        color: Colors.grey[100],
        margin: EdgeInsets.all(0),
        child: Container(
          padding: EdgeInsets.all(5),
          child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
              itemCount: _dataRelease.status <= 0
                  ? _attachementList.length + 1
                  : _attachementList.length,
              itemBuilder: (context, index) {
                return _itemPhote(index);
              }),
        ),
      ),
    );
  }

  Widget _itemPhote(int index) {
    return (index < _attachementList.length)
        ? Stack(fit: StackFit.expand, children: [
            InkWell(
                onTap: () {
                  Utils.closeInput(context);
                  _attachementList[index].fileType == 'Photo'
                      ? Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                          return ViewPhoto(
                              Utils.getImageUrl(_attachementList[index].fileId),
                              _attachementList[index].file);
                        }))
                      : _viewAttachment(_attachementList[index]);
                },
                child: _attachementList[index].fileType == 'Photo'
                    ? Image.network(
                        Utils.getImageUrl(_attachementList[index].fileId),
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
                            customText(
                                value: _attachementList[index].shortName),
                          ],
                        ),
                      )),
            _dataRelease.status < 10
                ? Positioned(
                    top: 0,
                    right: 0,
                    child: InkWell(
                        onTap: () {
                          _deleteAttachement(index);
                        },
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                        )),
                  )
                : Container()
          ])
        : Container(
            color: Colors.grey[200],
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
                        padding: EdgeInsets.all(10),
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
                                    padding: EdgeInsets.only(bottom: 8)),
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
                                    padding: EdgeInsets.only(top: 8)),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Icon(Icons.add, color: Colors.grey[400], size: 40),
            ),
          );
  }

  void _viewAttachment(Attachments attachment) async {
    DownloadResultModel result = await downloadAttachmentWithFileExt(
        attachment.fileId, attachment.fileExt);
    if (result.success) {
      viewFile(context,
          storageFilePath: result.storageFilePath,
          filePath: attachment.fileName,
          title: attachment.remarks);
    } else {
      DialogUtils.showToast('附件下载失败');
    }
  }

  void _addAttachement(String type) async {
    bool isSaved = true;
    Utils.closeInput(context);
    if (_dataRelease.releasePassId == null) isSaved = await _save();
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

  void _uploadFile(filePath) async {
    await _progressDialog?.show();
    try {
      await upload(_dataRelease.releasePassId, filePath).then((value) async {
        if (value.errCode == 0) {
          await _progressDialog?.hide();
          toastBlackStyle('上传成功!');
          _attachementList = value.attachments;
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg,
              iconData: Icons.info, color: Colors.red);
        }
      });
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _deleteAttachement(int index) async {
    bool result = await DialogUtils.showConfirmDialog(context, '是否删除该附件？',
        iconData: Icons.info, color: Colors.red);
    if (result) {
      String fileId = _attachementList[index].releasePassFileId;
      await attachementDelete(_dataRelease.releasePassId, fileId).then((value) {
        if (value.errCode == 0) {
          _attachementList.removeAt(index);
          toastBlackStyle('删除成功!');
          setState(() {});
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg);
        }
      });
    }
  }

  Widget _draftButtons() {
    bool visible = _dataRelease.code == null ? false : true;
    return Container(
      height: ScreenUtil().setWidth(100),
      child: Row(
        children: <Widget>[
          if (visible) customButtom(Colors.red, '删除', _delete),
          customButtom(Colors.blue, '保存', _save),
          customButtom(Colors.green, '提交', _submit),
        ],
      ),
    );
  }

  Widget _submitButtons() {
    return Container(
      height: ScreenUtil().setWidth(100),
      child: Row(
        children: <Widget>[
          customButtom(Colors.orange[300], '取消提交', _toDraft),
        ],
      ),
    );
  }

  Future<bool> _save() async {
    bool result;
    if (_checkData()) {
      result = await _request('save');
    }
    return result;
  }

  void _submit() {
    if (!_checkData()) {
      return;
    }
    _request('submit');
  }

  void _toDraft() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否取消提交?',
        iconData: Icons.info, color: Colors.red);
    if (result) _request('todraft');
  }

  void _delete() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否删除该条记录?',
        iconData: Icons.info, color: Colors.red);
    if (result) _request('delete');
  }

  List<DropdownMenuItem> generateItemList() {
    var result = ReleaseBaseDB.areaList.map((Area item) {
      return DropdownMenuItem(
        child: Text(item.shortName),
        value: item.areaId,
      );
    }).toList();

    return result;
  }

  List<DropdownMenuItem> getTypeList() {
    var result = ReleaseBaseDB.typeList.map((PassType item) {
      return DropdownMenuItem(
        child: Text(item.typeName),
        value: item.typeCode,
      );
    }).toList();

    return result;
  }

  // Future<void> _selectDate() async {
  //   final DateTime date = await showDatePicker(
  //     context: context,
  //     initialDate: _dataRelease.applyDate, // 初始日期
  //     firstDate: DateTime(1900), // 可选择的最早日期
  //     lastDate: DateTime(2100), // 可选择的最晚日期
  //   );
  //   if (date == null) return;

  //   setState(() {
  //     _dataRelease.applyDate = date;
  //     // _applyDate = Utils.dateTimeToStr(date);
  //   });
  // }

  void _staffSelect(BuildContext context) async {
    var result = await showSearch(
        context: context,
        delegate: SearchStaffDelegate(Prefs.keyHistorySelectStaff));
    if (result == null || result == '') return;
    StaffModel staffModel = StaffModel.fromJson(jsonDecode(result));
    setState(() {
      if (result != null) {
        setState(
          () {
            _dataRelease.staffCode = staffModel.code;
            _dataRelease.staffId = staffModel.staffId;
            _dataRelease.name = staffModel.name;
            _dataRelease.deptName = staffModel.deptName;
          },
        );
      }
    });
  }

  Future<bool> _request(String action) async {
    bool result;
    try {
      await _progressDialog?.show();
      _dataRelease.groupName = _group.text;
      _dataRelease.reason = _reason.text;
      ReleasePassWrapper _data;
      setPageDataChanged(this.widget, true);
      switch (action) {
        case 'save':
          _data = _dataRelease.code == null
              ? await releaseService('add', _dataRelease, '')
              : await releaseService('update', _dataRelease, '');
          break;
        case 'submit':
          _data = _dataRelease.code == null
              ? await releaseService('add', _dataRelease, 'submit')
              : await releaseService('update', _dataRelease, 'submit');
          break;
        case 'todraft':
          _data = await releaseService('todraft', _dataRelease, '');
          break;
        case 'delete':
          Map<dynamic, dynamic> result =
              await delete('delete', _dataRelease.releasePassId);
          if (result['ErrCode'] == 0) {
            Fluttertoast.showToast(msg: "删除成功！", gravity: ToastGravity.CENTER);
            Navigator.of(context).pop();
          } else {
            DialogUtils.showConfirmDialog(context, result['ErrMsg'].toString());
          }
          break;
        default:
      }
      int errCode = _data.errCode;
      String errMsg = _data.errMsg;
      if (errCode == 0) {
        await _progressDialog?.hide();
        if (action == 'save') {
          toastBlackStyle('保存成功!');
          result = true;
        } else if (action == 'submit') {
          toastBlackStyle('提交成功!');
          result = true;
        } else if (action == 'todraft') {
          toastBlackStyle('取消成功!');
          result = true;
        }
        setState(() {
          _dataRelease = _data.releasePass;
          _group.text = _dataRelease.groupName;
          _reason.text = _dataRelease.reason;
          Utils.closeInput(context);
        });
      } else {
        await _progressDialog?.hide();
        DialogUtils.showAlertDialog(context, errMsg);
        result = false;
      }
    } catch (e) {} finally {
      await _progressDialog?.hide();
    }
    return result;
  }

  bool _checkData() {
    if (!_checkInputText(_reason, "请输入放行原因！")) return false;
    return true;
  }

  bool _checkInputText(TextEditingController controller, String msg) {
    if (Utils.textIsEmptyOrWhiteSpace(controller.text)) {
      DialogUtils.showToast(msg);
      return false;
    }
    return true;
  }
}
