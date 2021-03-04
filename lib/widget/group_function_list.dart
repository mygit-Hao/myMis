import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/widget/function_item.dart';
import 'package:mis_app/widget/function_list.dart';

class GroupFunctionList extends StatelessWidget {
  final String title;
  final List<MobileFunction> functions;
  final CallFunctionCallback callFunction;
  final ScrollPhysics physics;
  final double childAspectRatio;
  final Color titleColor;

  const GroupFunctionList(
      {Key key,
      this.functions,
      this.callFunction,
      this.title,
      this.physics,
      this.childAspectRatio = 0.9,
      this.titleColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 每行显示项目的数量
    const int countPerRow = 4;

    // 为空白位置补上占位项目
    int showItemCount =
        (((functions.length - 1) / countPerRow).floor() + 1) * countPerRow;

    return Container(
      padding: EdgeInsets.fromLTRB(0.0, 4.0, 0.0, 0.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(
                  color: titleColor == null ? defaultFontColor : titleColor),
            ),
          ),
          Divider(height: 1.0, thickness: 1.0),
          Container(
            // padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
            color: backgroundColor,
            child: GridView.builder(
              itemCount: showItemCount,
              shrinkWrap: true,
              physics: physics,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: countPerRow,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 1.0,
                  childAspectRatio: childAspectRatio),
              itemBuilder: (BuildContext context, int index) {
                if (index >= functions.length) {
                  // 用于占位
                  return FunctionItem(
                    isSubPage: true,
                    backgroundColor: Colors.white,
                    isPlaceHolder: true,
                  );
                }

                MobileFunction item = functions[index];
                return FunctionItem(
                  icon: item.icon,
                  title: item.functionName,
                  isSubPage: true,
                  // color: item.color,
                  backgroundColor: Colors.white,
                  titleColor: Theme.of(context).textTheme.bodyText1.color,
                  onTap: () {
                    callFunction(context, item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
