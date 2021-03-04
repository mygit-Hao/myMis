import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';

class FunctionItem extends StatelessWidget {
  // final IconData icon;
  final Icon icon;
  final String title;
  final Function onTap;
  final bool isSubPage;
  // final Color color;
  final Color backgroundColor;
  final Color titleColor;
  final bool isPlaceHolder;

  const FunctionItem(
      {Key key,
      this.icon,
      this.title = '',
      this.onTap,
      this.isSubPage = false,
      // this.color,
      this.backgroundColor,
      this.isPlaceHolder = false,
      this.titleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content;
    Icon itemIcon;
    if (icon != null) {
      itemIcon = Icon(
        icon.icon,
        color: icon.color ?? Theme.of(context).primaryColor,
        size: isSubPage ? 36.0 : 45.0,
      );
    }

    if (!isPlaceHolder) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Icon(
          //   icon,
          //   color: color ?? defaultThemeColor,
          //   size: isSubPage ? 36.0 : 45.0,
          // ),
          if (itemIcon != null) itemIcon,
          SizedBox(
            height: isSubPage ? 4.0 : 6.0,
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: titleColor == null ? Colors.grey : titleColor,
              // fontSize: title.length > 4 ? 14.0 : 16.0,
              fontSize: isSubPage ? fontSizeDetail : null,
            ),
          ),
        ],
      );
    }

    return InkWell(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor == null
              ? (isSubPage
                  // ? Theme.of(context).scaffoldBackgroundColor
                  ? null
                  : Colors.white)
              : backgroundColor,
          borderRadius: BorderRadius.circular(isSubPage ? 0 : 8.0),
        ),
        child: content,
      ),
      onTap: isPlaceHolder ? null : onTap,
    );
  }
}
