import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';

class PageTitle extends StatelessWidget {
  final String title;

  const PageTitle({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSizeLarge,
        ),
      ),
      color: Theme.of(context).primaryColor,
      width: double.infinity,
    );
  }
}
