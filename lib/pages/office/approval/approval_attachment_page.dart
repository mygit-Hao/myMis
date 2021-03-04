import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/model/attachment.dart';
import 'package:mis_app/model/download_result.dart';
import 'package:mis_app/service/approval_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';

class ApprovalAttachmentPage extends StatefulWidget {
  final Map arguments;
  ApprovalAttachmentPage({Key key, this.arguments}) : super(key: key);

  @override
  _ApprovalAttachmentPageState createState() => _ApprovalAttachmentPageState();
}

class _ApprovalAttachmentPageState extends State<ApprovalAttachmentPage> {
  String _docType;
  String _docId;
  List<AttachmentModel> _attachmentList;

  @override
  void initState() {
    super.initState();

    _docType = widget.arguments['docType'];
    _docId = widget.arguments['docId'];
    _attachmentList = List();

    _loadAttachments();
  }

  void _loadAttachments() async {
    List<AttachmentModel> list =
        await ApprovalService.getAttachments(_docType, _docId);
    setState(() {
      _attachmentList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('附件'),
      ),
      body: SafeArea(
        child: Container(
          child: _mainWidget,
        ),
      ),
    );
  }

  Widget get _mainWidget {
    return ListView.builder(
      itemCount: _attachmentList.length,
      itemBuilder: (BuildContext context, int index) {
        AttachmentModel item = _attachmentList[index];

        Widget itemWidget;

        if (Utils.textIsEmptyOrWhiteSpace(item.remarks)) {
          itemWidget = ListTile(
            leading: getFileIcon(item.fileExt),
            title: Text(item.shortName),
            subtitle: Text(item.remarks),
          );
        } else {
          itemWidget = ListTile(
            leading: getFileIcon(item.fileExt),
            title: Text(item.shortName),
          );
        }

        return InkWell(
          onTap: () {
            _viewAttachment(item);
          },
          child: itemWidget,
        );
      },
    );
  }

  void _viewAttachment(AttachmentModel attachment) async {
    DownloadResultModel result = await downloadAttachmentWithFileExt(
        attachment.fileId, attachment.fileExt);
    if (result.success) {
      // print('文件已下载：${result.storageFilePath}');
      viewFile(context,
          storageFilePath: result.storageFilePath,
          filePath: attachment.filePath,
          title: attachment.remarks);
    } else {
      DialogUtils.showToast('附件下载失败');
    }
  }
}
