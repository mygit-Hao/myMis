import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/work_clock_service.dart';
import 'package:mis_app/utils/utils.dart';

class CustomerSelectPage extends StatefulWidget {
  @override
  _CustomerSelectPageState createState() => _CustomerSelectPageState();
}

class _CustomerSelectPageState extends State<CustomerSelectPage>
    with SingleTickerProviderStateMixin {
  Widget _textContactAndPhone(String str) {
    return Text(str,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14, color: Color.fromARGB(180, 45, 45, 45)));
  }

  String _maxCode = '';
  List<Tab> tabsList = [];
  List _oldCustomerList = [];
  List _newCustomerList = [];

  TabController _tabController;
  TextEditingController _keywordController = new TextEditingController();
  // FLToastDefaults _flToastDefaults = FLToastDefaults();

  @override
  void initState() {
    super.initState();
    tabsList.add(Tab(text: "客户"));
    tabsList.add(Tab(text: "新客"));
    this._tabController =
        new TabController(vsync: this, length: tabsList.length);
    // WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
    // var dismiss=FLToast.loading(text:'tttttt');
    _getCustomerData();
    // dismiss();
    // });
  }

  @override
  void dispose() {
    this._tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Utils.closeInput(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('客户选择'),
        ),
        body: Container(
          padding: EdgeInsets.all(8),
          child: Column(children: <Widget>[
            _searchWidget(),
            _customTabBar(),
          ]),
        ),
      ),
    );
  }

  ///客户搜索、添加
  Widget _searchWidget() {
    return Container(
      alignment: Alignment.center,
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(width: 0.5, color: Colors.black45),
      ),
      child: Row(children: <Widget>[
        _keyword(),
        _searchCustomer(),
        _addCustomer(),
      ]),
    );
  }

  ///关键字输入框
  Widget _keyword() {
    return Expanded(
      child: TextField(
        controller: _keywordController,
        textInputAction: TextInputAction.search,
        onSubmitted: (v) {
          _maxCode = '';
          _oldCustomerList.clear();
          _getCustomerData();
        },
        decoration: InputDecoration(
            hintText: '关键字搜索',
            contentPadding: EdgeInsets.fromLTRB(10, 1, 1, 5),
            border: InputBorder.none),
      ),
    );
  }

  ///搜索
  Widget _searchCustomer() {
    return InkWell(
      onTap: () {
        _maxCode = '';
        _oldCustomerList.clear();
        _getCustomerData();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.search,
          color: Colors.blue,
        ),
      ),
    );
  }

  ///添加顾客
  Widget _addCustomer() {
    return InkWell(
      onTap: () async {
        // Navigator.pushNamed(context, customerAddPath).then((value) {
        //   Utils.closeInput(context);
        //   _getCustomerData();
        // });
        Utils.closeInput(context);
        bool dataChanged = await navigatePage(context, customerAddPath);
        if (dataChanged) _getCustomerData();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(
          Icons.group_add,
          color: Colors.blue,
        ),
      ),
    );
  }

  ///客户TabBar
  Widget _customTabBar() {
    return Expanded(
      child: Column(children: <Widget>[
        Container(
          //  padding: EdgeInsets.all(0.5),
          decoration:
              BoxDecoration(border: Border(bottom: BorderSide(width: 0.2))),
          child: TabBar(
              unselectedLabelColor: Colors.black,
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
              indicatorSize: TabBarIndicatorSize.tab,
              controller: _tabController,
              tabs: tabsList),
        ),
        Expanded(
          child: TabBarView(controller: _tabController, children: [
            _customersList(_oldCustomerList, false),
            _customersList(_newCustomerList, true),
          ]),
        ),
      ]),
    );
  }

  Widget _customersList(List list, bool isNew) {
    return EasyRefresh(
      header: customRefreshHeader,
      footer: customRefreshFooter,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = list[index];
          return InkWell(
            onTap: () {
              item.addAll({'isNew': isNew});
              Navigator.pop(context, item);
            },
            child: Container(
                decoration: bottomLineDecotation,
                padding: EdgeInsets.only(top: 10, bottom: 8),
                child: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          padding: EdgeInsets.only(top: 3, bottom: 3),
                          child: Text(
                            list[index]['Name'],
                            style: TextStyle(color: Colors.blue),
                          )),
                      Row(
                        children: <Widget>[
                          Expanded(
                            // width: ScreenUtil().setWidth(350),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.person,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                Expanded(
                                  child: _textContactAndPhone(
                                      "联系人：${list[index]['ContactPerson']}"),
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.phone,
                                  size: 18,
                                  color: Colors.orange,
                                ),
                                Expanded(
                                  child: _textContactAndPhone(
                                    "电话：${isNew ? list[index]['ContactPersonTel'] : list[index]['ContactTel']}",
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                )),
          );
        },
      ),
      onRefresh: () async {
        _oldCustomerList.clear();
        _maxCode = '';
        _getCustomerData();
      },
      onLoad: () async {
        _getCustomerData();
      },
    );
  }

  ///获取客服列表
  void _getCustomerData() async {
    // var dismiss = FLToast.loading(text: 'Loading...');
    try {
      ///老客服
      var oldCustomerList = await WorkClockService.getCustomerList(
          'getcustlist', _keywordController.text,
          maxCode: _maxCode);

      ///新客服
      var newCustomerList = await WorkClockService.getCustomerList(
          'getpotentiallist', _keywordController.text);

      {
        if (mounted) {
          setState(() {
            _oldCustomerList.addAll(oldCustomerList);
            _newCustomerList = newCustomerList;
          });
        }
        if (_oldCustomerList.length > 0) {
          int lastIndex = _oldCustomerList.length - 1;
          _maxCode = _oldCustomerList[lastIndex]['Code'];
        }
      }
    } finally {
      // dismiss();
    }
  }
}
