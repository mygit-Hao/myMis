import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/sample_delivery_log.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SampleDeliveryLogPage extends StatefulWidget {
  final Map arguments;
  SampleDeliveryLogPage({Key key, this.arguments}) : super(key: key);

  @override
  _SampleDeliveryLogPageState createState() => _SampleDeliveryLogPageState();
}

class _SampleDeliveryLogPageState extends State<SampleDeliveryLogPage> {
  int _sampleDeliveryDetailId;
  List<SampleDeliveryLogModel> _list = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    Map arguments = widget.arguments;

    if (arguments != null) {
      _sampleDeliveryDetailId = arguments['sampleDeliveryDetailId'];

      if (_sampleDeliveryDetailId != null) {
        WidgetsBinding.instance.addPostFrameCallback((Duration d) {
          _loadData();
        });
      }
    }
  }

  void _loadData() async {
    await _progressDialog?.show();

    try {
      _list = await SalesService.getSampleDeliveryLog(_sampleDeliveryDetailId);
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
        title: Text('回复记录'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: _listWidget,
    );
  }

  Widget get _listWidget {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return _itemWidget(_list[index]);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemCount: _list.length,
    );
  }

  Widget _itemWidget(SampleDeliveryLogModel item) {
    return Container(
      color: backgroundColor,
      padding: EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LabelText(
            Utils.dateTimeToStrWithPattern(
                item.qCReplyDate, formatPatternDateTime),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'QC回复：',
                style: TextStyle(color: Colors.red),
              ),
              Expanded(
                child: LabelText(item.qCReplyStatusName),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          LabelText(
            Utils.dateTimeToStrWithPattern(
                item.handleDate, formatPatternDateTime),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '营业回复：',
                style: TextStyle(color: Colors.blueAccent),
              ),
              Expanded(
                child: LabelText(item.handleStatusName),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
