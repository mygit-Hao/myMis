import 'package:flutter/material.dart';
import 'package:mis_app/common/common.dart';
import 'package:mis_app/common/const_values.dart';
import 'package:mis_app/model/meal_booking.dart';
import 'package:mis_app/routers/routes.dart';
import 'package:mis_app/service/life_service.dart';
import 'package:mis_app/utils/dialog_utils.dart';
import 'package:mis_app/utils/utils.dart';
import 'package:mis_app/widget/custom_flat_button.dart';
import 'package:progress_dialog/progress_dialog.dart';

class MealBookingPage extends StatefulWidget {
  MealBookingPage({Key key}) : super(key: key);

  @override
  _MealBookingPageState createState() => _MealBookingPageState();
}

class _MealBookingPageState extends State<MealBookingPage> {
  static const int _calendarFlex = 3;
  static const int _mealFlex = 2;
  static const int _itemCount = 7;
  static const double _dividerHeight = 1.0;
  static final Color _mealBackground = Colors.grey[400];
  ProgressDialog _progressDialog;

  GlobalKey _containerKey = GlobalKey();
  double _itemHeight = 50;
  int _weekIndex = 0;
  List<MealBookingModel> _list = [];

  @override
  void initState() {
    super.initState();

    _init();
  }

  void _init() {
    WidgetsBinding.instance.addPostFrameCallback((Duration d) {
      double containerHeight = _containerKey.currentContext.size.height -
          _dividerHeight * (_itemCount - 1);
      _itemHeight = containerHeight / _itemCount;

      setState(() {});
      _loadData();
    });
  }

  void _loadData() async {
    _progressDialog?.style(message: loadingMessage);

    await _progressDialog?.show();
    try {
      MealBookingWrapper result =
          await LifeService.getMealBookingByWeek(_weekIndex);
      _updateToList(result);
    } finally {
      await _progressDialog?.hide();
    }
  }

  bool _updateToList(MealBookingWrapper data, {String successMsg}) {
    bool result = false;
    if (data != null) {
      if (data.errCode == 0) {
        if (!Utils.textIsEmptyOrWhiteSpace(successMsg)) {
          DialogUtils.showToast(successMsg);
        }
        _list = data.list;
        result = true;
        setState(() {});
      } else {
        DialogUtils.showToast(data.errMsg);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    _progressDialog = getProgressDialog(context);

    return WillPopScope(
      onWillPop: () async {
        if (_dataChanged) {
          if (await DialogUtils.showConfirmDialog(
              context, '报餐资料已修改，返回前需要提交吗？')) {
            return await _submitMealBooking();
          }
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('报餐'),
        ),
        body: SafeArea(child: _mainWidget),
      ),
    );
  }

  Widget get _mainWidget {
    return Column(
      children: <Widget>[
        _headerWidget,
        Expanded(child: _listWidget),
        _navigatorWidget,
        _buttons,
      ],
    );
  }

  Widget get _listWidget {
    return Container(
      key: _containerKey,
      color: _mealBackground,
      // padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: _itemHeight,
            child: _listItemWidget(index),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: _dividerHeight,
            thickness: _dividerHeight,
          );
        },
        itemCount: _list.length,
      ),
    );
  }

  Widget _listItemWidget(int index) {
    MealBookingModel item = _list[index];
    String date = Utils.weekdayToStr(item.bookDate.weekday);
    date = date[date.length - 1];
    date = '${Utils.dateTimeToStrWithPattern(item.bookDate, "MM-dd")}($date)';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: _calendarFlex,
          child: InkWell(
            onTap: () {
              _changeBookStatusByDate(item);
            },
            child: Container(
              alignment: Alignment.center,
              color: Colors.grey[300],
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: item.isSunday ? TextStyle(color: Colors.red) : null,
              ),
            ),
          ),
        ),
        _mealButton(item, 0),
        _mealButton(item, 1),
        _mealButton(item, 2),
        _mealButton(item, 3),
      ],
    );
  }

  bool _changeBookStatusByColumn(int columnIndex) {
    DateTime today = Utils.today;
    bool allInTime = true;
    DateTime now = DateTime.now();
    for (MealBookingModel item in _list) {
      if (!now.isAfter(item.limitedTimeValues[columnIndex])) {
        if (!today.isSameDate((item.bookDate)))
          item.setBookStatusValue(
              columnIndex, !item.bookStatusValues[columnIndex]);
      } else {
        if (item.mealAvailableValues[columnIndex]) allInTime = false;
      }
    }

    setState(() {});

    return allInTime;
  }

  void _changeBookStatusByDate(MealBookingModel item) {
    bool allInTime = true;
    DateTime now = DateTime.now();
    for (int i = 0; i < 4; i++) {
      if (now.isAfter(item.limitedTimeValues[i])) {
        if (item.mealAvailableValues[i]) allInTime = false;
      } else {
        item.setBookStatusValue(i, !item.bookStatusValues[i]);
      }
    }
    setState(() {});
    if (!allInTime) {
      DialogUtils.showToast('部分超过限制时间，未能修改');
    }
  }

  Widget _mealButton(MealBookingModel item, int columnIndex) {
    Widget icon;
    Color color;

    if (item.bookStatusValues[columnIndex]) {
      icon = Icon(Icons.check_circle);
      color = Colors.lightGreenAccent;
    } else {
      if (item.bookStatusOldValues[columnIndex]) {
        icon = Icon(Icons.close);
        color = Colors.redAccent;
      } else {
        if (item.mealAvailableValues[columnIndex]) {
          icon = Icon(Icons.check_circle);
          color = _mealBackground;
        } else {
          icon = Icon(Icons.lock);
          color = Colors.grey;
        }
      }
    }

    return Expanded(
      flex: _mealFlex,
      child: Opacity(
        opacity: item.columnCanOperate(columnIndex) ? 1 : 0.5,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (item.columnDataChanged(columnIndex))
              Align(
                alignment: Alignment(-0.7, 0.0),
                child: Icon(
                  Icons.lens,
                  color: Colors.red,
                  size: 4.0,
                ),
              ),
            Container(
              // padding: EdgeInsets.all(8.0),
              child: FittedBox(
                fit: BoxFit.cover,
                child: IconButton(
                  color: color,
                  icon: icon,
                  onPressed: item.mealAvailableValues[columnIndex]
                      ? () {
                          _changeBookStatus(item, columnIndex);
                        }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeBookStatus(MealBookingModel item, int columnIndex) {
    if (DateTime.now().isAfter(item.limitedTimeValues[columnIndex])) {
      DialogUtils.showToast('超过限制时间，不能修改');
      return;
    }

    item.setBookStatusValue(columnIndex, !item.bookStatusValues[columnIndex]);
    setState(() {});
  }

  Widget get _buttons {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          CustomFlatButton(
            icon: Icon(Icons.lightbulb_outline, color: Colors.yellow),
            child: Text('温馨提示', style: TextStyle(color: Colors.white)),
            iconAlign: Alignment.topCenter,
            onPressed: () {
              Navigator.pushNamed(context, mealBookingTipsPath);
            },
          ),
          CustomFlatButton(
            icon: Icon(Icons.refresh, color: Colors.pinkAccent),
            child: Text('重置', style: TextStyle(color: Colors.white)),
            iconAlign: Alignment.topCenter,
            onPressed: _resetMealBooking,
          ),
          CustomFlatButton(
            icon: Icon(Icons.check),
            child: Text('提交', style: TextStyle(color: Colors.white)),
            iconAlign: Alignment.topCenter,
            onPressed: () async {
              if (await DialogUtils.showConfirmDialog(context, '要提交报餐资料吗？',
                  confirmText: '提交')) {
                _submitMealBooking();
              }
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _submitMealBooking() async {
    List<MealBookingModel> pendingList = List();
    _list.forEach((element) {
      if (element.dataChanged) {
        MealBookingModel item =
            MealBookingModel(mealBookId: element.mealBookId);
        item.bookStatusValues = element.bookStatusValues;
        pendingList.add(item);
      }
    });

    String submittedMsg = '已提交报餐';

    if (pendingList.length <= 0) {
      DialogUtils.showToast(submittedMsg);
      return true;
    }

    MealBookingWrapper result;
    _progressDialog?.style(message: submittingMessage);
    await _progressDialog?.show();
    try {
      result = await LifeService.updateMealBooking(_weekIndex, pendingList);
    } finally {
      await _progressDialog?.hide();
    }

    return _updateToList(result, successMsg: submittedMsg);
  }

  void _resetMealBooking() async {
    if (await DialogUtils.showConfirmDialog(context, '确定要恢复报餐资料？',
        confirmText: '重置', confirmTextColor: Colors.red)) {
      for (MealBookingModel item in _list) {
        for (int i = 0; i < 4; i++) {
          item.setBookStatusValue(i, item.bookStatusOldValues[i]);
        }
      }

      setState(() {});
    }
  }

  Widget get _navigatorWidget {
    String weekText = '本  周';
    if (_weekIndex == 1) {
      weekText = '下  周';
    }

    return Container(
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Opacity(
            opacity: _weekIndex == 1 ? 1 : 0,
            child: IconButton(
                icon: Icon(Icons.arrow_left,
                    color: Theme.of(context).primaryColor),
                onPressed: _navigateToThisWeek),
          ),
          Text(weekText),
          Opacity(
            opacity: _weekIndex == 0 ? 1 : 0,
            child: IconButton(
                icon: Icon(
                  Icons.arrow_right,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _navigateToNextWeek),
          ),
        ],
      ),
    );
  }

  void _navigateToThisWeek() async {
    if (_dataChanged) {
      if (await DialogUtils.showConfirmDialog(context, '报餐资料已修改，要提交吗？',
          confirmText: '提交')) {
        if (!await _submitMealBooking()) return;
      }
      _showThisWeek();
    } else {
      _showThisWeek();
    }
  }

  void _navigateToNextWeek() async {
    if (_dataChanged) {
      if (await DialogUtils.showConfirmDialog(context, '报餐资料已修改，要提交吗？',
          confirmText: '提交')) {
        if (!await _submitMealBooking()) return;
      }
      _showNextWeek();
    } else {
      _showNextWeek();
    }
  }

  void _showNextWeek() {
    _weekIndex = 1;
    _loadData();
  }

  void _showThisWeek() {
    _weekIndex = 0;
    _loadData();
  }

  bool get _dataChanged {
    for (MealBookingModel item in _list) {
      if (item.dataChanged) return true;
    }

    return false;
  }

  Widget get _headerWidget {
    return Row(
      children: <Widget>[
        Expanded(
          flex: _calendarFlex,
          child: Container(
            alignment: Alignment.center,
            child: IconButton(
              icon: Icon(
                ConstValues.icon_calendar,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: _changeAllBookStatus,
            ),
          ),
        ),
        _mealTitleButton('早', image: ConstValues.imageBread, onTap: () {
          _changeBookStatusByColumnWithMsg(0);
        }),
        _mealTitleButton('午', image: ConstValues.imageRice, onTap: () {
          _changeBookStatusByColumnWithMsg(1);
        }),
        _mealTitleButton('晚', image: ConstValues.imageDinner, onTap: () {
          _changeBookStatusByColumnWithMsg(2);
        }),
        _mealTitleButton('宵', image: ConstValues.imageSoup, onTap: () {
          _changeBookStatusByColumnWithMsg(3);
        }),
      ],
    );
  }

  void _changeAllBookStatus() {
    bool allInTime = true;
    for (int i = 0; i < 4; i++) {
      if (!_changeBookStatusByColumn(i)) allInTime = false;
    }
    setState(() {});
    if (!allInTime) {
      DialogUtils.showToast('部分超过限制时间，未能修改');
    }
  }

  void _changeBookStatusByColumnWithMsg(int columnIndex) {
    if (!_changeBookStatusByColumn(columnIndex)) {
      DialogUtils.showToast('部分超过限制时间，未能修改');
    }
  }

  Widget _mealTitleButton(String title, {Image image, Function onTap}) {
    return Expanded(
      flex: _mealFlex,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              image,
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}
