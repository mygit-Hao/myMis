import 'package:flutter/material.dart';

class UnderlineContainer extends StatelessWidget {
  final Widget child;
  const UnderlineContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).focusColor,
          ),
        ),
      ),
      child: child,
    );
  }
}
