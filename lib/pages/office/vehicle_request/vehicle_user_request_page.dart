import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/request_result.dart';
import 'package:mis_app/model/vehicle_request.dart';
import 'package:mis_app/pages/office/vehicle_request/vehicle_request_list_item.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/oa_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/dismissible_delete_background.dart';
import 'package:mis_app/widget/search_text_field.dart';
import 'package:progress_dialog/progress_dialog.dart';

class VehicleUserRequestPage extends StatefulWidget {
  VehicleUserRequestPage({Key key}) : super(key: key);

  @override
  _VehicleUserRequestPageState createState() => _VehicleUserRequestPageState();
}

class _VehicleUserRequestPageState extends State<VehicleUserRequestPage> {
  List<VehicleRequestModel> _list = [];
  bool _hasMoreData;
  List<String> _suggestList = [];
  String _searchKeyword;
  ProgressDialog _progressDialog;

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    _suggestList = Prefs.getSelectHistory(Prefs.keyHistorySearchVehicleRequest);

    DataCache.initVehicleRequestBaseDb();

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadData(true);
    });
  }

  void _loadData(bool renewing) async {
    if (renewing) {
      _hasMoreData = true;
      _list.clear();
    }

    if (!_hasMoreData) return;

    await _progressDialog?.show();
    try {
      int maxId = _list.length > 0 ? _list.last.vehicleRequestId : 0;

      List<VehicleRequestModel> list =
          await OaService.getVehicleUserRequestList(_searchKeyword,
              maxId: maxId);
      if (list.length > 0) {
        _list.addAll(list);
        setState(() {});
      } else {
        _hasMoreData = false;
      }
    } finally {
      await _progressDialog?.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('用车申请'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.add), onPressed: _addRequest),
        ],
      ),
      body: SafeArea(child: _mainWidget),
    );
  }

  void _addRequest() {
    _openDetail();
  }

  Widget get _mainWidget {
    return Container(
      padding: EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
      child: Column(
        children: <Widget>[
          _searchWidget,
          SizedBox(height: 4.0),
          Expanded(child: _listWidget),
        ],
      ),
    );
  }

  Widget get _searchWidget {
    return SearchTextField(
      suggestList: _suggestList,
      hintText: '请输入查询条件',
      style: TextStyle(fontSize: fontSizeDefault),
      onTextChanged: (value) {
        setState(() {
          _searchKeyword = value;
        });
      },
      onSearch: () {
        _suggestList = Utils.updateHistoryList(_suggestList, _searchKeyword,
            maxHistoryCount: 20);
        Prefs.saveSelectHistory(
            Prefs.keyHistorySearchVehicleRequest, _suggestList);
        _loadData(true);
        Utils.closeInput(context);
      },
    );
  }

  Widget get _listWidget {
    return EasyRefresh(
      onRefresh: () async {
        _loadData(true);
      },
      onLoad: () async {
        _loadData(false);
      },
      child: ListView.separated(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          VehicleRequestModel item = _list[index];

          Widget itemWidget = InkWell(
            onTap: () {
              _openDetail(vehicleRequestId: item.vehicleRequestId);
            },
            child: VehicleRequestListItem(
              item: item,
              index: index + 1,
            ),
          );

          return item.userCanModify
              ? Dismissible(
                  key: Key(item.vehicleRequestId.toString()),
                  child: itemWidget,
                  background: DismissibleDeleteBackground(),
                  confirmDismiss: (DismissDirection direction) {
                    return _deleteItem(item);
                  },
                )
              : itemWidget;
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        },
        itemCount: _list.length,
      ),
    );
  }

  Future<bool> _deleteItem(VehicleRequestModel item) async {
    if (await DialogUtils.showConfirmDialog(
      context,
      '确定要删除当前申请吗？',
      confirmText: '删除',
      confirmTextColor: Colors.red,
    )) {
      RequestResult result =
          await OaService.deleteVehicleRequest(item.vehicleRequestId);
      if (result.success) {
        setState(() {
          _list.remove(item);
        });
        DialogUtils.showToast('申请已删除');

        return true;
      } else {
        DialogUtils.showToast(result.msg);
      }
    }

    return false;
  }

  void _openDetail({int vehicleRequestId}) async {
    bool dataChanged =
        await navigatePage(context, vehicleUserRequestDetailPath, arguments: {
      'vehicleRequestId': vehicleRequestId,
    });

    if (dataChanged) {
      _loadData(true);
    }
  }
}
