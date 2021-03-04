import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/pages/sales/widget/sample_delivery_detail_widget.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/single_line_info.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SampleDeliveryHandlePage extends StatefulWidget {
  final Map arguments;
  SampleDeliveryHandlePage({Key key, this.arguments}) : super(key: key);

  @override
  _SampleDeliveryHandlePageState createState() =>
      _SampleDeliveryHandlePageState();
}

class _SampleDeliveryHandlePageState extends State<SampleDeliveryHandlePage> {
  SampleDeliveryModel _sampleDelivery;
  List<SampleDeliveryDetailModel> _list = [];
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _sampleDelivery = SampleDeliveryModel();

    if (widget.arguments != null) {
      int sampleDeliveryId = widget.arguments['sampleDeliveryId'];
      if (sampleDeliveryId != null) {
        WidgetsBinding.instance.addPostFrameCallback((Duration d) {
          _loadData(sampleDeliveryId: sampleDeliveryId);
        });
      }
    }
  }

  void _loadData({int sampleDeliveryId}) async {
    if ((sampleDeliveryId == null) &&
        ((_sampleDelivery == null) || (_sampleDelivery.sampleDeliveryId <= 0)))
      return;

    sampleDeliveryId = sampleDeliveryId ?? _sampleDelivery.sampleDeliveryId;

    await _progressDialog?.show();
    try {
      SampleDeliveryWrapper result =
          await SalesService.getSampleDelivery(sampleDeliveryId);
      _updateCurrentSampleDelivery(result);
    } finally {
      await _progressDialog?.hide();
    }
  }

  void _updateCurrentSampleDelivery(SampleDeliveryWrapper result) {
    if (result == null) return;

    _sampleDelivery = result.sampleDelivery;
    _list = result.sampleDeliveryDetailList;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('申请处理'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
          color: backgroundColor,
          child: _masterDataWidget,
        ),
        Expanded(child: _listWidget),
      ],
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      onRefresh: () async {
        _loadData();
      },
      child: Container(
        color: Color(0xFFF5F1E6),
        // padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: SingleChildScrollView(
          child: ListView.builder(
            shrinkWrap: true,
            physics: new NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              SampleDeliveryDetailModel item = _list[index];

              Widget itemWidget = InkWell(
                onTap: () {
                  Navigator.pushNamed(context, sampleDeliveryLogPath,
                      arguments: {
                        'sampleDeliveryDetailId': item.sampleDeliveryDtlId
                      });
                },
                child: Card(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                    child: SampleDeliveryDetailWidget(
                      item: item,
                      sampleDeliveryStatus: _sampleDelivery.status,
                      onHandleButtonPressed:
                          (SampleDeliveryDetailModel item) async {
                        var result = await Navigator.pushNamed(
                            context, sampleDeliveryDetailReplyPath,
                            arguments: {
                              'sampleDelivery': _sampleDelivery.toJson(),
                              'sampleDeliveryDetail': item.toJson()
                            });
                        if ((result != null) && (result)) {
                          setPageDataChanged(this.widget, true);
                          _loadData();
                        }
                      },
                    ),
                  ),
                ),
              );

              return itemWidget;
            },
            // separatorBuilder: (BuildContext context, int index) {
            //   return Divider();
            // },
            itemCount: _list.length,
          ),
        ),
      ),
    );
  }

  Widget get _masterDataWidget {
    return Column(
      children: <Widget>[
        SingleLineInfo('客户名称：', _sampleDelivery.custName),
        _custDetailWidget('联系人：', _sampleDelivery.contactPerson),
        if (!Utils.textIsEmptyOrWhiteSpace(_sampleDelivery.contactPersonPosi))
          _custDetailWidget('职位：', _sampleDelivery.contactPersonPosi),
        _custDetailWidget('电话：', _sampleDelivery.contactTel),
        _custDetailWidget('地址：', _sampleDelivery.address),
        SingleLineInfo('运输方式：', _sampleDelivery.deliveryMethodName),
        if (!Utils.textIsEmptyOrWhiteSpace(
            _sampleDelivery.deliveryFeePayerName))
          SingleLineInfo('快递支付：', _sampleDelivery.deliveryFeePayerName),
        SingleLineInfo('申请日期：', Utils.dateTimeToStr(_sampleDelivery.date)),
        SingleLineInfo('备注：', _sampleDelivery.deliveryMethodName),
      ],
    );
  }

  Widget _custDetailWidget(String label, String value) {
    Widget placeHolder = Visibility(
      child: Text('客户'),
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      visible: false,
    );

    return Row(
      children: <Widget>[
        placeHolder,
        LabelText(
          label,
          fontSize: fontSizeDetail,
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: fontSizeDetail),
          ),
        ),
      ],
    );
  }
}
