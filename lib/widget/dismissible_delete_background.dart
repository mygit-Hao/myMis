import 'package:flutter/material.dart';
import 'package:mis_app/widget/dismissible_background.dart';

class DismissibleDeleteBackground extends StatelessWidget {
  const DismissibleDeleteBackground({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*
    return Container(
      color: Colors.red,
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
    */

    return DismissibleBackground(
      title: '删除',
      color: Colors.red,
      icon: Icon(
        Icons.delete,
        color: Colors.white,
      ),
    );
  }
}
