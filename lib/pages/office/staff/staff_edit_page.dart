import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/device_info.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/config/service_url.dart';
import 'package:mis_app/model/staffQuery.dart';
import 'package:mis_app/pages/common/view_photo.dart';
import 'package:mis_app/provide/user_provide.dart';
import 'package:mis_app/service/staffQuery_service.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class StaffEditPage extends StatefulWidget {
  final Map arguments;

  StaffEditPage({this.arguments});
  @override
  _StaffEditPageState createState() => _StaffEditPageState();
}

class _StaffEditPageState extends State<StaffEditPage>
    with SingleTickerProviderStateMixin {
  List<Tab> _tabs = [];
  // List<EmploymentRecord> _employmentRecord = [];
  String user = UserProvide.currentUser.userName;
  String devid = DeviceInfo.devId;
  String passWordKey = UserProvide.currentUserMd5Password;
  String date = Utils.dateTimeToStrWithPattern(DateTime.now(), 'yyyyMMdd');
  String key;
  int _staffId;
  StaffQueryModel _dataStaff = new StaffQueryModel();
  StaffDetailModel _detailModel = new StaffDetailModel();
  List<Files> _files = [];
  List<Performance> _performance = [];
  final TextEditingController _address = TextEditingController();
// final TextEditingController _nowAddress = TextEditingController();
  final TextEditingController _tel = TextEditingController();
  final TextEditingController _ecTel = TextEditingController();
// TextStyle _textStyle = TextStyle(fontSize: 15.5);

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('人事资料明细'),
        bottom: TabBar(
          controller: this._tabController,
          isScrollable: true,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: this._tabController,
        children: <Widget>[
          _staffBase(context),
          _staffFile(context),
          _staffPerformance(),
          _staffDuty(),
          Center(child: Text("薪金考勤")),
        ],
      ),
    );
  }

  void _init() {
    key = Utils.getMd5_16(user.trim() + passWordKey + devid + date);
    _tabs
      ..add(Tab(text: "基本资料"))
      ..add(Tab(text: "档案文件"))
      ..add(Tab(text: "绩效考核"))
      ..add(Tab(text: "岗位职责"))
      ..add(Tab(text: "薪金考勤"));
    _tabController = new TabController(length: _tabs.length, vsync: this);

    // _getDefaltData();
    if (this.widget.arguments != null) {
      // _dataStaff.data[0].staffId = int.parse(this.widget.arguments['staffId']);
      _staffId = this.widget.arguments['staffId'];
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _getDetail();
      });
    }
  }

  _getDetail() async {
    _dataStaff = await StaffService.requestStaffData(_staffId);
    setState(() {
      _showDetail(_dataStaff);
    });
  }

  void _showDetail(StaffQueryModel staffQueryModel) {
    _detailModel = staffQueryModel.staffDetail;
    // _employmentRecord = staffQueryModel.employmentRecord;
    _files = staffQueryModel.files;
    _performance = staffQueryModel.performance;
    _address.text = _detailModel.address;
    // _nowAddress.text = _detailModel.nowAddress;
    _tel.text = _detailModel.tel;
    _ecTel.text = _detailModel.ecTel;
  }

  Widget _staffBase(BuildContext context) {
    if (_dataStaff.staffDetail == null)
      return Text('');
    else
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              _headerWidget(context),
              SizedBox(height: ScreenUtil().setHeight(18)),
              _primaryWidget(context),
            ],
          ),
        ),
      );
  }

  Widget _staffFile(BuildContext context) {
    return Container(
      child: _filesWidget(_files, context),
    );
  }

  Widget _staffDuty() {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Text(_detailModel.duty ?? ''),
    );
  }

  Widget _staffPerformance() {
    return _staffListview();
  }

  Widget _headerWidget(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      Row(
                        children: [
                          Text('工号：'),
                          customText(
                              value: _detailModel.code,
                              color: Colors.lightBlue),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15)),
                      Row(
                        children: [
                          Text('籍贯：'),
                          customText(
                              value: _detailModel.province,
                              color: Colors.lightBlue),
                        ],
                      ),
                    ],
                  )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('姓名：'),
                          customText(
                              value: _detailModel.name,
                              color: Colors.lightBlue),
                          SizedBox(width: ScreenUtil().setWidth(8)),
                          Text(
                            '(' + _detailModel.genderName + ')',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 13),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(3)),
                        ],
                      ),
                      SizedBox(height: ScreenUtil().setHeight(15)),
                      Row(
                        children: [
                          Text('婚姻：'),
                          customText(
                              value: _detailModel.marry,
                              color: Colors.lightBlue),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Row(
                children: [
                  Text('部门：'),
                  customText(
                      value: _detailModel.deptName, color: Colors.lightBlue),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Row(
                children: [
                  Expanded(
                      child: Row(
                    children: [
                      Text('职位：'),
                      customText(
                          value: _detailModel.posi, color: Colors.lightBlue),
                    ],
                  )),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Row(
                children: [
                  Text('入职日期：'),
                  customText(
                      value: Utils.dateTimeToStr(_detailModel.inDate),
                      color: Colors.orange),
                ],
              ),
            ],
          ),
        ),
        // Expanded(child: Text('')),
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ViewPhoto(
                  serviceUrl[hrmsUrl] +
                      "?user=$user&devid=$devid&action=staff-photo&key=$key&staff-id=" +
                      _staffId.toString(),
                  null);
            }));
          },
          child: Image.network(
            serviceUrl[hrmsUrl] +
                "?user=$user&devid=$devid&action=staff-photo&key=$key&staff-id=" +
                _staffId.toString(),
            width: ScreenUtil().setWidth(250),
            height: ScreenUtil().setHeight(250),
          ),
        ),
      ],
    );
  }

  Widget _primaryWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('试用日期：'),
            customText(
                value: Utils.dateTimeToStr(_detailModel.tryDate) ?? '',
                color: Colors.orange),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: [
            Text('合同日期：'),
            customText(
                value: Utils.dateTimeToStr(_detailModel.contractFrom),
                color: Colors.green),
            customText(value: ' — ', color: Colors.green),
            customText(
                value: Utils.dateTimeToStr(_detailModel.contractTo),
                color: Colors.green),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('常用住址：'),
            Expanded(
              child: Text(
                _detailModel.address,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(color: Colors.lightBlue),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('现住址：'),
            Expanded(
              child: Text(
                _detailModel.nowAddress ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: TextStyle(color: Colors.lightBlue),
              ),
            ),
          ],
        ),
        // _customAddress(_nowAddress),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: <Widget>[
            Text('联系电话：'),
            if (_detailModel.tel != '')
              InkWell(
                onTap: () {
                  _launchURL(_tel);
                },
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Colors.green),
                    customText(color: Colors.purple, value: _detailModel.tel),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: <Widget>[
            Text('紧急联系电话：'),
            if (_detailModel.ecTel != '')
              InkWell(
                onTap: () {
                  _launchURL(_ecTel);
                },
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Colors.green),
                    customText(color: Colors.purple, value: _detailModel.ecTel),
                  ],
                ),
              ),
            // _customPhone(_ecTel),
            // SizedBox(width: ScreenUtil().setWidth(50)),
            // InkWell(
            //     onTap: () {
            //       if (_ecTel.text != '') _launchURL(_ecTel);
            //     },
            //     child: Icon(Icons.phone, color: Colors.green)),
            // Expanded(child: Text('')),
            // FlatButton(
            //   shape:
            //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            //   color: Colors.yellow,
            //   onPressed: () async {
            //     Utils.closeInput(context);
            //     _updateDetail(context);
            //   },
            //   child: Text(
            //     "确认修改",
            //   ),
            // ),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: [
            Text('身份证号：'),
            customText(value: _detailModel.idNum ?? '', color: Colors.orange),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: [
            Text('工作日期：'),
            customText(
                value: Utils.dateTimeToStr(_detailModel.workDate),
                color: Colors.orange),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: [
            Text('毕业学校：'),
            customText(
                value: _detailModel.lastSchool ?? '', color: Colors.lightBlue),
          ],
        ),
        SizedBox(height: ScreenUtil().setHeight(15)),
        Row(
          children: [
            Expanded(
                child: Row(
              children: [
                Text('专业：'),
                customText(
                    value: _detailModel.major ?? '', color: Colors.lightBlue),
              ],
            )),
            Expanded(
                child: Row(
              children: [
                Text('学历：'),
                customText(
                    value: _detailModel.educationName, color: Colors.lightBlue),
              ],
            )),
          ],
        ),
      ],
    );
  }

// void _updateDetail(BuildContext context) async {
//   var result = await DialogUtils.showConfirmDialog(context, '是否对修改内容进行保存?',
//       iconData: Icons.info, color: Colors.red);
//   if (result) {
//     _updateData();
//   }
// }

// _updateData() async {
//   _detailModel.nowAddress = _nowAddress.text;
//   _detailModel.tel = _tel.text;
//   _detailModel.ecTel = _ecTel.text;
//   _dataStaff = await StaffService.requestUpdateData(_detailModel);
// }

  Widget _staffListview() {
    return ListView.separated(
      itemCount: _performance.length,
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
      itemBuilder: (BuildContext context, int index) {
        final item = _performance[index];
        return Container(
          padding: EdgeInsets.all(3.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: customText(
                    color: Colors.blue,
                    value: item.dimension,
                  )),
                  Expanded(
                    child: Text(item.norm),
                    flex: 2,
                  ),
                  SizedBox(width: ScreenUtil().setWidth(12)),
                  Expanded(
                    child: customText(
                      color: Colors.green,
                      value: '编号：' + item.performanceId.toString(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Text('指标说明及计算公式：' + item.illustrate),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Text('评分标准：' + item.standard),
              SizedBox(height: ScreenUtil().setHeight(15)),
              Text('目标值：' + item.goal),
              SizedBox(height: ScreenUtil().setHeight(15)),
              customText(
                  color: Colors.orange, value: '数据填写人：' + item.userFullName),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchURL(TextEditingController _phone) async {
    String url = 'tel:' + _phone.text;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url!';
    }
  }

// Widget _customAddress(TextEditingController _controller) {
//   return Container(
//     height: ScreenUtil().setHeight(80),
//     child: TextField(
//       enabled: false,
//       maxLines: 2,
//       style: _textStyle,
//       controller: _controller,
//       decoration: InputDecoration(
//         filled: true,
//         contentPadding: EdgeInsets.all(1),
//         fillColor: Colors.blue[200],
//         border: OutlineInputBorder(
//           borderSide: BorderSide.none,
//           borderRadius: BorderRadius.circular(5),
//         ),
//       ),
//     ),
//   );
// }

// Widget _customPhone(TextEditingController _controller) {
//   return Container(
//     height: ScreenUtil().setHeight(40),
//     width: ScreenUtil().setWidth(280),
//     child: TextField(
//       maxLines: 1,
//       enabled: false,
//       style: _textStyle,
//       controller: _controller,
//       decoration: InputDecoration(
//         filled: true,
//         contentPadding: EdgeInsets.all(1),
//         fillColor: Colors.orange[200],
//         border: OutlineInputBorder(
//           borderSide: BorderSide.none,
//           borderRadius: BorderRadius.circular(5),
//         ),
//       ),
//     ),
//   );
// }

  Widget _filesWidget(List<Files> files, BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.grey[100],
      margin: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(5),
        child: GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
            itemCount: files.length + 1,
            itemBuilder: (context, index) {
              return _itemPhote(files, index, context);
            }),
      ),
    );
  }

  Widget _itemPhote(List<Files> _filesList, int index, BuildContext context) {
    return (index < _filesList.length)
        ? Stack(fit: StackFit.expand, children: [
            InkWell(
                onTap: () {
                  Utils.viewAttachment(context, _filesList[index]);
                },
                child: _filesList[index].fileExt == 'jpg'
                    ? Image.network(
                        Utils.getImageUrl(_filesList[index].fileId),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            getFileIcon(_filesList[index].fileExt),
                            // Container(
                            //   color: Colors.lightBlue,
                            // child:
                            Text(
                              _filesList[index].shortName,
                              maxLines: 3,
                            ),
                            // ),
                          ],
                        ),
                      )),
          ])
        : Container();
  }
}
