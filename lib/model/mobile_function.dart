import 'package:flutter/material.dart';

class MobileFunction {
  int mobileFunctionId;
  int categoryId;
  int resId;
  String functionName;
  String name;
  String resourceName;
  String routeName;
  List<String> childRoutes;
  Object routeArguments;
  bool needPermission;
  int authorityLevel;
  // IconData icon;
  // Color color;
  Icon icon;

  MobileFunction({
    this.mobileFunctionId,
    this.categoryId,
    this.resId,
    this.functionName,
    @required this.name,
    this.resourceName,
    this.routeName,
    this.childRoutes,
    this.routeArguments,
    this.needPermission = false,
    this.authorityLevel,
    this.icon,
    // this.color
  });

  MobileFunction.fromJson(Map<String, dynamic> json) {
    mobileFunctionId = json['MobileFunctionId'];
    categoryId = json['CategoryId'];
    resId = json['ResId'];
    functionName = json['FunctionName'];
    name = json['Name'];
    resourceName = json['ResourceName'];
    routeName = json['RouteName'];
    routeArguments = json['RouteArguments'];
    needPermission = json['NeedPermission'] ?? false;
    authorityLevel = json['AuthorityLevel'];
    // color = json['Color'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MobileFunctionId'] = this.mobileFunctionId;
    data['CategoryId'] = this.categoryId;
    data['ResId'] = this.resId;
    data['FunctionName'] = this.functionName;
    data['Name'] = this.name;
    data['ResourceName'] = this.resourceName;
    data['RouteName'] = routeName;
    data['RouteArguments'] = routeArguments;
    data['NeedPermission'] = needPermission;
    data['AuthorityLevel'] = this.authorityLevel;
    // data['Color'] = this.color;
    return data;
  }
}
