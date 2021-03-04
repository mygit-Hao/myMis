import 'package:flutter/material.dart';

class BaseContainer extends StatelessWidget {
  final BuildContext parentContext;
  final Widget child;
  const BaseContainer({Key key, @required this.parentContext, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(parentContext);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: child,
    );
  }
}
