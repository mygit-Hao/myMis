import 'package:flui/flui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/sevens_dept_deduct_list.dart';
import 'package:mis_app/pages/office/sevens_check/sevens_group_page.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/sevens_check_service.dart';
import 'package:mis_app/utils/utils.dart';

class SevenSDtlListPage extends StatefulWidget {
  final Map arguments;
  const SevenSDtlListPage({Key key, this.arguments}) : super(key: key);

  @override
  _SevenSDtlListPageState createState() => _SevenSDtlListPageState();
}

class _SevenSDtlListPageState extends State<SevenSDtlListPage> {
  final _textStyle = TextStyle(color: Colors.black54);

  String _imageUrl;
  List<DetailSpot> _detailSpotList = [];

  // ProgressDialog _progressDialog;
  FLToastDefaults _flToastDefaults = new FLToastDefaults();
  @override
  void initState() {
    super.initState();

    // Future.delayed(Duration.zero, () {
    //   _progressDialog = getProgressDialog(context);
    //   _getDetaiList(true);
    // });
    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      _getDetaiList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // _progressDialog = new ProgressDialog(context);
    // _progressDialog = customProgressDialog(context, '加载中...');

    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('部门扣分详细'),
        ),
        body: SafeArea(
            child: FLToastProvider(
          defaults: _flToastDefaults,
          child: Container(
            // padding: EdgeInsets.all(15),
            child: ListView.builder(
                itemCount: _detailSpotList.length,
                itemBuilder: (contex, index) {
                  return _listItem(_detailSpotList[index]);
                }),
          ),
        )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            StaticData.status == 5
                ? Navigator.pushNamed(context, sevensDetailPath).then(
                    (value) {
                      _getDetaiList();
                    },
                  )
                : toastBlackStyle("评分状态才能添加检查记录！");
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _listItem(DetailSpot item) {
    _imageUrl = Utils.getImageUrl(item.photoFileId);
    return InkWell(
      onTap: () async {
        Map<String, dynamic> arguments = item.toJson();

        bool dataChanged =
            await navigatePage(context, sevensDetailPath, arguments: arguments);
        if (dataChanged) _getDetaiList();
      },
      child: Container(
        // width: ScreenUtil().setWidth(700),
        // height: ScreenUtil().setHeight(300),
        padding: EdgeInsets.all(ScreenUtil().setWidth(15)),
        decoration: bottomLineDecotation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              // flex: 1,
              // width: ScreenUtil().setWidth(100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                    // height: ScreenUtil().setSp(300),
                    child: Image.network(_imageUrl)),
              ),
            ),
            Expanded(
                flex: 3,
                child: Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            child: Text(
                          "部门：${item.deptName}",
                          style: _textStyle,
                        )),
                        Container(
                            margin: EdgeInsets.only(top: ScreenUtil().setSp(6)),
                            child: Text(
                              "区域：${item.spotName}",
                              overflow: TextOverflow.ellipsis,
                              style: _textStyle,
                            )),
                        Container(
                          margin: EdgeInsets.only(top: ScreenUtil().setSp(6)),
                          child: Text(
                            "详细地点：${item.spotRemarks}",
                            style: _textStyle,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(top: ScreenUtil().setSp(6)),
                            child: Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                  text: '扣分：',
                                  style: _textStyle,
                                ),
                                TextSpan(
                                  text: '${item.deduct}',
                                  style: _textStyle,
                                ),
                              ]),
                            )),
                        Container(
                            margin: EdgeInsets.only(top: ScreenUtil().setSp(6)),
                            child: Text(
                              "描述：${item.remarks}",
                              overflow: TextOverflow.ellipsis,
                              style: _textStyle,
                            )),
                      ],
                    ))),
            // padding: EdgeInsets.all(10),
          ],
        ),
      ),
    );
  }

  void _getDetaiList() async {
    Function dismss = FLToast.showLoading(text: '加载中...');
    try {
      // await _progressDialog?.show();
      int deptId = this.widget.arguments['deptId'];
      int checkId = StaticData.checkId;
      var result = await SevensCheckService.getRequstResult3(
          deptId, checkId, 'get_detail');
      // print(result.toString());
      SevensDeptDeductModel sevensDeptDeductModel =
          SevensDeptDeductModel.fromJson(result);
      if (mounted) {
        setState(() {
          _detailSpotList = sevensDeptDeductModel.detailSpot;
        });
      }
    } finally {
      // await _progressDialog?.hide();
      await dismss();
    }
  }
}
