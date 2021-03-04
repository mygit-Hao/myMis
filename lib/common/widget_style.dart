import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog/progress_dialog.dart';

//无边框灰色输入框样式
InputDecoration textFieldDecorationNoBorder({String label, Color color}) {
  return InputDecoration(
    filled: true,
    labelText: label == null ? '' : label + ':',
    labelStyle: TextStyle(color: Colors.black),
    hintText: label == null
        ? ''
        : ((label == '历史批注' || label == '添加批注(选填)') ? '' : '请输入' + label),
    contentPadding: EdgeInsets.fromLTRB(6, 12, 6, 0),
    fillColor: color ?? Colors.grey[100],
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      // borderSide: BorderSide(
      // width: 0.5,
      // color: Color(0xffd4e0ef),
      // ),
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

//外边线包裹输入框样式
InputDecoration outLineDecoration(double borderRadius) {
  return InputDecoration(
      contentPadding: EdgeInsets.all(3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ));
}

//listview item底部分割线
final bottomLineDecotation = BoxDecoration(
  border: Border(
    bottom: BorderSide(width: 0.2, color: Colors.black54),
  ),
);

///容器灰色装饰
BoxDecoration containerDeroation({Color color}) {
  return BoxDecoration(
    color: color ?? Colors.grey[100],
    border: Border.all(width: 0.5, color: Color(0xffd4e0ef)),
    borderRadius: BorderRadius.circular(5),
  );
}

//不同状态样式
TextStyle statusTextStyle(int status) {
  var style;
  if (status == 0) {
    style = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == 5) {
    style = TextStyle(
      color: Colors.pinkAccent,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == 10) {
    style = TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == 15) {
    style = TextStyle(
      color: Colors.amber,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == 20) {
    style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  }
  return style;
}

TextStyle statusNameTextStyle(String status) {
  var style;
  if (status == '草稿') {
    style = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == '提交') {
    style = TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == '审批中') {
    style = TextStyle(
      color: Colors.amber,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  } else if (status == '审批完成') {
    style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    );
  }
  return style;
}

//时间选择样式
final timePickDecoration = BoxDecoration(
    // border: Border.all(color:Colors.blue,width:0.5),
    color: Colors.grey[100],
    borderRadius: BorderRadius.circular(5));

//text样式
Text customText(
    {Color color,
    double fontSize,
    FontWeight fontWeight,
    String value,
    Color backgroundColor}) {
  return Text(
    value ?? '',
    style: TextStyle(
        color: color ?? Color.fromARGB(180, 45, 45, 45),
        // color: color ?? Colors.black54,
        fontSize: fontSize ?? 15,
        fontWeight: fontWeight,
        backgroundColor: backgroundColor),
    overflow: TextOverflow.ellipsis,
  );
}

///自定义灰色容器
Widget customContainer({Color color, Widget child}) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(3),
    decoration: BoxDecoration(
        color: color == null ? Colors.grey[100] : color,
        borderRadius: BorderRadius.circular(5)),
    child: child,
  );
}

Widget customOutLineContainer({Color color, Widget child}) {
  return Container(
    alignment: Alignment.center,
    padding: EdgeInsets.all(3),
    decoration: BoxDecoration(
        // color: color == null ? Colors.grey[100] : color,
        // border: Border.all(width: 1, color: Colors.blue),
        borderRadius: BorderRadius.circular(5)),
    child: child,
  );
}

///自定义按钮
Widget customButtom(Color color, String value, Function function,
    {double radius}) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: RaisedButton(
        elevation: 1,
        onPressed: function,
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 20)),
        child: customText(color: Colors.white, value: value),
      ),
    ),
  );
}

toastBlackStyle(String msg) {
  return Fluttertoast.showToast(
      msg: msg,
      gravity: ToastGravity.CENTER,
      backgroundColor: Color.fromARGB(240, 45, 45, 45),
      textColor: Colors.white);
}

///黑色样式加载对话框
ProgressDialog customProgressDialog(BuildContext context, String msg) {
  ProgressDialog progressDialog = ProgressDialog(context);

  progressDialog.style(
    message: msg,
    backgroundColor: Colors.black54,
    messageTextStyle: TextStyle(color: Colors.white),
    progressTextStyle: TextStyle(color: Colors.white),
    borderRadius: 5,
  );

  return progressDialog;
}

class CustomRoute extends PageRouteBuilder {
  Widget widget;
  CustomRoute(this.widget)
      : super(
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (BuildContext context, Animation<double> animation1,
                Animation<double> animation2) {
              return widget;
            },
            transitionsBuilder: (BuildContext context,
                Animation<double> animation1,
                Animation<double> animation2,
                Widget child) {
              return ScaleTransition(
                scale: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: animation1, curve: Curves.linear)),
                child: FadeTransition(
                    opacity: Tween(begin: 0.0, end: 2.0).animate(
                      CurvedAnimation(parent: animation1, curve: Curves.linear),
                    ),
                    child: child),
              );
            });
}

Header customRefreshHeader = ClassicalHeader(
    refreshText: '下拉刷新...',
    refreshReadyText: '准备加载',
    refreshingText: '加载中...',
    refreshedText: '加载完成！',
    refreshFailedText: '加载失败',
    noMoreText: '没有更多了',
    textColor: Colors.blue,
    infoColor: Colors.black54);

Footer customRefreshFooter = ClassicalFooter(
    loadText: '上拉加载...',
    loadReadyText: '上拉加载',
    loadingText: '加载中...',
    loadedText: '加载完成！',
    loadFailedText: '加载失败',
    noMoreText: '没有更多了',
    textColor: Colors.blue,
    infoColor: Colors.black54);

Widget get refreshWidget {
  return Center(
    child: CircularProgressIndicator(
      backgroundColor: Colors.grey[200],
      valueColor: AlwaysStoppedAnimation(Colors.blue),
    ),
  );
}

///自定义顶部搜索
Widget searchViewCustom(TextEditingController textContr, Function function) {
  return Container(
    // color: Colors.white,
    height: 50,
    width: ScreenUtil().setWidth(750),
    padding: EdgeInsets.all(5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextField(
            autofocus: false,
            controller: textContr,
            textInputAction: TextInputAction.search,
            onSubmitted: (val) {
              function();
            },
            decoration: InputDecoration(
                hintText: '关键字搜索',
                hintStyle: TextStyle(fontSize: 15),
                contentPadding: EdgeInsets.only(left: 10),
                fillColor: Colors.grey[200],
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20.0),
                )),
          ),
        ),
        // InkWell(
        //   onTap: () {
        //     function();
        //   },
        //   child: Icon(
        //     Icons.search,
        //     color: Colors.blue,
        //     size: 40,
        //   ),
        // ),
      ],
    ),
  );
}

Widget deleteBg({Color bgcolor, Color txtColor}) {
  // return Container(
  //   alignment: Alignment.center,
  //   color: bgcolor ?? Colors.white,
  //   child: customText(value: '', color: txtColor ?? Colors.red),
  // );
  return Container(
    color: bgcolor ?? Colors.red,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          Text(
            '删除',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

Widget copyNewBg({Color bgcolor, Color txtColor}) {
  return Container(
    color: bgcolor ?? Colors.blue,
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.content_copy,
            color: Colors.white,
          ),
          Text(
            '复制新增',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
