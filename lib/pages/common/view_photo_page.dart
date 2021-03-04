import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mis_app/pages/common/base_view_page.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:photo_view/photo_view.dart';

class ViewPhotoPage extends StatelessWidget {
  final Map arguments;

  const ViewPhotoPage({Key key, this.arguments}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String filePath = arguments['filePath'];
    // String title = arguments['title'];
    String storageFilePath = arguments['storageFilePath'];
    File file = File(storageFilePath);

    return BaseViewPage(
      // storageFilePath: storageFilePath,
      // filePath: filePath,
      // title: title,
      arguments: arguments,
      viewWidget: Container(
        // child: PhotoView(imageProvider: FileImage(file)),
        child: PhotoView(imageProvider: MemoryImage(Utils.fileToBytes(file))),
      ),
    );
  }
}
