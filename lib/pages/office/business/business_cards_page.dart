import 'package:flutter/material.dart';
import 'package:mis_app/model/businessClockRecords.dart';

class BusinessCardPage extends StatelessWidget {
  final List<ClockRecords> arguments;
  BusinessCardPage({this.arguments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('出差打卡记录'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: arguments.length,
          itemBuilder: (BuildContext context, int index) {
            final item = arguments[index];
            return InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(5.0),
                child: Row(
                  children: <Widget>[
                    Expanded(child: Text(item.clockTime)),
                    Expanded(child: Text(item.address)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
