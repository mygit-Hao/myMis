import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mis_app/config/service_url.dart';

class ServensHelpPage extends StatefulWidget {
  @override
  _ServensHelpPageState createState() => _ServensHelpPageState();
}

class _ServensHelpPageState extends State<ServensHelpPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text('7S操作文档')),
        body: Container(
          child: InAppWebView(
            initialUrl: serviceUrl[sevensHelpUrl],
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(supportZoom: true),
                android: AndroidInAppWebViewOptions(
                  builtInZoomControls: true,
                  loadWithOverviewMode: false,
                )),
          ),
        ),
      ),
    );
  }
}
