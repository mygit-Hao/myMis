import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mis_app/config/service_url.dart';

class MealBookingTipsPage extends StatefulWidget {
  MealBookingTipsPage({Key key}) : super(key: key);

  @override
  _MealBookingTipsPageState createState() => _MealBookingTipsPageState();
}

class _MealBookingTipsPageState extends State<MealBookingTipsPage> {
  @override
  Widget build(BuildContext context) {
    String url = serviceUrl[mealBookingTipsUrl];
    // print('url: $url');

    return Scaffold(
      appBar: AppBar(
        title: Text('温馨提示'),
      ),
      body: SafeArea(
        child: Container(
          child: InAppWebView(
            initialUrl: url,
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                supportZoom: true,
              ),
              android: AndroidInAppWebViewOptions(
                loadWithOverviewMode: false,
                builtInZoomControls: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
