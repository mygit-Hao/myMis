import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/sample_delivery.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sales_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/critical_button.dart';
import 'package:mis_app/widget/search_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SampleDeliveryPage extends StatefulWidget {
  SampleDeliveryPage({Key key}) : super(key: key);

  @override
  _SampleDeliveryPageState createState() => _SampleDeliveryPageState();
}

class _SampleDeliveryPageState extends State<SampleDeliveryPage> {
  List<SampleDeliveryModel> _list = [];
  List<String> _suggestList = [];
  String _searchKeyword;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _suggestList = Prefs.getSelectHistory(Prefs.keyHistorySampleDelivery);

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('送样申请'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _addSampleDelivery),
        ],
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  void _addSampleDelivery() async {
    // Navigator.pushNamed(context, sampleDeliveryDetailPath);
    if (await navigatePage(context, sampleDeliveryDetailPath)) {
      _loadData();
    }
  }

  void _loadData() async {
    await _progressDialog?.show();
    try {
      SampleDeliveryListWrapper result =
          await SalesService.getSampleDeliveryList(0, _searchKeyword);
      _list = result.sampleDeliveryList;
      setState(() {});
    } finally {
      await _progressDialog?.hide();
    }
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        _searchWidget,
        Expanded(
          child: _listWidget,
        ),
      ],
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      onRefresh: () async {
        _loadData();
      },
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          SampleDeliveryModel item = _list[index];
          return InkWell(
            onTap: () {
              _handleDetail(item);
            },
            child: _itemWidget(index),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: _list.length,
      ),
    );
  }

  void _handleDetail(SampleDeliveryModel item) async {
    // Navigator.pushNamed(context, sampleDeliveryDetailPath,
    //     arguments: {'sampleDeliveryId': item.sampleDeliveryId});

    bool dataChanged = false;

    /*
    if (item.status <= SampleDeliveryModel.statusSubmit) {
      dataChanged = await navigatePage(context, sampleDeliveryDetailPath,
          arguments: {'sampleDeliveryId': item.sampleDeliveryId});
    } else {
      dataChanged = await navigatePage(context, sampleDeliveryHandlePath,
          arguments: {'sampleDeliveryId': item.sampleDeliveryId});
    }
    */

    String routeName = item.status <= SampleDeliveryModel.statusSubmit
        ? sampleDeliveryDetailPath
        : sampleDeliveryHandlePath;
    dataChanged = await navigatePage(context, routeName,
        arguments: {'sampleDeliveryId': item.sampleDeliveryId});

    if (dataChanged) {
      _loadData();
    }
  }

  Widget _itemWidget(int index) {
    SampleDeliveryModel item = _list[index];
    return Column(
      children: <Widget>[
        Container(
          color: backgroundColor,
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (item.isUrgent)
                    Icon(
                      Icons.lens,
                      color: Colors.red,
                      size: 6.0,
                    ),
                  Expanded(child: Text(item.code)),
                  Text(
                    Utils.dateTimeToStr(item.date),
                    style: TextStyle(color: defaultFontColor),
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    item.statusName,
                    style: TextStyle(color: Colors.blue),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              Text(item.custName),
              if (!Utils.textIsEmptyOrWhiteSpace(item.sampleDeliveryItems))
                Text(
                  item.sampleDeliveryItems,
                  maxLines: 1,
                  style: TextStyle(
                    color: defaultFontColor,
                    fontSize: fontSizeDetail,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 8.0,
          ),
          child: CriticalButton(
            title: item.criticalFunctionName,
            onPressed: () {
              _handleSampleDelivery(index);
            },
          ),
        ),
      ],
    );
  }

  void _handleSampleDelivery(int index) async {
    SampleDeliveryModel item = _list[index];

    if (item.status == SampleDeliveryModel.statusSubmit) {
      if (await DialogUtils.showConfirmDialog(context, '确定要撤销该申请吗',
          confirmText: '撤销', confirmTextColor: Colors.red)) {
        SampleDeliveryWrapper result =
            await SalesService.toDraftSampleDelivery(item.sampleDeliveryId);
        if (result != null) {
          DialogUtils.showToast('已撤销申请');
          _list[index] = result.sampleDelivery;
          setState(() {});
        }
      }
    } else if (item.status == SampleDeliveryModel.statusDraft) {
      if (await DialogUtils.showConfirmDialog(context, '确定要删除该申请吗',
          confirmText: '删除', confirmTextColor: Colors.red)) {
        RequestResult result =
            await SalesService.cancelSampleDelivery(item.sampleDeliveryId);
        if (result.success) {
          DialogUtils.showToast('已删除申请');
          _loadData();
        } else {
          DialogUtils.showToast(result.msg);
        }
      }
    } else {
      _handleDetail(item);
    }
  }

  Widget get _searchWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
      color: Theme.of(context).backgroundColor,
      child: SearchTextField(
        suggestList: _suggestList,
        hintText: '请输入关键字',
        style: TextStyle(
          fontSize: fontSizeDefault,
          color: Colors.white,
        ),
        onTextChanged: (value) {
          setState(() {
            _searchKeyword = value;
          });
        },
        onSearch: _searchTap,
      ),
    );
  }

  void _searchTap() async {
    _suggestList = Utils.updateHistoryList(_suggestList, _searchKeyword,
        maxHistoryCount: 20);
    Prefs.saveSelectHistory(Prefs.keyHistorySampleDelivery, _suggestList);
    Utils.closeInput(context);
    _loadData();
  }
}
