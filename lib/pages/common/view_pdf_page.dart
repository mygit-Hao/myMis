import 'package:flutter/material.dart';
import 'package:mis_app/pages/common/base_view_page.dart';
import 'package:native_pdf_view/native_pdf_view.dart';

class ViewPdfPage extends StatefulWidget {
  final Map arguments;
  ViewPdfPage({Key key, this.arguments}) : super(key: key);

  @override
  _ViewPdfPageState createState() => _ViewPdfPageState();
}

class _ViewPdfPageState extends State<ViewPdfPage> {
  PdfController _controller;

  @override
  void initState() {
    super.initState();

    String storageFilePath = widget.arguments['storageFilePath'];
    _controller =
        PdfController(document: PdfDocument.openFile(storageFilePath));
  }

  @override
  Widget build(BuildContext context) {
    return BaseViewPage(
      arguments: widget.arguments,
      viewWidget: Container(
        child: PdfView(
          controller: _controller,
        ),
      ),
    );
  }
}
