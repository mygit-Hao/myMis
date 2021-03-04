import 'package:flutter/material.dart';
import 'package:mis_app/utils/utils.dart';

class BaseViewPage extends StatefulWidget {
  // final String storageFilePath;
  // final String filePath;
  // final String title;
  final Map arguments;
  final Widget viewWidget;

  BaseViewPage(
      {Key key,
      // this.storageFilePath,
      // this.filePath,
      // this.title,
      this.arguments,
      @required this.viewWidget})
      : super(key: key);

  @override
  _BaseViewPageState createState() => _BaseViewPageState();
}

class _BaseViewPageState extends State<BaseViewPage> {
  @override
  Widget build(BuildContext context) {
    String filePath = widget.arguments['filePath'];
    String title = widget.arguments['title'];

    title = Utils.textIsEmptyOrWhiteSpace(title)
        ? Utils.getFileName(filePath)
        : title;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: widget.viewWidget,
      ),
    );
  }
}
