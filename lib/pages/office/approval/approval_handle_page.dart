import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/common/data_cache.dart';
import 'package:mis_app/common/prefs.dart';
import 'package:mis_app/model/approval.dart';
import 'package:mis_app/model/approval_audit_remarks.dart';
import 'package:mis_app/model/approval_head.dart';
import 'package:mis_app/model/approval_invite_result.dart';
import 'package:mis_app/model/approval_message.dart';
import 'package:mis_app/model/approval_message_result.dart';
import 'package:mis_app/model/approval_next.dart';
import 'package:mis_app/model/approval_result.dart';
import 'package:mis_app/model/user.dart';
import 'package:mis_app/pages/common/search_user.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/approval_service.dart';
import 'package:mis_app/service/service_method.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/utils/web_view_manager.dart';
import 'package:mis_app/widget/custom_button.dart';
import 'package:mis_app/widget/large_button.dart';
import 'package:mis_app/widget/loading_indicator.dart';
import 'package:mis_app/widget/page_title.dart';
// import 'package:progress_dialog/progress_dialog.dart';

class ApprovalHandlePage extends StatefulWidget {
  final Map arguments;
  ApprovalHandlePage({Key key, this.arguments}) : super(key: key);

  @override
  _ApprovalHandlePageState createState() => _ApprovalHandlePageState();
}

class _ApprovalHandlePageState extends State<ApprovalHandlePage> {
  static const int _approvalMessageKindApproval = 0;
  static const int _approvalMessageKindDeny = 1;
  static const int _direction_forward = 1;
  static const int _direction_backward = -1;

  static GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  // InAppWebViewController _controller;
  String _docType;
  String _docId;
  bool _isApprovaled;
  ApprovalHeadModel _approvalHead;
  // String _url;
  String _homeUrl;
  bool _selectedApprovalOK;
  // bool _autoClearHistory;
  // ProgressDialog _progressDialog;
  TextEditingController _denyRemarksController = TextEditingController();
  TextEditingController _signUndoRemarksController = TextEditingController();
  TextEditingController _denyAfterSignController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  List<ApprovalMessageModel> _currentMessageList;
  List<ApprovalMessageModel> _allMessageList;
  int _currentApprovalMessageType;
  List<int> _usedMessageList;
  // bool _showNavigator = false;
  bool _loading = false;
  String _loadingMessage = loadingMessage;
  bool _functionVisible = true;

  bool _approvalWidgetVisible,
      _accountingWidgetVisible,
      _signCancelWidgetVisible,
      _signUndoWidgetVisible,
      _denyAfterSignWidgetVisible;
  int _webViewIndex = 0;
  List<InAppWebView> _webViewList;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    WebViewManager.dispose();

    super.dispose();
  }

  InAppWebViewController get _controller {
    InAppWebViewController controller =
        WebViewManager.getController(_webViewIndex);
    return controller;
  }

  void _init() {
    // _autoClearHistory = false;

    // print(widget.arguments);

    var arguments = widget.arguments;

    _docType = arguments['docType'];
    _docId = arguments['docId'];
    _isApprovaled = arguments['isApprovaled'];

    _currentMessageList = List();
    _allMessageList = List();
    _usedMessageList = List();
    _currentApprovalMessageType = _approvalMessageKindApproval;

    // _url = 'https://baidu.com';
    // _url = ApprovalService.getApprovalDataUrl(_docType, _docId);
    // print(_url);
    // _loadApprovalData();
    _initWebViews();

    _loadApprovalMessage();

    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _loadApprovalData();
      _preloadUrls(_direction_forward);
    });
  }

  void _initWebViews() {
    List<String> urls = _getInitUrls();

    WebViewManager.init(
      urls: urls,
      headers: getRequestHeader(),
      initialOptions: InAppWebViewGroupOptions(
        android: AndroidInAppWebViewOptions(
          builtInZoomControls: true,
        ),
      ),
    );
  }

  List<String> _getInitUrls() {
    List<String> urls = List();
    String url = ApprovalService.getApprovalDataUrl(_docType, _docId);
    urls.add(url);

    String nextDocType = _docType;
    String nextDocId = _docId;

    for (var i = 0; i < WebViewManager.capatity - 1; i++) {
      ApprovalModel nextItem =
          DataCache.getNextApprovalItem(nextDocType, nextDocId);
      if (nextItem == null) break;

      nextDocType = nextItem?.docType;
      nextDocId = nextItem?.docId;
      url = ApprovalService.getApprovalDataUrl(nextDocType, nextDocId);

      if (!urls.contains(url)) {
        urls.add(url);
      }
    }

    return urls;
  }

  @override
  Widget build(BuildContext context) {
    // _progressDialog = getProgressDialog(this.context);

    return WillPopScope(
      onWillPop: () async {
        if (_controller != null) {
          bool value = await _controller.canGoBack();

          if (value) {
            // 由于iOS平台没有清除历史记录clearHistory方法
            // 跳转到新的审批单后，不能清除历史记录
            // 导致跳到下一张单、按返回时，跳到之前的单，不能自动返回，需要自己判断

            // 获取最后一项原始Url
            // 如果与_homeUrl一致，表示当前是重新加载的起始页，按返回键时退出
            // 用于上一单、下一单的返回，避免跳转多个单后，需要从第1张单才能返回的问题
            String originalUrl = await _currentOriginalUrl;
            if (Utils.sameUrl(originalUrl, _homeUrl)) {
              return true;
            }

            _controller.goBack();

            return false;
          }
        }

        return true;
      },
      child: _mainWidget,
    );
  }

  /// 获取页面在历史记录中对应的原始Url
  Future<String> get _currentOriginalUrl async {
    WebHistory history = await _controller.getCopyBackForwardList();

    if (history.list.length > 0) {
      return history.list[history.currentIndex].originalUrl;
    }

    return '';
  }

  void _loadApprovalData({bool needProgressDialog = true}) async {
    String url = ApprovalService.getApprovalDataUrl(_docType, _docId);
    ApprovalHeadModel head;

    // _progressDialog?.style(message: loadingMessage);

    int index = 0;

    if (needProgressDialog) {
      // await _progressDialog?.show();
      _showLoading();
    }
    try {
      // _autoClearHistory = true;
      // _controller.loadUrl(url: url, headers: getRequestHeader());

      index = WebViewManager.loadUrl(url);
      _homeUrl = url;
      head = await ApprovalService.getHead(_docType, _docId);
    } finally {
      // await _progressDialog?.hide();
      _hideLoading();
    }

    // print('Approval Head: $head');
    _denyRemarksController.text = '';
    _signUndoRemarksController.text = '';
    _denyAfterSignController.text = '';

    setState(() {
      _selectedApprovalOK = null;
      _approvalHead = head;
      _webViewIndex = index;
    });

    if (!head.canSupport) {
      DialogUtils.showToast('暂不支持此单据审批，请使用电脑版操作');
    } else if (head.fileCount > 0) {
      DialogUtils.showToast('有 ${head.fileCount} 个附件，请注意查看',
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void _preloadUrls(int direction) {
    String nextDocType = _docType;
    String nextDocId = _docId;

    for (var i = 0; i < 2; i++) {
      // ApprovalModel nextItem =
      //     DataCache.getNextApprovalItem(nextDocType, nextDocId);
      ApprovalModel nextItem = direction > 0
          ? DataCache.getNextApprovalItem(_docType, _docId)
          : DataCache.getPreviousApprovalItem(_docType, _docId);

      if (nextItem == null) break;

      nextDocType = nextItem?.docType;
      nextDocId = nextItem?.docId;

      WebViewManager.preloadUrl(
          ApprovalService.getApprovalDataUrl(nextDocType, nextDocId));
    }
  }

  bool get _isApprovalBill {
    return (_approvalHead != null) && _approvalHead.isApprovalBill;
  }

  Widget get _mainWidget {
    String title = _approvalHead?.docTypeName;
    title = (Utils.textIsEmpty(title) ? "" : title + ' - ');
    title = '$title审批';
    // 测试用
    // showInvite = true;

    return Scaffold(
      key: _globalKey,
      appBar: AppBar(
        title: Text(title),
        actions: _actionsWidget,
      ),
      body: SafeArea(
        child: Container(
          child: Stack(
            children: <Widget>[
              _approvalMainWidget,
              Visibility(
                // visible: _showNavigator,
                // visible: true,
                visible: DataCache.hasMultiApprovalCache,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _navigateWidget(
                    Icons.arrow_left,
                    onPressed: () {
                      // print('left');
                      _getNext(_direction_backward);
                    },
                  ),
                ),
              ),
              Visibility(
                // visible: _showNavigator,
                // visible: true,
                visible: DataCache.hasMultiApprovalCache,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _navigateWidget(
                    Icons.arrow_right,
                    onPressed: () {
                      // print('right');
                      _getNext(_direction_forward);
                    },
                  ),
                ),
              ),
              if (_loading)
                GestureDetector(
                  child: LoadingIndicator(
                    message: _loadingMessage,
                  ),
                  onTap: () {
                    _hideLoading();
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_isApprovalBill
          ? null
          : FloatingActionButton(
              mini: true,
              child: Icon(Icons.share),
              onPressed: () {
                _showInvite();
              },
            ),
    );
  }

  List<Widget> get _actionsWidget {
    bool hasApprovalFunction = false;
    if (_approvalHead != null) {
      if (_isApprovaled) {
        hasApprovalFunction =
            (!_approvalHead.isApprovalBill && _approvalHead.canSignUndo) ||
                _approvalHead.isApprovalBill;
      } else {
        hasApprovalFunction = _approvalHead.canApproval ||
            _approvalHead.canAccounting ||
            _approvalHead.canSignCancel ||
            _approvalHead.canSignUndo;
      }
    }

    return <Widget>[
      if (_isApprovalBill)
        IconButton(
          icon: Icon(Icons.library_books),
          onPressed: () {
            _showAuditRemarks();
          },
        ),
      if ((_approvalHead != null) && (_approvalHead.fileCount > 0))
        IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () {
              _showAttachment();
            }),
      if (hasApprovalFunction)
        IconButton(
          icon:
              Icon(_functionVisible ? Icons.fullscreen : Icons.fullscreen_exit),
          onPressed: () {
            setState(() {
              _functionVisible = !_functionVisible;
            });
          },
        ),
    ];
  }

  void _showAttachment() {
    Navigator.pushNamed(context, approvalAttachmentPath, arguments: {
      'docType': _docType,
      'docId': _docId,
    });
  }

  void _showAuditRemarks() async {
    // 测试用
    // List<ApprovalAuditRemarksModel> auditRemarksList =
    //     await ApprovalService.getAuditRemarks('ExpenseClaim', '1812000249');

    List<ApprovalAuditRemarksModel> auditRemarksList =
        await ApprovalService.getAuditRemarks(_docType, _docId);

    if (auditRemarksList.isEmpty) {
      DialogUtils.showToast('没有“审批/否决备注记录”');
      return;
    }

    // print(auditRemarksList);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var child = Column(
          children: <Widget>[
            PageTitle(
              title: '审批/否决备注',
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ApprovalService.approvaledDaysItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return _auditRemarksWidget(auditRemarksList[index]);
                },
              ),
            ),
          ],
        );
        //使用AlertDialog会报错
        //return AlertDialog(content: child);

        return Dialog(child: child);
      },
    );
  }

  Widget _auditRemarksWidget(ApprovalAuditRemarksModel remarks) {
    return Container(
      padding: EdgeInsets.all(6.0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(150.0),
                child: Text(
                  remarks.userName,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: fontSizeDefault,
                  ),
                ),
              ),
              Text(
                remarks.type,
                style: TextStyle(
                  fontSize: fontSizeDefault,
                ),
              ),
              Expanded(
                child: Text(
                  Utils.dateTimeToStr(remarks.auditDate),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: fontSizeDefault,
                  ),
                ),
              ),
            ],
          ),
          if (!Utils.textIsEmptyOrWhiteSpace(remarks.auditRemarks))
            Container(
              width: double.infinity,
              child: Text(
                remarks.auditRemarks,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: fontSizeSmall,
                ),
              ),
            )
        ],
      ),
    );
  }

  void _showInvite() {
    SnackBar snackBar = SnackBar(
      content: Text("审批人：${_approvalHead.allApproval}"),
      action: SnackBarAction(
        label: '邀请',
        onPressed: () async {
          var result = await showSearch(
            context: context,
            delegate: SearchUserDelegate(Prefs.keyHistorySelectUser),
          );

          if (result == null) return;

          UserModel user = UserModel.fromJson(json.decode(result));
          if (await DialogUtils.showConfirmDialog(
              context, '确定要邀请用户 (${user.userChnName}) 加入审批吗?')) {
            // print('Invited');
            _invite(user.userId);
          }
        },
      ),
    );

    // Scaffold.of(context).showSnackBar(snackBar);
    _globalKey.currentState.showSnackBar(snackBar);
  }

  void _invite(String userId) async {
    // print(userId);

    ApprovalInviteResultModel result;
    // _progressDialog?.style(message: updatingMessage);

    // await _progressDialog?.show();

    _showLoading(message: updatingMessage);
    try {
      result = await ApprovalService.invite(_docType, _docId, userId);
    } finally {
      // await _progressDialog?.hide();
      _hideLoading();
    }

    if (result == null) return;

    String msg = result.result;
    Toast toastLength = Toast.LENGTH_SHORT;

    if (result.errCode == 0) {
      if (result.data != null) {
        ApprovalHeadModel head = result.data;
        setState(() {
          _approvalHead = head;
        });
      }
    } else {
      msg = result.errMsg;
      toastLength = Toast.LENGTH_LONG;
    }
    DialogUtils.showToast(msg, toastLength: toastLength);
    //Toast.makeText(this, msg, toastLen).show();
  }

  void _getNext(int direction) async {
    Utils.closeInput(context);

    ApprovalModel nextItem = direction > 0
        ? DataCache.getNextApprovalItem(_docType, _docId)
        : DataCache.getPreviousApprovalItem(_docType, _docId);

    /*
    String nextDocType = nextItem?.docType;
    String nextDocId = nextItem?.docId;

    _progressDialog?.style(message: loadingMessage);

    await _progressDialog?.show();
    try {
      ApprovalNextModel result =
          await ApprovalService.getNext(nextDocType, nextDocId);

      if (result.hasMoreData &&
          (!Utils.textIsEmpty(nextDocType)) &&
          (!Utils.textIsEmpty(nextDocId))) {
        _docType = nextDocType;
        _docId = nextDocId;

        _loadApprovalData(needProgressDialog: false);
      } else {
        _loadApprovalData(needProgressDialog: false);
        DialogUtils.showToast('已无可审单据');
      }
    } finally {
      await _progressDialog?.hide();
    }
    */

    _showLoading();

    try {
      String nextDocType = nextItem?.docType;
      String nextDocId = nextItem?.docId;

      if (nextItem != null) {
        if ((!Utils.textIsEmpty(nextDocType)) &&
            (!Utils.textIsEmpty(nextDocId))) {
          _docType = nextDocType;
          _docId = nextDocId;

          _loadApprovalData(needProgressDialog: false);
        }
      } else {
        ApprovalNextModel result =
            await ApprovalService.getNext(nextDocType, nextDocId);

        if (result.hasMoreData &&
            (!Utils.textIsEmpty(nextDocType)) &&
            (!Utils.textIsEmpty(nextDocId))) {
          _docType = nextDocType;
          _docId = nextDocId;

          _loadApprovalData(needProgressDialog: false);
        } else {
          _loadApprovalData(needProgressDialog: false);
          DialogUtils.showToast('已无可审单据');
        }
      }
      _preloadUrls(direction);
    } finally {
      _hideLoading();
    }
  }

  void _showLoading({String message = loadingMessage}) {
    setState(() {
      _loadingMessage = message;
      _loading = true;
    });
  }

  void _hideLoading() {
    if (_loading) {
      setState(() {
        _loading = false;
      });
    }
  }

  Widget _navigateWidget(IconData icon, {Function onPressed}) {
    // return FloatingActionButton(
    //   onPressed: onPressed,
    //   child: Icon(icon),
    //   mini: true,
    //   backgroundColor: Colors.transparent,
    //   foregroundColor: Theme.of(context).primaryColor,
    //   elevation: 0,
    // );
    return IconButton(
      icon: Icon(
        icon,
        size: 36.0,
        // color: Theme.of(context).primaryColor,
        color: secondaryColor,
      ),
      onPressed: onPressed,
    );
  }

  Widget get _approvalMainWidget {
    return Column(
      children: <Widget>[
        Expanded(
          // child: _webViewWidget,
          child: _webViewWidgets,
        ),
        Visibility(
          child: _functionWidget,
          visible: _functionVisible,
        ),
      ],
    );
  }

  Widget get _webViewWidgets {
    /*
    return IndexedStack(
      children: [
        _webViewWidget,
        InAppWebView(
          initialUrl: "https://www.baidu.com/",
        ),
        InAppWebView(
          initialUrl: "https://cn.bing.com/",
        ),
      ],
      index: _index,
    );
    */

    if (_webViewList == null) {
      _webViewList = WebViewManager.webViews;
    }

    return IndexedStack(
      children: _webViewList,
      index: _webViewIndex,
    );

    /*
    return IndexedStack(
      children: [
        InAppWebView(
          initialUrl: 'https://baidu.com',
        ),
        InAppWebView(
          initialUrl: 'https://baidu.com',
        ),
        InAppWebView(
          initialUrl: 'https://baidu.com',
        ),
        InAppWebView(
          initialUrl: 'https://baidu.com',
        ),
        InAppWebView(
          initialUrl: 'https://baidu.com',
        ),
      ],
      index: _webViewIndex,
    );
    */

    /*
    return IndexedStack(
      children: _webViewList,
      index: _webViewIndex,
    );
    */
  }

  /*
  Widget get _webViewWidget {
    return InAppWebView(
      // initialUrl: _url,

      onWebViewCreated: (InAppWebViewController inAppWebViewController) {
        _controller = inAppWebViewController;
        // _loadUrl(_url);
        _loadApprovalData();
      },
      onLoadStart: (InAppWebViewController controller, String url) {
        setState(() {
          this._showNavigator = false;
        });
      },
      onLoadStop: (InAppWebViewController controller, String url) async {
        // Android平台支持清除历史记录，iOS不支持
        /*
        实际应用中，部分Android手机不支持clearHistory()方法，所以暂不使用
        if ((_autoClearHistory) && (Platform.isAndroid)) {
          try {
            _controller.android.clearHistory();
            _autoClearHistory = false;
          } catch (e) {
            print(e);
          }
        }
        */
        setState(() {
          this._showNavigator = true;
        });
      },
      onLoadError: (InAppWebViewController controller, String url, int code,
          String message) {
        setState(() {
          this._showNavigator = true;
        });
      },

      // initialHeaders: getRequestHeader(),
      initialOptions: InAppWebViewGroupOptions(
        // crossPlatform: InAppWebViewOptions(
        //   preferredContentMode: UserPreferredContentMode.DESKTOP,
        //   // debuggingEnabled: true,
        // ),
        android: AndroidInAppWebViewOptions(
          // supportZoom: true,
          // displayZoomControls: true,
          builtInZoomControls: true,
        ),
      ),

      // onWebViewCreated:
      //     (WebViewController webViewController) async {
      //   _controller = webViewController;
      //   _controller.loadUrl(_url, headers: getRequestHeader());
      // },
    );
  }
  */

  Widget get _functionWidget {
    _approvalWidgetVisible = false;
    _accountingWidgetVisible = false;
    _signCancelWidgetVisible = false;
    _signUndoWidgetVisible = false;
    _denyAfterSignWidgetVisible = false;

    if (_approvalHead != null) {
      if (_isApprovaled) {
        //通过已审列表进入
        //申请单使用否决，非申请单（如请购单）使用反审
        //signUndoVisible = !mApprovalHead.isApprovalBill();
        _signUndoWidgetVisible =
            !_approvalHead.isApprovalBill && _approvalHead.canSignUndo;
        _denyAfterSignWidgetVisible = _approvalHead.isApprovalBill;
      } else {
        //通过待审列表进入
        _approvalWidgetVisible = _approvalHead.canApproval;
        _accountingWidgetVisible = _approvalHead.canAccounting;
        _signCancelWidgetVisible = _approvalHead.canSignCancel;
        _signUndoWidgetVisible = _approvalHead.canSignUndo;
      }
    }

    return Container(
      padding: EdgeInsets.all(4.0),
      child: Column(
        children: <Widget>[
          if (_approvalWidgetVisible) _approvalWidget,
          if (_accountingWidgetVisible) _accountingWidget,
          if (_signCancelWidgetVisible) _signCancelWidget,
          if (_signUndoWidgetVisible) _signUndoWidget,
          if (_denyAfterSignWidgetVisible) _denyAfterSignWidget,
        ],
      ),
    );
  }

  Widget get _denyAfterSignWidget {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.deepOrange,
                ),
                onPressed: () {
                  _showRemarksDialogWithType(_approvalMessageKindDeny);
                },
              ),
              Expanded(
                child: CustomButton(
                  title: '否决',
                  onPressed: () {
                    _handleRemarksApproval(ApprovalService.approvalHandleDeny,
                        '否决', _denyAfterSignController);
                  },
                ),
              ),
            ],
          ),
          TextField(
            controller: _denyAfterSignController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '请输入否决备注',
            ),
          ),
        ],
      ),
    );
  }

  Widget get _signUndoWidget {
    //请输入反审备注
    return Container(
      child: Column(
        children: <Widget>[
          LargeButton(
            title: '反审',
            height: 40.0,
            onPressed: () {
              _handleRemarksApproval(ApprovalService.approvalHandleSignUndo,
                  '反审', _signUndoRemarksController);
            },
          ),
          SizedBox(
            height: 5.0,
          ),
          TextField(
            controller: _signUndoRemarksController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '请输入反审备注',
            ),
          ),
        ],
      ),
    );
  }

  /// 否决确认组件
  Widget get _signCancelWidget {
    return Container(
      child: LargeButton(
        title: '否决确认',
        height: 40.0,
        onPressed: () {
          handleApproval(ApprovalService.approvalHandleSignCancel, '否决确认', '');
        },
      ),
    );
  }

  /// 直属上司审批组件
  Widget get _accountingWidget {
    return Container(
      child: LargeButton(
        title: '直属上司审批',
        height: 40.0,
        onPressed: () {
          handleApproval(ApprovalService.approvalHandleAccounting, '审核', '');
        },
      ),
    );
  }

  void _handleRemarksApproval(
      int handleId, String title, TextEditingController remarksController) {
    String remarks = remarksController.text.trim();

    if (Utils.textIsEmpty(remarks)) {
      DialogUtils.showToast('请输入$title备注');
      return;
    }

    handleApproval(handleId, title, remarks);
  }

  void handleApproval(int handleId, String title, String remarks) async {
    bool value =
        await DialogUtils.showConfirmDialog(context, '确定要$title当前单据吗？');
    if (value) {
      // print('handleApproval');
      _approval(handleId, remarks);
    }
  }

  /// 审批(否决)组件
  Widget get _approvalWidget {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.deepOrange,
                ),
                onPressed: () {
                  _showRemarksDialog();
                },
              ),
              Expanded(
                child: CupertinoSegmentedControl(
                  children: {true: Text('审批'), false: Text('否决')},
                  groupValue: _selectedApprovalOK,
                  onValueChanged: (value) {
                    _selectedApprovalOK = value;
                    // print(_selectedApprovalOK);
                  },
                ),
              ),
              CustomButton(
                  title: '确定',
                  onPressed: () {
                    _approvalSigning();
                  }),
            ],
          ),
          TextField(
            controller: _denyRemarksController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '请输入审批/否决备注',
            ),
          ),
        ],
      ),
    );
  }

  /// 审批确定的处理
  void _approvalSigning() {
    if (_selectedApprovalOK == null) {
      DialogUtils.showToast('请先审批或否决');
      return;
    }

    String remarks = _denyRemarksController.text.trim();
    // print('Remarks: $remarks');

    if (_selectedApprovalOK) {
      _approval(ApprovalService.approvalHandleSign, remarks);
    } else {
      if (Utils.textIsEmpty(remarks)) {
        DialogUtils.showToast('请输入否决原因');
        return;
      }
      _approval(ApprovalService.approvalHandleDeny, remarks);
    }
  }

  void _approval(int approvalHandle, String remarks) async {
    Utils.closeInput(context);

    ApprovalModel nextItem = DataCache.getNextApprovalItem(_docType, _docId);

    String nextDocType = nextItem?.docType;
    String nextDocId = nextItem?.docId;

    ApprovalResultModel result;
    // _progressDialog?.style(message: updatingMessage);
    // await _progressDialog?.show();
    _showLoading(message: updatingMessage);
    try {
      result = await ApprovalService.approval(
        approvalHandle,
        _docType,
        _docId,
        remarks,
        nextDocType: nextDocType,
        nextDocId: nextDocId,
      );
    } finally {
      // await _progressDialog?.hide();
      _hideLoading();
    }

    if (result == null) {
      return;
    }

    if (result.success) {
      // 审批操作后，数据已变更，所以，移除ApprovalHead的缓存
      DataCache.removeApprovalHeadCache(_docType, _docId);
      WebViewManager.disposeUrl(_homeUrl);

      if (_isApprovaled) {
        await DialogUtils.showAlertDialog(context, '单据处理完成');
        Navigator.of(context).pop();
        return;
      }

      if (result.hasMoreData &&
          (!Utils.textIsEmpty(result.nextDocType)) &&
          (!Utils.textIsEmpty(result.nextDocId))) {
        _docType = result.nextDocType;
        _docId = result.nextDocId;

        _loadApprovalData();
        DialogUtils.showToast("操作完成，将进行一张单据操作");
      } else {
        _loadApprovalData();
        DialogUtils.showToast("已无可审单据");
      }
    } else {
      DialogUtils.showToast('操作失败：${result.msg}');
    }
  }

  void _loadApprovalMessage() async {
    List<ApprovalMessageModel> list = await ApprovalService.getMessageList();

    _allMessageList.clear();
    _currentMessageList.clear();

    list.forEach((ApprovalMessageModel item) {
      _allMessageList.add(item);
      if (item.messageType == _currentApprovalMessageType) {
        _currentMessageList.add(item);
      }
    });
  }

  void _showRemarksDialog() {
    if (_selectedApprovalOK == null) {
      return;
    }

    if (_selectedApprovalOK) {
      _showRemarksDialogWithType(_approvalMessageKindApproval);
    } else {
      _showRemarksDialogWithType(_approvalMessageKindDeny);
    }
  }

  void _showRemarksDialogWithType(int messageType) {
    _currentApprovalMessageType = messageType;
    _refreshMessageList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: _remarksDialogMainWidget(context)),
                SizedBox(
                  height: 25.0,
                ),
                LargeButton(
                    title: '关闭',
                    height: 40,
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _remarksDialogMainWidget(BuildContext dialogContext) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '请输入备注',
                ),
              ),
            ),
            RaisedButton(
              padding: EdgeInsets.all(0),
              child: Icon(
                Icons.add,
                color: Theme.of(context).primaryColor,
              ),
              shape: CircleBorder(),
              onPressed: () {
                String msg = _messageController.text;
                _addMessage(dialogContext, msg);
              },
            ),
          ],
        ),
        _messageWidgetList(dialogContext)
      ],
    );
  }

  void _addMessage(BuildContext dialogContext, String msg) async {
    if (Utils.textIsEmptyOrWhiteSpace(msg)) return;

    ApprovalMessageResultModel result =
        await ApprovalService.addMessage(_currentApprovalMessageType, msg);
    if (result.errCode != 0) {
      DialogUtils.showToast(result.errMsg);
      return;
    }
    if (result.data.length > 0) {
      List<ApprovalMessageModel> list = _currentMessageList;
      ApprovalMessageModel item = result.data[0];
      list.add(item);
      _allMessageList.add(item);

      // setState(() {
      //   _currentMessageList = list;
      //   _messageController.text = '';
      // });
      (dialogContext as Element).markNeedsBuild();

      _currentMessageList = list;
      _messageController.text = '';
    }
  }

  Widget _messageWidgetList(BuildContext dialogContext) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        ApprovalMessageModel item = _currentMessageList[index];

        return InkWell(
          onTap: () {
            if (!Utils.textIsEmptyOrWhiteSpace(item.messageContent)) {
              // print('use message: ${item.messageContent}');
              _useMessage(item);

              Navigator.pop(context);
            }
          },
          child: Slidable(
            actionPane: SlidableDrawerActionPane(),
            child: ListTile(
              title: Text(item.messageContent),
            ),
            actions: <Widget>[
              // IconButton(
              //   icon: Icon(Icons.delete),
              //   color: Colors.red,
              //   onPressed: () {
              //     print('deleted.');
              //   },
              // ),
              // IconButton(
              //   icon: Icon(Icons.edit),
              //   color: Theme.of(context).primaryColor,
              //   onPressed: () {
              //     print('edit');
              //   },
              // ),
              IconSlideAction(
                // caption: '修改',
                color: Colors.blue,
                icon: Icons.edit,
                onTap: () {
                  // print('edit');
                  _changeMessage(dialogContext, item);
                },
              ),
              IconSlideAction(
                // caption: '删除',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {
                  // print('delete');
                  _removeMessage(dialogContext, item.messageId);
                },
              ),
            ],
          ),
        );
      },
      itemCount: _currentMessageList.length,
    );
  }

  void _useMessage(ApprovalMessageModel item) async {
    TextEditingController controller = _denyAfterSignWidgetVisible
        ? _denyAfterSignController
        : _denyRemarksController;
    controller.text = controller.text + item.messageContent;

    _updateUsedMessageList(item);
    Map<String, dynamic> result =
        await ApprovalService.useMessages(_usedMessageList);
    if (result == null) return;

    if (result['ErrCode'] != 0) {
      DialogUtils.showToast(result['ErrMsg']);
      return;
    }

    _usedMessageList.clear();
  }

  void _updateUsedMessageList(ApprovalMessageModel item) {
    bool existed = false;
    for (int usedItem in _usedMessageList) {
      if (usedItem == item.messageId) {
        existed = true;
        break;
      }
    }

    if (!existed) {
      _usedMessageList.add(item.messageId);
    }
  }

  void _removeMessage(BuildContext dialogContext, int messageId) async {
    Map<String, dynamic> result =
        await ApprovalService.removeMessage(messageId);

    if (result == null) return;

    if (result['ErrCode'] != 0) {
      DialogUtils.showToast(result['ErrMsg']);
      return;
    }

    int dataMessageId = result['Data'];
    if (_removeFromList(dataMessageId)) {
      (dialogContext as Element).markNeedsBuild();
    }
  }

  bool _removeFromList(int messageId) {
    bool found = false;
    for (int i = 0; i < _currentMessageList.length; i++) {
      if (_currentMessageList[i].messageId == messageId) {
        _currentMessageList.removeAt(i);
        found = true;
        break;
      }
    }

    for (int i = 0; i < _allMessageList.length; i++) {
      if (_allMessageList[i].messageId == messageId) {
        _allMessageList.removeAt(i);
        found = true;
        break;
      }
    }

    return found;
  }

  void _changeMessage(
      BuildContext dialogContext, ApprovalMessageModel item) async {
    String msg =
        await DialogUtils.showTextFieldDialog(context, item.messageContent);

    if (msg == item.messageContent) return;

    ApprovalMessageResultModel result =
        await ApprovalService.updateMessage(item, msg);
    if (result.errCode != 0) {
      DialogUtils.showToast(result.errMsg);

      return;
    }

    if (result.data.length > 0) {
      if (_updateToList(result.data[0])) {
        (dialogContext as Element).markNeedsBuild();
      }
    }
  }

  bool _updateToList(ApprovalMessageModel newItem) {
    bool updated = false;

    ApprovalMessageModel item = _findAllMessage(newItem.messageId);
    if (item != null) {
      item.messageContent = newItem.messageContent;
    }

    item = _findMessage(newItem.messageId);
    if (item != null) {
      item.messageContent = newItem.messageContent;
      updated = true;
    }

    return updated;
  }

  ApprovalMessageModel _findAllMessage(int messageId) {
    return _allMessageList
        .where((item) => item.messageId == messageId)
        .toList()[0];
  }

  ApprovalMessageModel _findMessage(int messageId) {
    return _currentMessageList
        .where((item) => item.messageId == messageId)
        .toList()[0];
  }

  void _refreshMessageList() {
    _currentMessageList.clear();

    _allMessageList.forEach((item) {
      if (item.messageType == _currentApprovalMessageType) {
        _currentMessageList.add(item);
      }
    });
  }
}
