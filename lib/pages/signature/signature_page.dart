import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/signature_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/large_button.dart';
import 'package:mis_app/widget/loading_indicator.dart';

class SignaturePage extends StatefulWidget {
  SignaturePage({Key key}) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  File _signatureFile;
  // 是否初次进入该页面
  // 初始进入时，把签名文件删除
  bool _firstLoad;

  @override
  void initState() {
    super.initState();

    _firstLoad = true;
  }

  Future _deleteSignature() async {
    File file = File(Global.signatureFilePath);
    //如果签名文件存在，就删除
    if (await file.exists()) {
      try {
        file.delete();
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('签名'),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                child: Text('当前签名：'),
              ),
              Expanded(
                child: Center(
                  child: _signatureWidget(context),
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              LargeButton(
                title: '增加签名',
                onPressed: () async {
                  // Application.router.navigateTo(context, signatureAddPage);
                  /*
                  Navigator.pushNamed(context, signatureAddPath).then((result) {
                    if (result == Global.signature_updated) {
                      Utils.clearImageCache();
                    }
                  });
                  */

                  if (await navigatePage(context, signatureAddPath)) {
                    Utils.clearImageCache();
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _signatureWidget(BuildContext context) {
    return FutureBuilder(
      future: _getSignature(),
      // future: _initSignature(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
            return new Text('');

          case ConnectionState.waiting:
            // return Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     CircularProgressIndicator(),
            //     Text('加载中........'),
            //   ],
            // );
            return LoadingIndicator();

          case ConnectionState.done:
            // return snapshot.hasError || (_signatureFile == null)
            //     ? Text('暂无签名')
            //     : Image.file(_signatureFile);

            return snapshot.hasError
                ? Text('签名加载失败，请稍后再试')
                : ((_signatureFile == null)
                    ? Text('暂无签名')
                    : Image.file(_signatureFile));
        }

        return Text('加载中........');
      },
    );
  }

  Future _getSignature() async {
    //初次加载时，先把之前的签名文件删除
    if (_firstLoad) {
      await _deleteSignature();
      _firstLoad = false;
    }

    File signatureFile = File(Global.signatureFilePath);
    //如果签名文存在，就不重新下载
    // if (!await signatureFile.exists())
    if (!await Utils.fileHasData(signatureFile)) {
      await SignatureService.getSignature();
      Utils.clearImageCache();
    }

    signatureFile = File(Global.signatureFilePath);
    // if (await signatureFile.exists())
    if (await Utils.fileHasData(signatureFile)) {
      _signatureFile = signatureFile;
    }

    return;
  }
}
