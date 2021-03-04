import 'package:flutter/material.dart';
import 'package:mis_app/widget/custom_button.dart';

class LargeButton extends StatelessWidget {
  final String title;
  final double height;
  final Function onPressed;

  const LargeButton({Key key, this.title, this.height = 55.0, this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /*
    return Padding(
      padding: const EdgeInsets.only(top: 25),
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(height: height),
        // child: RaisedButton(
        //   color: Theme.of(context).primaryColor,
        //   onPressed: onPressed,
        //   textColor: Colors.white,
        //   child: Text(title),
        // ),
        child: CustomButton(
          title: title,
          onPressed: onPressed,
        ),
      ),
    );
    */
    return ConstrainedBox(
      constraints: BoxConstraints.expand(height: height),
      child: CustomButton(
        title: title,
        onPressed: onPressed,
      ),
    );
  }
}
