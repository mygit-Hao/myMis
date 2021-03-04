import 'package:flui/flui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/base_db.dart';
import 'package:mis_app/model/sevens_basedb.dart';
import 'package:mis_app/model/user.dart';
import 'package:mis_app/pages/common/webView_page.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_group_page.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sevens_check_service.dart';
import 'package:mis_app/service/user_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/utils/dialog_utils.dart';

class SevenSMainPage extends StatefulWidget {
  @override
  _SevenSMainPageState createState() => _SevenSMainPageState();
}

class _SevenSMainPageState extends State<SevenSMainPage> {
  bool _hasMoreData = true;
  int _errCode = -1;
  List<Map> _list = [];
  FLToastDefaults _defaults = new FLToastDefaults();
  // List<Map> _baseList=[];

  FocusNode _keywordFN = FocusNode();
  final TextEditingController _keywordControl = TextEditingController();
  SlidableController _slidableController = SlidableController();
  EasyRefreshController _refreshCtrl = EasyRefreshController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _getBaseDb();
      _getCheckBaseData();
      _getCheckListData(true);
      _getDefaultUser();
    });

    super.initState();
  }

  // @override
  // void deactivate() {
  //   super.deactivate();
  //   var bool = ModalRoute.of(context).isCurrent;
  //   if (bool) {
  //     initState(); //需要调用的方法
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return FLToastProvider(
      defaults: _defaults,
      child: Container(
        child: Scaffold(
          appBar: _appBar(),
          body: SafeArea(
              child: Container(
            margin: EdgeInsets.only(top: 3),
            color: Colors.white,
            child: Column(children: <Widget>[
              searchViewCustom(_keywordControl, _search),
              // _searchViewCustom(),
              _checkListView(),
              _addCheckButton(),
            ]),
          )),
          // floatingActionButton: FloatingActionButton(onPressed: (){},child:Icon(Icons.add)),
        ),
      ),
    );
  }

//标题栏
  Widget _appBar() {
    return AppBar(
      elevation: 0.5,
      title: Text("7S检查"),
      actions: <Widget>[
        // IconButton(
        //   icon: Icon(
        //     Icons.add,
        //     size: 30,
        //   ),
        //   onPressed: () async {
        //     _keywordFN.unfocus();
        //     StaticData.status = 0;
        //     StaticData.isCopyAdd = false;
        //     bool dataChanged = await navigatePage(context, sevensGroupPath);
        //     if (dataChanged) _getCheckListData(true);
        //   },
        // ),
        IconButton(
          icon: Icon(
            Icons.help_outline,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return WebViewPage(
                arguments: {'title': '7S检查', 'url': serviceUrl[sevensHelpUrl]},
              );
            }));
          },
        )
      ],
    );
  }

//检查列表
  Widget _checkListView() {
    return Expanded(
      child: EasyRefresh(
        controller: _refreshCtrl,
        header: customRefreshHeader,
        footer: customRefreshFooter,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _list.length,
          itemBuilder: (context, index) {
            // return Dismissible(
            //     key: Key(_list[index]['CheckId'].toString()),
            //     confirmDismiss: (DismissDirection dismissDirection) {
            //       return _handleDeleteRusult(_list[index]);
            //     },
            //     background: deleteBg(),
            //     child: _itemCheck(context, _list[index]));
            return Slidable(
              actionPane: SlidableDrawerActionPane(),
              controller: _slidableController,
              secondaryActions: [
                IconSlideAction(
                  caption: '复制新增',
                  icon: Icons.content_copy,
                  color: Colors.blue,
                  onTap: () async {
                    StaticData.isCopyAdd = true;
                    bool dataChanged = await navigatePage(
                        context, sevensGroupPath,
                        arguments: {'checkId': _list[index]['CheckId']});
                    if (dataChanged) _getCheckListData(true);
                  },
                ),
                IconSlideAction(
                  caption: '删除',
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () {
                    _handleDeleteRusult(_list[index]);
                  },
                )
              ],
              child: _itemCheck(context, _list[index]),
            );
          },
        ),
        onRefresh: () async {
          _getCheckListData(true);
        },
        onLoad: () async {
          _getCheckListData(false);
        },
      ),
    );
  }

//添加按钮
  Widget _addCheckButton() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      width: ScreenUtil().setWidth(720),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.blue,
        onPressed: () async {
          _keywordFN.unfocus();
          StaticData.status = 0;
          StaticData.isCopyAdd = false;
          bool dataChanged = await navigatePage(context, sevensGroupPath);
          if (dataChanged) _getCheckListData(true);
        },
        child: Text(
          "新增7S 检查",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  //item
  Widget _itemCheck(BuildContext context, item) {
    DateTime checkDate = DateTime.parse(item["CheckDate"]);
    return InkWell(
      onTap: () async {
        int checkId = item['CheckId'];
        _keywordFN.unfocus();
        StaticData.isCopyAdd = false;
        bool dataChanged = await navigatePage(context, sevensGroupPath,
            arguments: {'checkId': checkId});
        if (dataChanged) _getCheckListData(true);
      },
      child: Container(
        decoration: bottomLineDecotation,
        child: Row(
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(750),
              padding: EdgeInsets.all(8),
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: customText(
                      color: Colors.blue[600],
                      value: item['AreaName'] + "/" + item['AreaGroupName'],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child:
                              customText(value: "第" + item['GroupName'] + "组"),
                        ),
                        Expanded(
                          child: Text(
                            item['StatusName'],
                            style: statusTextStyle(item['Status']),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: customText(value: item['CheckUserChnName']),
                          ),
                          Expanded(
                            child: customText(
                                value: Utils.dateTimeToStr(checkDate)),
                          )
                        ],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
      // Icon(Icons.clear),
    );
  }

//获取地区人员数据
  void _getBaseDb() async {
    BaseDbModel.baseDbModel = await UserService.getBaseDb();
  }

//获取7S检查基础数据
  void _getCheckBaseData() async {
    SevensBaseDBModel.baseDBModel = await SevensCheckService.getCheckBaseData();
  }

  void _search() {
    _getCheckListData(true);
  }

//获取检查列表
  void _getCheckListData(bool isRefresh) async {
    if (isRefresh) {
      _list.clear();
      _hasMoreData = true;
    }
    if (!_hasMoreData) return;
    Function dismiss = FLToast.showLoading();
    try {
      int maxid = isRefresh ? 0 : _list.last['CheckId'];
      var list =
          await SevensCheckService.getCheckData(_keywordControl.text, maxid);
      if (list.length > 0) {
        _list.addAll(list);
        if (isRefresh) _refreshCtrl.resetLoadState();
      } else {
        _hasMoreData = false;
        _refreshCtrl.finishLoad(success: true, noMore: true);
      }
      setState(() {});
    } catch (e) {
      dismiss();
    } finally {
      dismiss();
    }
  }

//删除检查记录
  Future<bool> _handleDeleteRusult(item) async {
    if (item['Status'] != 0) {
      DialogUtils.showToast("${item['StatusName']}单据不能删除");
      return false;
    }
    bool isDelete = false;
    bool isDel = await DialogUtils.showConfirmDialog(context, "是否删除该次检查记录？",
        iconData: Icons.warning, color: Colors.red);
    if (isDel) {
      var result =
          await SevensCheckService.getRequstResult(item['CheckId'], 'delete');
      _errCode = result['ErrCode'];
      String errMsg = result['ErrMsg'];
      if (_errCode == 0) {
        isDelete = true;
        DialogUtils.showToast("删除成功");
        if (_errCode == 0) {
          _list.remove(item);
          setState(() {});
        }
      } else {
        Fluttertoast.showToast(msg: errMsg, gravity: ToastGravity.CENTER);
      }
    }

    return isDelete;
  }

  void _getDefaultUser() {
    SevensBaseDBModel.userList.clear();
    UserModel userModel = new UserModel();
    userModel.userId = UserProvide.currentUser.userId;
    userModel.userChnName = UserProvide.currentUser.staffName;
    SevensBaseDBModel.userList.add(userModel);
  }
}
