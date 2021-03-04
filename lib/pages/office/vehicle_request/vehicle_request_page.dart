import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/model/vehicle_request.dart';
import 'package:mis_app/pages/office/vehicle_request/vehicle_request_list_item.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/oa_service.dart';
import 'package:progress_dialog/progress_dialog.dart';

class VehicleRequestPage extends StatefulWidget {
  final Map arguments;
  VehicleRequestPage({Key key, this.arguments}) : super(key: key);

  @override
  _VehicleRequestPageState createState() => _VehicleRequestPageState();
}

class _VehicleRequestPageState extends State<VehicleRequestPage> {
  List<VehicleRequestModel> _list = [];
  // double _leadingWidth = ScreenUtil().setSp(40.0);
  bool _shifting;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _shifting = false;

    Map arguments = widget.arguments;
    if (arguments != null) {
      _shifting = arguments['shifting'];
    }

    DataCache.initVehicleRequestBaseDb();

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadData();
    });
  }

  void _loadData() async {
    await _progressDialog?.show();
    try {
      _list = await OaService.getVehicleRequestList(_shifting);
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(VehicleRequestModel.getTitle(_shifting)),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: EasyRefresh(
        onRefresh: () async {
          _loadData();
        },
        child: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            VehicleRequestModel item = _list[index];
            return InkWell(
              onTap: () async {
                // Navigator.pushNamed(context, vehicleRequestDetailPath,
                //     arguments: {
                //       'vehicleRequestId': item.vehicleRequestId,
                //     });

                bool dataChanged = await navigatePage(
                    context, vehicleRequestDetailPath, arguments: {
                  'vehicleRequestId': item.vehicleRequestId,
                  'shifting': _shifting
                });

                if (dataChanged) {
                  _loadData();
                }
              },
              // child: _listItemWidget(item),
              child: VehicleRequestListItem(
                item: item,
                index: index + 1,
              ),
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
          itemCount: _list.length,
        ),
      ),
    );
  }

  /*
  Widget _listItemWidget(VehicleRequestModel item) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 4.0),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _listItemRow1(item),
          _listItemRow2(item),
          Text(
            item.reason,
            style: TextStyle(
              fontSize: fontSizeDetail,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItemRow1(VehicleRequestModel item) {
    return Row(
      children: <Widget>[
        Container(
          width: _leadingWidth,
          child: LabelText(
            '[${item.seqNo}]',
          ),
        ),
        Text(item.deptName),
        Expanded(
            child: Text(
          item.requestName,
          textAlign: TextAlign.center,
        )),
        Text(
          item.statusName,
          style: TextStyle(
            color: item.scheduled ? Colors.blue : Colors.red,
            fontSize: fontSizeDetail,
          ),
        ),
      ],
    );
  }

  Widget _listItemRow2(VehicleRequestModel item) {
    return Row(
      children: <Widget>[
        SizedBox(width: _leadingWidth),
        Expanded(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.flag,
                    color: Colors.green,
                    size: 16.0,
                  ),
                  Expanded(
                    child: Text(
                      item.origin,
                      style: TextStyle(
                        fontSize: fontSizeDetail,
                      ),
                    ),
                  ),
                  LabelText(
                    '${Utils.dateTimeToStrWithPattern(item.startTime, formatPatternDateTime)}',
                    fontSize: fontSizeDetail,
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.flag,
                    color: Colors.red,
                    size: 16.0,
                  ),
                  Expanded(
                    child: Text(
                      item.destination,
                      style: TextStyle(
                        fontSize: fontSizeDetail,
                      ),
                    ),
                  ),
                  LabelText(
                    '${Utils.dateTimeToStrWithPattern(item.finishTime, formatPatternDateTime)}',
                    fontSize: fontSizeDetail,
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: ScreenUtil().setSp(190.0),
          child: LabelText(
            item.usingTime,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
  */
}
