import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/utils/utils.dart';

typedef ShowDatePickerCallback = void Function(DateTime val);

class DialogUtils {
  // static TextEditingController _textFieldController = TextEditingController();
  static TextEditingController _textFieldController;

  static void _initController() {
    if (_textFieldController == null) {
      _textFieldController = TextEditingController();
    }
  }

  static void showToast(String msg, {Toast toastLength = Toast.LENGTH_SHORT}) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: toastLength,
        gravity: ToastGravity.CENTER,
        backgroundColor: Color.fromARGB(240, 45, 45, 45),
        textColor: Colors.white);
  }

  static Future<void> showInfoDialog(BuildContext context,
      {@required Widget content, String title}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: Utils.textIsEmptyOrWhiteSpace(title) ? null : Text(title),
          content: content,
          actions: <Widget>[
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> showAlertDialog(BuildContext context, String msg,
      {IconData iconData, Color color}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: (iconData == null || color == null)
              ? Text("提示")
              : Row(
                  children: <Widget>[
                    Icon(
                      iconData,
                      color: color,
                    ),
                    Text(" 提示")
                  ],
                ),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text("确定"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool> showConfirmDialog(BuildContext context, String msg,
      {IconData iconData,
      Color color,
      String confirmText = '确定',
      Color confirmTextColor}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          title: (iconData == null || color == null)
              ? Text("提示")
              : Row(
                  children: <Widget>[
                    Icon(
                      iconData,
                      color: color,
                    ),
                    Text(" 提示")
                  ],
                ),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: confirmTextColor == null
                  ? Text(confirmText)
                  : Text(
                      confirmText,
                      style: TextStyle(color: confirmTextColor),
                    ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<String> showTextFieldDialog(
      BuildContext context, String defaultText) {
    // TextEditingController textFieldController = TextEditingController();
    _initController();
    _textFieldController.text = defaultText ?? '';

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('请输入'),
          content: TextField(
            controller: _textFieldController,
            // decoration: InputDecoration(hintText: "TextField in Dialog"),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                Navigator.of(context).pop(_textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<double> showNumberDialog(BuildContext context,
      {String title = '', double defaultValue = 0}) {
    // TextEditingController textFieldController = TextEditingController();
    _initController();
    _textFieldController.text = '${Utils.getNumberStr(defaultValue)}';

    return showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    size: 20.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    double value = double.tryParse(_textFieldController.text);
                    value = value ?? 0;
                    if (value > 1) {
                      value = value - 1;
                      _textFieldController.text = Utils.getNumberStr(value);
                    }
                  },
                ),
                Container(
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: _textFieldController,
                    keyboardType: TextInputType.number,
                    // inputFormatters: [
                    //   WhitelistingTextInputFormatter.digitsOnly
                    // ],
                  ),
                  width: ScreenUtil().setWidth(120.0),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    size: 20.0,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: () {
                    double value = double.tryParse(_textFieldController.text);
                    value = (value ?? 0) + 1;
                    _textFieldController.text = Utils.getNumberStr(value);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('确定'),
              onPressed: () {
                double doubleValue = double.tryParse(_textFieldController.text);
                Navigator.of(context).pop(doubleValue);
              },
            ),
          ],
        );
      },
    );
  }

  static void showDatePickerDialog(BuildContext context, DateTime initialDate,
      {DateTime firstDate, DateTime lastDate, ShowDatePickerCallback onValue}) {
    showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? defaultFirstDate,
      lastDate: lastDate ?? defaultLastDate,
    ).then((DateTime val) {
      if ((val != null) && (onValue != null)) {
        onValue(val);
      }
    }).catchError((err) {
      print(err);
    });
  }

  static void showTimePickerDialog(BuildContext context, DateTime initialDate,
      {TimeOfDay initialTime, Function(TimeOfDay) onValue}) {
    showTimePicker(
      context: context,
      initialTime: initialTime,
    ).then((TimeOfDay val) {
      if ((val != null) && (onValue != null)) {
        onValue(val);
      }
    }).catchError((err) {
      print(err);
    });
  }
}
