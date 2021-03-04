import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/cust.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/date_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';

class CustStatementPage extends StatefulWidget {
  final Map arguments;
  CustStatementPage({Key key, this.arguments}) : super(key: key);

  @override
  _CustStatementPageState createState() => _CustStatementPageState();
}

class _CustStatementPageState extends State<CustStatementPage> {
  File _imgFile;
  CustModel _cust;
  DateTime _startDate;
  DateTime _endDate;
  bool _showPreviousData = true;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _endDate = Utils.firstDayOfMonth(Utils.today).add(Duration(days: -1));
    _startDate = Utils.firstDayOfMonth(_endDate);

    if (widget.arguments != null) {
      _cust = CustModel.fromJson(widget.arguments);
      WidgetsBinding.instance.addPostFrameCallback((Duration d) {
        _loadData();
      });
    } else {
      _cust = CustModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('对账单'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              _share();
            },
          ),
          IconButton(
            icon: Icon(Icons.cloud_download),
            onPressed: () {
              _saveToGallery();
            },
          ),
        ],
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  void _share() async {
    String path = SalesService.custStatementPdfFilePath;
    bool downloaded = false;

    await _progressDialog?.show();
    try {
      await Utils.deleteFile(path);

      // 检查文件是否成功删除，确保不会错发其他客户的对账单
      if (!await Utils.fileHasData(File(path))) {
        if (await SalesService.downloadCustStatement(
            _cust.custId, _startDate, _endDate, _showPreviousData, true)) {
          if (await Utils.fileHasData(File(path))) {
            downloaded = true;
          }
        }
      }
    } finally {
      await _progressDialog?.hide();
    }

    if (!downloaded) {
      DialogUtils.showToast('文件下载失败');
      return;
    }

    final RenderBox box = context.findRenderObject();

    await Share.shareFiles([path],
        text: '对账单',
        subject: '对账单',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  void _saveToGallery() async {
    if (_imgFile == null) {
      DialogUtils.showToast('请先查询数据');
      return;
    }
    PermissionStatus status = await Permission.storage.request();
    if (!status.isGranted) return;

    var bytes = Utils.fileToBytes(_imgFile);

    final result = await ImageGallerySaver.saveImage(bytes);
    // print(result);
    if (result != null) {
      String msg = result['isSuccess'] ? '对账单已保存到相册中' : '未能保存到相册';
      DialogUtils.showToast(msg);
    }
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        _headerWidget,
        Expanded(child: _statementWidget),
      ],
    );
  }

  Widget get _headerWidget {
    return Container(
      color: Theme.of(context).backgroundColor,
      padding: EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 0.0),
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.white,
          // fontSize: fontSizeDefault,
        ),
        child: Column(
          children: [
            _custInfoWidget,
            _searchWidget,
            _showPreviousWidget,
          ],
        ),
      ),
    );
  }

  Widget get _showPreviousWidget {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text('显示账龄'),
            Switch(
              value: _showPreviousData,
              onChanged: (bool value) {
                setState(() {
                  _showPreviousData = value;
                });
              },
            ),
          ],
        ),
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            _loadData();
          },
        ),
      ],
    );
  }

  Widget get _searchWidget {
    return Row(
      children: [
        Text('送货日期'),
        DateView(
          value: _startDate,
          fontSize: ConstValues.defaultFontSize,
          onTap: () {
            DialogUtils.showDatePickerDialog(context, _startDate,
                onValue: (val) {
              setState(() {
                _startDate = val;
                if (_startDate.isAfter(_endDate)) {
                  _endDate = Utils.lastDayOfMonth(_startDate);
                }
              });
            });
          },
        ),
        Icon(
          Icons.remove,
          size: ConstValues.defaultFontSize,
          color: Colors.white,
        ),
        DateView(
          value: _endDate,
          fontSize: ConstValues.defaultFontSize,
          onTap: () {
            DialogUtils.showDatePickerDialog(context, _endDate, onValue: (val) {
              setState(() {
                _endDate = val;
                if (_endDate.isBefore(_startDate)) {
                  _startDate = Utils.firstDayOfMonth(_endDate);
                }
              });
            });
          },
        ),
        /*
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            _loadData();
          },
        ),
        */
      ],
    );
  }

  void _loadData() async {
    await _progressDialog?.show();
    try {
      String path = SalesService.custStatementFilePath;

      await Utils.deleteFile(path);

      if (await SalesService.downloadCustStatement(
          _cust.custId, _startDate, _endDate, _showPreviousData, false)) {
        File newFile = File(path);

        if (!await Utils.fileHasData(newFile)) {
          return;
        }

        setState(() {
          _imgFile = newFile;
        });
      }
    } finally {
      await _progressDialog?.hide();
    }
  }

  Widget get _custInfoWidget {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Text(_cust.code),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _cust.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: ConstValues.defaultFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _statementWidget {
    if (_imgFile == null) {
      return Container();
    }

    return SingleChildScrollView(
      child: InkWell(
        child: Image.memory(
          Utils.fileToBytes(_imgFile),
          fit: BoxFit.fitWidth,
        ),
        onTap: () {
          Navigator.pushNamed(context, viewPhotoPath, arguments: {
            'storageFilePath': SalesService.custStatementFilePath,
            'title': '对账单',
          });
        },
      ),
    );
  }
}
