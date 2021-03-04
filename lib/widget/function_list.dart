import 'package:flutter/material.dart';
import 'package:mis_app/model/mobile_function.dart';
import 'package:mis_app/widget/function_item.dart';

typedef CallFunctionCallback = void Function(
    BuildContext context, MobileFunction function);

class FunctionList extends StatelessWidget {
  final List<MobileFunction> functions;
  final bool isSubPage;
  final double childAspectRatio;
  final CallFunctionCallback callFunction;
  const FunctionList(
      {Key key,
      this.functions,
      this.isSubPage = false,
      this.childAspectRatio = 0.9,
      @required this.callFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: functions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isSubPage ? 4 : 3,
          mainAxisSpacing: isSubPage ? 5.0 : 6.0,
          crossAxisSpacing: isSubPage ? 5.0 : 6.0,
          childAspectRatio: childAspectRatio),
      itemBuilder: (BuildContext context, int index) {
        MobileFunction item = functions[index];
        return FunctionItem(
          icon: item.icon,
          title: item.functionName,
          isSubPage: isSubPage,
          // color: item.color,
          onTap: () {
            // startFunction(context, item);
            callFunction(context, item);
          },
        );
      },
    );
  }
}
