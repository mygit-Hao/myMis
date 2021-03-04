import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';

class StickyHeaderContainer extends StatelessWidget {
  final String title;
  const StickyHeaderContainer({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      color: headerBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
