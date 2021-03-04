import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/model/sample_delivery_detail.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/critical_button.dart';
import 'package:mis_app/widget/label_text.dart';
import 'package:mis_app/widget/remarks_text_field.dart';
import 'package:mis_app/widget/single_line_info.dart';

class SampleDeliveryDetailReplyPage extends StatefulWidget {
  final Map arguments;
  SampleDeliveryDetailReplyPage({Key key, this.arguments}) : super(key: key);

  @override
  _SampleDeliveryDetailReplyPageState createState() =>
      _SampleDeliveryDetailReplyPageState();
}

class _SampleDeliveryDetailReplyPageState
    extends State<SampleDeliveryDetailReplyPage> {
  SampleDeliveryModel _sampleDelivery;
  SampleDeliveryDetailModel _sampleDeliveryDetail;
  bool _accepted;
  bool _endDelivery = false;
  TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _feedbackList = [
    {'name': '客户已下单，送货', 'tag': 101, 'selected': false},
    {'name': '客户稍候下单', 'tag': 102, 'selected': false},
    {'name': '价格太贵', 'tag': 1, 'selected': false},
    {'name': '粘力不够', 'tag': 2, 'selected': false},
    {'name': '粘度太高', 'tag': 3, 'selected': false},
    {'name': '粘度太稀', 'tag': 4, 'selected': false},
    {'name': '颜色不合要求', 'tag': 5, 'selected': false},
    {'name': '气味太大', 'tag': 6, 'selected': false}
  ];

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    Map arguments = widget.arguments;
    if (arguments != null) {
      _sampleDelivery =
          SampleDeliveryModel.fromJson(arguments['sampleDelivery']);
      _sampleDeliveryDetail =
          SampleDeliveryDetailModel.fromJson(arguments['sampleDeliveryDetail']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('送样反馈'),
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  Widget get _mainWidget {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _masterDataWidget,
          _detailDataWidget,
          _editingArea,
        ],
      ),
    );
  }

  Widget get _editingArea {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 8.0, 0, 4.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: CupertinoSegmentedControl(
                  children: {true: Text('接受'), false: Text('不接受')},
                  groupValue: _accepted,
                  onValueChanged: (value) {
                    _accepted = value;
                    if (!_sampleDeliveryDetail.isConfirming) {
                      _endDelivery = _accepted;
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
          _feedbacksWidget,
          Container(
            padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
            child: Column(
              children: <Widget>[
                RemarksTextField(
                  controller: _controller,
                  hintText: '请输入备注',
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    if (_sampleDeliveryDetail.canEndDelivery) Text('结束送样'),
                    if (_sampleDeliveryDetail.canEndDelivery)
                      Checkbox(
                          value: _endDelivery,
                          onChanged: (bool value) {
                            if (!_sampleDeliveryDetail.isConfirming) {
                              setState(() {
                                _endDelivery = !_endDelivery;
                              });
                            }
                          }),
                    CriticalButton(
                      title: '确定',
                      onPressed: _reply,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reply() async {
    if (await DialogUtils.showConfirmDialog(context, '确定要提交回复吗？')) {
      int handleStatus;
      if (_sampleDeliveryDetail.isConfirming) {
        if (!_accepted) {
          handleStatus = SampleDeliveryDetailModel.handleStatusRefuse;
        } else {
          handleStatus = SampleDeliveryDetailModel.handleStatusAccept;
        }
      } else {
        if (!_accepted) {
          handleStatus = SampleDeliveryDetailModel.handleStatusCustRefuse;
        } else {
          handleStatus = SampleDeliveryDetailModel.handleStatusCustAccept;
        }
      }

      String remarks = _controller.text;

      RequestResult result = await SalesService.updateSampleDeliveryDetailReply(
          _sampleDeliveryDetail.sampleDeliveryDtlId,
          handleStatus,
          _custFeedbackValue,
          _endDelivery,
          remarks);

      if (result.success) {
        DialogUtils.showToast('已提交回复');
        Navigator.pop(context, true);
      } else {
        DialogUtils.showToast(result.msg);
      }
    }
  }

  String get _custFeedbackValue {
    String splitor = ",";
    String value = splitor;

    if (!_sampleDeliveryDetail.isConfirming) {
      _feedbackList.forEach((element) {
        if (element['selected']) {
          int tag = element['tag'];
          if ((tag > 100) == _accepted) {
            value = value + tag.toString() + splitor;
          }
        }
      });
    }

    return value == splitor ? "" : value;
  }

  Widget get _feedbacksWidget {
    List<Widget> widgetList = _feedbackList.map((Map<String, dynamic> item) {
      return _feedbackWidget(item);
    }).toList();

    return Container(
      child: Column(
        children: widgetList,
      ),
    );
  }

  Widget _feedbackWidget(Map<String, dynamic> item) {
    int tag = item['tag'];
    bool visible = false;

    if (!_sampleDeliveryDetail.isConfirming) {
      if (_accepted == null) {
        visible = false;
      } else if (_accepted) {
        visible = tag > 100;
      } else {
        visible = tag <= 100;
      }
    }

    return Visibility(
      visible: visible,
      child: CheckboxListTile(
        title: Text(
          item['name'],
          style: TextStyle(fontSize: fontSizeDetail),
        ),
        dense: true,
        value: item['selected'],
        selected: item['selected'],
        onChanged: (bool value) {
          setState(() {
            item['selected'] = !item['selected'];
          });
        },
      ),
    );
  }

  Widget get _detailDataWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      color: backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _sampleItemWidget,
          if (!Utils.textIsEmptyOrWhiteSpace(_sampleDeliveryDetail.otdesc1))
            LabelText(_sampleDeliveryDetail.otdesc1, fontSize: fontSizeDetail),
          if (!Utils.textIsEmptyOrWhiteSpace(_sampleDeliveryDetail.otdesc2))
            LabelText(_sampleDeliveryDetail.otdesc2, fontSize: fontSizeDetail),
          if (!Utils.textIsEmptyOrWhiteSpace(_sampleDeliveryDetail.otdesc3))
            LabelText(_sampleDeliveryDetail.otdesc3, fontSize: fontSizeDetail),
          if (!Utils.textIsEmptyOrWhiteSpace(_sampleDeliveryDetail.otdesc4))
            Text(
              _sampleDeliveryDetail.otdesc4,
              style:
                  TextStyle(fontSize: fontSizeDetail, color: Color(0xffff9900)),
            ),
          if (!Utils.textIsEmptyOrWhiteSpace(
              _sampleDeliveryDetail.operationTech))
            LabelText(_sampleDeliveryDetail.operationTech,
                fontSize: fontSizeDetail),
          if (!Utils.textIsEmptyOrWhiteSpace(_sampleDeliveryDetail.specialReq))
            LabelText(_sampleDeliveryDetail.specialReq,
                fontSize: fontSizeDetail),
          if (!Utils.textIsEmptyOrWhiteSpace(
              _sampleDeliveryDetail.predictDemand))
            LabelText(_sampleDeliveryDetail.predictDemand,
                fontSize: fontSizeDetail),
          SizedBox(height: 4.0),
          Text(
            _sampleDeliveryDetail.statusDesc,
            style:
                TextStyle(fontSize: fontSizeDetail, color: Colors.blueAccent),
          ),
        ],
      ),
    );
  }

  Widget get _sampleItemWidget {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            _sampleDeliveryDetail.itemDesc,
            style: TextStyle(fontSize: fontSizeDetail),
          ),
        ),
        LabelText(
          '(${_sampleDeliveryDetail.ot1})',
          fontSize: fontSizeSmall,
        ),
        if (_sampleDeliveryDetail.deliveryItemIsDifferent)
          Icon(
            Icons.arrow_right,
            color: Colors.blue,
            size: 20.0,
          ),
        if (_sampleDeliveryDetail.deliveryItemIsDifferent)
          Expanded(
            child: LabelText(
              _sampleDeliveryDetail.deliveryItemDesc,
              fontSize: fontSizeDetail,
            ),
          ),
        Text(
          ' ${_sampleDeliveryDetail.qtyDesc}',
          style: TextStyle(fontSize: fontSizeDetail),
        ),
      ],
    );
  }

  Widget get _masterDataWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: Column(
        children: <Widget>[
          SingleLineInfo('客户：', _sampleDelivery.custName),
          SingleLineInfo('日期：', Utils.dateTimeToStr(_sampleDelivery.date)),
        ],
      ),
    );
  }
}
