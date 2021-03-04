import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewPage extends StatefulWidget {
  final Map<String, dynamic> arguments;
  const WebViewPage({Key key, this.arguments}) : super(key: key);
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String _title;
  String _url;
  @override
  void initState() {
    super.initState();
    _title = this.widget.arguments['title'] ?? '';
    _url = this.widget.arguments['url'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(_title + '操作说明')),
        body: Container(
          child: Center(
            child: customWebView(_url),
          ),
        ),
      ),
    );
  }
}

Widget customWebView(String url, {ctrl}) {
  return FutureBuilder<Widget>(
    future: Future.delayed(Duration(seconds: 0), () => Container()),
    builder: (BuildContext context, AsyncSnapshot snapshot) {
      // 请求已结束
      if (snapshot.connectionState == ConnectionState.done) {
        if (snapshot.hasError) {
          // 请求失败，显示错误
          return Text("Error: ${snapshot.error}");
        } else {
          // 请求成功，显示数据
          // return Text("Contents: ${snapshot.data}");
          return InAppWebView(
            initialUrl: url,
            initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(supportZoom: true),
                android: AndroidInAppWebViewOptions(
                  builtInZoomControls: true,
                  loadWithOverviewMode: false,
                )),
            onWebViewCreated: (InAppWebViewController controller) {
              ctrl = controller;
            },
          );
        }
      } else {
        // 请求未结束，显示loading
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    },
  );
}
