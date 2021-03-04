import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({Key key, this.message = loadingMessage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(),
          // Text('加载中........'),
          Text(message),
        ],
      ),
    );
  }
}
