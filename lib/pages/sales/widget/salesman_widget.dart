import 'package:flutter/material.dart';
import 'package:mis_app/model/salesman.dart';

class SalesmanWidget extends StatelessWidget {
  final List<SalesmanModel> list;
  final SalesmanModel value;
  final Function(SalesmanModel) onChanged;

  const SalesmanWidget({Key key, this.list, this.value, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('营业员：'),
        Expanded(
          child: DropdownButton<SalesmanModel>(
            value: value,
            items: list.map((SalesmanModel item) {
              return DropdownMenuItem(
                child: Text(item.salesmanName),
                value: item,
              );
            }).toList(),
            isExpanded: true,
            onChanged: onChanged,
          ),
        )
      ],
    );
  }
}
