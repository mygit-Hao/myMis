import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/service/week_plan_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:provide/provide.dart';

class WeekPlanFilePage extends StatefulWidget {
  final Map<String, dynamic> arguments;
  const WeekPlanFilePage({Key key, this.arguments}) : super(key: key);

  @override
  _WeekPlanFilePageState createState() => _WeekPlanFilePageState();
}

class _WeekPlanFilePageState extends State<WeekPlanFilePage> {
  int _projId = 0;
  int status;
  bool _canFollow = true;
  bool _readOnly = false;
  ProgressDialog _progressDialog;

  @override
  Widget build(BuildContext context) {
    _progressDialog = customProgressDialog(context, '正在上传...');
    return Provide<WeekPlanProvide>(builder: (context, child, value) {
      _projId = value.detailModel.projData.projId;
      _readOnly = this.widget.arguments['readOnly'] ?? false;
      _canFollow = value.detailModel.projData.canFollow;
      List<Files> files = value.detailModel.files ?? [];
      List<Files> list = _getList(files);
      return Container(
        child: _filesWidget(list),
      );
    });
  }

  List<Files> _getList(List<Files> files) {
    int weekId = this.widget.arguments['weekId'];
    List<Files> list = [];
    files.forEach((element) {
      if (this.widget.arguments['weekId'] != null) {
        //进展的附件
        // print(
        //     '当前进展Id：${weekId.toString()}>>>>>>附件中进展ID：${element.weekId}}>>>相等:${element.weekId == (weekId)}');
        if (element.weekId == (weekId)) list.add(element);
      } else {
        //进展的附件
        if (element.fileType == 1) list.add(element);
      }
    });
    return list;
  }

  Widget _filesWidget(List<Files> files) {
    return Card(
      elevation: 0.0,
      color: Colors.grey[100],
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(5),
        child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 5, mainAxisSpacing: 5),
            itemCount: files.length + 1,
            itemBuilder: (context, index) {
              return _itemPhote(files, index);
            }),
      ),
    );
  }

  ///单个照片
  Widget _itemPhote(List<Files> _filesList, int index) {
    // String imageUrl = Utils.getImageUrl(_attachementList[index].fileId);
    return (index < _filesList.length)
        ? Stack(fit: StackFit.expand, children: [
            InkWell(
                onTap: () {
                  Utils.closeInput(context);
                  Utils.viewAttachment(context, _filesList[index]);
                },
                child: _filesList[index].fileExt == 'jpg'
                    ? Image.network(
                        Utils.getImageUrl(_filesList[index].fileId),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            getFileIcon(_filesList[index].fileExt),
                            customText(value: _filesList[index].shortName),
                          ],
                        ),
                      )),
            if (_filesList[index].canDelete && _canFollow && !_readOnly)
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                    onTap: () {
                      _deletefile(_filesList[index].weekPlanObjFilId);
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 20,
                    )),
              )
          ])
        : (_canFollow && _projId != 0)
            ? Container(
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
                                      _addFile('camera');
                                    },
                                    child: Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: Center(child: Text('拍照')),
                                        padding: EdgeInsets.only(bottom: 8)),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      _addFile('photo');
                                    },
                                    child: Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: Center(child: Text('相册')),
                                        padding: EdgeInsets.all(8)),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      _addFile('File');
                                    },
                                    child: Container(
                                        width: ScreenUtil().setWidth(700),
                                        child: Center(child: Text('文件')),
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
              )
            : Container();
  }

  void _addFile(String type) async {
    switch (type) {
      case 'camera':
        var imageFile = await Utils.takePhote();
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'photo':
        var imageFile = await Utils.takePhote(fromPhote: true);
        if (imageFile != null) _uploadFile(imageFile.path);
        break;
      case 'File':
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
    int weekId = this.widget.arguments['weekId'] ?? 0;
    await _progressDialog?.show();
    try {
      // navigatePage(context, weekPlanProgressPath);
      await WeekPlanService.uploadWeekFile(_projId, filePath, weekId: weekId)
          .then((value) async {
        if (value.errCode == 0) {
          toastBlackStyle('上传成功!');
          Provide.value<WeekPlanProvide>(context).setDetailData(value);
        } else {
          DialogUtils.showAlertDialog(context, value.errMsg,
              iconData: Icons.info, color: Colors.red);
        }
      });
    } finally {
      await _progressDialog.hide();
    }
  }

  void _deletefile(int weekPlanObjFilId) async {
    if (await DialogUtils.showConfirmDialog(context, '是否删除附件？',
            iconData: Icons.info_outline,
            color: Colors.red,
            confirmTextColor: Colors.red) ==
        true)
      try {
        // navigatePage(context, weekPlanProgressPath);
        await WeekPlanService.deleteWeekFile(weekPlanObjFilId).then((value) {
          if (value.errCode == 0) {
            DialogUtils.showToast('删除成功');
            Provide.value<WeekPlanProvide>(context).setDetailData(value);
          } else {
            DialogUtils.showToast(value.errMsg);
          }
        });
      } catch (e) {
        DialogUtils.showToast(e.toString());
      }
  }
}
