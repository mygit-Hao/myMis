class MealBookingWrapper {
  int errCode;
  String errMsg;
  List<MealBookingModel> list;

  MealBookingWrapper({this.errCode, this.errMsg, this.list});

  MealBookingWrapper.fromJson(Map<String, dynamic> json) {
    errCode = json['ErrCode'];
    errMsg = json['ErrMsg'];
    if (json['Data'] != null) {
      list = new List<MealBookingModel>();
      json['Data'].forEach((v) {
        list.add(new MealBookingModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrCode'] = this.errCode;
    data['ErrMsg'] = this.errMsg;
    if (this.list != null) {
      data['Data'] = this.list.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MealBookingModel {
  static const _mealCount = 4;
  int mealBookId;
  int mealBookDateId;
  String dStaffId;
  String dStaffName;
  DateTime bookDate;
  List<bool> bookStatusValues;
  List<bool> bookStatusOldValues;
  List<DateTime> limitedTimeValues;
  List<bool> mealAvailableValues;

  bool get isSunday {
    return bookDate.weekday == DateTime.sunday;
  }

  void setBookStatusValue(int columnIndex, bool bookStatusValue) {
    if ((mealAvailableValues[columnIndex]))
      this.bookStatusValues[columnIndex] = bookStatusValue;
  }

  bool get dataChanged {
    for (int i = 0; i < _mealCount; i++) {
      if (columnDataChanged(i)) return true;
    }
    return false;
  }

  bool columnDataChanged(int columnIndex) {
    return (bookStatusValues[columnIndex] != bookStatusOldValues[columnIndex]);
  }

  bool columnCanOperate(int columnIndex) {
    return this.mealAvailableValues[columnIndex] ||
        ((!this.mealAvailableValues[columnIndex] &&
            (!this.bookStatusValues[columnIndex]) &&
            (!this.bookStatusOldValues[columnIndex])));
  }

  MealBookingModel({
    this.mealBookId,
    this.mealBookDateId,
    this.dStaffId,
    this.dStaffName,
    this.bookDate,
  }) {
    bookStatusValues = List(_mealCount);
    limitedTimeValues = List(_mealCount);
    mealAvailableValues = List(_mealCount).map((e) => false).toList();
    bookStatusOldValues = List(_mealCount);
  }

  MealBookingModel.fromJson(Map<String, dynamic> json) {
    bookStatusValues = List(_mealCount);
    limitedTimeValues = List(_mealCount);
    mealAvailableValues = List(_mealCount);
    bookStatusOldValues = List(_mealCount);

    mealBookId = json['MealBookId'];
    mealBookDateId = json['MealBookDateId'];
    dStaffId = json['DStaffId'];
    dStaffName = json['DStaffName'];
    bookDate = DateTime.parse(json['BookDate']);

    for (int i = 0; i < _mealCount; i++) {
      bookStatusValues[i] = json['BookStatus${i + 1}'];
      limitedTimeValues[i] = DateTime.parse(json['LimitedTime${i + 1}']);
      mealAvailableValues[i] = json['MealAvailable${i + 1}'] ?? false;

      bookStatusOldValues[i] = bookStatusValues[i];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MealBookId'] = this.mealBookId;
    data['MealBookDateId'] = this.mealBookDateId;
    data['DStaffId'] = this.dStaffId;
    data['DStaffName'] = this.dStaffName;
    if (this.bookDate != null) {
      data['BookDate'] = this.bookDate.toIso8601String();
    }

    for (int i = 0; i < _mealCount; i++) {
      data['BookStatus${i + 1}'] = this.bookStatusValues[i];
      if (this.limitedTimeValues[i] != null) {
        data['LimitedTime${i + 1}'] =
            this.limitedTimeValues[i].toIso8601String();
      }
      data['MealAvailable${i + 1}'] = this.mealAvailableValues[i];
    }
    return data;
  }
}
