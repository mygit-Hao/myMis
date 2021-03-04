import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mis_app/common/device_info.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:provide/provide.dart';

class WeekPlanProgressWebPage extends StatefulWidget {
  @override
  _WeekPlanProgressWebPageState createState() =>
      _WeekPlanProgressWebPageState();
}

class _WeekPlanProgressWebPageState extends State<WeekPlanProgressWebPage> {
  InAppWebViewController _webViewController;
  FLCountStepperController _weekCtrl;
  int _projId = 0;

  @override
  void initState() {
    super.initState();
    _weekCtrl = FLCountStepperController(min: 1, max: 100, step: 1);
    _weekCtrl.value = 5;
  }

  @override
  Widget build(BuildContext context) {
    return Provide<WeekPlanProvide>(
      builder: (context, child, detail) {
        _projId = detail.detailModel.projData.projId;
        return Container(
          child: _webView(),
        );
      },
    );
  }

  Widget _webView() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: InAppWebView(
                initialUrl: _getFileUrl(),
                initialOptions: InAppWebViewGroupOptions(
                    crossPlatform: InAppWebViewOptions(supportZoom: true),
                    android: AndroidInAppWebViewOptions(
                      builtInZoomControls: true,
                      loadWithOverviewMode: false,
                    )),
                onWebViewCreated: (InAppWebViewController controller) {
                  _webViewController = controller;
                },
              ),
            ),
          ),
          _weekChange(),
          // _webCtrlBt(),
        ],
      ),
    );
  }

  Widget _weekChange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('近'),
        FLCountStepper(
          controller: _weekCtrl,
          disableInput: false,
          onChanged: (value) {
            _webViewController.loadUrl(url: _getFileUrl());
          },
        ),
        Text('周'),
      ],
    );
  }

  String _getFileUrl() {
    int week = _weekCtrl.value;
    String user = UserProvide.currentUser.userName;
    String devid = DeviceInfo.devId;
    String passWordKey = UserProvide.currentUserMd5Password;
    String date = Utils.dateTimeToStrWithPattern(DateTime.now(), 'yyyyMMdd');
    String key = Utils.getMd5_16(user + passWordKey + devid + date);
    String urlToken = getUrlToken();
    String url =
        '${serviceUrl[weekProgressUrl]}?user=$user&devid=$devid&key=$key&=$urlToken&did=$_projId&weeks=$week';
    return url;
  }
}
