import 'package:mis_app/utils/utils.dart';

class ScanDataModel {
  static const String _typePattern = '/';
  String primaryType;
  String type;
  String data;
  List<String> _typeList;

  bool get valid {
    return !Utils.textIsEmptyOrWhiteSpace(this.type) &&
        (!Utils.textIsEmptyOrWhiteSpace(this.data));
  }

  List<String> get typeList {
    if (_typeList == null) {
      _typeList = this.type.split(_typePattern);
      _typeList = _typeList.map((e) => e.trim()).toList();
    }

    return _typeList;
  }

  ScanDataModel({this.primaryType, this.type = '', this.data = ''});

  ScanDataModel.fromJson(Map<String, dynamic> json) {
    primaryType = json['OrimaryType'];
    type = json['Type'];
    data = json['Data'];
  }

  ScanDataModel.fromRawContent(String rawContent) {
    if (!Utils.textIsEmptyOrWhiteSpace(rawContent)) {
      List<String> list = rawContent.split(':');
      if (list.length >= 2) {
        list = list.map((e) => e.trim()).toList();
        type = list[0];
        data = list[1];

        list = type.split(_typePattern);
        primaryType = list[0].trim();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PrimaryType'] = this.primaryType;
    data['Type'] = this.type;
    data['Data'] = this.data;
    return data;
  }
}
