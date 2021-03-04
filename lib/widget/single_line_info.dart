import 'package:flutter/widgets.dart';
import 'package:mis_app/widget/label_text.dart';

class SingleLineInfo extends StatelessWidget {
  final String label;
  final String info;
  const SingleLineInfo(this.label, this.info, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        LabelText(label),
        Expanded(child: Text(info ?? '')),
      ],
    );
  }
}
