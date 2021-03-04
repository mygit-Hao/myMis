import 'package:flutter/material.dart';
import 'package:mis_app/common/widget_style.dart';
import 'package:mis_app/model/week_plan_detail.dart';
import 'package:mis_app/pages/office/week_Plan/provide/project_provide.dart';
import 'package:mis_app/pages/office/week_Plan/week_plan_file.dart';
import 'package:mis_app/service/week_plan_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:provide/provide.dart';

class WeekPlanProgressDtlPage extends StatefulWidget {
  final Week item;

  const WeekPlanProgressDtlPage({Key key, this.item}) : super(key: key);
  @override
  _WeekPlanProgressDtlPageState createState() =>
      _WeekPlanProgressDtlPageState();
}

class _WeekPlanProgressDtlPageState extends State<WeekPlanProgressDtlPage> {
  final _fontsize = 14.5;
  TextEditingController _targetControl = TextEditingController();
  TextEditingController _resultControl = TextEditingController();
  TextEditingController _historyCommentkControl = TextEditingController();
  TextEditingController _commentControl = TextEditingController();
  int _weekId = 0;
  bool _canFollow = true;
  bool _isnNextWeek = false;
  Week _weekDtl = new Week();

  @override
  void initState() {
    super.initState();
    _weekId = this.widget.item.weekId;
    // _isnNextWeek = _weekId == 0 ? true : false;
  }

  ///用于保存后更新数据,当修改时通过id找到状态管理中对应数据
  Week getWeekDtl(detail) {
    for (var element in detail.detailModel.weeks) {
      if (element.weekId == _weekId) {
        // _weekDtl = element;
        return element;
      }
    }
    return this.widget.item;
  }

  Future<bool> _isPop() async {
    bool result = true;
    if (_weekId == 0)
      result = await DialogUtils.showConfirmDialog(context, '进展尚未保存,是否退出?',
          confirmTextColor: Colors.red);
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Utils.closeInput(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('进展'),
        ),
        body: Provide<WeekPlanProvide>(
          builder: (context, child, detail) {
            _canFollow = detail.detailModel.projData.canFollow;
            _weekDtl = getWeekDtl(detail);
            _targetControl.text = _weekDtl.weekObj;
            _resultControl.text = _weekDtl.weekResult;
            _historyCommentkControl.text = _weekDtl.comment;
            return GestureDetector(
              onTap: () {
                Utils.closeInput(context);
              },
              child: Form(
                onWillPop: _isPop,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _week(),
                              _mainMember(),
                              _customTextField(
                                  _targetControl,
                                  _weekDtl.weekObjReadOnly || _weekDtl.readOnly,
                                  '周目标'),
                              if (!_isnNextWeek)
                                _customTextField(
                                    _resultControl,
                                    _weekDtl.weekResultReadOnly ||
                                        _weekDtl.readOnly,
                                    '周结果'),
                              if (!_weekDtl.commentReadOnly)
                                _customTextField(_commentControl,
                                    _weekDtl.commentReadOnly, '添加批注(选填)'),
                              if (_weekDtl.comment != '')
                                _customTextField(
                                    _historyCommentkControl, true, '历史批注'),
                              if (_weekDtl.weekId != 0)
                                customText(value: '附件:', fontSize: _fontsize),
                              if (_weekDtl.weekId != 0)
                                // _filesWidget(_filesList),
                                WeekPlanFilePage(arguments: {
                                  'weekId': _weekDtl.weekId,
                                  'readOnly': _weekDtl.readOnly
                                })
                            ],
                          ),
                        ),
                      ),
                      if (_canFollow)
                        Row(
                          children: [
                            if (_weekDtl.weekId != 0 && !_weekDtl.readOnly)
                              customButtom(Colors.red, '删除', _delete),
                            customButtom(Colors.blue, '保存', _save)
                          ],
                        )
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Widget _week() {
    String begin = getDateTimeStr(_weekDtl.weekFrom);
    String end = getDateTimeStr(_weekDtl.weekTo);
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          customText(value: "周：${_weekDtl.week}   ", fontSize: _fontsize),
          customText(
              value: "$begin", color: Colors.orange, fontSize: _fontsize),
          customText(value: " - ", fontSize: _fontsize),
          customText(value: "$end", color: Colors.orange, fontSize: _fontsize),
        ],
      ),
    );
  }

  String getDateTimeStr(String dataStr) {
    if (dataStr != null) {
      DateTime data = DateTime.parse(dataStr);
      String str = Utils.dateTimeToStr(data, pattern: 'yyyy/MM/dd');
      return str;
    } else {
      return '';
    }
  }

  Widget _mainMember() {
    return Container(
      height: 45,
      child: Row(
        children: [
          customText(value: '主参与人：', fontSize: _fontsize),
          customText(
              value: _weekDtl.staffName,
              fontSize: _fontsize,
              color: Colors.blue),
          if (_weekDtl.weekId == 0)
            Checkbox(
                value: _isnNextWeek,
                onChanged: (v) {
                  _isnNextWeek = v;
                  _isnNextWeek ? _weekDtl.week++ : _weekDtl.week--;
                  _weekChange(v);
                  setState(() {});
                }),
          if (_weekDtl.weekId == 0) customText(value: '当前周的下一周'),
        ],
      ),
    );
  }

  void _weekChange(bool isNext) {
    // DateTime startOfYear = DateTime(_weekDtl.year, 1, 1, 0, 0);
    // int firstMonday = startOfYear.weekday;
    // //第一周的天数
    // int daysInFirstWeek = 8 - firstMonday;
    // // 通过周数和年份得出将开始、结束时间
    // DateTime begin = startOfYear.add(Duration(days: 7 * (_weekDtl.week - 1)));
    // DateTime end = startOfYear
    //     .add(Duration(days: 7 * (_weekDtl.week - 1) + daysInFirstWeek - 1));
    DateTime begin = DateTime.parse(_weekDtl.weekFrom);
    DateTime end = DateTime.parse(_weekDtl.weekTo);
    if (isNext) {
      begin = begin.add(Duration(days: 7));
      end = end.add(Duration(days: 7));
    } else {
      begin = begin.add(Duration(days: -7));
      end = end.add(Duration(days: -7));
    }
    _weekDtl.weekFrom = Utils.dateTimeToStr(begin, pattern: 'yyyy-MM-dd');
    _weekDtl.weekTo = Utils.dateTimeToStr(end, pattern: 'yyyy-MM-dd');
//设置修改权限
    _isnNextWeek
        ? _weekDtl.weekResultReadOnly = true
        : _weekDtl.weekResultReadOnly = false;
    _isnNextWeek
        ? _weekDtl.commentReadOnly = true
        : _weekDtl.commentReadOnly = false;
  }

  Widget _customTextField(
      TextEditingController controller, bool readOnly, String label) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        children: <Widget>[
          // Text('原因：'),
          Expanded(
            child: Container(
              // height: 30,
              child: TextFormField(
                // autovalidate: true,
                maxLines: 5,
                minLines: 1,
                // maxLength: 200,
                // maxLengthEnforced: false,
                readOnly: readOnly,
                style: TextStyle(color: _getColor(controller), fontSize: 14.5),
                controller: controller,
                decoration: textFieldDecorationNoBorder(
                    label: label,
                    color: readOnly ? Colors.white : Colors.grey[100]),
                validator: (v) {
                  return v.length > 0
                      ? null
                      : (controller == _historyCommentkControl ||
                              controller == _commentControl)
                          ? null
                          : '请输入$label';
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(TextEditingController ctrl) {
    Color color = Colors.black;
    if (ctrl == _targetControl) {
      color = Colors.purple;
    } else if (ctrl == _resultControl) {
      color = Colors.blue;
    } else {
      color = Colors.black54;
    }
    return color;
  }

  void _save() async {
    String now =
        Utils.dateTimeToStr(DateTime.now(), pattern: 'yyyy-MM-dd HH:mm');
    _weekDtl.weekObj = _targetControl.text;
    _weekDtl.weekResult = _resultControl.text;
    if (_commentControl.text != '')
      _weekDtl.comment = _weekDtl.comment == ''
          ? (now + _commentControl.text)
          : (_weekDtl.comment + "\n" + now + " " + _commentControl.text);
    if (_targetControl.text == '') {
      DialogUtils.showToast('目标不能为空');
    } else {
      await WeekPlanService.updateProgress(_weekDtl).then((value) {
        if (value.errCode == 0) {
          Provide.value<WeekPlanProvide>(context).setDetailData(value);
          _commentControl.clear();

          DialogUtils.showToast('保存成功');
          if (_weekId == 0) {
            _weekId = value.weekId;
          }
          // setState(() {});
        } else {
          DialogUtils.showToast(value.errMsg);
        }
      });
    }
  }

  void _delete() async {
    var result = await DialogUtils.showConfirmDialog(context, '是否删除该条进展？',
        iconData: Icons.info_outline,
        color: Colors.red,
        confirmTextColor: Colors.red);
    if (result == true)
      await WeekPlanService.deleteProgress(_weekDtl.weekId).then((value) {
        if (value.errCode == 0) {
          DialogUtils.showToast('删除成功');
          Provide.value<WeekPlanProvide>(context).setDetailData(value);
          Navigator.pop(context);
        } else {
          DialogUtils.showToast(value.errMsg);
        }
      });
  }
}
