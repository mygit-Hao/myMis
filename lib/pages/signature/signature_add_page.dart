import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/const_values.dart';
// import 'package:flutter_signature_pad/flutter_signature_pad.dart';
// import 'package:hand_signature/signature.dart';
import 'package:mis_app/common/global.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/signature_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/circular_icon_button.dart';
import 'package:mis_app/widget/signature.dart';

class SignatureAddPage extends StatefulWidget {
  SignatureAddPage({Key key}) : super(key: key);

  @override
  _SignatureAddPageState createState() => _SignatureAddPageState();
}

class _SignatureAddPageState extends State<SignatureAddPage> {
  // ByteData _img = ByteData(0);
  static final List<double> _widths = [6.0, 8.0];
  // static final List<double> _widths = [2.0, 5.0];
  static final List<Color> _colors = [
    Colors.black,
    Color.fromARGB(255, 0, 0, 96),
  ];
  // static final int _defaultColorIndex = 1;
  // static final int _defaultWidthIndex = 0;

  // double _strokeWidth = _widths[_defaultWidthIndex];
  // Color _color = _colors[_defaultColorIndex];
  // int _selectedWidthIndex = _defaultWidthIndex;
  // int _selectedColorIndex = _defaultColorIndex;
  int _selectedWidthIndex;
  double _strokeWidth;
  int _selectedColorIndex;
  Color _color;
  // final _sign = GlobalKey<SignatureState>();
  /*
  final _control = HandSignatureControl(
    threshold: 3.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );
  */
  double _appBarHeight;
  double _appBarTitleFontSize;
  double _appBarTitleSecondaryFontSize;
  GlobalKey<SignatureState> _signatureKey = GlobalKey();
  bool _originIsPortrait = true;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _calcMeasured();

    _selectedWidthIndex = Prefs.getSignatureWidthIndex();
    _strokeWidth = _widths[_selectedWidthIndex];
    _selectedColorIndex = Prefs.getSignatureColorIndex();
    _color = _colors[_selectedColorIndex];

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _originIsPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;

      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
      _calcMeasured();
      setState(() {});
    });
  }

  void _calcMeasured() {
    // _appBarHeight = ScreenUtil().setHeight(80.0);
    // _appBarTitleFontSize = ScreenUtil().setSp(32.0);
    // _appBarTitleSecondaryFontSize = ScreenUtil().setSp(28.0);

    // _appBarHeight = ScreenUtil().setHeight(_originIsPortrait ? 80.0 : 160.0);
    // _appBarTitleFontSize = ScreenUtil().setSp(_originIsPortrait ? 32.0 : 20.0);
    // _appBarTitleSecondaryFontSize =
    //     ScreenUtil().setSp(_originIsPortrait ? 28.0 : 16.0);
    const double appBarHeight = 80.0;
    const double appBarTitleFontSize = 32.0;
    const double appBarTitleSecondaryFontSize = 28.0;
    // final double ratio = ConstValues.useMobileLayout ? 1.25 : 1.7;
    final double ratio =
        ConstValues.screenLongestSide / ConstValues.screenShortestSide;

    _appBarHeight = ScreenUtil()
        .setHeight(_originIsPortrait ? appBarHeight : appBarHeight * ratio);
    _appBarTitleFontSize = ScreenUtil().setSp(
        _originIsPortrait ? appBarTitleFontSize : appBarTitleFontSize * ratio);
    _appBarTitleSecondaryFontSize = ScreenUtil().setSp(_originIsPortrait
        ? appBarTitleSecondaryFontSize
        : appBarTitleSecondaryFontSize * ratio);
  }

  @override
  void dispose() {
    if (_originIsPortrait) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(title: Text('我的签名')),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(_appBarHeight),
          child: AppBar(
            // title: Text(
            //   '我的签名',
            //   style: TextStyle(fontSize: _appBarTitleFontSize),
            // ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '我的签名',
                      style: TextStyle(fontSize: _appBarTitleFontSize),
                    ),
                    TextSpan(
                      text: '（用户：${UserProvide.currentUser.fullName}）',
                      style: TextStyle(
                        fontSize: _appBarTitleSecondaryFontSize,
                        color: secondaryColor,
                      ),
                    ),
                  ]),
                ),
                Text(
                  '${Utils.dateTimeToStr(DateTime.now())}',
                  style: TextStyle(fontSize: _appBarTitleSecondaryFontSize),
                ),
              ],
            ),
            // toolbarHeight: ScreenUtil().setHeight(80.0),
          ),
        ),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                child: Padding(
                  // padding: const EdgeInsets.all(8.0),
                  padding: const EdgeInsets.all(0.0),
                  /*
                  child: Signature(
                    color: _color,
                    key: _sign,
                    // onSign: () {
                    //   final sign = _sign.currentState;
                    //   debugPrint(
                    //       '${sign.points.length} points in the signature');
                    // },
                    strokeWidth: _strokeWidth,
                  ),
                  */
                  child: _signatureWidget,
                ),
                color: Colors.black12,
              ),
            ),
            _buttonWidgets(),
          ],
        ),
      ),
    );
  }

  Widget get _signatureWidget {
    /*
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints.expand(),
          color: Colors.white,
          child: HandSignaturePainterView(
            control: _control,
            color: _color,
            width: _strokeWidth,
            type: SignatureDrawType.shape,
          ),
        ),
        CustomPaint(
          painter: DebugSignaturePainterCP(
            control: _control,
            cp: false,
            cpStart: false,
            cpEnd: false,
          ),
        ),
      ],
    );
    */

    return Signature(
      key: _signatureKey,
      color: _color,
      strokeWidth: _strokeWidth,
    );
  }

  Widget _selectWidthButton(int index, {double size}) {
    return IconButton(
      icon: Icon(
        Icons.brightness_1,
        size: size,
        color: _selectedWidthIndex == index
            ? Colors.black87
            : Colors.grey.withOpacity(0.5),
      ),
      onPressed: () {
        setState(() {
          _selectedWidthIndex = index;
          _strokeWidth = _widths[_selectedWidthIndex];
          Prefs.setSignatureWidthIndex(_selectedWidthIndex);
        });
      },
    );
  }

  Widget _selectColorButton(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColorIndex = index;
          _color = _colors[_selectedColorIndex];
          Prefs.setSignatureColorIndex(_selectedColorIndex);
        });
      },
      child: Container(
        color: _selectedColorIndex == index
            ? Colors.grey.withOpacity(0.2)
            : Colors.transparent,
        child: Icon(
          Icons.create,
          size: 32.0,
          color: _colors[index],
        ),
      ),
    );
  }

  Widget _buttonWidgets() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                _save();
              },
              child: Text(
                "完成",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
              // margin: EdgeInsets.only(top: 10.0),
              child: Row(
                children: <Widget>[
                  _selectColorButton(0),
                  SizedBox(
                    width: 20.0,
                  ),
                  _selectColorButton(1),
                ],
              ),
            ),
            SizedBox(height: 6.0),
            _selectWidthButton(0, size: 15.0),
            _selectWidthButton(1, size: 20.0),
            /*
            RaisedButton(
              // color: Theme.of(context).primaryColor,
              color: Colors.red,
              onPressed: () {
                _clear();
              },
              child: Text(
                "清除",
                // style: TextStyle(color: Colors.red),
                style: TextStyle(color: Colors.white),
              ),
            ),
            */
            /*
            ClipOval(
              child: Container(
                color: Colors.red,
                padding: EdgeInsets.all(6.0),
                child: InkWell(
                  child: Icon(
                    ConstValues.icon_eraser,
                    color: Colors.white,
                  ),
                  onTap: _clear,
                ),
              ),
            ),
            */
            CircularIconButton(
              icon: ConstValues.icon_eraser,
              color: Colors.white,
              backgroundColor: Colors.red,
              onPressed: _clear,
            ),
            SizedBox(height: 4.0),
            _warningWidget,
          ],
        ),
      ),
    );
  }

  Widget get _warningWidget {
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.red,
        fontSize: 9.0,
      ),
      child: Column(
        children: <Widget>[
          Text('不接受简单签名，'),
          Text('且须有当天日期，'),
          Text('否则会被退回。'),
        ],
      ),
    );
  }

  void _clear() {
    _signatureKey.currentState.clear();
  }

  void _save() async {
    final sign = _signatureKey.currentState;
    //retrieve image data, do whatever you want with it (send to server, save locally...)
    final ui.Image image = await sign.getData();
    ByteData data = await image.toByteData(format: ui.ImageByteFormat.png);
    Utils.saveImage(data.buffer.asUint8List(), Global.signatureFilePath,
        success: () async {
      RequestResult result = await SignatureService.uploadSignature();
      // Application.router.pop(context);

      if (result.success) {
        // Navigator.pop(context, Global.signature_updated);
        setPageDataChanged(this.widget, true);
        Navigator.pop(context);
      } else {
        if (result.msg != "") {
          DialogUtils.showToast(result.msg);
        }
      }
    });
  }

  /*
  void _clear() {
    final sign = _sign.currentState;
    sign.clear();
    setState(() {
      _img = ByteData(0);
    });
    debugPrint("cleared");
  }
  */

  /*
  void _clear() {
    _control.clear();
  }
  */

  /*
  void _save() async {
    final SignatureState sign = _sign.currentState;
    //retrieve image data, do whatever you want with it (send to server, save locally...)
    final ui.Image image = await sign.getData();
/
    ByteData data = await image.toByteData(format: ui.ImageByteFormat.png);
    Utils.saveImage(data.buffer.asUint8List(), Global.signatureFilePath,
        success: () async {
      RequestResult result = await SignatureService.uploadSignature();
      // Application.router.pop(context);

      if (result.success) {
        // Navigator.pop(context, Global.signature_updated);
        setPageDataChanged(this.widget, true);
        Navigator.pop(context);
      } else {
        if (result.msg != "") {
          DialogUtils.showToast(result.msg);
        }
      }
    });

    // sign.clear();
    // final encoded = base64.encode(data.buffer.asUint8List());
    // setState(() {
    //   _img = data;
    // });
    // debugPrint("onPressed " + encoded);
  }
  */

  /*
  void _save() async {
    final ByteData data =
        await _control.toImage(format: ui.ImageByteFormat.png);
    Utils.saveImage(data.buffer.asUint8List(), Global.signatureFilePath,
        success: () async {
      RequestResult result = await SignatureService.uploadSignature();

      if (result.success) {
        setPageDataChanged(this.widget, true);
        Navigator.pop(context);
      } else {
        if (result.msg != "") {
          DialogUtils.showToast(result.msg);
        }
      }
    });
  }
  */
}
