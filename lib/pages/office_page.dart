import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/pages/common/base_inner_page.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/widget/group_function_list.dart';
import 'package:provide/provide.dart';

class OfficePage extends StatefulWidget {
  OfficePage({Key key}) : super(key: key);

  @override
  _OfficePageState createState() => _OfficePageState();
}

class _OfficePageState extends State<OfficePage> {
  @override
  Widget build(BuildContext context) {
    // return BaseInnerPage(
    //   title: '办公',
    //   child: Container(padding: EdgeInsets.all(8.0), child: _itemList()),
    // );

    return Provide<UserProvide>(
      builder: (BuildContext context, Widget child, UserProvide value) {
        // List<MobileFunction> functions =
        //     Provide.value<UserProvide>(context).officeFunctions;
        // List<MobileFunction> functions = UserProvide.officeFunctions;
        List<Map<String, dynamic>> groupFunctions =
            UserProvide.officeGroupFunctions;
        // print('functions: $functions');

        return BaseInnerPage(
          title: '办公',
          child: Container(
            color: backgroundColor,
            padding: EdgeInsets.all(8.0),
            // child: _itemList(functions),
            // child: FunctionList(
            //   functions: functions,
            //   callFunction: callFunction,
            // ),

            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                Map<String, dynamic> item = groupFunctions[index];

                return GroupFunctionList(
                  title: item['name'],
                  physics: NeverScrollableScrollPhysics(),
                  functions: item['functions'],
                  childAspectRatio: 1,
                  callFunction: callFunction,
                  titleColor: (item['tag'] ?? 0) > 0
                      ? Theme.of(context).primaryColor
                      : null,
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 8.0,
                  thickness: 8.0,
                  color: backgroundColor,
                );
              },
              itemCount: groupFunctions.length,
            ),
          ),
        );
      },
    );
  }

  /*
  Widget _itemList(List<MobileFunction> functions) {
    return GridView.builder(
      itemCount: functions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          //横轴元素个数
          crossAxisCount: 3,
          //纵轴间距
          mainAxisSpacing: 10.0,
          //横轴间距
          crossAxisSpacing: 10.0,
          //子组件宽高长度比例
          childAspectRatio: 1.0),
      itemBuilder: (BuildContext context, int index) {
        MobileFunction item = functions[index];
        return FunctionItem(
          // icon: IconData(0xe646, fontFamily: 'MyIcons'),
          icon: item.icon,
          title: item.functionName,
          onTap: () {
            _startFunction(item);
          },
        );

        // return FunctionItem(
        //   icon: IconData(0xe646, fontFamily: 'MyIcons'),
        //   title: 'test',
        //   onTap: () {
        //     print('点击了功能');
        //   },
        // );
      },
    );
  }

  void _startFunction(MobileFunction function) {
    // print('点击了功能: ' + function.functionName);
    switch (function.mobileFunctionId) {
      case functionIdAttendance:
        Navigator.pushNamed(context, attendancePath);
        break;
      case functionIdApproval:
        Navigator.pushNamed(context, approvalPath);
        break;
      default:
    }
  }
  */
}
