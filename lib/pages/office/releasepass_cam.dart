import 'dart:convert';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/releaseFile.dart';
import 'package:mis_app/model/releasePass.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/scan_data.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/service/releasePass_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ReleasePassCamPage extends StatefulWidget {
  @override
  _ReleasePassCamPageState createState() => _ReleasePassCamPageState();
}

class _ReleasePassCamPageState extends State<ReleasePassCamPage> {
  // ReleasePassWrapper _release = ReleasePassWrapper();
  ReleasePassModel _releasePass = ReleasePassModel();
  List<ReleasePhotos> _photoList = [];
  ProgressDialog _progressDialog;

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '上传中...');
    return Scaffold(
      appBar: AppBar(
        title: Text('放行拍照'),
      ),
      body: Container(
        color: Colors.grey[200],
        child: Column(
          children: <Widget>[
            Container(margin: EdgeInsets.only(top: 10)),
            _detail(),
            _photos(),
          ],
        ),
      ),
    );
  }

  void _scanCode() async {
    try {
      var result = await BarcodeScanner.scan(
        options: ScanOptions(strings: scanOptionsStrings),
      );
      if ((result == null) ||
          (Utils.textIsEmptyOrWhiteSpace(result.rawContent))) return;
      ScanDataModel data = ScanDataModel.fromRawContent(result.rawContent);
      if (data.primaryType == "lp") {
        _getDetail(data.data);
      } else {
        DialogUtils.showToast('该二维码不是放行拍照二维码', toastLength: Toast.LENGTH_LONG);
      }
    } catch (e) {
      DialogUtils.showToast(e, toastLength: Toast.LENGTH_LONG);
    }
  }

  Widget _detail() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.fromLTRB(8, 2, 8, 10),
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          customText(
              value: '放行条', fontWeight: FontWeight.w600, color: Colors.black),
          _costomRow('单号', _releasePass.code),
          _costomRow('姓名', _releasePass.name),
          _costomRow('放行类型', _releasePass.passType),
          _costomRow('放行原因', _releasePass.reason),
          _btScan(),
        ],
      ),
    );
  }

  Widget _btScan() {
    return Container(
      height: 40,
      margin: EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
              child: FlatButton.icon(
            label: customText(
              value: '扫描',
              color: Colors.white,
            ),
            icon: Icon(
              Icons.crop_free,
              color: Colors.white,
            ),
            onPressed: _scanCode,
          ))
        ],
      ),
    );
  }

  Widget _photos() {
    return Expanded(
        child: Container(
            margin: EdgeInsets.fromLTRB(8, 2, 8, 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                customText(
                    value: '已拍照片',
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                Container(height: 5),
                GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5),
                    itemCount: _photoList.length + 1,
                    itemBuilder: (context, index) {
                      String url = '';
                      if (index < _photoList.length)
                        url = Utils.getImageUrl(_photoList[index].fileId);
                      return index < _photoList.length
                          ? _item(url)
                          : InkWell(
                              onTap: _takePhote,
                              child: Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.camera_alt,
                                    color: Colors.blue, size: 30),
                              ),
                            );
                    }),
              ],
            )));
  }

  Widget _item(String url) {
    return InkWell(
      onTap: () {
        Navigator.push(context, CustomRoute(ViewPhoto(url, null)));
      },
      child: Image.network(url, fit: BoxFit.cover),
    );
  }

  Widget _costomRow(String title, String content) {
    return Container(
      margin: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          customText(value: title + '：', fontSize: 14, color: Colors.black),
          Expanded(
              child: Text(
            content ?? '',
            style: TextStyle(fontSize: 14),
          )),
        ],
      ),
    );
  }

  void _getDetail(String id) async {
    ReleasePassWrapper release = await releaseDetail(id);
    setState(() {
      _releasePass = release.releasePass;
      _photoList = release.photos;
    });
  }

  void _takePhote() async {
    if (_releasePass.releasePassId == null) {
      DialogUtils.showToast('请先扫描单号');
    } else {
      var file = await Utils.takePhote();
      if (file != null) {
        _upload(file.path);
      }
    }
  }

  void _upload(String path) async {
    await _progressDialog?.show();
    try {
      RequestResult result =
          await uploadPhoto(_releasePass.releasePassId, path);
      if (result.success) {
        DialogUtils.showToast('照片上传成功');
        var requestdata = jsonDecode(result.data.toString());
        PhotosModel photos = PhotosModel.fromJson(requestdata);
        setState(() {
          _photoList = photos.photos;
        });
      } else {
        if (await DialogUtils.showConfirmDialog(context, '照片上传失败,是否重新上传？')) {
          _upload(path);
        }
      }
    } finally {
      await _progressDialog?.hide();
    }
  }
}
